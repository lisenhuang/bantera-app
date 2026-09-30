import 'package:app/core/goal_reminder_service.dart';
import 'package:app/domain/activity/daily_word_goal.dart';
import 'package:app/domain/activity/word_activity.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const notifications = MethodChannel(
    'dexterous.com/flutter/local_notifications',
  );
  const timezone = MethodChannel('flutter_timezone');
  late List<MethodCall> calls;
  setUp(() {
    calls = [];
    IOSFlutterLocalNotificationsPlugin.registerWith();
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(notifications, (call) async {
          calls.add(call);
          if (call.method == 'initialize' ||
              call.method == 'requestPermissions') {
            return true;
          }
          return null;
        });
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          timezone,
          (call) async => {
            'identifier': 'Pacific/Auckland',
            'localizedName': 'New Zealand Time',
            'locale': 'en_NZ',
          },
        );
  });
  tearDown(() {
    debugDefaultTargetPlatformOverride = null;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(notifications, null);
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(timezone, null);
  });
  test(
    'enabled schedules local calendar reminders; opt-out cancels owned IDs',
    () async {
      final service = GoalReminderService.forTesting();
      await service.update(
        ownerId: 'user-a',
        language: 'en',
        goal: const DailyWordGoal(listened: 600, spoken: 300),
        today: const WordTotals(),
      );
      final scheduled = calls.where((c) => c.method == 'zonedSchedule');
      expect(scheduled.length, inInclusiveRange(59, 60));
      for (final call in scheduled) {
        final args = call.arguments as Map;
        expect(args['timeZoneName'], 'Pacific/Auckland');
        expect(args['scheduledDateTime'], contains('T19:00:00'));
        expect(args['payload'], 'daily-goal');
      }
      calls.clear();
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
            timezone,
            (call) async => throw PlatformException(code: 'unavailable'),
          );
      await service.update(
        ownerId: 'user-a',
        language: 'en',
        goal: const DailyWordGoal(
          listened: 600,
          spoken: 300,
          notificationsEnabled: false,
        ),
        today: const WordTotals(),
      );
      expect(calls.where((c) => c.method == 'zonedSchedule'), isEmpty);
      final cancelled = calls
          .where((c) => c.method == 'cancel')
          .map((c) => c.arguments);
      expect(cancelled.toSet(), {for (var i = 650000; i < 650060; i++) i});
      expect(calls.where((c) => c.method == 'cancelAll'), isEmpty);
    },
  );
  test('sign-out supersedes an earlier queued schedule', () async {
    final service = GoalReminderService.forTesting();
    final old = service.update(
      ownerId: 'user-a',
      language: 'en',
      goal: const DailyWordGoal(listened: 600, spoken: 300),
      today: const WordTotals(),
    );
    final signOut = service.update(
      ownerId: null,
      language: null,
      goal: null,
      today: const WordTotals(),
    );
    await Future.wait([old, signOut]);
    expect(calls.where((c) => c.method == 'zonedSchedule'), isEmpty);
    expect(calls.where((c) => c.method == 'cancel').length, 60);
  });
}
