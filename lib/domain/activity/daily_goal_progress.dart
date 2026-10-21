import 'daily_word_goal.dart';
import 'word_activity.dart';

/// Caps each target separately: excess listening cannot complete speaking.
double? dailyGoalProgress(DailyWordGoal? goal, WordTotals today) {
  if (goal == null || !goal.isValid || goal.listened + goal.spoken == 0) {
    return null;
  }
  return (today.listened.clamp(0, goal.listened) +
          today.spoken.clamp(0, goal.spoken)) /
      (goal.listened + goal.spoken);
}
