import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart' show NumberFormat;

import '../../domain/activity/daily_word_goal.dart';
import '../../domain/activity/word_activity.dart';
import '../../l10n/app_localizations.dart';

/// Caps each target separately: excess listening cannot complete speaking.
double? practiceGoalProgress(DailyWordGoal? goal, WordTotals today) {
  if (goal == null || !goal.isValid || goal.listened + goal.spoken == 0) {
    return null;
  }
  return (today.listened.clamp(0, goal.listened) +
          today.spoken.clamp(0, goal.spoken)) /
      (goal.listened + goal.spoken);
}

class PracticeHeader extends StatelessWidget implements PreferredSizeWidget {
  const PracticeHeader({
    super.key,
    required this.goal,
    required this.today,
    required this.onGoalPressed,
    this.goalAnchor,
    this.onLongerDialogues,
  });
  final DailyWordGoal? goal;
  final WordTotals today;
  final VoidCallback? onGoalPressed;
  final Key? goalAnchor;
  final VoidCallback? onLongerDialogues;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final target = practiceGoalProgress(goal, today) ?? 0;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: target, end: target),
      duration: MediaQuery.disableAnimationsOf(context)
          ? Duration.zero
          : const Duration(milliseconds: 800),
      curve: Curves.easeOutCubic,
      builder: (context, value, _) => _bar(context, value),
    );
  }

  Widget _bar(BuildContext context, double animatedProgress) => AppBar(
    key: const ValueKey('practice-header-bar'),
    automaticallyImplyLeading: false,
    titleSpacing: 16,
    title: LayoutBuilder(
      builder: (context, constraints) {
        final l = AppLocalizations.of(context)!;
        final theme = Theme.of(context), c = theme.colorScheme;
        final progress = practiceGoalProgress(goal, today) == null
            ? null
            : animatedProgress;
        // Never round an unfinished goal up to 100.0%.
        final display = progress == null
            ? 0.0
            : progress < 1
            ? math.min(progress, .999)
            : 1.0;
        final percent = NumberFormat.decimalPercentPattern(
          locale: Localizations.localeOf(context).toLanguageTag(),
          decimalDigits: 1,
        ).format(display);
        const side = 48.0;
        const buttonSize = 48.0;
        final titleStyle =
            theme.appBarTheme.titleTextStyle ?? theme.textTheme.titleLarge;
        final title = Text(
          l.navPractice,
          key: const ValueKey('practice-title'),
          textAlign: TextAlign.center,
          style: titleStyle,
        );
        final goalControl = SizedBox(
          width: side,
          height: buttonSize,
          child: Align(
            alignment: AlignmentDirectional.centerEnd,
            child: SizedBox(
              key: goalAnchor,
              width: buttonSize,
              height: buttonSize,
              child: progress == null
                  ? Semantics(
                      button: true,
                      label: l.dailyGoalSet,
                      child: Tooltip(
                        message: l.dailyGoalSet,
                        child: Material(
                          color: c.primary,
                          borderRadius: BorderRadius.circular(14),
                          child: InkWell(
                            key: const ValueKey('practice-set-goal'),
                            onTap: onGoalPressed,
                            borderRadius: BorderRadius.circular(14),
                            child: Padding(
                              padding: const EdgeInsets.all(5),
                              child: ExcludeSemantics(
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: SizedBox(
                                    width: 38,
                                    child: Text(
                                      l.quickSetGoal,
                                      textAlign: TextAlign.center,
                                      style: theme.textTheme.labelSmall
                                          ?.copyWith(
                                            color: c.onPrimary,
                                            fontWeight: FontWeight.w700,
                                          ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    )
                  : Semantics(
                      button: true,
                      label: l.dailyGoalTitle,
                      value: percent,
                      child: Tooltip(
                        message: l.dailyGoalEdit,
                        child: InkWell(
                          key: const ValueKey('practice-goal-ring'),
                          onTap: onGoalPressed,
                          borderRadius: BorderRadius.circular(buttonSize / 2),
                          child: ExcludeSemantics(
                            child: SizedBox(
                              height: buttonSize,
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  Positioned.fill(
                                    child: Padding(
                                      padding: const EdgeInsets.all(3),
                                      child: CircularProgressIndicator(
                                        value: progress,
                                        strokeWidth: 3,
                                        strokeCap: StrokeCap.round,
                                        backgroundColor: c.primary.withValues(
                                          alpha: .12,
                                        ),
                                        color: progress >= 1
                                            ? (theme.brightness ==
                                                      Brightness.dark
                                                  ? c.secondary
                                                  : const Color(0xFF007D62))
                                            : c.primary,
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(7),
                                    child: FittedBox(
                                      fit: BoxFit.scaleDown,
                                      child: Text(
                                        percent,
                                        key: const ValueKey(
                                          'practice-goal-percent',
                                        ),
                                        style: theme.textTheme.labelSmall
                                            ?.copyWith(
                                              fontWeight: FontWeight.w800,
                                              fontFeatures: const [
                                                FontFeature.tabularFigures(),
                                              ],
                                            ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
            ),
          ),
        );
        return SizedBox(
          height: buttonSize,
          child: Row(
            children: [
              goalControl,
              Expanded(
                child: Center(
                  child: FittedBox(fit: BoxFit.scaleDown, child: title),
                ),
              ),
              SizedBox(
                width: buttonSize,
                height: buttonSize,
                child: PopupMenuButton<String>(
                  key: const ValueKey('practice-more-menu'),
                  enabled: onLongerDialogues != null,
                  tooltip: l.more,
                  icon: const Icon(Icons.more_horiz),
                  position: PopupMenuPosition.under,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  onSelected: (_) => onLongerDialogues?.call(),
                  itemBuilder: (_) => [
                    PopupMenuItem(
                      value: 'dialogues',
                      child: Text(l.longerDialogues),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    ),
  );
}
