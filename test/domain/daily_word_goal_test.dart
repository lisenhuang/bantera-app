import 'package:app/domain/activity/daily_word_goal.dart';
import 'package:app/domain/activity/word_activity.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('goal estimates divide effort between listening and speaking', () {
    final goal = DailyWordGoal.forMinutes(10);
    expect(goal.notificationWeekdays, [1, 2, 3, 4, 5]);
    expect(goal.listened, 600);
    expect(goal.spoken, 300);
    expect(goal.listeningMinutes, 5);
    expect(goal.speakingMinutes, 5);
    expect(goal.totalMinutes, 10);
  });

  test('zero disables either or both targets and survives ledger storage', () {
    for (final goal in [
      const DailyWordGoal(listened: 0, spoken: 120),
      const DailyWordGoal(listened: 240, spoken: 0),
      const DailyWordGoal(listened: 0, spoken: 0),
    ]) {
      expect(goal.isValid, isTrue);
      final ledger = WordActivityLedger(deviceId: 'device')..dailyGoal = goal;
      final restored = WordActivityLedger.fromJson(ledger.toJson()).dailyGoal!;
      expect(restored.listened, goal.listened);
      expect(restored.spoken, goal.spoken);
      expect(restored.totalMinutes, goal.totalMinutes);
    }
    expect(DailyWordGoal.fromJson({'listened': -1, 'spoken': 0}), isNull);
    expect(DailyWordGoal.fromJson({'listened': 100001, 'spoken': 0}), isNull);
    expect(
      WordActivityLedger.fromJson({'deviceId': 'old-device'}).dailyGoal,
      isNull,
    );
  });
}
