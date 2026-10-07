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

final aiReminderNavigatorKey = GlobalKey<NavigatorState>();
Route<dynamic>? _activeAiRoute;
void openAiReminderChat() {
  final navigator = aiReminderNavigatorKey.currentState;
  if (navigator == null) return;
  if (_activeAiRoute != null) {
    navigator.popUntil(
      (route) => identical(route, _activeAiRoute) || route.isFirst,
    );
    return;
  }
  navigator.push(MaterialPageRoute<void>(builder: (_) => const AiChatScreen()));
}

class AiChatScreen extends StatefulWidget {
  const AiChatScreen({
    super.key,
    this.startWithCall = false,
    this.onClose,
    this.controller,
  });
  final AiChatController? controller;
  final bool startWithCall;
  final VoidCallback? onClose;
  @override
  State<AiChatScreen> createState() => _AiChatScreenState();
}

class _AiChatScreenState extends State<AiChatScreen>
    with WidgetsBindingObserver {
  late final AiChatController _chat = widget.controller ?? AiChatController();
  final _scroll = ScrollController();
  final _player = AudioPlayer();
  String? _playing;
  ListeningWordTracker? _listening;
  String _listeningLanguage = '';
  StreamSubscription? _completion, _positionEvents, _durationEvents;
  Duration _position = Duration.zero;
  final Map<String, Duration> _durations = {};
  bool _holdingRecord = false, _startingRecord = false;
  int _count = 0;
  bool _historyLoaded = false;
  bool _confirmingCall = false;
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
      unawaited(
        _chat.initialize().then((_) async {
          if (mounted && widget.startWithCall) await _call();
        }),
      );
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (widget.controller == null) _activeAiRoute = ModalRoute.of(context);
  }

  void _changed() {
    if (!mounted) return;
    final reply = _chat.takePlaybackRequest();
    if (reply != null &&
        WidgetsBinding.instance.lifecycleState != AppLifecycleState.paused &&
        WidgetsBinding.instance.lifecycleState != AppLifecycleState.inactive &&
        WidgetsBinding.instance.lifecycleState != AppLifecycleState.detached) {
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
    // iOS playAndRecord + UIBackgroundModes audio keeps a user-started call
    // duplex while locked. Stopping either player here can deactivate the
    // shared audio session. The call's deadline and interruption handling remain active.
    if (state == AppLifecycleState.paused &&
        _chat.calling &&
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
    if (widget.controller == null) _activeAiRoute = null;
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
                    content: Text(l.aiUsageBody),
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
                  : ListView(
                      // Zero offset is the latest message from the first layout.
                      // Reversing the children preserves chronological reading order.
                      reverse: true,
                      controller: _scroll,
                      padding: const EdgeInsets.all(16),
                      children: [
                        if (_chat.messages.isEmpty)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 24),
                            child: Column(
                              children: [
                                const AiAvatar(radius: 28),
                                const SizedBox(height: 16),
                                Text(
                                  l.aiWelcome,
                                  textAlign: TextAlign.center,
                                  style: Theme.of(
                                    context,
                                  ).textTheme.titleMedium,
                                ),
                              ],
                            ),
                          ),
                        for (final m in _chat.messages) _bubble(m),
                        if (_chat.draftUser.isNotEmpty)
                          _draft(_chat.draftUser, true),
                        if (_chat.sendingVoice)
                          Padding(
                            padding: const EdgeInsets.all(12),
                            child: Row(
                              children: [
                                const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Text(l.chatSendingAudio),
                              ],
                            ),
                          ),
                      ].reversed.toList(),
                    ),
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

  Future<void> _startRecording() async {
    if (_startingRecord || !_chat.loaded || _chat.busy || _chat.recording) {
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

  Future<void> _beginHold() async {
    _holdingRecord = true;
    await _startRecording();
    // Releasing while a permission prompt/startup is pending cancels that take.
    if (!_holdingRecord && _chat.recording) await _chat.cancelRecording();
  }

  void _finishHold({bool cancel = false}) {
    if (!_holdingRecord) return;
    _holdingRecord = false;
    if (_startingRecord || !_chat.recording) return;
    if (cancel) {
      unawaited(_chat.cancelRecording());
    } else {
      unawaited(_chat.sendRecording());
    }
  }

  Widget _composer(BuildContext context, AppLocalizations l) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final enabled = _chat.loaded && !_chat.busy;
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border(top: BorderSide(color: colors.outlineVariant)),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onLongPressStart: enabled ? (_) => _beginHold() : null,
              onLongPressEnd: enabled ? (_) => _finishHold() : null,
              onLongPressCancel: () => _finishHold(cancel: true),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                constraints: const BoxConstraints(minHeight: 48),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: _chat.recording
                      ? colors.error.withValues(alpha: .1)
                      : colors.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: _chat.recording
                        ? colors.error
                        : colors.outlineVariant,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Text(
                        _chat.busy
                            ? (_chat.sendingVoice
                                  ? l.chatSendingAudio
                                  : l.aiReplying)
                            : _chat.recording
                            ? l.chatRecordingStatus
                            : l.chatHoldToRecordAudio,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: _chat.recording
                              ? colors.error
                              : colors.onSurface,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    if (_chat.recording) ...[
                      const SizedBox(width: 8),
                      Text(
                        _durationLabel(
                          Duration(seconds: _chat.recordingRemaining),
                        ),
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: colors.error,
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
          if (_chat.recording && !_holdingRecord)
            IconButton(
              tooltip: l.cancel,
              onPressed: _chat.cancelRecording,
              icon: const Icon(Icons.close),
            ),
          const SizedBox(width: 12),
          IconButton.filled(
            tooltip: _chat.recording ? l.aiSend : l.aiRecordVoiceMessage,
            onPressed: !enabled
                ? null
                : _chat.recording
                ? _chat.sendRecording
                : _startRecording,
            style: IconButton.styleFrom(minimumSize: const Size(48, 48)),
            icon: Icon(_chat.recording ? Icons.send_rounded : Icons.mic),
          ),
        ],
      ),
    );
  }

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
                child: SelectableText(
                  m.text,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: colors.onSurface,
                  ),
                ),
              ),
            if (_chat.visibleTranslations.contains(m.id) &&
                m.translation.isNotEmpty) ...[
              const Divider(height: 20),
              SelectableText(
                m.translation,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: colors.onSurface,
                ),
              ),
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
            ChatMessageTimestamp(sentAt: m.createdAt),
          ],
        ),
      ),
    );
  }
}
