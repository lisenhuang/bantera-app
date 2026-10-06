import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../infrastructure/practice_progress_store.dart';
import '../../l10n/app_localizations.dart';

/// Three large, labelled destinations; the recent lesson makes history useful
/// before opening it. Rows wrap naturally with larger accessibility text.
class ProfileLibrarySection extends StatelessWidget {
  const ProfileLibrarySection({
    super.key,
    required this.savedCount,
    required this.cueCount,
    required this.historyCount,
    required this.recent,
    required this.onSavedMedia,
    required this.onSavedCues,
    required this.onHistory,
  });

  final int? savedCount;
  final int cueCount;
  final int? historyCount;
  final PracticeHistoryEntry? recent;
  final VoidCallback onSavedMedia;
  final VoidCallback onSavedCues;
  final VoidCallback onHistory;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = Theme.of(context).colorScheme;
    final number = NumberFormat.decimalPattern(
      Localizations.localeOf(context).toLanguageTag(),
    );
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l10n.profileLibraryTitle,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          _LibraryCard(
            icon: Icons.history_rounded,
            title: l10n.practiceHistoryTitle,
            subtitle: l10n.practiceHistorySubtitle,
            count: historyCount == null ? null : number.format(historyCount),
            onTap: onHistory,
            featured: true,
            child: recent == null
                ? null
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Divider(
                        height: 25,
                        color: colors.primary.withValues(alpha: .15),
                      ),
                      Text(
                        recent!.mediaItem.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      const SizedBox(height: 8),
                      LinearProgressIndicator(
                        value: recent!.progress,
                        minHeight: 5,
                        borderRadius: BorderRadius.circular(6),
                        backgroundColor: colors.primary.withValues(alpha: .12),
                      ),
                      const SizedBox(height: 7),
                      Text(
                        l10n.practiceHistoryProgress(
                          number.format(recent!.completedCues),
                          number.format(recent!.totalCues),
                        ),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
          ),
          const SizedBox(height: 10),
          _LibraryCard(
            icon: Icons.video_library_outlined,
            title: l10n.savedTitle,
            subtitle: l10n.profileSavedMediaSubtitle,
            count: savedCount == null ? null : number.format(savedCount),
            onTap: onSavedMedia,
          ),
          const SizedBox(height: 10),
          _LibraryCard(
            icon: Icons.format_quote_rounded,
            title: l10n.savedCuesTitle,
            subtitle: l10n.profileSavedCuesSubtitle,
            count: number.format(cueCount),
            onTap: onSavedCues,
          ),
        ],
      ),
    );
  }
}

class _LibraryCard extends StatelessWidget {
  const _LibraryCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.count,
    required this.onTap,
    this.featured = false,
    this.child,
  });
  final IconData icon;
  final String title;
  final String subtitle;
  final String? count;
  final VoidCallback onTap;
  final bool featured;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Material(
      color: featured
          ? Color.alphaBlend(
              colors.primary.withValues(alpha: .07),
              colors.surface,
            )
          : colors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: featured
              ? colors.primary.withValues(alpha: .22)
              : colors.outlineVariant.withValues(alpha: .65),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: colors.primary.withValues(alpha: .1),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(icon, color: colors.primary, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: Theme.of(context).textTheme.titleSmall
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          subtitle,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: colors.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (count != null)
                    Text(
                      count!,
                      style: Theme.of(
                        context,
                      ).textTheme.titleSmall?.copyWith(color: colors.primary),
                    ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.chevron_right_rounded,
                    size: 20,
                    color: colors.onSurfaceVariant,
                  ),
                ],
              ),
              ?child,
            ],
          ),
        ),
      ),
    );
  }
}
