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
    this.embedded = false,
  });
  final bool enabled, recording;

  /// The parent supplies the shared composer background and padding.
  final bool embedded;
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
    final countdown =
        '${remaining ~/ 60}:${(remaining % 60).toString().padLeft(2, '0')}';
    final countdownStyle = theme.textTheme.labelLarge?.copyWith(
      color: colors.error,
      fontFeatures: const [FontFeature.tabularFigures()],
    );
    // Equal side gutters center the label within the whole button, even with
    // the icon on the left and a scaled countdown on the right.
    final timerPainter = TextPainter(
      text: TextSpan(text: recording ? countdown : '', style: countdownStyle),
      textDirection: Directionality.of(context),
      textScaler: MediaQuery.textScalerOf(context),
    )..layout();
    final sideWidth =
        (timerPainter.width > 20 ? timerPainter.width : 20.0) + 10;
    timerPainter.dispose();
    final label = recording
        ? (_holding ? l.chatRecordingReleaseToSend : l.chatTapToSendAudio)
        : (widget.busyLabel ?? l.chatTapOrHoldToRecordAudio);
    Widget contentRow({required bool inlineCountdown}) {
      final gutter = inlineCountdown ? sideWidth : 30.0;
      return Row(
        children: [
          SizedBox(
            width: gutter,
            child: Align(
              alignment: Alignment.centerLeft,
              heightFactor: 1,
              child: Icon(
                recording && !_holding ? Icons.send_rounded : Icons.mic,
                size: 20,
                color: recording ? colors.error : colors.onSurfaceVariant,
              ),
            ),
          ),
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
          SizedBox(
            width: gutter,
            child: inlineCountdown
                ? Align(
                    alignment: Alignment.centerRight,
                    heightFactor: 1,
                    child: Text(countdown, style: countdownStyle),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      );
    }

    return Container(
      padding: widget.embedded
          ? EdgeInsets.zero
          : const EdgeInsets.fromLTRB(16, 12, 16, 16),
      decoration: widget.embedded
          ? null
          : BoxDecoration(
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
              value: recording ? countdown : null,
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
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final inlineCountdown =
                          recording &&
                          constraints.maxWidth >= sideWidth * 2 + 80;
                      final row = contentRow(inlineCountdown: inlineCountdown);
                      if (!recording || inlineCountdown) return row;
                      // Keep large accessibility text readable on narrow phones.
                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          row,
                          const SizedBox(height: 4),
                          Text(countdown, style: countdownStyle),
                        ],
                      );
                    },
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
