import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';

/// Shared recording gestures for AI and human DMs. A pending permission prompt
/// never turns a released hold into an unintended hands-free recording.
class VoiceMessageComposer extends StatefulWidget {
  const VoiceMessageComposer({
    super.key,
    required this.enabled,
    required this.recording,
    required this.remainingSeconds,
    required this.onStart,
    required this.onSend,
    required this.onCancel,
    this.busyLabel,
  });
  final bool enabled, recording;
  final int remainingSeconds;
  final String? busyLabel;
  final Future<void> Function() onStart, onSend, onCancel;

  @override
  State<VoiceMessageComposer> createState() => _VoiceMessageComposerState();
}

class _VoiceMessageComposerState extends State<VoiceMessageComposer> {
  bool _holding = false, _starting = false, _finishing = false;

  @override
  void didUpdateWidget(VoiceMessageComposer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.recording && !widget.recording) _holding = false;
  }

  Future<void> _start({bool hold = false}) async {
    if (!widget.enabled || widget.recording || _starting || _finishing) return;
    setState(() {
      _starting = true;
      _holding = hold;
    });
    try {
      await widget.onStart();
      if (mounted && hold && !_holding) await widget.onCancel();
    } finally {
      if (mounted) setState(() => _starting = false);
    }
  }

  Future<void> _finish({bool cancel = false}) async {
    if (_finishing || _starting || !widget.recording) return;
    setState(() {
      _finishing = true;
      _holding = false;
    });
    try {
      await (cancel ? widget.onCancel() : widget.onSend());
    } finally {
      if (mounted) setState(() => _finishing = false);
    }
  }

  void _release({bool cancel = false}) {
    if (!_holding) return;
    setState(() => _holding = false);
    _finish(cancel: cancel);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final theme = Theme.of(context), colors = Theme.of(context).colorScheme;
    final enabled = widget.enabled && !_starting && !_finishing;
    final recording = widget.recording;
    final remaining = widget.remainingSeconds;
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
              key: const Key('voice-hold-record'),
              onLongPressStart: enabled && !recording
                  ? (_) => _start(hold: true)
                  : null,
              // Keep release handlers attached while startup or recording is active.
              onLongPressEnd: (_) => _release(),
              onLongPressCancel: () => _release(cancel: true),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                constraints: const BoxConstraints(minHeight: 48),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: recording
                      ? colors.error.withValues(alpha: .1)
                      : colors.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: recording ? colors.error : colors.outlineVariant,
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        widget.busyLabel ??
                            (recording
                                ? l.chatRecordingStatus
                                : l.chatHoldToRecordAudio),
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: recording ? colors.error : colors.onSurface,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    if (recording) ...[
                      const SizedBox(width: 8),
                      Text(
                        '${remaining ~/ 60}:${(remaining % 60).toString().padLeft(2, '0')}',
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
          if (recording && !_holding)
            IconButton(
              tooltip: l.cancel,
              onPressed: enabled ? () => _finish(cancel: true) : null,
              icon: const Icon(Icons.close),
            ),
          const SizedBox(width: 12),
          IconButton.filled(
            key: const Key('voice-tap-record-send'),
            tooltip: recording ? l.aiSend : l.aiRecordVoiceMessage,
            onPressed: !enabled || _holding
                ? null
                : recording
                ? () => _finish()
                : () => _start(),
            style: IconButton.styleFrom(minimumSize: const Size(48, 48)),
            icon: Icon(recording ? Icons.send_rounded : Icons.mic),
          ),
        ],
      ),
    );
  }
}
