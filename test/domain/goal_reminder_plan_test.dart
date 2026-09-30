import 'package:app/domain/activity/daily_word_goal.dart';
import 'package:app/domain/activity/goal_reminder_plan.dart';
import 'package:app/domain/activity/word_activity.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

void main() {
  setUpAll(tzdata.initializeTimeZones);

  test('selected weekdays follow local dates and persist', () {
    const goal = DailyWordGoal(
      listened: 600,
      spoken: 300,
      notificationWeekdays: [1, 3, 5],
    );
    final now = tz.TZDateTime(
      tz.getLocation('Pacific/Auckland'),
      2026,
      9,
      30,
      12,
    );
    final restored = DailyWordGoal.fromJson(goal.toJson())!;
    expect(restored.notificationWeekdays, [1, 3, 5]);
    final dates = goalReminderDates(
      now: now,
      goal: restored,
      today: const WordTotals(),
    );
    expect(dates, isNotEmpty);
    expect(
      dates.every(
        (date) => [1, 3, 5].contains(date.weekday) && date.hour == 19,
      ),
      isTrue,
    );
    expect(
      DailyWordGoal.fromJson({
        'listened': 600,
        'spoken': 300,
      })!.notificationWeekdays,
      [1, 2, 3, 4, 5, 6, 7],
    );
    expect(
      const DailyWordGoal(
        listened: 600,
        spoken: 300,
        notificationWeekdays: [0],
      ).isValid,
      isFalse,
    );
  });
  test(
    'Never schedules one dated reminder and cannot repeat after it expires',
    () {
      final zone = tz.getLocation('Pacific/Auckland');
      final once = DailyWordGoal(
        listened: 600,
        spoken: 300,
        notificationWeekdays: [],
        notificationOnceAt: DateTime(2026, 9, 30, 19),
      );
      final restored = DailyWordGoal.fromJson(once.toJson())!;
      expect(
        goalReminderDates(
          now: tz.TZDateTime(zone, 2026, 9, 30, 18),
          goal: restored,
          today: const WordTotals(),
        ).length,
        1,
      );
      expect(
        goalReminderDates(
          now: tz.TZDateTime(zone, 2026, 9, 30, 20),
          goal: restored,
          today: const WordTotals(),
        ),
        isEmpty,
      );
      expect(
        goalReminderDates(
          now: tz.TZDateTime(zone, 2026, 10, 1, 18),
          goal: restored,
          today: const WordTotals(),
        ),
        isEmpty,
      );
      expect(
        goalReminderDates(
          now: tz.TZDateTime(zone, 2026, 9, 30, 18),
          goal: restored,
          today: const WordTotals(listened: 600, spoken: 300),
        ),
        isEmpty,
      );
    },
  );

  test('chosen reminder time persists and schedules in the local timezone', () {
    const goal = DailyWordGoal(
      listened: 600,
      spoken: 300,
      notificationHour: 8,
      notificationMinute: 45,
    );
    final restored = DailyWordGoal.fromJson(goal.toJson())!;
    expect(restored.notificationHour, 8);
    expect(restored.notificationMinute, 45);
    final zone = tz.getLocation('Pacific/Auckland');
    final dates = goalReminderDates(
      now: tz.TZDateTime(zone, 2026, 9, 25, 7),
      goal: restored,
      today: const WordTotals(),
    );
    expect(dates.every((d) => d.hour == 8 && d.minute == 45), isTrue);
    expect(dates.first.timeZoneOffset, isNot(dates.last.timeZoneOffset));
    expect(
      DailyWordGoal.fromJson({
        'listened': 600,
        'spoken': 300,
      })!.notificationHour,
      19,
    );
    expect(
      const DailyWordGoal(
        listened: 600,
        spoken: 300,
        notificationHour: 24,
      ).isValid,
      isFalse,
    );
  });

  const goal = DailyWordGoal(listened: 600, spoken: 300);
  for (final zone in ['Pacific/Auckland', 'America/New_York', 'Asia/Kolkata']) {
    test('7 PM follows $zone calendar and daylight saving', () {
      final location = tz.getLocation(zone);
      final now = tz.TZDateTime(location, 2026, 9, 25, 12);
      final dates = goalReminderDates(
        now: now,
        goal: goal,
        today: const WordTotals(),
      );
      expect(dates.length, 60);
      expect(
        dates.every((date) => date.hour == 19 && date.minute == 0),
        isTrue,
      );
      expect(dates.first.day, 25);
      expect(dates.first.location.name, zone);
      if (zone != 'Asia/Kolkata') {
        expect(dates.first.timeZoneOffset, isNot(dates.last.timeZoneOffset));
      }
    });
  }
  test('completed day skips today but midnight allows the next day', () {
    final zone = tz.getLocation('Pacific/Auckland');
    final now = tz.TZDateTime(zone, 2026, 9, 30, 18);
    final dates = goalReminderDates(
      now: now,
      goal: goal,
      today: const WordTotals(listened: 600, spoken: 300),
    );
    expect(dates.first.day, 1);
    expect(dates.first.month, 10);
    final nextDay = goalReminderDates(
      now: tz.TZDateTime(zone, 2026, 10, 1),
      goal: goal,
      today: const WordTotals(),
    );
    expect(nextDay.first.day, 1);
    expect(nextDay.first.hour, 19);
  });
  test('after 7 PM starts tomorrow', () {
    final now = tz.TZDateTime(
      tz.getLocation('America/New_York'),
      2026,
      9,
      30,
      19,
    );
    expect(
      goalReminderDates(
        now: now,
        goal: goal,
        today: const WordTotals(),
      ).first.day,
      1,
    );
  });
  test('zero goals and disabled notifications do not remind', () {
    final now = tz.TZDateTime(tz.getLocation('Asia/Kolkata'), 2026, 9, 30);
    for (final disabled in [
      null,
      const DailyWordGoal(listened: 0, spoken: 0),
      const DailyWordGoal(
        listened: 600,
        spoken: 300,
        notificationsEnabled: false,
      ),
    ]) {
      expect(
        goalReminderDates(now: now, goal: disabled, today: const WordTotals()),
        isEmpty,
      );
    }
    expect(
      goalReminderDates(
        now: now,
        goal: const DailyWordGoal(listened: 0, spoken: 300),
        today: const WordTotals(spoken: 300),
      ).first.day,
      1,
    );
    expect(
      goalReminderDates(
        now: now,
        goal: const DailyWordGoal(listened: 600, spoken: 0),
        today: const WordTotals(listened: 599),
      ).first.day,
      30,
    );
  });
  test('old saved goals enable reminders by default, opt-out persists', () {
    expect(
      DailyWordGoal.fromJson({
        'listened': 600,
        'spoken': 300,
      })!.notificationsEnabled,
      isTrue,
    );
    const disabled = DailyWordGoal(
      listened: 600,
      spoken: 300,
      notificationsEnabled: false,
    );
    expect(
      DailyWordGoal.fromJson(disabled.toJson())!.notificationsEnabled,
      isFalse,
    );
  });
}
