import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../core/dm_call_notifier.dart';
import '../../l10n/app_localizations.dart';
import '../shared/profile_avatar.dart';

class DmCallOverlayHost extends StatelessWidget {
  const DmCallOverlayHost({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: DmCallNotifier.instance,
      builder: (context, _) {
        final call = DmCallNotifier.instance;
        if (!call.isActive) {
          return const SizedBox.shrink();
        }

        return Positioned.fill(
          child: Material(
            color: Colors.black.withValues(alpha: 0.88),
            child: SafeArea(
              child: switch (call.phase) {
                DmCallPhase.error => _CallErrorView(call: call),
                _ => _ActiveCallView(call: call),
              },
            ),
          ),
        );
      },
    );
  }
}

class _ActiveCallView extends StatelessWidget {
  const _ActiveCallView({required this.call});

  final DmCallNotifier call;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final peer = call.peerUser;
    final hasRemoteVideo =
        call.hasVideo && call.remoteRenderer.srcObject != null;

    return Stack(
      children: [
        if (hasRemoteVideo)
          Positioned.fill(
            child: RTCVideoView(
              call.remoteRenderer,
              objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
            ),
          ),
        if (!hasRemoteVideo)
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ProfileAvatar(radius: 56, imageUrl: peer?.avatarUrl),
                const SizedBox(height: 20),
                Text(
                  peer?.name ?? l10n.appName,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  _statusText(l10n),
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
        if (call.hasVideo && call.localRenderer.srcObject != null)
          Positioned(
            top: 20,
            right: 20,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: SizedBox(
                width: 108,
                height: 156,
                child: RTCVideoView(
                  call.localRenderer,
                  mirror: true,
                  objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                ),
              ),
            ),
          ),
        Positioned(
          left: 24,
          right: 24,
          bottom: 28,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (hasRemoteVideo)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Column(
                    children: [
                      Text(
                        peer?.name ?? l10n.appName,
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _statusText(l10n),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 20,
                runSpacing: 16,
                children: [
                  if (call.phase == DmCallPhase.incoming) ...[
                    _CallButton(
                      icon: Icons.call_end,
                      label: l10n.chatCallDecline,
                      background: Colors.redAccent,
                      onPressed: call.declineIncomingCall,
                    ),
                    _CallButton(
                      icon: call.hasVideo ? Icons.videocam : Icons.call,
                      label: l10n.chatCallAccept,
                      background: Colors.green,
                      onPressed: call.acceptIncomingCall,
                    ),
                  ] else ...[
                    _CallButton(
                      icon: call.isMuted ? Icons.mic_off : Icons.mic,
                      label: call.isMuted
                          ? l10n.chatCallUnmute
                          : l10n.chatCallMute,
                      onPressed: call.toggleMute,
                    ),
                    _CallButton(
                      icon: call.isSpeakerEnabled
                          ? Icons.volume_up
                          : Icons.hearing,
                      label: l10n.chatCallSpeaker,
                      onPressed: call.toggleSpeaker,
                    ),
                    if (call.hasVideo)
                      _CallButton(
                        icon: call.isCameraEnabled
                            ? Icons.videocam
                            : Icons.videocam_off,
                        label: l10n.chatCallCamera,
                        onPressed: call.toggleCamera,
                      ),
                    if (call.hasVideo)
                      _CallButton(
                        icon: Icons.cameraswitch_outlined,
                        label: l10n.chatCallSwitchCamera,
                        onPressed: call.switchCamera,
                      ),
                    _CallButton(
                      icon: Icons.call_end,
                      label: l10n.chatCallEnd,
                      background: Colors.redAccent,
                      onPressed: call.endCurrentCall,
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _statusText(AppLocalizations l10n) {
    return switch (call.phase) {
      DmCallPhase.outgoing =>
        call.hasVideo ? l10n.chatVideoCalling : l10n.chatAudioCalling,
      DmCallPhase.incoming =>
        call.hasVideo ? l10n.chatVideoIncoming : l10n.chatAudioIncoming,
      DmCallPhase.connecting => l10n.chatCallConnecting,
      DmCallPhase.connected => _formatDuration(call.connectedDuration),
      _ => '',
    };
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
}

class _CallErrorView extends StatelessWidget {
  const _CallErrorView({required this.call});

  final DmCallNotifier call;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  l10n.chatCallIssueTitle,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 12),
                Text(_messageFor(l10n, call.errorCode)),
                const SizedBox(height: 20),
                if (call.shouldShowSettingsAction)
                  FilledButton(
                    onPressed: openAppSettings,
                    child: Text(l10n.permissionsOpenSettings),
                  ),
                TextButton(
                  onPressed: call.dismissError,
                  child: Text(l10n.closeLabel),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _messageFor(AppLocalizations l10n, DmCallErrorCode? code) {
    return switch (code) {
      DmCallErrorCode.microphoneDenied => l10n.chatCallMicrophoneDenied,
      DmCallErrorCode.microphoneSettings => l10n.chatCallMicrophoneSettings,
      DmCallErrorCode.cameraDenied => l10n.chatCallCameraDenied,
      DmCallErrorCode.cameraSettings => l10n.chatCallCameraSettings,
      DmCallErrorCode.busy => l10n.chatCallBusy,
      DmCallErrorCode.unavailable => l10n.chatCallUnavailable,
      DmCallErrorCode.networkRestricted => l10n.chatCallNetworkRestricted,
      _ => l10n.chatCallFailed,
    };
  }
}

class _CallButton extends StatelessWidget {
  const _CallButton({
    required this.icon,
    required this.label,
    required this.onPressed,
    this.background,
  });

  final IconData icon;
  final String label;
  final Future<void> Function() onPressed;
  final Color? background;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 76,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton.filled(
            onPressed: () => onPressed(),
            style: IconButton.styleFrom(
              backgroundColor: background ?? Colors.white12,
              foregroundColor: Colors.white,
              iconSize: 28,
              minimumSize: const Size(60, 60),
            ),
            icon: Icon(icon),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: Colors.white),
          ),
        ],
      ),
    );
  }
}
