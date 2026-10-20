import 'package:flutter/material.dart';
import 'practice_level_help.dart';
import '../../l10n/app_localizations.dart';

const practiceLevels = ['A1', 'A2', 'B1', 'B2', 'C1', 'C2'];

/// Locked entries remain actionable so people can learn how to unlock them.
class PracticeLevelMenu extends StatelessWidget {
  const PracticeLevelMenu({
    super.key,
    required this.level,
    required this.currentLevel,
    required this.onSelected,
  });
  final String level, currentLevel;
  final ValueChanged<String>? onSelected;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!, c = Theme.of(context).colorScheme;
    return PopupMenuButton<String>(
      key: const ValueKey('practice-level-menu'),
      enabled: onSelected != null,
      tooltip: l.quickChooseLevel,
      position: PopupMenuPosition.under,
      constraints: const BoxConstraints(minWidth: 220, maxWidth: 280),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      onSelected: (value) {
        if (value == '_help') {
          showPracticeLevelHelp(context);
        } else {
          onSelected?.call(value);
        }
      },
      itemBuilder: (_) => [
        PopupMenuItem<String>(
          enabled: false,
          child: Text(
            l.quickCurrentLevel(currentLevel),
            style: TextStyle(color: c.onSurfaceVariant),
          ),
        ),
        const PopupMenuDivider(),
        for (final candidate in practiceLevels)
          PopupMenuItem<String>(
            key: ValueKey('practice-level-option-$candidate'),
            value: candidate,
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    candidate,
                    style: TextStyle(
                      color:
                          practiceLevels.indexOf(candidate) >
                              practiceLevels.indexOf(currentLevel)
                          ? c.onSurface.withValues(alpha: .38)
                          : candidate == level
                          ? c.primary
                          : c.onSurface,
                      fontWeight: candidate == level
                          ? FontWeight.w700
                          : FontWeight.w500,
                    ),
                  ),
                ),
                if (practiceLevels.indexOf(candidate) >
                    practiceLevels.indexOf(currentLevel))
                  Icon(
                    Icons.lock_outline_rounded,
                    size: 18,
                    color: c.onSurface.withValues(alpha: .38),
                    semanticLabel: l.quickLevelLocked,
                  )
                else if (candidate == level)
                  Icon(Icons.check_rounded, size: 20, color: c.primary),
              ],
            ),
          ),
        const PopupMenuDivider(),
        PopupMenuItem<String>(
          key: const ValueKey('practice-level-help-link'),
          value: '_help',
          child: Row(
            children: [
              Icon(
                Icons.help_outline_rounded,
                size: 20,
                color: c.onSurfaceVariant,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  l.quickLevelsLink,
                  style: TextStyle(color: c.onSurfaceVariant),
                ),
              ),
            ],
          ),
        ),
      ],
      child: Center(
        child: Container(
          key: const ValueKey('practice-level'),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: c.primary.withValues(alpha: .08),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: c.primary.withValues(alpha: .18)),
          ),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              level,
              textDirection: TextDirection.ltr,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: c.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

Future<bool> confirmPracticeLevel(
  BuildContext context, {
  required String selected,
  required String current,
}) async {
  final l = AppLocalizations.of(context)!;
  final locked =
      practiceLevels.indexOf(selected) > practiceLevels.indexOf(current);
  return await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(
            locked ? l.quickLevelLocked : l.quickSwitchLevel(selected),
          ),
          content: Text(
            locked
                ? l.quickLevelLockedBody(selected, current)
                : selected == current
                ? l.quickReturnLevelBody
                : l.quickReviewLevelBody(current),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(locked ? l.closeLabel : l.cancel),
            ),
            if (!locked)
              FilledButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text(l.continueLabel),
              ),
          ],
        ),
      ) ??
      false;
}
