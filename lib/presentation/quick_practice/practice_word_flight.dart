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
                duration: const Duration(milliseconds: 3000),
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
    _timeout = Timer(const Duration(milliseconds: 3200), cancel);
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

  double get particleProgress => (progress * 3000 / 1600).clamp(0.0, 1.0);
  double get rocketProgress =>
      ((progress * 3000 - 1600) / 1400).clamp(0.0, 1.0);

  /// Starts at the Goal ring and accelerates until the rocket clears the top.
  Offset get rocketPosition => Offset(
    end.dx,
    end.dy - Curves.easeInCubic.transform(rocketProgress) * (end.dy + 120),
  );

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
    final flicker = math.sin(t * math.pi * 32);
    final sway = math.sin(t * math.pi * 21) * 2;
    final flameLength = 26 + 28 * t + flicker * 4;
    const mint = Color(0xFF43CEB1);
    const gold = Color(0xFFFFCA68);
    final lightPurple = Color.lerp(color, Colors.white, .48)!;
    final deepPurple = Color.lerp(color, const Color(0xFF25164B), .35)!;
    Paint fill(Color c) => Paint()..color = c.withValues(alpha: reveal);
    canvas.save();
    canvas.translate(rocketPosition.dx, rocketPosition.dy);
    canvas.scale(.85 + .3 * Curves.easeOutCubic.transform(reveal));

    // Soft engine glow and three independently flickering flame layers.
    final glowRect = Rect.fromCenter(
      center: const Offset(0, 24),
      width: 52,
      height: 64 + 24 * t,
    );
    canvas.drawOval(
      glowRect,
      Paint()
        ..shader = RadialGradient(
          colors: [
            gold.withValues(alpha: .22 * reveal),
            gold.withValues(alpha: 0),
          ],
        ).createShader(glowRect),
    );
    Path flame(double width, double length, double bend) => Path()
      ..moveTo(-width, 13)
      ..cubicTo(-width * 1.4, 24, bend - 4, 26 + length * .6, bend, 15 + length)
      ..cubicTo(bend + 5, 24 + length * .58, width * 1.25, 25, width, 13)
      ..close();
    final flameRect = Rect.fromLTWH(-10, 13, 20, flameLength + 5);
    canvas.drawPath(
      flame(7 + flicker * .6, flameLength, sway),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            gold.withValues(alpha: reveal),
            const Color(0xFFFF9659).withValues(alpha: .7 * reveal),
          ],
        ).createShader(flameRect),
    );
    canvas.drawPath(
      flame(
        4.5,
        flameLength * (.65 + .06 * math.sin(t * math.pi * 43)),
        -sway * .6,
      ),
      fill(const Color(0xFFFFE9AA)),
    );
    canvas.drawPath(
      flame(2.3, flameLength * .34, sway * .3),
      fill(const Color(0xFFFFF8E7)),
    );
    for (var i = 0; i < 6; i++) {
      final phase = (t * 3.4 + i / 6) % 1;
      final x = math.sin(i * 2.3) * (3 + 8 * phase);
      final y = 22 + phase * (44 + 18 * t);
      canvas.drawCircle(
        Offset(x, y),
        1.7 * (1 - phase) + .3,
        Paint()..color = gold.withValues(alpha: (1 - phase) * reveal * .65),
      );
    }

    // Mint swept fins, a shaded purple hull and a glass porthole.
    final fins = Path()
      ..moveTo(-7, -1)
      ..quadraticBezierTo(-17, 5, -16, 16)
      ..lineTo(-6, 11)
      ..moveTo(7, -1)
      ..quadraticBezierTo(17, 5, 16, 16)
      ..lineTo(6, 11);
    canvas.drawPath(fins, fill(mint));
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(-6, 10, 12, 6),
        const Radius.circular(2),
      ),
      fill(deepPurple),
    );
    final body = Path()
      ..moveTo(0, -23)
      ..cubicTo(10, -16, 13, 1, 7, 12)
      ..quadraticBezierTo(0, 15, -7, 12)
      ..cubicTo(-13, 1, -10, -16, 0, -23)
      ..close();
    canvas.drawPath(
      body,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            lightPurple.withValues(alpha: reveal),
            color.withValues(alpha: reveal),
            deepPurple.withValues(alpha: reveal),
          ],
          stops: const [0, .5, 1],
        ).createShader(const Rect.fromLTWH(-11, -23, 22, 38)),
    );
    canvas.drawPath(
      Path()
        ..moveTo(-3, -15)
        ..quadraticBezierTo(-7, -8, -7, -1),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.4
        ..strokeCap = StrokeCap.round
        ..color = Colors.white.withValues(alpha: .48 * reveal),
    );
    canvas.drawCircle(const Offset(0, -4), 6, fill(lightPurple));
    canvas.drawCircle(
      const Offset(0, -4),
      4.5,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFFC9FFF1).withValues(alpha: reveal),
            mint.withValues(alpha: reveal),
          ],
        ).createShader(const Rect.fromLTWH(-5, -9, 10, 10)),
    );
    canvas.drawCircle(const Offset(-1.3, -5.5), 1.3, fill(Colors.white));
    canvas.restore();
  }

  @override
  bool shouldRepaint(WordFlightPainter old) =>
      old.progress != progress ||
      old.start != start ||
      old.end != end ||
      old.color != color;
}
