import 'ai_image_cards.dart';
import 'ai_message_markdown.dart';
import 'ai_search_sources.dart';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import '../../../infrastructure/ai/ai_history_store.dart';
import '../../../l10n/app_localizations.dart';
import 'ai_chat_controller.dart';
import 'ai_avatar.dart';
import 'ai_reminders_screen.dart';
import '../../../domain/activity/listening_word_tracker.dart';
import '../chat_bubble_parts.dart';
import '../voice_message_composer.dart';
import '../../../core/auth_session_notifier.dart';
import '../../../core/ai_callback_notifier.dart';
import 'ai_chat_navigation.dart';

final aiReminderNavigatorKey = GlobalKey<NavigatorState>();
final _aiNavigation = AiChatNavigation();
void openAiChat([BuildContext? context]) {
  final navigator = context == null
      ? aiReminderNavigatorKey.currentState
      : Navigator.of(context, rootNavigator: true);
  if (navigator == null) return;
  if (!AuthSessionNotifier.instance.isAuthenticated) return;
  unawaited(
    _aiNavigation.open(navigator, (_) {
      final callback = AiCallbackNotifier.instance;
      return ListenableBuilder(
        listenable: callback,
        builder: (_, _) {
          final controller = callback.accepted ? callback.controller : null;
          return AiChatScreen(
            key: ObjectKey(controller),
            controller: controller,
          );
        },
      );
    }),
  );
}

void openAiReminderChat() => openAiChat();

class AiChatScreen extends StatefulWidget {
  const AiChatScreen({
    super.key,
    this.startWithCall = false,
    this.onClose,
    this.controller,
  }) : _controllerFactory = null;
  @visibleForTesting
  const AiChatScreen.ownedControllerForTesting({
    super.key,
    required AiChatController Function() createController,
  }) : _controllerFactory = createController,
       controller = null,
       startWithCall = false,
       onClose = null;
  final AiChatController Function()? _controllerFactory;
  final AiChatController? controller;
  final bool startWithCall;
  final VoidCallback? onClose;
  @override
  State<AiChatScreen> createState() => _AiChatScreenState();
}

class _AiChatScreenState extends State<AiChatScreen>
    with WidgetsBindingObserver {
  late final AiChatController _chat =
      widget.controller ??
      widget._controllerFactory?.call() ??
      AiChatController();
  final _scroll = ScrollController();
  final _player = AudioPlayer();
  String? _playing;
  ListeningWordTracker? _listening;
  String _listeningLanguage = '';
  StreamSubscription? _completion, _positionEvents, _durationEvents;
  Duration _position = Duration.zero;
  final Map<String, Duration> _durations = {};
  bool _startingRecord = false;
  int _count = 0;
  bool _historyLoaded = false;
  bool _confirmingCall = false;
  bool _initializationStarted = false;
  Animation<double>? _openingAnimation;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _count = _chat.messages.length;
    _historyLoaded = _chat.loaded;
    _chat.addListener(_changed);
    _completion = _player.onPlayerComplete.listen((_) {
      final message = _chat.messages.where((m) => m.id == _playing).firstOrNull;
      final duration =
          _durations[_playing] ??
          (message?.durationMs == null
              ? null
              : Duration(milliseconds: message!.durationMs!));
      if (duration != null) {
        final words =
            _listening?.advance(duration.inMilliseconds, playing: true) ?? 0;
        unawaited(_chat.recordListened(words, _listeningLanguage));
      }
      _listening = null;
      if (mounted) {
        setState(() {
          _playing = null;
          _position = Duration.zero;
        });
      }
    });
    _positionEvents = _player.onPositionChanged.listen((position) {
      final words =
          _listening?.advance(
            position.inMilliseconds,
            playing: _player.state == PlayerState.playing,
          ) ??
          0;
      unawaited(_chat.recordListened(words, _listeningLanguage));
      if (mounted) setState(() => _position = position);
    });
    _durationEvents = _player.onDurationChanged.listen((duration) {
      if (mounted && _playing != null) {
        setState(() => _durations[_playing!] = duration);
      }
    });
    if (widget.controller == null) {
      // Present the page before reading/decoding history and starting sync.
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => _initializeWhenVisible(),
      );
    }
  }

  void _initializeWhenVisible() {
    if (!mounted || _initializationStarted) return;
    final route = ModalRoute.of(context);
    final animation = route?.animation;
    if (route?.offstage == true ||
        (animation != null && !animation.isCompleted)) {
      if (!identical(_openingAnimation, animation)) {
        _openingAnimation?.removeStatusListener(_openingChanged);
        _openingAnimation = animation;
        animation?.addStatusListener(_openingChanged);
      }
      return;
    }
    _openingAnimation?.removeStatusListener(_openingChanged);
    _openingAnimation = null;
    _initializationStarted = true;
    unawaited(
      _chat.initialize().then((_) async {
        if (mounted && widget.startWithCall) await _call();
      }),
    );
  }

  void _openingChanged(AnimationStatus status) {
    if (status == AnimationStatus.completed) _initializeWhenVisible();
  }

  void _changed() {
    if (!mounted) return;
    final reply = _chat.takePlaybackRequest();
    if (reply != null &&
        WidgetsBinding.instance.lifecycleState != AppLifecycleState.detached &&
        (defaultTargetPlatform == TargetPlatform.iOS ||
            (WidgetsBinding.instance.lifecycleState !=
                    AppLifecycleState.paused &&
                WidgetsBinding.instance.lifecycleState !=
                    AppLifecycleState.inactive))) {
      unawaited(_play(reply));
    }
    final count = _chat.messages.length;
    final arrivingMessage = _historyLoaded && count > _count;
    _historyLoaded = _chat.loaded;
    _count = count;
    if (arrivingMessage) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _scroll.hasClients) {
          _scroll.animateTo(
            0,
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOut,
          );
        }
      });
    }
    setState(() {});
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) unawaited(_chat.syncReminders());
    // iOS background audio keeps user-started calls and sent voice replies
    // playing while locked. Never cancel an already committed voice stream. Stopping either player here can deactivate the
    // shared audio session. The call's deadline and interruption handling remain active.
    if (state == AppLifecycleState.paused &&
        (_chat.calling || _chat.busy || _player.state == PlayerState.playing) &&
        defaultTargetPlatform == TargetPlatform.iOS) {
      return;
    }
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      unawaited(_chat.endCall());
      unawaited(_chat.cancelRecording());
      unawaited(_player.stop());
    }
  }

  @override
  void dispose() {
    _openingAnimation?.removeStatusListener(_openingChanged);
    WidgetsBinding.instance.removeObserver(this);
    _chat.removeListener(_changed);
    if (widget.controller == null) _chat.dispose();
    _completion?.cancel();
    _positionEvents?.cancel();
    _durationEvents?.cancel();
    _player.dispose();
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _clear() async {
    final l = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l.aiClearHistory),
        content: Text(l.aiClearHistoryBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: Text(l.aiClearHistory),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      await _player.stop();
      _playing = null;
      try {
        await _chat.clear();
      } catch (_) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(l.onboardingLoadFailed)));
        }
      }
    }
  }

  Future<void> _play(AiMessage m) async {
    if (_chat.calling || _chat.recording || m.audio == null) return;
    try {
      if (_playing == m.id) {
        if (_player.state == PlayerState.playing) {
          await _player.pause();
        } else {
          _listening?.seek(_position.inMilliseconds);
          await _player.resume();
        }
        if (mounted) setState(() {});
        return;
      }
      await _player.setAudioContext(
        AudioContext(
          iOS: AudioContextIOS(category: AVAudioSessionCategory.playback),
        ),
      );
      if (!mounted || _chat.calling || _chat.recording) return;
      await _player.stop();
      if (!mounted || _chat.calling || _chat.recording) return;
      setState(() {
        _playing = m.id;
        _position = Duration.zero;
      });
      _listeningLanguage = m.language;
      final durationMs = m.durationMs ?? _durations[m.id]?.inMilliseconds ?? 0;
      _listening = m.role == 'model'
          ? ListeningWordTracker(
              ListeningWordTracker.estimatedUnits(m.text, 0, durationMs),
            )
          : null;
      _listening?.seek(0);
      await _player.play(DeviceFileSource(_chat.store.path(m.audio!)));
    } catch (_) {
      if (mounted) {
        setState(() => _playing = null);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.onboardingLoadFailed),
          ),
        );
      }
    }
  }

  Future<void> _call() async {
    if (_confirmingCall ||
        !_chat.loaded ||
        _chat.busy ||
        _chat.recording ||
        _chat.calling) {
      return;
    }
    _confirmingCall = true;
    try {
      final l = AppLocalizations.of(context)!;
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(l.aiCallConfirmTitle),
          content: Text(l.aiCallConfirmBody),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(l.cancel),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(l.aiCallConfirmStart),
            ),
          ],
        ),
      );
      if (confirmed != true ||
          !mounted ||
          !_chat.loaded ||
          _chat.busy ||
          _chat.recording ||
          _chat.calling) {
        return;
      }
      await _player.stop();
      if (!mounted || _chat.busy || _chat.recording || _chat.calling) return;
      _playing = null;
      await _chat.startCall();
    } finally {
      _confirmingCall = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final colors = Theme.of(context).colorScheme;
    final clock =
        '${_chat.remaining ~/ 60}:${(_chat.remaining % 60).toString().padLeft(2, '0')}';
    return Scaffold(
      appBar: AppBar(
        leading: widget.onClose == null
            ? null
            : IconButton(
                onPressed: widget.onClose,
                icon: const Icon(Icons.arrow_back),
              ),
        title: Row(
          children: [
            const AiAvatar(radius: 18),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Bantera AI',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Row(
                    children: [
                      const Icon(Icons.circle, color: Colors.green, size: 7),
                      const SizedBox(width: 5),
                      Text(
                        l.chatOnlineSection,
                        style: Theme.of(context).textTheme.labelSmall,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: l.chatStartAudioCall,
            onPressed:
                _chat.loaded &&
                    !_chat.busy &&
                    !_chat.recording &&
                    !_chat.calling
                ? _call
                : null,
            icon: const Icon(Icons.call_outlined),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_horiz),
            onSelected: (value) {
              if (value == 'reminders') {
                Navigator.push(
                  context,
                  MaterialPageRoute<void>(
                    builder: (_) => const AiRemindersScreen(),
                  ),
                );
              } else if (value == 'clear') {
                _clear();
              } else if (value == 'usage') {
                showDialog<void>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text(l.aiUsageTitle),
                    scrollable: true,
                    content: SingleChildScrollView(
                      child: Text(
                        '${l.aiUsageBody}\n\n${l.aiWebSearchHelp}\n\n${l.aiImagesHelp}',
                      ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text(l.closeLabel),
                      ),
                    ],
                  ),
                );
              } else if (value == 'privacy') {
                showDialog<void>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text(l.aiPrivacyNotice),
                    content: Text(l.aiLocalHistory),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text(l.closeLabel),
                      ),
                    ],
                  ),
                );
              }
            },
            itemBuilder: (_) => [
              PopupMenuItem(
                value: 'reminders',
                child: Row(
                  children: [
                    const Icon(Icons.notifications_active_outlined),
                    const SizedBox(width: 12),
                    Text(l.aiRemindersTitle),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'usage',
                child: Row(
                  children: [
                    const Icon(Icons.help_outline),
                    const SizedBox(width: 12),
                    Text(l.aiUsageTitle),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'privacy',
                child: Row(
                  children: [
                    const Icon(Icons.privacy_tip_outlined),
                    const SizedBox(width: 12),
                    Text(l.aiPrivacyNotice),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'clear',
                enabled: _chat.loaded,
                child: Row(
                  children: [
                    const Icon(Icons.delete_outline),
                    const SizedBox(width: 12),
                    Text(l.aiClearHistory),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            if (_chat.privacyNoticeVisible)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        l.aiLocalHistory,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                    ),
                    IconButton(
                      tooltip: l.closeLabel,
                      onPressed: _chat.dismissPrivacyNotice,
                      icon: const Icon(Icons.close, size: 20),
                    ),
                  ],
                ),
              ),
            if (_chat.calling)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 12),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: colors.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Icon(
                      _chat.farewell
                          ? Icons.waving_hand_outlined
                          : Icons.graphic_eq,
                      color: colors.onSurface,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        !_chat.connected
                            ? l.chatCallConnecting
                            : _chat.farewell
                            ? '${l.aiSayingGoodbye} · $clock'
                            : '${l.chatStartAudioCall} · $clock',
                        style: TextStyle(color: colors.onSurface),
                      ),
                    ),
                    IconButton(
                      tooltip: _chat.muted ? l.chatCallUnmute : l.chatCallMute,
                      onPressed: _chat.farewell ? null : _chat.toggleMute,
                      icon: Icon(_chat.muted ? Icons.mic_off : Icons.mic),
                    ),
                    IconButton(
                      tooltip: l.chatCallSpeaker,
                      onPressed: _chat.setSpeaker,
                      icon: Icon(
                        _chat.speaker ? Icons.volume_up : Icons.hearing,
                      ),
                    ),
                    IconButton.filled(
                      style: IconButton.styleFrom(
                        backgroundColor: colors.error,
                        foregroundColor: colors.onError,
                      ),
                      tooltip: l.chatCallEnd,
                      onPressed: _chat.endCall,
                      icon: const Icon(Icons.call_end),
                    ),
                  ],
                ),
              ),
            Expanded(
              child: !_chat.loaded
                  ? Center(
                      child: _chat.failed
                          ? TextButton(
                              onPressed: _chat.initialize,
                              child: Text(l.onboardingRetry),
                            )
                          : const CircularProgressIndicator(),
                    )
                  : _conversation(l),
            ),
            if (_chat.failed)
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Text(
                  l.onboardingLoadFailed,
                  style: TextStyle(color: colors.error),
                ),
              ),
            if (!_chat.calling) _composer(context, l),
          ],
        ),
      ),
    );
  }

  Widget _conversation(AppLocalizations l) {
    final messages = _chat.messages;
    final sending = _chat.sendingVoice;
    final draft = _chat.draftUser.isNotEmpty;
    final extra = (sending ? 1 : 0) + (draft ? 1 : 0);
    return ListView.builder(
      // Offset zero is the newest message; only visible history builds bubbles.
      reverse: true,
      controller: _scroll,
      padding: const EdgeInsets.all(16),
      itemCount: extra + (messages.isEmpty ? 1 : messages.length),
      findChildIndexCallback: (key) {
        if (key == const ValueKey('ai-sending')) return sending ? 0 : null;
        if (key == const ValueKey('ai-draft')) {
          return draft ? (sending ? 1 : 0) : null;
        }
        if (key == const ValueKey('ai-welcome')) {
          return messages.isEmpty ? extra : null;
        }
        final index = messages.indexWhere((m) => ValueKey(m.id) == key);
        return index < 0 ? null : extra + messages.length - 1 - index;
      },
      itemBuilder: (context, index) {
        if (sending && index == 0) {
          return Padding(
            key: const ValueKey('ai-sending'),
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                const SizedBox(width: 12),
                Text(l.chatSendingAudio),
              ],
            ),
          );
        }
        if (draft && index == (sending ? 1 : 0)) {
          return KeyedSubtree(
            key: const ValueKey('ai-draft'),
            child: _draft(_chat.draftUser, true),
          );
        }
        if (messages.isEmpty) {
          return Padding(
            key: const ValueKey('ai-welcome'),
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Column(
              children: [
                const AiAvatar(radius: 28),
                const SizedBox(height: 16),
                Text(
                  l.aiWelcome,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
          );
        }
        return _bubble(messages[messages.length - 1 - (index - extra)]);
      },
    );
  }

  Future<void> _startRecording() async {
    if (_startingRecord || !_chat.canRecord) {
      return;
    }
    _startingRecord = true;
    try {
      await _player.stop();
      if (!mounted) return;
      _playing = null;
      await _chat.record();
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context)!.chatCallMicrophoneDenied,
            ),
          ),
        );
      }
    } finally {
      _startingRecord = false;
    }
  }

  Widget _composer(BuildContext context, AppLocalizations l) =>
      VoiceMessageComposer(
        enabled: _chat.recording || _chat.canRecord,
        recording: _chat.recording,
        remainingSeconds: _chat.recordingRemaining,
        busyLabel: _chat.busy && !_chat.recording
            ? (_chat.sendingVoice ? l.chatSendingAudio : l.aiReplying)
            : null,
        onStart: _startRecording,
        onSend: () async {
          unawaited(_chat.sendRecording());
        },
        onCancel: _chat.cancelRecording,
      );

  String _durationLabel(Duration duration) =>
      '${duration.inMinutes}:${(duration.inSeconds % 60).toString().padLeft(2, '0')}';

  Widget _draft(String text, bool user) => Align(
    alignment: user ? Alignment.centerRight : Alignment.centerLeft,
    child: Padding(
      padding: const EdgeInsets.all(12),
      child: Text(text, style: const TextStyle(fontStyle: FontStyle.italic)),
    ),
  );
  Widget _bubble(AiMessage m) {
    final l = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final user = m.role == 'user';
    final receiving = _chat.isReceiving(m);
    final selected = _playing == m.id;
    final duration =
        _durations[m.id] ??
        (m.durationMs == null ? null : Duration(milliseconds: m.durationMs!));
    final progress = selected && duration != null && duration.inMilliseconds > 0
        ? (_position.inMilliseconds / duration.inMilliseconds).clamp(0.0, 1.0)
        : 0.0;
    final translationAction =
        defaultTargetPlatform == TargetPlatform.iOS &&
            m.text.isNotEmpty &&
            !receiving
        ? IconButton(
            tooltip:
                _chat.visibleTranslations.contains(m.id) ||
                    _chat.translationFailed.contains(m.id)
                ? l.chatRetranslate
                : l.chatTranslate,
            onPressed: _chat.translating.contains(m.id)
                ? null
                : () => _chat.translate(
                    m,
                    force:
                        _chat.visibleTranslations.contains(m.id) ||
                        _chat.translationFailed.contains(m.id),
                  ),
            icon: _chat.translating.contains(m.id)
                ? const SizedBox.square(
                    dimension: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.translate, size: 20),
          )
        : null;
    return Align(
      key: ValueKey(m.id),
      alignment: user ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 340),
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: user
              ? colors.primary.withValues(alpha: .12)
              : colors.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: colors.outlineVariant),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (m.audio != null || receiving || (m.durationMs ?? 0) > 0)
              ChatAudioHeader(
                audioKey: m.audio == null ? null : _chat.store.path(m.audio!),
                loadAudioPath: m.audio == null
                    ? null
                    : () async => _chat.store.path(m.audio!),
                receiving: receiving,
                playing: selected && _player.state == PlayerState.playing,
                progress: progress,
                duration: duration == null ? null : _durationLabel(duration),
                playTooltip: l.aiPlayAudio,
                onPlay: _chat.calling || _chat.busy || _chat.recording
                    ? null
                    : () => _play(m),
                trailing: translationAction,
              )
            else if (translationAction != null)
              Align(alignment: Alignment.centerRight, child: translationAction),
            if (receiving)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(l.aiReplying, style: theme.textTheme.labelMedium),
              ),
            if (m.text.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: user
                    ? SelectableText(
                        m.text,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: colors.onSurface,
                        ),
                      )
                    : AiMessageMarkdown(text: m.text),
              ),
            if (_chat.visibleTranslations.contains(m.id) &&
                m.translation.isNotEmpty) ...[
              const Divider(height: 20),
              if (user)
                SelectableText(
                  m.translation,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: colors.onSurface,
                  ),
                )
              else
                AiMessageMarkdown(text: m.translation),
            ],
            if (_chat.translating.contains(m.id))
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  l.chatTranslating,
                  style: Theme.of(context).textTheme.labelSmall,
                ),
              ),
            if (m.failed && !user)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  l.aiReplyInterrupted,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: colors.error,
                  ),
                ),
              ),
            if (m.failed && user && m.audio != null)
              TextButton.icon(
                onPressed: _chat.busy || _chat.calling
                    ? null
                    : () => _chat.retry(m),
                icon: const Icon(Icons.refresh),
                label: Text(l.onboardingRetry),
              ),
            if (m.webSearchStatus != null || m.sources.isNotEmpty)
              AiSearchSources(message: m),
            if (m.imageSearchStatus != null || m.images.isNotEmpty)
              AiImageCards(message: m, path: _chat.store.path),
            ChatMessageTimestamp(sentAt: m.createdAt),
          ],
        ),
      ),
    );
  }
}
