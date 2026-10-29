import 'package:flutter/material.dart';
import 'practice_level_help.dart';
import 'practice_level_state.dart';
import '../../l10n/app_localizations.dart';
import '../shared/language_code_label.dart';
import '../shared/learning_language_label.dart';
import '../shared/locale_flag.dart';

const practiceLevels = ['A0', 'A1', 'A2', 'B1', 'B2', 'C1', 'C2'];

/// Locked entries remain actionable so people can learn how to unlock them.
class PracticeLevelMenu extends StatelessWidget {
  const PracticeLevelMenu({
    super.key,
    required this.level,
    required this.currentLevel,
    required this.onSelected,
    this.levelStates,
    this.freeSelection = false,
    this.highestUnlockedLevel,
    this.learningLocale,
  });
  final String level, currentLevel;
  final String? learningLocale;
  final bool freeSelection;
  final Map<String, dynamic>? levelStates;
  final String? highestUnlockedLevel;

  String _state(String candidate) => freeSelection
      ? 'practicing'
      : levelStates?[candidate] as String? ??
            (practiceLevels.indexOf(candidate) <
                    practiceLevels.indexOf(currentLevel)
                ? 'passed'
                : candidate == currentLevel
                ? 'practicing'
                : 'locked');
  final ValueChanged<String>? onSelected;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final locale = learningLocale;
    final hasLocale = locale != null && locale.isNotEmpty;
    return Tooltip(
      message: l.quickChooseLevel,
      child: Semantics(
        label:
            '${l.quickChooseLevel}, $level'
            '${hasLocale ? ', ${learningLanguageLabel(locale).name}' : ''}',
        excludeSemantics: true,
        button: true,
        enabled: onSelected != null,
        onTap: onSelected == null ? null : () => _showLevels(context),
        child: TextButton(
          key: const ValueKey('practice-level-menu'),
          onPressed: onSelected == null ? null : () => _showLevels(context),
          style: TextButton.styleFrom(
            minimumSize: const Size(48, 48),
            padding: EdgeInsets.zero,
            shape: const StadiumBorder(),
          ),
          child: Container(
            height: 30,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: .06),
              border: Border.all(
                color: theme.colorScheme.primary.withValues(alpha: .35),
              ),
              borderRadius: BorderRadius.circular(999),
            ),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                textDirection: TextDirection.ltr,
                children: [
                  Text(
                    level,
                    key: const ValueKey('practice-level'),
                    textDirection: TextDirection.ltr,
                    style: theme.textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: onSelected == null
                          ? theme.disabledColor
                          : theme.colorScheme.primary,
                    ),
                  ),
                  if (hasLocale) ...[
                    const SizedBox(width: 4),
                    Row(
                      key: const ValueKey('practice-language-label'),
                      mainAxisSize: MainAxisSize.min,
                      textDirection: TextDirection.ltr,
                      children: [
                        Text(
                          flagEmojiForLocale(locale),
                          style: const TextStyle(fontSize: 16),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          languageCodeLabel(locale),
                          style: Theme.of(context).textTheme.labelMedium
                              ?.copyWith(
                                color: onSelected == null
                                    ? Theme.of(context).disabledColor
                                    : Theme.of(
                                        context,
                                      ).colorScheme.onSurfaceVariant,
                              ),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(width: 4),
                  const Icon(Icons.keyboard_arrow_down_rounded, size: 14),
                ],
              ),
            ),
          ),
        ),
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
                  if (learningLocale != null && learningLocale!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text(
                        learningLanguageLabel(learningLocale).name,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: c.onSurfaceVariant,
                        ),
                      ),
                    ),
                  Text(
                    l.quickCurrentLevel(freeSelection ? level : currentLevel),
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
                          color: _state(candidate) == 'locked'
                              ? c.onSurface.withValues(alpha: .38)
                              : candidate == level
                              ? c.primary
                              : c.onSurface,
                          fontWeight: candidate == level
                              ? FontWeight.w700
                              : FontWeight.w500,
                        ),
                      ),
                      subtitle: Text(
                        [
                          if (candidate == 'A0') l.quickA0Label,
                          if (!freeSelection)
                            practiceLevelStateLabel(l, _state(candidate)),
                        ].join(' · '),
                      ),
                      leading: Icon(
                        freeSelection
                            ? Icons.headphones_outlined
                            : practiceLevelStateIcon(_state(candidate)),
                        color: _state(candidate) == 'locked'
                            ? c.onSurfaceVariant
                            : c.primary,
                      ),
                      trailing: candidate == level
                          ? Icon(Icons.radio_button_checked, color: c.primary)
                          : null,
                      onTap: () => Navigator.pop(sheetContext, candidate),
                    ),
                  const SizedBox(height: 8),
                  const Divider(),
                  if (!freeSelection)
                    TextButton.icon(
                      key: const ValueKey('practice-level-help-link'),
                      onPressed: () => Navigator.pop(sheetContext, '_help'),
                      icon: const Icon(Icons.help_outline_rounded, size: 20),
                      label: Text(
                        l.quickLevelsLink,
                        textAlign: TextAlign.center,
                      ),
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
  String? highestUnlockedLevel,
  bool freeSelection = false,
}) async {
  final l = AppLocalizations.of(context)!;
  final locked =
      !freeSelection &&
      practiceLevels.indexOf(selected) >
          practiceLevels.indexOf(highestUnlockedLevel ?? current);
  return await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(
            locked ? l.quickLevelLocked : l.quickSwitchLevel(selected),
          ),
          content: Text(
            freeSelection
                ? l.quickChooseLevel
                : locked
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
