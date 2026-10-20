import 'dart:async';
import 'dart:math' as math;

import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';

/// A brief, silent celebration above the root dialog. Never consumes touches.
class GoalConfetti extends StatefulWidget {
  const GoalConfetti({super.key});

  @override
  State<GoalConfetti> createState() => _GoalConfettiState();
}

class _GoalConfettiState extends State<GoalConfetti>
    with WidgetsBindingObserver {
  final _controller = ConfettiController(
    duration: const Duration(milliseconds: 700),
  );
  Timer? _endTimer;
  bool _started = false, _finished = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _started = true;
      _finished = true;
      _controller.stop();
      _endTimer?.cancel();
    } else if (!_started) {
      _started = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted || _finished) return;
        _controller.play();
        _endTimer = Timer(const Duration(seconds: 4), _finish);
      });
    }
  }

  void _finish() {
    _controller.stop();
    _endTimer?.cancel();
    if (mounted) setState(() => _finished = true);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed) _finish();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _endTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_finished) return const SizedBox.shrink();
    final colors = [
      Theme.of(context).colorScheme.primary,
      const Color(0xFF43CEB1),
      const Color(0xFFFFCA68),
      const Color(0xFFF18BB8),
    ];
    return IgnorePointer(
      key: const ValueKey('goal-full-screen-confetti'),
      child: ExcludeSemantics(
        child: RepaintBoundary(
          child: Stack(
            children: [
              for (final left in [true, false])
                Align(
                  alignment: Alignment(left ? -1 : 1, -.35),
                  child: ConfettiWidget(
                    confettiController: _controller,
                    blastDirection: left ? -math.pi / 4 : -3 * math.pi / 4,
                    emissionFrequency: .12,
                    numberOfParticles: 6,
                    maxBlastForce: 30,
                    minBlastForce: 15,
                    gravity: .18,
                    minimumSize: const Size(5, 3),
                    maximumSize: const Size(10, 6),
                    colors: colors,
                    shouldLoop: false,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
