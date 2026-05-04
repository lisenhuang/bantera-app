import 'dart:async';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';

import '../../core/chat_session_notifier.dart';
import '../../domain/models/chat_models.dart';
import '../../infrastructure/auth_api_client.dart';
import '../../infrastructure/video_processing_service.dart';
import '../../l10n/app_localizations.dart';
import '../shared/locale_flag.dart';
import '../shared/profile_avatar.dart';
import 'blocked_users_screen.dart';
import 'chat_menu_item_row.dart';

class ChatConversationScreen extends StatefulWidget {
  const ChatConversationScreen.thread({super.key, required this.thread})
    : partner = null;

  const ChatConversationScreen.directUser({super.key, required this.partner})
    : thread = null;

  final ChatThreadSummary? thread;
  final ChatUserSummary? partner;

  @override
  State<ChatConversationScreen> createState() => _ChatConversationScreenState();
}

class _ChatConversationScreenState extends State<ChatConversationScreen> {
  final ChatSessionNotifier _chat = ChatSessionNotifier.instance;
  final AudioRecorder _recorder = AudioRecorder();
  final AudioPlayer _player = AudioPlayer();
  final Set<String> _transcribingIds = <String>{};
  bool _isRecording = false;
  bool _isSending = false;
  String? _currentPlayingMessageId;
  Duration _currentPlaybackPosition = Duration.zero;
  StreamSubscription<void>? _playerCompleteSubscription;
  StreamSubscription<Duration>? _playerPositionSubscription;
  String? _threadId;
  String? _groupKind;
  ChatUserSummary? _partner;
  DateTime? _recordingStartedAt;
  Timer? _maxRecordingTimer;

  @override
  void initState() {
    super.initState();
    _threadId = widget.thread?.threadId;
    _groupKind = _inferGroupKind(widget.thread);
    _partner = widget.partner ?? widget.thread?.otherUser;
    if (_threadId != null) {
      _chat.registerActiveThread(_threadId!);
      unawaited(_chat.loadMessages(_threadId!));
    }

    _playerCompleteSubscription = _player.onPlayerComplete.listen((_) {
      if (mounted) {
        setState(() {
          _currentPlayingMessageId = null;
          _currentPlaybackPosition = Duration.zero;
        });
      }
    });
    _playerPositionSubscription = _player.onPositionChanged.listen((position) {
      if (_currentPlayingMessageId != null && mounted) {
        setState(() {
          _currentPlaybackPosition = position;
        });
      }
    });
  }

  @override
  void dispose() {
    _maxRecordingTimer?.cancel();
    _playerCompleteSubscription?.cancel();
    _playerPositionSubscription?.cancel();
    if (_threadId != null) {
      _chat.unregisterActiveThread(_threadId!);
    }
    _recorder.dispose();
    _player.dispose();
    super.dispose();
  }

  bool get _isGroup => widget.thread?.isGroup == true;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final title = _isGroup
        ? (widget.thread?.title ?? l10n.chatsTitle)
        : (_partner?.name ?? widget.thread?.title ?? l10n.chatsTitle);

    return ListenableBuilder(
      listenable: _chat,
      builder: (context, _) {
        return Scaffold(
          appBar: AppBar(
            titleSpacing: 0,
            title: GestureDetector(
              onTap: (!_isGroup && _partner != null)
                  ? () => _showUserSheet(_partner!)
                  : null,
              child: Row(
                children: [
                  ProfileAvatar(
                    radius: 18,
                    imageUrl: _isGroup ? null : _partner?.avatarUrl,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          title,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 16),
                        ),
                        Text(
                          _subtitleText(l10n),
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              if (_isGroup)
                IconButton(
                  icon: const Icon(CupertinoIcons.gear),
                  onPressed: widget.thread == null
                      ? null
                      : () => Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) =>
                                _GroupSettingsScreen(thread: widget.thread!),
                          ),
                        ),
                )
              else
                PopupMenuButton<_DirectMenuAction>(
                  onSelected: _handleDirectMenuAction,
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: _DirectMenuAction.toggleMute,
                      child: ChatMenuItemRow(
                        icon: (widget.thread?.isMuted ?? false)
                            ? Icons.notifications_active_outlined
                            : Icons.notifications_off_outlined,
                        label: (widget.thread?.isMuted ?? false)
                            ? l10n.chatEnableNotifications
                            : l10n.chatMuteNotifications,
                      ),
                    ),
                    PopupMenuItem(
                      value: _DirectMenuAction.block,
                      child: ChatMenuItemRow(
                        icon: Icons.block,
                        label: l10n.chatBlockUser,
                      ),
                    ),
                    if (_threadId != null)
                      PopupMenuItem(
                        value: _DirectMenuAction.deleteDm,
                        child: ChatMenuItemRow(
                          icon: Icons.delete_outline,
                          label: l10n.chatDeleteDm,
                        ),
                      ),
                  ],
                ),
            ],
          ),
          body: Column(
            children: [
              Expanded(child: _buildMessages(context, l10n)),
              _buildComposer(context, l10n),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMessages(BuildContext context, AppLocalizations l10n) {
    if (_threadId == null) {
      return Center(
        child: Text(
          _isGroup ? l10n.chatGroupReady : l10n.chatHoldToStartDm,
          style: Theme.of(context).textTheme.bodyLarge,
          textAlign: TextAlign.center,
        ),
      );
    }

    return StreamBuilder<List<ChatMessageItem>>(
      stream: _chat.watchMessages(_threadId!),
      builder: (context, snapshot) {
        final messages = snapshot.data ?? const <ChatMessageItem>[];
        if (messages.isEmpty && _chat.isRefreshingMessages) {
          return const Center(child: CircularProgressIndicator());
        }

        if (messages.isEmpty) {
          return Center(
            child: Text(_isGroup ? l10n.chatNoGroupAudio : l10n.chatNoDmAudio),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          itemCount: messages.length,
          itemBuilder: (context, index) {
            final message = messages[index];
            return _MessageBubble(
              message: message,
              isGroup: _isGroup,
              isPlaying: _currentPlayingMessageId == message.messageId,
              playbackPosition: _currentPlayingMessageId == message.messageId
                  ? _currentPlaybackPosition
                  : Duration.zero,
              isTranscribing: _transcribingIds.contains(message.messageId),
              onPlay: () => _playMessage(message),
              onTranscribe: () => _transcribeMessage(message),
              onTapSender: _isGroup && !message.isMine
                  ? () => _showUserSheet(message.senderUser)
                  : null,
              onLongPress: message.isMine
                  ? () => _showOwnMessageMenu(message)
                  : null,
            );
          },
        );
      },
    );
  }

  Widget _buildComposer(BuildContext context, AppLocalizations l10n) {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          border: Border(
            top: BorderSide(
              color: Theme.of(context).colorScheme.outlineVariant,
            ),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: GestureDetector(
                onLongPressStart: _isSending ? null : (_) => _startRecording(),
                onLongPressEnd: _isSending ? null : (_) => _stopRecording(),
                onLongPressCancel: _isSending ? null : _cancelRecording,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  height: 48,
                  decoration: BoxDecoration(
                    color: _isRecording
                        ? Colors.red.withValues(alpha: 0.1)
                        : Theme.of(context).colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: _isRecording
                          ? Colors.redAccent
                          : Theme.of(context).colorScheme.outlineVariant,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    _isSending
                        ? l10n.chatSendingAudio
                        : _isRecording
                        ? l10n.chatRecordingReleaseToSend
                        : l10n.chatHoldToRecordAudio,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: _isRecording
                          ? Colors.redAccent
                          : Theme.of(context).colorScheme.onSurfaceVariant,
                      fontWeight: _isRecording
                          ? FontWeight.w600
                          : FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            CircleAvatar(
              radius: 24,
              backgroundColor: _isRecording
                  ? Colors.redAccent
                  : Theme.of(context).colorScheme.primary,
              child: const Icon(CupertinoIcons.mic_fill, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  String _subtitleText(AppLocalizations l10n) {
    if (_threadId != null && _chat.isPartnerRecording(_threadId!)) {
      return l10n.chatRecordingStatus;
    }

    if (_isGroup) {
      final badges = widget.thread?.roleBadges ?? const <String>[];
      if (badges.isEmpty) {
        return widget.thread?.learningLanguageDisplay ?? l10n.chatGroupLabel;
      }
      return badges.join(' • ');
    }

    final learning = _partner?.learningLanguageDisplay;
    final native = _partner?.nativeLanguageDisplay;
    return [
      learning,
      native,
    ].whereType<String>().where((v) => v.isNotEmpty).join(' • ');
  }

  String? _inferGroupKind(ChatThreadSummary? thread) {
    if (thread == null || !thread.isGroup) {
      return null;
    }
    final badges = thread.roleBadges
        .map((badge) => badge.toLowerCase())
        .toSet();
    if (badges.contains('learning')) {
      return 'learning';
    }
    if (badges.contains('native')) {
      return 'native';
    }
    return 'learning';
  }

  Future<void> _handleDirectMenuAction(_DirectMenuAction action) async {
    final l10n = AppLocalizations.of(context)!;
    final threadId = _threadId;
    final partner = _partner;
    if (partner == null) {
      return;
    }

    switch (action) {
      case _DirectMenuAction.toggleMute:
        if (threadId == null) {
          return;
        }
        final nextEnabled = !(widget.thread?.isMuted ?? false);
        await _chat.updateThreadNotifications(
          threadId: threadId,
          enabled: nextEnabled,
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                nextEnabled
                    ? l10n.chatNotificationsEnabledForDm
                    : l10n.chatNotificationsMutedForDm,
              ),
            ),
          );
        }
        break;
      case _DirectMenuAction.block:
        final confirmed = await _confirmAction(
          title: l10n.chatBlockUserTitle(partner.name),
          body: l10n.chatBlockUserBody,
        );
        if (confirmed != true) {
          return;
        }
        await _chat.blockUser(partner.id);
        if (mounted) {
          Navigator.of(context).pop();
        }
        break;
      case _DirectMenuAction.deleteDm:
        if (threadId == null) {
          return;
        }
        final confirmed = await _confirmAction(
          title: l10n.chatDeleteDmTitle,
          body: l10n.chatDeleteDmBody,
        );
        if (confirmed != true) {
          return;
        }
        await _chat.deleteDirectMessageForSelf(threadId);
        if (mounted) {
          Navigator.of(context).pop();
        }
        break;
    }
  }

  Future<bool> _ensureMicrophonePermission() async {
    var status = await Permission.microphone.status;
    if (status.isGranted) {
      return true;
    }

    status = await Permission.microphone.request();
    if (status.isGranted) {
      return true;
    }

    if (!mounted) {
      return false;
    }

    final l10n = AppLocalizations.of(context)!;
    final permanentlyDenied = status.isPermanentlyDenied || status.isRestricted;
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.chatMicrophoneRequiredTitle),
        content: Text(
          permanentlyDenied
              ? l10n.chatMicrophoneRequiredSettings
              : l10n.chatMicrophoneRequiredBody,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.closeLabel),
          ),
          if (permanentlyDenied)
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                openAppSettings();
              },
              child: Text(l10n.permissionsOpenSettings),
            ),
        ],
      ),
    );
    return false;
  }

  Future<void> _startRecording() async {
    if (_isRecording || _isSending) {
      return;
    }
    if (!await _ensureMicrophonePermission()) {
      return;
    }

    final dir = await getTemporaryDirectory();
    final path =
        '${dir.path}/bantera-chat-${DateTime.now().millisecondsSinceEpoch}.m4a';
    await _recorder.start(
      const RecordConfig(
        encoder: AudioEncoder.aacLc,
        bitRate: 96000,
        sampleRate: 44100,
      ),
      path: path,
    );

    _recordingStartedAt = DateTime.now();
    _maxRecordingTimer?.cancel();
    _maxRecordingTimer = Timer(const Duration(seconds: 60), _stopRecording);
    if (_threadId != null && !_isGroup) {
      unawaited(
        _chat.sendRecordingEvent(threadId: _threadId!, isRecording: true),
      );
    }

    if (mounted) {
      setState(() {
        _isRecording = true;
      });
    }
  }

  Future<void> _cancelRecording() async {
    if (!_isRecording) {
      return;
    }

    _maxRecordingTimer?.cancel();
    _maxRecordingTimer = null;
    final path = await _recorder.stop();
    if (_threadId != null && !_isGroup) {
      unawaited(
        _chat.sendRecordingEvent(threadId: _threadId!, isRecording: false),
      );
    }
    if (path != null) {
      unawaited(() async {
        try {
          await File(path).delete();
        } catch (_) {}
      }());
    }
    if (mounted) {
      setState(() {
        _isRecording = false;
      });
    }
  }

  Future<void> _stopRecording() async {
    if (!_isRecording) {
      return;
    }

    _maxRecordingTimer?.cancel();
    _maxRecordingTimer = null;
    final path = await _recorder.stop();
    if (_threadId != null && !_isGroup) {
      unawaited(
        _chat.sendRecordingEvent(threadId: _threadId!, isRecording: false),
      );
    }

    if (mounted) {
      setState(() {
        _isRecording = false;
      });
    }

    if (path == null) {
      return;
    }

    final audioFile = File(path);
    final durationMs = DateTime.now()
        .difference(_recordingStartedAt ?? DateTime.now())
        .inMilliseconds
        .clamp(1, 60000);

    if (_isGroup && _groupKind == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.chatGroupNotReady),
          ),
        );
      }
      return;
    }

    try {
      if (mounted) {
        setState(() {
          _isSending = true;
        });
      }

      ChatMessageItem message;
      if (_isGroup) {
        message = await _chat.sendGroupAudio(
          groupKind: _groupKind!,
          audioFile: audioFile,
          durationMs: durationMs,
        );
      } else {
        final partner = _partner;
        if (partner == null) {
          return;
        }
        message = await _chat.sendDirectMessageAudio(
          otherUserId: partner.id,
          audioFile: audioFile,
          durationMs: durationMs,
        );
      }

      if (_threadId == null && mounted) {
        _threadId = message.threadId;
        _chat.registerActiveThread(_threadId!);
      }
    } on AuthApiException catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(error.message)));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSending = false;
        });
      }
      unawaited(() async {
        try {
          await audioFile.delete();
        } catch (_) {}
      }());
    }
  }

  Future<void> _playMessage(ChatMessageItem message) async {
    if (_currentPlayingMessageId == message.messageId) {
      await _player.stop();
      if (mounted) {
        setState(() {
          _currentPlayingMessageId = null;
          _currentPlaybackPosition = Duration.zero;
        });
      }
      return;
    }

    try {
      final file = await _chat.ensureLocalAudio(message);
      await _player.stop();
      if (mounted) {
        setState(() {
          _currentPlayingMessageId = message.messageId;
          _currentPlaybackPosition = Duration.zero;
        });
      }
      await _player.play(DeviceFileSource(file.path));
    } on AuthApiException catch (error) {
      if (mounted) {
        setState(() {
          _currentPlayingMessageId = null;
          _currentPlaybackPosition = Duration.zero;
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(error.message)));
      }
    }
  }

  Future<void> _transcribeMessage(ChatMessageItem message) async {
    if (_transcribingIds.contains(message.messageId)) {
      return;
    }

    setState(() {
      _transcribingIds.add(message.messageId);
    });
    try {
      await _chat.transcribeMessage(message);
    } on VideoProcessingException catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(error.message)));
      }
    } finally {
      if (mounted) {
        setState(() {
          _transcribingIds.remove(message.messageId);
        });
      }
    }
  }

  Future<void> _showUserSheet(ChatUserSummary user) async {
    if (!_isGroup) {
      return;
    }

    final l10n = AppLocalizations.of(context)!;
    final navigator = Navigator.of(context);
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ProfileAvatar(radius: 34, imageUrl: user.avatarUrl),
              const SizedBox(height: 12),
              Text(user.name, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              Text(
                [
                  _languageLine(
                    user.learningLanguage,
                    user.learningLanguageDisplay,
                  ),
                  _languageLine(
                    user.nativeLanguage,
                    user.nativeLanguageDisplay,
                  ),
                ].whereType<String>().join('\n'),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () async {
                    Navigator.of(sheetContext).pop();
                    final existingThread = await _chat
                        .directMessageThreadForUser(user.id);
                    if (!mounted) {
                      return;
                    }
                    navigator.push(
                      MaterialPageRoute<void>(
                        builder: (_) => existingThread == null
                            ? ChatConversationScreen.directUser(partner: user)
                            : ChatConversationScreen.thread(
                                thread: existingThread,
                              ),
                      ),
                    );
                  },
                  child: Text(l10n.chatMessageAction),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Theme.of(context).colorScheme.error,
                  ),
                  onPressed: () {
                    Navigator.of(sheetContext).pop();
                    unawaited(_blockGroupUser(user));
                  },
                  child: Text(l10n.chatBlockUser),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showOwnMessageMenu(ChatMessageItem message) async {
    final l10n = AppLocalizations.of(context)!;
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () async {
                  Navigator.of(sheetContext).pop();
                  await _deleteOwnMessage(message);
                },
                child: ChatMenuItemRow(
                  icon: Icons.delete_outline,
                  label: l10n.chatDeleteMessage,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _deleteOwnMessage(ChatMessageItem message) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await _confirmAction(
      title: l10n.chatDeleteMessageTitle,
      body: l10n.chatDeleteMessageBody,
    );
    if (confirmed != true) {
      return;
    }

    try {
      await _chat.deleteOwnMessage(message);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.chatDeleteMessageSuccess)),
        );
      }
    } on AuthApiException catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error.message)),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.chatDeleteMessageFailed)),
        );
      }
    }
  }

  Future<void> _blockGroupUser(ChatUserSummary user) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await _confirmAction(
      title: l10n.chatBlockUserTitle(user.name),
      body: l10n.chatBlockUserBody,
    );
    if (confirmed != true) {
      return;
    }

    try {
      await _chat.blockUser(user.id);
      final threadId = _threadId;
      if (threadId != null) {
        await _chat.loadMessages(threadId);
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.chatBlockUserSuccess(user.name))),
        );
      }
    } on AuthApiException catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(error.message)));
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.chatBlockUserFailed)));
      }
    }
  }

  String? _languageLine(String? identifier, String? display) {
    final value = display ?? identifier;
    if (value == null || value.trim().isEmpty) {
      return null;
    }
    final flag = identifier == null || identifier.trim().isEmpty
        ? '🌐'
        : flagEmojiForLocale(identifier);
    return '$flag  $value';
  }

  Future<bool?> _confirmAction({required String title, required String body}) {
    final l10n = AppLocalizations.of(context)!;
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(body),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.confirmLabel),
          ),
        ],
      ),
    );
  }
}

enum _DirectMenuAction { toggleMute, block, deleteDm }

class _RoundedAudioProgressBar extends StatelessWidget {
  const _RoundedAudioProgressBar({
    required this.value,
    required this.backgroundColor,
    required this.foregroundColor,
  });

  final double value;
  final Color backgroundColor;
  final Color foregroundColor;

  @override
  Widget build(BuildContext context) {
    final clampedValue = value.clamp(0.0, 1.0);

    return SizedBox(
      height: 6,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(999),
        child: Stack(
          fit: StackFit.expand,
          children: [
            ColoredBox(color: backgroundColor),
            Align(
              alignment: Alignment.centerLeft,
              child: FractionallySizedBox(
                widthFactor: clampedValue,
                heightFactor: 1,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: foregroundColor,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({
    required this.message,
    required this.isGroup,
    required this.isPlaying,
    required this.playbackPosition,
    required this.isTranscribing,
    required this.onPlay,
    required this.onTranscribe,
    required this.onTapSender,
    required this.onLongPress,
  });

  final ChatMessageItem message;
  final bool isGroup;
  final bool isPlaying;
  final Duration playbackPosition;
  final bool isTranscribing;
  final VoidCallback onPlay;
  final VoidCallback onTranscribe;
  final VoidCallback? onTapSender;
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final bubbleColor = message.isMine
        ? theme.colorScheme.primary.withValues(alpha: 0.12)
        : theme.colorScheme.surfaceContainerHighest;
    final durationMs = message.durationMs;
    final progress = isPlaying && durationMs > 0
        ? (playbackPosition.inMilliseconds / durationMs).clamp(0.0, 1.0)
        : 0.0;

    return Align(
      alignment: message.isMine ? Alignment.centerRight : Alignment.centerLeft,
      child: GestureDetector(
        onLongPress: onLongPress,
        child: Container(
        constraints: const BoxConstraints(maxWidth: 340),
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: bubbleColor,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: theme.colorScheme.outlineVariant),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isGroup)
              _SenderHeader(
                user: message.senderUser,
                onTap: onTapSender,
                color: onTapSender == null
                    ? theme.colorScheme.onSurfaceVariant
                    : theme.colorScheme.primary,
              ),
            Row(
              children: [
                IconButton.filled(
                  onPressed: onPlay,
                  icon: Icon(
                    isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _RoundedAudioProgressBar(
                    value: progress,
                    backgroundColor: theme.colorScheme.outlineVariant,
                    foregroundColor: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Text(_formatDuration(message.durationMs)),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                OutlinedButton.icon(
                  onPressed: isTranscribing ? null : onTranscribe,
                  icon: isTranscribing
                      ? const SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.subtitles_outlined),
                  label: Text(
                    message.hasTranscript
                        ? l10n.chatRetranscribe
                        : l10n.chatTranscribe,
                  ),
                ),
                const Spacer(),
                Text(
                  _formatTimestamp(message.createdAt),
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
            if (message.localTranscriptStatus == 'processing')
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Text(l10n.chatTranscribingOnDevice),
              ),
            if (message.localTranscriptStatus == 'failed')
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Text(
                  l10n.chatTranscriptionFailed,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.error,
                  ),
                ),
              ),
            if (message.hasTranscript)
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: SelectableText(
                  message.localTranscriptText!,
                  style: theme.textTheme.bodyLarge,
                ),
              ),
          ],
        ),
      ),
      ),
    );
  }
}

class _SenderHeader extends StatelessWidget {
  const _SenderHeader({
    required this.user,
    required this.color,
    required this.onTap,
  });

  final ChatUserSummary user;
  final Color color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final row = Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ProfileAvatar(radius: 14, imageUrl: user.avatarUrl),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              user.name,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.labelLarge?.copyWith(
                color: color,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );

    if (onTap == null) {
      return row;
    }

    return GestureDetector(onTap: onTap, child: row);
  }
}

String _formatDuration(int durationMs) {
  final totalSeconds = (durationMs / 1000).round();
  final minutes = totalSeconds ~/ 60;
  final seconds = totalSeconds % 60;
  return '$minutes:${seconds.toString().padLeft(2, '0')}';
}

String _formatTimestamp(DateTime time) {
  final hour = time.hour.toString().padLeft(2, '0');
  final minute = time.minute.toString().padLeft(2, '0');
  return '$hour:$minute';
}

class _GroupSettingsScreen extends StatelessWidget {
  const _GroupSettingsScreen({required this.thread});

  final ChatThreadSummary thread;

  @override
  Widget build(BuildContext context) {
    final chat = ChatSessionNotifier.instance;
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.chatGroupSettingsTitle)),
      body: ListenableBuilder(
        listenable: chat,
        builder: (context, _) {
          return StreamBuilder<List<ChatThreadSummary>>(
            stream: chat.watchGroups(),
            builder: (context, snapshot) {
              final currentThread = _currentThread(snapshot.data) ?? thread;
              final isUpdating = chat.isUpdatingThreadNotifications(
                currentThread.threadId,
              );

              return ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  SwitchListTile(
                    title: Text(l10n.chatNotifications),
                    subtitle: Text(currentThread.title),
                    value: !currentThread.isMuted,
                    onChanged: isUpdating
                        ? null
                        : (value) async {
                            try {
                              await chat.updateThreadNotifications(
                                threadId: currentThread.threadId,
                                enabled: value,
                              );
                            } catch (_) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      l10n.chatNotificationUpdateFailed,
                                    ),
                                  ),
                                );
                              }
                            }
                          },
                  ),
                  const SizedBox(height: 16),
                  Text(
                    l10n.chatBlockedPeople,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 12),
                  const BlockedUsersList(),
                ],
              );
            },
          );
        },
      ),
    );
  }

  ChatThreadSummary? _currentThread(List<ChatThreadSummary>? threads) {
    if (threads == null) {
      return null;
    }
    for (final candidate in threads) {
      if (candidate.threadId == thread.threadId) {
        return candidate;
      }
    }
    return null;
  }
}
