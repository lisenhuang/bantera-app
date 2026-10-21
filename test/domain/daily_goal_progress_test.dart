import 'package:app/domain/activity/daily_goal_progress.dart';
import 'package:app/domain/activity/daily_word_goal.dart';
import 'package:app/domain/activity/word_activity.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const goal = DailyWordGoal(listened: 600, spoken: 400);
  test(
    'each goal contributes capped words; excess listening cannot mask speaking',
    () {
      expect(
        dailyGoalProgress(goal, const WordTotals(listened: 100, spoken: 1)),
        .101,
      );
      expect(dailyGoalProgress(goal, const WordTotals(listened: 10000)), .6);
      expect(
        dailyGoalProgress(goal, const WordTotals(listened: 10000, spoken: 400)),
        1,
      );
      expect(dailyGoalProgress(null, const WordTotals()), isNull);
      expect(
        dailyGoalProgress(
          const DailyWordGoal(listened: 0, spoken: 0),
          const WordTotals(),
        ),
        isNull,
      );
      expect(
        dailyGoalProgress(
          const DailyWordGoal(listened: 0, spoken: 200),
          const WordTotals(listened: 500, spoken: 100),
        ),
        .5,
      );
    },
  );
}
