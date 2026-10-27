import 'dart:math' as math;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

enum AnimatedTabKind { practice, chats }

/// A one-second, tap-triggered accent that never moves the navigation hit target.
class AnimatedTabIcon extends StatefulWidget {
  const AnimatedTabIcon({
    super.key,
    required this.kind,
    required this.replayTick,
    required this.selected,
  });
  final AnimatedTabKind kind;
  final int replayTick;
  final bool selected;
  @override
  State<AnimatedTabIcon> createState() => _AnimatedTabIconState();
}

class _AnimatedTabIconState extends State<AnimatedTabIcon>
    with SingleTickerProviderStateMixin {
  late final _controller = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 1),
    value: 1,
  );
  bool _reduce = false;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _reduce = MediaQuery.disableAnimationsOf(context);
    if (_reduce) _controller.value = 1;
  }

  @override
  void didUpdateWidget(AnimatedTabIcon oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!widget.selected || _reduce) {
      _controller.value = 1;
    } else if (oldWidget.replayTick != widget.replayTick) {
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: SizedBox.square(
      dimension: 28,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          final color =
              IconTheme.of(context).color ??
              Theme.of(context).colorScheme.primary;
          final phase = _controller.value;
          if (widget.kind == AnimatedTabKind.practice) {
            return CustomPaint(
              key: const ValueKey('practice-tab-motion'),
              painter: _WavePainter(phase, color),
            );
          }
          return Transform.scale(
            scale: 1 + .06 * math.sin(math.pi * phase),
            child: Stack(
              children: [
                Icon(
                  widget.selected
                      ? CupertinoIcons.chat_bubble_fill
                      : CupertinoIcons.chat_bubble,
                  size: 28,
                ),
                Positioned.fill(
                  child: CustomPaint(
                    key: const ValueKey('chat-tab-motion'),
                    painter: _ChatLinesPainter(
                      phase,
                      widget.selected
                          ? Theme.of(context).colorScheme.onPrimary
                          : color,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    ),
  );
}

class _WavePainter extends CustomPainter {
  _WavePainter(this.phase, this.color);
  final double phase;
  final Color color;
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    const heights = [6.0, 12.0, 21.0, 27.0, 17.0, 11.0, 5.0];
    for (var i = 0; i < heights.length; i++) {
      final envelope = math.sin(math.pi * phase);
      final pulse = 1 + .38 * envelope * math.sin(phase * 5 * math.pi + i * .9);
      final height = (heights[i] * pulse).clamp(3.0, 27.0);
      final x = 3 + i * (size.width - 6) / 6;
      canvas.drawLine(
        Offset(x, (size.height - height) / 2),
        Offset(x, (size.height + height) / 2),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_WavePainter oldDelegate) =>
      phase != oldDelegate.phase || color != oldDelegate.color;
}

class _ChatLinesPainter extends CustomPainter {
  _ChatLinesPainter(this.phase, this.color);
  final double phase;
  final Color color;
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.7
      ..strokeCap = StrokeCap.round;
    for (var i = 0; i < 3; i++) {
      final fraction = Curves.easeOutCubic.transform(
        ((phase - i * .16) / .35).clamp(0.0, 1.0),
      );
      if (fraction == 0) continue;
      final y = 8.0 + i * 4;
      canvas.drawLine(
        Offset(7, y),
        Offset(7 + (i == 2 ? 8 : 14) * fraction, y),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_ChatLinesPainter oldDelegate) =>
      phase != oldDelegate.phase || color != oldDelegate.color;
}
