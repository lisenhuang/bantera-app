import 'package:flutter/material.dart';
import 'practice_level_help.dart';
import '../../l10n/app_localizations.dart';

const practiceLevels = ['A0', 'A1', 'A2', 'B1', 'B2', 'C1', 'C2'];

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
    final l = AppLocalizations.of(context)!;
    return OutlinedButton(
      key: const ValueKey('practice-level-menu'),
      onPressed: onSelected == null ? null : () => _showLevels(context),
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(0, 48),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        shape: const StadiumBorder(),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(child: Text(l.audioLevelSection)),
          const SizedBox(width: 8),
          Text(
            level,
            key: const ValueKey('practice-level'),
            textDirection: TextDirection.ltr,
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          const SizedBox(width: 6),
          const Icon(Icons.keyboard_arrow_down_rounded, size: 20),
        ],
      ),
    );
  }

  Future<void> _showLevels(BuildContext context) async {
    final l = AppLocalizations.of(context)!;
    final selected = await showModalBottomSheet<String>(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheetContext) {
        final theme = Theme.of(sheetContext), c = theme.colorScheme;
        return ConstrainedBox(
          key: const ValueKey('practice-level-sheet'),
          constraints: BoxConstraints(
            maxHeight: MediaQuery.sizeOf(sheetContext).height * .85,
            maxWidth: 600,
          ),
          child: SafeArea(
            top: false,
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Semantics(
                          header: true,
                          child: Text(
                            l.quickChooseLevel,
                            style: theme.textTheme.titleLarge,
                          ),
                        ),
                      ),
                      IconButton(
                        tooltip: l.closeLabel,
                        onPressed: () => Navigator.pop(sheetContext),
                        icon: const Icon(Icons.close_rounded),
                      ),
                    ],
                  ),
                  Text(
                    l.quickCurrentLevel(currentLevel),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: c.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 16),
                  for (final candidate in practiceLevels)
                    ListTile(
                      key: ValueKey('practice-level-option-$candidate'),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      selected: candidate == level,
                      selectedTileColor: c.primary.withValues(alpha: .08),
                      title: Text(
                        candidate,
                        textDirection: TextDirection.ltr,
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
                      subtitle: candidate == 'A0' ? Text(l.quickA0Label) : null,
                      trailing:
                          practiceLevels.indexOf(candidate) >
                              practiceLevels.indexOf(currentLevel)
                          ? Icon(
                              Icons.lock_outline_rounded,
                              size: 20,
                              color: c.onSurface.withValues(alpha: .38),
                              semanticLabel: l.quickLevelLocked,
                            )
                          : candidate == level
                          ? Icon(Icons.check_rounded, color: c.primary)
                          : null,
                      onTap: () => Navigator.pop(sheetContext, candidate),
                    ),
                  const SizedBox(height: 8),
                  const Divider(),
                  TextButton.icon(
                    key: const ValueKey('practice-level-help-link'),
                    onPressed: () => Navigator.pop(sheetContext, '_help'),
                    icon: const Icon(Icons.help_outline_rounded, size: 20),
                    label: Text(l.quickLevelsLink, textAlign: TextAlign.center),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
    if (!context.mounted || selected == null) return;
    if (selected == '_help') {
      await showPracticeLevelHelp(context);
    } else {
      onSelected?.call(selected);
    }
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
