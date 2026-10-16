import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';

/// One control for tap-to-record/tap-to-send and hold-to-record/release-to-send.
/// Releasing during permission/startup cancels the pending hold safely.
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
    final cancel = widget.onCancel;
    try {
      await widget.onStart();
      if (mounted && hold && !_holding) await cancel();
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

  void _tap() {
    if (_holding) return;
    widget.recording ? _finish() : _start();
  }

  void _release({bool cancel = false}) {
    if (!_holding) return;
    setState(() => _holding = false);
    _finish(cancel: cancel);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final theme = Theme.of(context), colors = theme.colorScheme;
    final enabled = widget.enabled && !_starting && !_finishing;
    final recording = widget.recording;
    final remaining = widget.remainingSeconds;
    final label = recording
        ? (_holding ? l.chatRecordingReleaseToSend : l.chatTapToSendAudio)
        : (widget.busyLabel ?? l.chatTapOrHoldToRecordAudio);
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border(top: BorderSide(color: colors.outlineVariant)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Semantics(
              button: true,
              enabled: enabled,
              label: label,
              value: recording
                  ? '${remaining ~/ 60}:${(remaining % 60).toString().padLeft(2, '0')}'
                  : null,
              onTap: enabled && !_holding ? _tap : null,
              excludeSemantics: true,
              child: RawGestureDetector(
                key: const Key('voice-record-button'),
                behavior: HitTestBehavior.opaque,
                excludeFromSemantics: true,
                gestures: {
                  TapGestureRecognizer:
                      GestureRecognizerFactoryWithHandlers<
                        TapGestureRecognizer
                      >(
                        TapGestureRecognizer.new,
                        (recognizer) => recognizer.onTap = enabled && !_holding
                            ? _tap
                            : null,
                      ),
                  LongPressGestureRecognizer:
                      GestureRecognizerFactoryWithHandlers<
                        LongPressGestureRecognizer
                      >(
                        () => LongPressGestureRecognizer(
                          duration: const Duration(milliseconds: 300),
                        ),
                        (recognizer) {
                          recognizer.onLongPressStart = enabled && !recording
                              ? (_) => _start(hold: true)
                              : null;
                          // Keep release/cancel attached during async startup.
                          recognizer.onLongPressEnd = (_) => _release();
                          recognizer.onLongPressCancel = () =>
                              _release(cancel: true);
                        },
                      ),
                },
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
                      Icon(
                        recording && !_holding ? Icons.send_rounded : Icons.mic,
                        size: 20,
                        color: recording
                            ? colors.error
                            : colors.onSurfaceVariant,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          label,
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
          ),
          if (recording && !_holding)
            IconButton(
              tooltip: l.cancel,
              onPressed: enabled ? () => _finish(cancel: true) : null,
              icon: const Icon(Icons.close),
            ),
        ],
      ),
    );
  }
}
