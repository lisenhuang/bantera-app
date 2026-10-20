import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';

Future<void> showPracticeLevelHelp(BuildContext context) =>
    showModalBottomSheet<void>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      builder: (_) => const PracticeLevelHelp(),
    );

class PracticeLevelHelp extends StatelessWidget {
  const PracticeLevelHelp({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!,
        theme = Theme.of(context),
        c = theme.colorScheme;
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * .85,
        maxWidth: 600,
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Semantics(
                      header: true,
                      child: Text(
                        l.quickLevelsLink,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: l.closeLabel,
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(CupertinoIcons.xmark_circle_fill),
                    color: c.onSurfaceVariant,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                l.quickLevelsIntro,
                style: theme.textTheme.bodyLarge?.copyWith(height: 1.5),
              ),
              const SizedBox(height: 20),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final level in const [
                    'A1',
                    'A2',
                    'B1',
                    'B2',
                    'C1',
                    'C2',
                  ])
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: c.primary.withValues(alpha: .08),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: c.primary.withValues(alpha: .18),
                        ),
                      ),
                      child: Text(
                        level,
                        textDirection: TextDirection.ltr,
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: c.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                l.quickLevelsWindow,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: c.onSurfaceVariant,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                decoration: BoxDecoration(
                  color: c.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 4,
                ),
                child: Column(
                  children: [
                    _rule(context, CupertinoIcons.arrow_up, l.quickLevelsUp),
                    Divider(height: 1, color: c.outlineVariant),
                    _rule(
                      context,
                      CupertinoIcons.arrow_right,
                      l.quickLevelsStay,
                    ),
                    Divider(height: 1, color: c.outlineVariant),
                    _rule(
                      context,
                      CupertinoIcons.arrow_down,
                      l.quickLevelsDown,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Text(
                l.quickLevelsScoring,
                style: theme.textTheme.bodyMedium?.copyWith(height: 1.5),
              ),
              const SizedBox(height: 12),
              Text(
                l.quickLevelsReset,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: c.onSurfaceVariant,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _rule(BuildContext context, IconData icon, String text) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(
        children: [
          ExcludeSemantics(
            child: Icon(icon, size: 20, color: theme.colorScheme.primary),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              text,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
