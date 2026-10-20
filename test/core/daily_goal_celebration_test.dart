import 'dart:io';
import 'package:app/core/daily_goal_celebration.dart';
import 'package:app/domain/activity/daily_word_goal.dart';
import 'package:app/domain/activity/word_activity.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('both targets must be met and zero targets are not an achievement', () {
    expect(
      DailyGoalCelebration.reached(
        const DailyWordGoal(listened: 10, spoken: 5),
        const WordTotals(listened: 10, spoken: 4),
      ),
      false,
    );
    expect(
      DailyGoalCelebration.reached(
        const DailyWordGoal(listened: 10, spoken: 5),
        const WordTotals(listened: 10, spoken: 5),
      ),
      true,
    );
    expect(
      DailyGoalCelebration.reached(
        const DailyWordGoal(listened: 0, spoken: 0),
        const WordTotals(),
      ),
      false,
    );
  });
  test(
    'achievement survives restart, isolates accounts, defers safely, and resets each local day',
    () async {
      final dir = Directory.systemTemp.createTempSync('goal-test');
      addTearDown(() => dir.deleteSync(recursive: true));
      var now = DateTime(2026, 10, 19, 23, 59);
      final file = File('${dir.path}/goals.json');
      var shown = 0;
      var safe = false;
      Future<bool> present(String owner) =>
          DailyGoalCelebration(
            file: () async => file,
            now: () => now,
          ).presentIfEligible(
            owner: owner,
            goal: const DailyWordGoal(listened: 10, spoken: 5),
            totals: const WordTotals(listened: 10, spoken: 5),
            isSafe: () => safe,
            present: () async {
              shown++;
            },
          );
      expect(await present('a'), false);
      safe = true;
      expect(await present('a'), true);
      expect(await present('a'), false);
      expect(await present('b'), true);
      now = now.add(const Duration(minutes: 2));
      expect(await present('a'), true);
      expect(shown, 3);
    },
  );
}
