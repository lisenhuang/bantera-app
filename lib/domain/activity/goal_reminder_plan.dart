import 'package:timezone/timezone.dart' as tz;

import 'daily_word_goal.dart';
import 'word_activity.dart';

/// Calendar dates are constructed separately so daylight saving changes cannot
/// shift a reminder away from the chosen local time. Stay below iOS's 64 pending request limit.
List<tz.TZDateTime> goalReminderDates({
  required tz.TZDateTime now,
  required DailyWordGoal? goal,
  required WordTotals today,
  int days = 60,
}) {
  if (goal == null ||
      !goal.notificationsEnabled ||
      (goal.listened == 0 && goal.spoken == 0)) {
    return [];
  }
  final complete =
      today.listened >= goal.listened && today.spoken >= goal.spoken;
  if (goal.notificationWeekdays.isEmpty) {
    final once = goal.notificationOnceAt;
    if (once == null) return [];
    final date = tz.TZDateTime(
      now.location,
      once.year,
      once.month,
      once.day,
      goal.notificationHour,
      goal.notificationMinute,
    );
    final isToday =
        date.year == now.year && date.month == now.month && date.day == now.day;
    return date.isAfter(now) && !(isToday && complete) ? [date] : [];
  }
  return [
        for (var day = 0; day < days; day++)
          if (!(day == 0 && complete))
            tz.TZDateTime(
              now.location,
              now.year,
              now.month,
              now.day + day,
              goal.notificationHour,
              goal.notificationMinute,
            ),
      ]
      .where(
        (date) =>
            date.isAfter(now) &&
            goal.notificationWeekdays.contains(date.weekday),
      )
      .toList();
}
