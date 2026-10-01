import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../domain/activity/word_activity.dart';
import '../../l10n/app_localizations.dart';
import 'word_activity_visuals.dart';

/// Calendar-day samples: missing days are zero, future data is never plotted.
List<({DateTime date, WordTotals totals})> activityTrendDays(
  Map<String, WordTotals> history,
  DateTime now,
  int? days,
) {
  final end = DateTime(now.year, now.month, now.day);
  var start = end;
  if (days != null) {
    start = DateTime(end.year, end.month, end.day - days + 1);
  } else {
    for (final key in history.keys) {
      final date = DateTime.tryParse(key);
      if (date != null && date.isBefore(start)) start = date;
    }
  }
  return [
    for (
      var day = start;
      !day.isAfter(end);
      day = DateTime(day.year, day.month, day.day + 1)
    )
      (
        date: day,
        totals: history[wordActivityDateKey(day)] ?? const WordTotals(),
      ),
  ];
}

class WordActivityTrend extends StatefulWidget {
  const WordActivityTrend({
    super.key,
    required this.history,
    required this.now,
  });
  final Map<String, WordTotals> history;
  final DateTime now;
  @override
  State<WordActivityTrend> createState() => _WordActivityTrendState();
}

class _WordActivityTrendState extends State<WordActivityTrend> {
  int? _days = 7;
  String? _selectedDate;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).toLanguageTag();
    final number = NumberFormat.decimalPattern(locale);
    final theme = Theme.of(context);
    final points = activityTrendDays(widget.history, widget.now, _days);
    var selected = points.indexWhere(
      (p) => wordActivityDateKey(p.date) == _selectedDate,
    );
    if (selected < 0) selected = points.length - 1;
    final current = points[selected];
    final maximum = points.fold<int>(
      0,
      (max, p) => math.max(max, math.max(p.totals.listened, p.totals.spoken)),
    );
    void select(int index) =>
        setState(() => _selectedDate = wordActivityDateKey(points[index].date));
    Widget metric(bool listening) => Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ActivityIcon(listening: listening, size: 28),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            '${listening ? l10n.wordActivityListening : l10n.wordActivitySpeaking}  ${number.format(listening ? current.totals.listened : current.totals.spoken)}',
            style: theme.textTheme.labelLarge,
          ),
        ),
      ],
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(l10n.wordActivityTrend, style: theme.textTheme.titleMedium),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: [
            for (final range in [
              (days: 7, label: l10n.wordActivitySevenDays),
              (days: 30, label: l10n.wordActivityThirtyDays),
              (days: null, label: l10n.wordActivityAllTime),
            ])
              ChoiceChip(
                label: Text(range.label),
                selected: _days == range.days,
                showCheckmark: false,
                onSelected: (_) => setState(() {
                  _days = range.days;
                  _selectedDate = null;
                }),
              ),
          ],
        ),
        const SizedBox(height: 8),
        if (maximum == 0)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Text(
              l10n.wordActivityTrendEmpty,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium,
            ),
          )
        else ...[
          Row(
            children: [
              IconButton(
                onPressed: selected > 0 ? () => select(selected - 1) : null,
                tooltip: MaterialLocalizations.of(context).previousPageTooltip,
                icon: const Icon(Icons.chevron_left),
              ),
              Expanded(
                child: Text(
                  DateFormat.yMMMd(locale).format(current.date),
                  textAlign: TextAlign.center,
                  style: theme.textTheme.labelLarge,
                ),
              ),
              IconButton(
                onPressed: selected < points.length - 1
                    ? () => select(selected + 1)
                    : null,
                tooltip: MaterialLocalizations.of(context).nextPageTooltip,
                icon: const Icon(Icons.chevron_right),
              ),
            ],
          ),
          Wrap(
            spacing: 20,
            runSpacing: 8,
            children: [metric(true), metric(false)],
          ),
          const SizedBox(height: 14),
          Text(
            '${l10n.wordActivityWords} · ${number.format(maximum)}',
            style: theme.textTheme.labelSmall,
          ),
          const SizedBox(height: 4),
          LayoutBuilder(
            builder: (context, constraints) => GestureDetector(
              key: const ValueKey('activity-trend-plot'),
              behavior: HitTestBehavior.opaque,
              onTapDown: (details) {
                final fraction =
                    ((details.localPosition.dx - 6) /
                            (constraints.maxWidth - 12))
                        .clamp(0.0, 1.0);
                select((fraction * (points.length - 1)).round());
              },
              child: ExcludeSemantics(
                child: CustomPaint(
                  size: Size(constraints.maxWidth, 140),
                  painter: _TrendPainter(
                    values: points.map((p) => p.totals).toList(),
                    maximum: maximum,
                    selected: selected,
                    listening: activityColor(context, listening: true),
                    speaking: activityColor(context, listening: false),
                    grid: theme.colorScheme.outlineVariant,
                  ),
                ),
              ),
            ),
          ),
          Text('0', style: theme.textTheme.labelSmall),
        ],
        Row(
          children: [
            Expanded(
              child: Text(
                DateFormat.MMMd(locale).format(points.first.date),
                style: theme.textTheme.labelSmall,
              ),
            ),
            Expanded(
              child: Text(
                DateFormat.MMMd(locale).format(points.last.date),
                textAlign: TextAlign.end,
                style: theme.textTheme.labelSmall,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _TrendPainter extends CustomPainter {
  _TrendPainter({
    required this.values,
    required this.maximum,
    required this.selected,
    required this.listening,
    required this.speaking,
    required this.grid,
  });
  final List<WordTotals> values;
  final int maximum;
  final int selected;
  final Color listening, speaking, grid;

  @override
  void paint(Canvas canvas, Size size) {
    final width = size.width - 12;
    final height = size.height - 12;
    double x(int index) =>
        6 +
        (values.length == 1 ? width / 2 : width * index / (values.length - 1));
    double y(int value) => 6 + height * (1 - value / maximum);
    final guide = Paint()
      ..color = grid.withValues(alpha: .6)
      ..strokeWidth = 1;
    for (final fraction in [0.0, .5, 1.0]) {
      canvas.drawLine(
        Offset(6, 6 + height * fraction),
        Offset(size.width - 6, 6 + height * fraction),
        guide,
      );
    }
    canvas.drawLine(
      Offset(x(selected), 0),
      Offset(x(selected), size.height),
      guide,
    );
    for (final isListening in [true, false]) {
      final paint = Paint()
        ..color = isListening ? listening : speaking
        ..strokeWidth = 2.5
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;
      final path = Path();
      for (var i = 0; i < values.length; i++) {
        final point = Offset(
          x(i),
          y(isListening ? values[i].listened : values[i].spoken),
        );
        if (i == 0) {
          path.moveTo(point.dx, point.dy);
        } else {
          path.lineTo(point.dx, point.dy);
        }
      }
      if (isListening) {
        canvas.drawPath(path, paint);
      } else {
        // Dashed speaking line also distinguishes the series without color.
        for (final metric in path.computeMetrics()) {
          for (double distance = 0; distance < metric.length; distance += 9) {
            canvas.drawPath(
              metric.extractPath(
                distance,
                math.min(distance + 5, metric.length),
              ),
              paint,
            );
          }
        }
      }
      final point = Offset(
        x(selected),
        y(isListening ? values[selected].listened : values[selected].spoken),
      );
      paint.style = PaintingStyle.fill;
      if (isListening) {
        canvas.drawCircle(point, 4, paint);
      } else {
        canvas.drawRect(
          Rect.fromCenter(center: point, width: 7, height: 7),
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _TrendPainter oldDelegate) => true;
}
