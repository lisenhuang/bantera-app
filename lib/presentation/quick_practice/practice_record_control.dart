import 'dart:math' as math;
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import 'practice_speaking_hint_store.dart';

/// Tap to start/check, or hold for 300 ms and release to check.
/// A released/cancelled hold must not start recording after a permission dialog.
class PracticeRecordControl extends StatefulWidget {
  const PracticeRecordControl({
    super.key,
    required this.enabled,
    required this.recording,
    required this.busy,
    required this.pulse,
    required this.onStart,
    required this.onCheck,
    required this.onCancel,
    this.microphoneAnchor,
    this.hintStore = const PracticeSpeakingHintStore(),
  });

  final PracticeSpeakingHintStore hintStore;
  final bool enabled, recording, busy;
  final Animation<double> pulse;
  final GlobalKey? microphoneAnchor;
  final Future<void> Function(bool Function() stillWanted) onStart;
  final Future<void> Function() onCheck, onCancel;

  @override
  State<PracticeRecordControl> createState() => _PracticeRecordControlState();
}

class _PracticeRecordControlState extends State<PracticeRecordControl>
    with SingleTickerProviderStateMixin {
  bool _showGuidance = false;
  bool _guidanceDismissed = false;
  late final AnimationController _guidancePulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1800),
  );

  @override
  void initState() {
    super.initState();
    _loadGuidance();
  }

  Future<void> _loadGuidance() async {
    bool dismissed = false;
    try {
      dismissed = await widget.hintStore.isDismissed();
    } catch (_) {
      // Guidance is optional; unavailable preferences must not block recording.
    }
    if (!mounted || dismissed || _guidanceDismissed) return;
    setState(() => _showGuidance = true);
    if (!MediaQuery.disableAnimationsOf(context)) _guidancePulse.forward();
  }

  Future<void> _dismissGuidance() async {
    if (_guidanceDismissed) return;
    _guidanceDismissed = true;
    setState(() => _showGuidance = false);
    _guidancePulse.stop();
    try {
      await widget.hintStore.dismiss();
    } catch (_) {
      // Keep it dismissed in this session even if the device cannot save it.
    }
  }

  @override
  void dispose() {
    _guidancePulse.dispose();
    super.dispose();
  }

  bool _holding = false, _starting = false, _finishing = false;
  int _generation = 0;

  @override
  void didUpdateWidget(PracticeRecordControl oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Also covers the parent's automatic recording timeout.
    if (oldWidget.recording && !widget.recording && widget.busy) {
      _dismissGuidance();
    }
    if ((oldWidget.recording && !widget.recording) || !widget.enabled) {
      _holding = false;
      _generation++;
    }
  }

  Future<void> _start({bool hold = false}) async {
    if (!widget.enabled ||
        widget.busy ||
        widget.recording ||
        _starting ||
        _finishing) {
      return;
    }
    final generation = ++_generation;
    setState(() {
      _holding = hold;
      _starting = true;
    });
    bool wanted() =>
        mounted &&
        widget.enabled &&
        generation == _generation &&
        (!hold || _holding);
    try {
      await widget.onStart(wanted);
    } finally {
      if (mounted) setState(() => _starting = false);
    }
  }

  Future<void> _finish({bool cancel = false}) async {
    if (_starting || _finishing || !widget.recording) return;
    setState(() {
      _holding = false;
      _finishing = true;
    });
    try {
      await (cancel ? widget.onCancel() : widget.onCheck());
      if (!cancel && mounted) await _dismissGuidance();
    } finally {
      if (mounted) setState(() => _finishing = false);
    }
  }

  void _release({bool cancel = false}) {
    if (!_holding) return;
    setState(() => _holding = false);
    _finish(cancel: cancel);
  }

  void _tap() {
    if (_starting || _finishing || _holding || widget.busy) return;
    widget.recording ? _finish() : _start();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final theme = Theme.of(context), c = theme.colorScheme;
    final available =
        widget.enabled && !widget.busy && !_starting && !_finishing;
    final busy = widget.busy || _starting || _finishing;
    final label = _starting
        ? l.practiceMicStarting
        : busy
        ? l.quickChecking
        : widget.recording
        ? (_holding ? l.practiceReleaseToCheck : l.practiceTapToCheck)
        : l.quickSpeak;
    return Column(
      children: [
        AnimatedBuilder(
          animation: Listenable.merge([widget.pulse, _guidancePulse]),
          builder: (context, child) => Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: c.primary.withValues(
                alpha: widget.recording
                    ? .08 + widget.pulse.value * .08
                    : _showGuidance &&
                          !busy &&
                          !MediaQuery.disableAnimationsOf(context)
                    ? .06 +
                          .12 *
                              math
                                  .pow(
                                    math.sin(
                                      _guidancePulse.value * math.pi * 2,
                                    ),
                                    2,
                                  )
                                  .toDouble()
                    : .06,
              ),
            ),
            child: child,
          ),
          child: SizedBox(
            key: widget.microphoneAnchor,
            width: 76,
            height: 76,
            child: Listener(
              onPointerCancel: (_) => _release(cancel: true),
              child: RawGestureDetector(
                excludeFromSemantics: true,
                gestures: {
                  LongPressGestureRecognizer:
                      GestureRecognizerFactoryWithHandlers<
                        LongPressGestureRecognizer
                      >(
                        () => LongPressGestureRecognizer(
                          duration: const Duration(milliseconds: 300),
                        ),
                        (recognizer) {
                          recognizer.onLongPressStart =
                              available && !widget.recording
                              ? (_) => _start(hold: true)
                              : null;
                          // Retain these callbacks while permission/startup is pending.
                          recognizer.onLongPressEnd = (_) => _release();
                          recognizer.onLongPressCancel = () =>
                              _release(cancel: true);
                        },
                      ),
                },
                child: Semantics(
                  label: label,
                  child: FilledButton(
                    key: const ValueKey('practice-record-button'),
                    onPressed: available ? _tap : null,
                    style: FilledButton.styleFrom(
                      shape: const CircleBorder(),
                      padding: EdgeInsets.zero,
                      backgroundColor: widget.recording ? c.error : c.primary,
                    ),
                    child: busy
                        ? SizedBox(
                            width: 26,
                            height: 26,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: c.primary,
                            ),
                          )
                        : Icon(
                            widget.recording
                                ? CupertinoIcons.stop_fill
                                : CupertinoIcons.mic_fill,
                            size: 30,
                          ),
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        // Reserve the same title height for every state, including large text.
        Stack(
          alignment: Alignment.center,
          children: [
            for (final title in {
              l.practiceMicStarting,
              l.quickChecking,
              l.practiceReleaseToCheck,
              l.practiceTapToCheck,
              l.quickSpeak,
            })
              Visibility(
                visible: title == label,
                maintainState: true,
                maintainAnimation: true,
                maintainSize: true,
                child: Text(
                  title,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 6),
        Visibility(
          visible: _showGuidance,
          maintainState: widget.recording || busy,
          maintainAnimation: widget.recording || busy,
          maintainSize: widget.recording || busy,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: Text(
                  l.practiceFirstAnswerHint,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: c.onSurfaceVariant,
                  ),
                ),
              ),
              IconButton(
                key: const ValueKey('dismiss-practice-speaking-hint'),
                tooltip: l.closeLabel,
                onPressed: widget.recording || busy ? null : _dismissGuidance,
                icon: const Icon(CupertinoIcons.xmark, size: 14),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
