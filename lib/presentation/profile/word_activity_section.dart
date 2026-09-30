import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../domain/activity/word_activity.dart';
import '../../l10n/app_localizations.dart';

class WordActivitySection extends StatelessWidget {
  const WordActivitySection({
    super.key,
    required this.today,
    required this.week,
    required this.total,
    this.onShare,
  });
  final WordTotals today;
  final WordTotals week;
  final WordTotals total;
  final VoidCallback? onShare;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final number = NumberFormat.decimalPattern(
      Localizations.localeOf(context).toLanguageTag(),
    );
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
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              if (onShare != null)
                Flexible(
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: TextButton.icon(
                      onPressed: onShare,
                      icon: const Icon(Icons.ios_share),
                      label: Text(l10n.wordActivityShare),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          for (final period in [
            (label: l10n.wordActivityToday, totals: today),
            (label: l10n.wordActivityThisWeek, totals: week),
            (label: l10n.wordActivityTotal, totals: total),
          ])
            Card(
              margin: const EdgeInsets.only(bottom: 10),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      period.label,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 12),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final listened = number.format(period.totals.listened);
                        final spoken = number.format(period.totals.spoken);
                        final countStyle = Theme.of(
                          context,
                        ).textTheme.titleLarge;
                        double widthFor(String value, {TextStyle? style}) {
                          final painter = TextPainter(
                            text: TextSpan(
                              text: value,
                              style: style ?? countStyle,
                            ),
                            textDirection: Directionality.of(context),
                            textScaler: MediaQuery.textScalerOf(context),
                          )..layout();
                          final width = painter.width;
                          painter.dispose();
                          return width;
                        }

                        final counts = [
                          _Count(
                            icon: Icons.headphones_outlined,
                            label: l10n.wordActivityListened,
                            value: listened,
                          ),
                          _Count(
                            icon: Icons.mic_none_outlined,
                            label: l10n.wordActivitySpoken,
                            value: spoken,
                          ),
                        ];
                        final columnWidth = (constraints.maxWidth - 12) / 2;
                        if (widthFor(listened) > columnWidth ||
                            widthFor(spoken) > columnWidth ||
                            widthFor(
                                      l10n.wordActivityListened,
                                      style: Theme.of(
                                        context,
                                      ).textTheme.bodyMedium,
                                    ) +
                                    28 >
                                columnWidth ||
                            widthFor(
                                      l10n.wordActivitySpoken,
                                      style: Theme.of(
                                        context,
                                      ).textTheme.bodyMedium,
                                    ) +
                                    28 >
                                columnWidth) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              counts[0],
                              const SizedBox(height: 16),
                              counts[1],
                            ],
                          );
                        }
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(child: counts[0]),
                            const SizedBox(width: 12),
                            Expanded(child: counts[1]),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          Text(
            l10n.wordActivityHint,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}

class _Count extends StatelessWidget {
  const _Count({required this.icon, required this.label, required this.value});
  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        children: [
          Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 8),
          Expanded(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: AlignmentDirectional.centerStart,
              child: Text(
                label,
                maxLines: 1,
                softWrap: false,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          ),
        ],
      ),
      const SizedBox(height: 8),
      Text(value, style: Theme.of(context).textTheme.titleLarge),
    ],
  );
}
