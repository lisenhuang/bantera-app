import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Decorative credit transfer. Never captures touches or owns audio resources.
class PracticeWordFlight {
  OverlayEntry? _entry;
  Completer<void>? _completion;
  Timer? _timeout;

  Future<void> show(
    BuildContext context,
    GlobalKey source,
    GlobalKey target, {
    required String? outcome,
  }) {
    cancel();
    if (outcome != 'correct') return Future.value();
    if (MediaQuery.disableAnimationsOf(context)) return Future.value();
    final overlay = Overlay.of(context, rootOverlay: true);
    final overlayBox = overlay.context.findRenderObject();
    final from = source.currentContext?.findRenderObject();
    final to = target.currentContext?.findRenderObject();
    if (overlayBox is! RenderBox ||
        from is! RenderBox ||
        to is! RenderBox ||
        !from.hasSize ||
        !to.hasSize) {
      return Future.value();
    }
    final start = overlayBox.globalToLocal(
      from.localToGlobal(from.size.center(Offset.zero)),
    );
    final end = overlayBox.globalToLocal(
      to.localToGlobal(to.size.center(Offset.zero)),
    );
    if (!(Offset.zero & overlayBox.size).contains(start)) return Future.value();
    final completion = _completion = Completer<void>();
    final color = Theme.of(context).colorScheme.primary;
    _entry = OverlayEntry(
      builder: (_) => Positioned.fill(
        child: IgnorePointer(
          child: ExcludeSemantics(
            child: RepaintBoundary(
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: 1),
                duration: const Duration(milliseconds: 2500),
                onEnd: cancel,
                builder: (_, value, _) => CustomPaint(
                  key: const ValueKey('practice-word-flight'),
                  painter: WordFlightPainter(start, end, value, color),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    overlay.insert(_entry!);
    // Tickers can be suppressed by route/lifecycle changes. Never delay credit
    // indefinitely; callers also cancel immediately when Practice becomes hidden.
    _timeout = Timer(const Duration(milliseconds: 2700), cancel);
    return completion.future;
  }

  void cancel() {
    _timeout?.cancel();
    _timeout = null;
    _entry?.remove();
    _entry?.dispose();
    _entry = null;
    if (_completion != null && !_completion!.isCompleted) {
      _completion!.complete();
    }
    _completion = null;
  }
}

class WordFlightPainter extends CustomPainter {
  WordFlightPainter(this.start, this.end, this.progress, this.color);
  final Offset start, end;
  final double progress;
  final Color color;

  double get particleProgress => (progress * 2500 / 1600).clamp(0.0, 1.0);
  double get rocketProgress => ((progress * 2500 - 1600) / 900).clamp(0.0, 1.0);

  @override
  void paint(Canvas canvas, Size size) {
    final control = Offset(
      math.min(size.width - 24, start.dx + 90),
      end.dy + (start.dy - end.dy) * .45,
    );
    Offset point(double t) =>
        start * ((1 - t) * (1 - t)) +
        control * (2 * (1 - t) * t) +
        end * (t * t);
    final palette = [
      color,
      const Color(0xFF43CEB1),
      const Color(0xFFA993FF),
      const Color(0xFFFFCA68),
    ];
    for (var i = 0; i < 16; i++) {
      final t = ((particleProgress - i * .012) / .80).clamp(0.0, 1.0);
      if (t <= 0 || t >= 1) continue;
      final eased = Curves.easeInOutCubic.transform(t);
      final spread = math.sin(math.pi * t);
      final center =
          point(eased) +
          Offset(
            math.sin(i * 2.4) * 17 * spread,
            math.cos(i * 1.7) * 12 * spread,
          );
      final opacity = (math.sin(math.pi * t) * 1.5).clamp(0.0, 1.0);
      final radius = 2.4 + (i % 3) * .65;
      final particle = palette[i % palette.length];
      canvas.drawCircle(
        center,
        radius * 2.8,
        Paint()..color = particle.withValues(alpha: opacity * .12),
      );
      canvas.save();
      canvas.translate(center.dx, center.dy);
      canvas.rotate(t * math.pi + i);
      final shape = Path()
        ..moveTo(0, -radius * 1.6)
        ..lineTo(radius, 0)
        ..lineTo(0, radius * 1.6)
        ..lineTo(-radius, 0)
        ..close();
      canvas.drawPath(
        shape,
        Paint()..color = particle.withValues(alpha: opacity),
      );
      canvas.restore();
    }
    if (particleProgress > .76 && particleProgress < 1) {
      final arrival = ((particleProgress - .76) / .24).clamp(0.0, 1.0);
      canvas.drawCircle(
        end,
        16 + arrival * 14,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2
          ..color = color.withValues(alpha: (1 - arrival) * .55),
      );
    }
    if (rocketProgress > 0 && rocketProgress < 1) _rocket(canvas);
  }

  void _rocket(Canvas canvas) {
    final t = rocketProgress;
    final reveal = (t / .18).clamp(0.0, 1.0);
    final fade = ((1 - t) / .3).clamp(0.0, 1.0);
    final lift = Curves.easeInCubic.transform(t) * 62;
    canvas.save();
    canvas.translate(end.dx, end.dy - lift);
    canvas.scale(.75 + .25 * Curves.easeOutCubic.transform(reveal));
    Paint fill(Color c) => Paint()..color = c.withValues(alpha: reveal * fade);
    // Soft launch glow, then a compact upward-facing rocket and warm exhaust.
    canvas.drawCircle(
      Offset.zero,
      23,
      Paint()..color = color.withValues(alpha: .13 * reveal * fade),
    );
    final flame = Path()
      ..moveTo(-4, 10)
      ..quadraticBezierTo(-6, 19, 0, 25 + 3 * math.sin(t * math.pi * 8))
      ..quadraticBezierTo(6, 19, 4, 10)
      ..close();
    canvas.drawPath(flame, fill(const Color(0xFFFFCA68)));
    final fins = Path()
      ..moveTo(-6, 0)
      ..lineTo(-13, 12)
      ..lineTo(-5, 9)
      ..moveTo(6, 0)
      ..lineTo(13, 12)
      ..lineTo(5, 9);
    canvas.drawPath(fins, fill(const Color(0xFF43CEB1)));
    final body = Path()
      ..moveTo(0, -18)
      ..cubicTo(9, -10, 10, 2, 5, 12)
      ..lineTo(-5, 12)
      ..cubicTo(-10, 2, -9, -10, 0, -18)
      ..close();
    canvas.drawPath(body, fill(color));
    canvas.drawCircle(const Offset(0, -4), 4.5, fill(Colors.white));
    canvas.drawCircle(const Offset(0, -4), 2.7, fill(const Color(0xFF43CEB1)));
    canvas.restore();
  }

  @override
  bool shouldRepaint(WordFlightPainter old) =>
      old.progress != progress ||
      old.start != start ||
      old.end != end ||
      old.color != color;
}
