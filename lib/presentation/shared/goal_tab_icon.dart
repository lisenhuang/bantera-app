import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/app_resume_notifier.dart';
import '../../core/practice_review_service.dart';
import '../../core/user_profile_notifier.dart';
import '../../core/word_activity_notifier.dart';
import '../../domain/activity/daily_word_goal.dart';
import '../../domain/activity/word_activity.dart';
import '../../l10n/app_localizations.dart';
import '../../domain/activity/daily_goal_progress.dart';

const goalProgressAnimationDuration = Duration(milliseconds: 800);

/// Keeps the tab current while practice, goal settings or language change.
class LiveGoalTabIcon extends StatelessWidget {
  const LiveGoalTabIcon({super.key, this.replayTick = 0});

  final int replayTick;

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
        replayTick: replayTick,
        goal: activity.dailyGoal,
        today: activity
            .summaryFor(UserProfileNotifier.instance.learningLanguage)
            .today,
      );
    },
  );
}

class GoalTabIcon extends StatefulWidget {
  const GoalTabIcon({
    super.key,
    required this.goal,
    required this.today,
    this.replayTick = 0,
  });

  final DailyWordGoal? goal;
  final WordTotals today;
  final int replayTick;

  @override
  State<GoalTabIcon> createState() => _GoalTabIconState();
}

class _GoalTabIconState extends State<GoalTabIcon> with RouteAware {
  ModalRoute<dynamic>? _route;
  int _appearance = 0;

  @override
  void initState() {
    super.initState();
    AppResumeNotifier.instance.addListener(_onResume);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route != _route) {
      practiceReviewRouteObserver.unsubscribe(this);
      _route = route;
      if (route != null) practiceReviewRouteObserver.subscribe(this, route);
    }
  }

  void _onResume() {
    if (_route?.isCurrent ?? true) _replay();
  }

  @override
  void didUpdateWidget(covariant GoalTabIcon oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.replayTick != widget.replayTick) _appearance++;
  }

  void _replay() => setState(() => _appearance++);

  @override
  void didPopNext() => _replay();

  @override
  void dispose() {
    AppResumeNotifier.instance.removeListener(_onResume);
    practiceReviewRouteObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final progress = dailyGoalProgress(widget.goal, widget.today);
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    final l10n = AppLocalizations.of(context)!;
    // Inherit the tab's selected/unselected colour, including its transition.
    final colour =
        IconTheme.of(context).color ?? Theme.of(context).colorScheme.primary;
    return TweenAnimationBuilder<double>(
      key: ValueKey(_appearance),
      tween: Tween(begin: reduceMotion ? progress ?? 0 : 0, end: progress ?? 0),
      duration: reduceMotion ? Duration.zero : goalProgressAnimationDuration,
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
