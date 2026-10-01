import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../domain/activity/word_activity.dart';
import '../../l10n/app_localizations.dart';
import 'word_activity_trend.dart';
import 'word_activity_visuals.dart';

class WordActivitySection extends StatelessWidget {
  const WordActivitySection({
    super.key,
    required this.today,
    required this.week,
    required this.total,
    this.history = const {},
    this.now,
    this.onShare,
  });
  final WordTotals today;
  final WordTotals week;
  final WordTotals total;
  final Map<String, WordTotals> history;
  final DateTime? now;
  final VoidCallback? onShare;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final number = NumberFormat.decimalPattern(
      Localizations.localeOf(context).toLanguageTag(),
    );
    final theme = Theme.of(context);
    final periods = [
      (id: 'today', label: l10n.wordActivityToday, totals: today),
      (id: 'week', label: l10n.wordActivityThisWeek, totals: week),
      (id: 'total', label: l10n.wordActivityTotal, totals: total),
    ];
    final countStyle = theme.textTheme.titleLarge!.copyWith(
      fontSize: 22,
      fontWeight: FontWeight.w800,
      fontFeatures: const [FontFeature.tabularFigures()],
    );
    Widget heading(bool listening) => Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        children: [
          ActivityIcon(listening: listening, size: 32),
          const SizedBox(height: 6),
          Text(
            listening ? l10n.wordActivityListening : l10n.wordActivitySpeaking,
            textAlign: TextAlign.center,
            style: theme.textTheme.labelMedium,
          ),
        ],
      ),
    );
    Widget value(String period, WordTotals totals, bool listening) {
      final count = listening ? totals.listened : totals.spoken;
      return Semantics(
        container: true,
        label: listening
            ? l10n.wordActivityListeningSummary(
                period,
                number.format(count),
                count,
              )
            : l10n.wordActivitySpeakingSummary(
                period,
                number.format(count),
                count,
              ),
        child: ExcludeSemantics(
          child: Text(
            number.format(count),
            textAlign: TextAlign.center,
            style: countStyle.copyWith(
              color: activityColor(context, listening: listening),
            ),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  l10n.wordActivityTitle,
                  style: theme.textTheme.titleLarge,
                ),
              ),
              if (onShare != null)
                Flexible(
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: TextButton.icon(
                      onPressed: onShare,
                      icon: const Icon(Icons.ios_share, size: 18),
                      label: Text(l10n.wordActivityShare),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Card(
            margin: EdgeInsets.zero,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(
                color: theme.colorScheme.outlineVariant.withValues(alpha: .6),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  double width(String text, TextStyle style) {
                    final painter = TextPainter(
                      text: TextSpan(text: text, style: style),
                      textDirection: Directionality.of(context),
                      textScaler: MediaQuery.textScalerOf(context),
                    )..layout();
                    final result = painter.width;
                    painter.dispose();
                    return result;
                  }

                  final labelWidth = periods
                      .map((p) => width(p.label, theme.textTheme.labelLarge!))
                      .reduce((a, b) => a > b ? a : b);
                  final countWidth = periods
                      .expand((p) => [p.totals.listened, p.totals.spoken])
                      .map((v) => width(number.format(v), countStyle))
                      .reduce((a, b) => a > b ? a : b);
                  // Keep exact numbers legible at large accessibility sizes. The
                  // table becomes labeled rows instead of shrinking or truncating.
                  final tableFits =
                      labelWidth + 24 + (countWidth + 16) * 2 <=
                      constraints.maxWidth;
                  if (!tableFits) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        for (final period in periods) ...[
                          Text(
                            period.label,
                            style: theme.textTheme.titleMedium,
                          ),
                          const SizedBox(height: 8),
                          for (final listening in [true, false])
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 6),
                              child: Row(
                                children: [
                                  ActivityIcon(listening: listening, size: 32),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          listening
                                              ? l10n.wordActivityListening
                                              : l10n.wordActivitySpeaking,
                                          style: theme.textTheme.labelMedium,
                                        ),
                                        value(
                                          period.id,
                                          period.totals,
                                          listening,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          if (period.id != 'total') const Divider(height: 24),
                        ],
                      ],
                    );
                  }
                  return Table(
                    columnWidths: {
                      0: FixedColumnWidth(labelWidth + 24),
                      1: const FlexColumnWidth(),
                      2: const FlexColumnWidth(),
                    },
                    defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                    children: [
                      TableRow(
                        children: [
                          Text(
                            l10n.wordActivityWords,
                            style: theme.textTheme.labelSmall,
                          ),
                          heading(true),
                          heading(false),
                        ],
                      ),
                      for (final period in periods)
                        TableRow(
                          decoration: BoxDecoration(
                            color: period.id == 'today'
                                ? theme.colorScheme.primary.withValues(
                                    alpha: .05,
                                  )
                                : null,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 16,
                                horizontal: 8,
                              ),
                              child: Text(
                                period.label,
                                style: theme.textTheme.labelLarge,
                              ),
                            ),
                            value(period.id, period.totals, true),
                            value(period.id, period.totals, false),
                          ],
                        ),
                    ],
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 20),
          WordActivityTrend(history: history, now: now ?? DateTime.now()),
          const SizedBox(height: 12),
          Text(l10n.wordActivityHint, style: theme.textTheme.bodySmall),
        ],
      ),
    );
  }
}
