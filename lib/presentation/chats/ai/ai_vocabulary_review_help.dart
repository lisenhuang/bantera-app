import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';

/// An illustration of spaced review, not a prediction of a learner's memory.
class AiVocabularyReviewHelp extends StatelessWidget {
  const AiVocabularyReviewHelp({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return AlertDialog(
      title: Text(l.vocabReviewHelpTitle),
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      scrollable: true,
      content: SizedBox(
        width: 440,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(l.vocabReviewHelpBody),
            const SizedBox(height: 24),
            Text(l.vocabReviewMemory, style: theme.textTheme.labelLarge),
            const SizedBox(height: 8),
            ExcludeSemantics(
              child: SizedBox(
                height: 150,
                width: double.infinity,
                child: CustomPaint(
                  key: const ValueKey('vocabulary-review-chart'),
                  painter: _ReviewChartPainter(
                    review: colors.primary,
                    fading: colors.onSurfaceVariant,
                    axis: colors.outlineVariant,
                  ),
                ),
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: Text(l.vocabReviewTime, style: theme.textTheme.labelLarge),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 16,
              runSpacing: 8,
              children: [
                _Legend(
                  label: l.vocabReviewWithout,
                  color: colors.onSurfaceVariant,
                  dashed: true,
                ),
                _Legend(label: l.vocabReviewWith, color: colors.primary),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              l.vocabReviewIllustration,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),
            Text(l.vocabReviewScheduleTitle, style: theme.textTheme.titleSmall),
            const SizedBox(height: 8),
            Text(l.vocabReviewScheduleBody),
            const SizedBox(height: 16),
            Text(l.vocabReviewDueNote),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l.vocabReviewGotIt),
        ),
      ],
    );
  }
}

class _Legend extends StatelessWidget {
  const _Legend({
    required this.label,
    required this.color,
    this.dashed = false,
  });
  final String label;
  final Color color;
  final bool dashed;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      ExcludeSemantics(
        child: SizedBox(
          width: 24,
          child: Row(
            children: [
              for (var i = 0; i < (dashed ? 3 : 1); i++)
                Container(
                  width: dashed ? 6 : 24,
                  height: 3,
                  margin: EdgeInsets.only(right: dashed ? 2 : 0),
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
            ],
          ),
        ),
      ),
      const SizedBox(width: 8),
      Flexible(
        child: Text(label, style: Theme.of(context).textTheme.labelMedium),
      ),
    ],
  );
}

class _ReviewChartPainter extends CustomPainter {
  const _ReviewChartPainter({
    required this.review,
    required this.fading,
    required this.axis,
  });
  final Color review, fading, axis;

  @override
  void paint(Canvas canvas, Size size) {
    final plot = Rect.fromLTRB(3, 6, size.width - 6, size.height - 6);
    Offset at(double x, double y) =>
        Offset(plot.left + x * plot.width, plot.bottom - y * plot.height);
    final axes = Paint()
      ..color = axis
      ..strokeWidth = 1.5;
    canvas.drawLine(at(0, 1), at(0, 0), axes);
    canvas.drawLine(at(0, 0), at(1, 0), axes);

    // Both curves have the SAME initial decline until the first review.
    // The unitless axes intentionally make no percentage or timing claims.
    Path initial() {
      final start = at(0, .91),
          c1 = at(.04, .65),
          c2 = at(.12, .38),
          end = at(.20, .30);
      return Path()
        ..moveTo(start.dx, start.dy)
        ..cubicTo(c1.dx, c1.dy, c2.dx, c2.dy, end.dx, end.dy);
    }

    final noReview = initial();
    final n1 = at(.35, .12), n2 = at(.58, .07), n3 = at(1, .07);
    noReview.cubicTo(n1.dx, n1.dy, n2.dx, n2.dy, n3.dx, n3.dy);
    final dashed = Paint()
      ..color = fading
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;
    for (final metric in noReview.computeMetrics()) {
      for (double start = 0; start < metric.length; start += 10) {
        canvas.drawPath(
          metric.extractPath(start, (start + 4).clamp(0, metric.length)),
          dashed,
        );
      }
    }
    final withReview = initial();
    for (final segment in [
      [.20, .88, .27, .67, .40, .48, .48, .46],
      [.48, .90, .56, .75, .71, .64, .78, .62],
      [.78, .92, .84, .86, .94, .82, 1.0, .81],
    ]) {
      final peak = at(segment[0], segment[1]);
      final a = at(segment[2], segment[3]),
          b = at(segment[4], segment[5]),
          end = at(segment[6], segment[7]);
      withReview.lineTo(peak.dx, peak.dy);
      withReview.cubicTo(a.dx, a.dy, b.dx, b.dy, end.dx, end.dy);
      canvas.drawCircle(peak, 3.5, Paint()..color = review);
    }
    canvas.drawPath(
      withReview,
      Paint()
        ..color = review
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..strokeJoin = StrokeJoin.round
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(_ReviewChartPainter oldDelegate) =>
      review != oldDelegate.review ||
      fading != oldDelegate.fading ||
      axis != oldDelegate.axis;
}
