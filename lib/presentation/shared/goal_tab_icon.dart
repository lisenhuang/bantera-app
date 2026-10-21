import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/app_resume_notifier.dart';
import '../../core/user_profile_notifier.dart';
import '../../core/word_activity_notifier.dart';
import '../../domain/activity/daily_word_goal.dart';
import '../../domain/activity/word_activity.dart';
import '../../l10n/app_localizations.dart';
import '../../domain/activity/daily_goal_progress.dart';

/// Keeps the tab current while practice, goal settings or language change.
class LiveGoalTabIcon extends StatelessWidget {
  const LiveGoalTabIcon({super.key});

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: Listenable.merge([
      WordActivityNotifier.instance,
      UserProfileNotifier.instance,
      AppResumeNotifier.instance,
    ]),
    builder: (context, _) {
      final activity = WordActivityNotifier.instance;
      return GoalTabIcon(
        goal: activity.dailyGoal,
        today: activity
            .summaryFor(UserProfileNotifier.instance.learningLanguage)
            .today,
      );
    },
  );
}

class GoalTabIcon extends StatelessWidget {
  const GoalTabIcon({super.key, required this.goal, required this.today});

  final DailyWordGoal? goal;
  final WordTotals today;

  @override
  Widget build(BuildContext context) {
    final progress = dailyGoalProgress(goal, today);
    final l10n = AppLocalizations.of(context)!;
    // Inherit the tab's selected/unselected colour, including its transition.
    final colour =
        IconTheme.of(context).color ?? Theme.of(context).colorScheme.primary;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: progress ?? 0, end: progress ?? 0),
      duration: MediaQuery.disableAnimationsOf(context)
          ? Duration.zero
          : const Duration(milliseconds: 800),
      curve: Curves.easeOutCubic,
      builder: (context, value, _) {
        // Show 100% only when both targets are complete.
        final display = value < 1 ? math.min(value, .999) : 1.0;
        final percent = NumberFormat.decimalPercentPattern(
          locale: Localizations.localeOf(context).toLanguageTag(),
          decimalDigits: display == 0 || display == 1 ? 0 : 1,
        ).format(display);
        return Semantics(
          label: progress == null ? l10n.dailyGoalSet : l10n.dailyGoalTitle,
          value: progress == null ? null : percent,
          child: ExcludeSemantics(
            child: SizedBox.square(
              dimension: 36,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Positioned.fill(
                    child: Padding(
                      padding: const EdgeInsets.all(2),
                      child: CircularProgressIndicator(
                        value: progress == null ? 0 : value,
                        strokeWidth: 2.5,
                        strokeCap: StrokeCap.round,
                        backgroundColor: colour.withValues(alpha: .18),
                        color: colour,
                      ),
                    ),
                  ),
                  if (progress == null)
                    Icon(Icons.add_rounded, size: 18, color: colour)
                  else
                    Padding(
                      padding: const EdgeInsets.all(5),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          percent,
                          key: const ValueKey('goal-tab-percent'),
                          maxLines: 1,
                          style: TextStyle(
                            color: colour,
                            fontSize: 10,
                            height: 1,
                            fontWeight: FontWeight.w800,
                            fontFeatures: const [FontFeature.tabularFigures()],
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
