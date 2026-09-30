import 'dart:convert';
import 'dart:io';

import 'package:app/core/auth_session_notifier.dart';
import 'package:app/core/word_activity_notifier.dart';
import 'package:app/domain/activity/daily_word_goal.dart';
import 'package:app/infrastructure/auth_api_client.dart';
import 'package:app/l10n/app_localizations.dart';
import 'package:app/presentation/profile/daily_word_goal_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('preferences persist and removing a goal requires confirmation', (
    tester,
  ) async {
    final dir = Directory.systemTemp.createTempSync(
      'bantera-goal-settings-test',
    );
    final session = AuthSession(
      provider: AuthProviderType.email,
      accountLabel: 'test',
      accessToken:
          'test.${base64Url.encode(utf8.encode(jsonEncode({'sub': 'test-user'})))}.test',
      tokenType: 'Bearer',
      expiresIn: 3600,
      refreshToken: 'test',
      issuedAt: DateTime.now(),
    );
    final notifier = WordActivityNotifier.forTesting(
      session: () => session,
      file: (id) async => File('${dir.path}/$id.json'),
      apiClient: AuthApiClient.forTesting(
        baseUrl: Uri.parse('http://127.0.0.1:1'),
      ),
    );
    addTearDown(() {
      notifier.dispose();
      dir.deleteSync(recursive: true);
    });
    await tester.runAsync(
      () => notifier.setDailyGoal(
        const DailyWordGoal(
          listened: 600,
          spoken: 300,
          notificationHour: 8,
          notificationMinute: 45,
        ),
      ),
    );
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute<void>(
                  builder: (_) => DailyWordGoalScreen(notifier: notifier),
                ),
              ),
              child: const Text('Open'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.byKey(const ValueKey('daily-goal-notifications')),
      250,
      scrollable: find
          .descendant(
            of: find.byType(ListView),
            matching: find.byType(Scrollable),
          )
          .first,
    );
    expect(
      tester
          .widget<SwitchListTile>(
            find.byKey(const ValueKey('daily-goal-notifications')),
          )
          .value,
      isTrue,
    );
    expect(
      find.byKey(const ValueKey('daily-goal-notification-time')),
      findsOneWidget,
    );
    final time =
        tester
                .widget<ListTile>(
                  find.byKey(const ValueKey('daily-goal-notification-time')),
                )
                .trailing!
            as Text;
    expect(time.data, contains('8:45'));
    await tester.tap(find.byKey(const ValueKey('daily-goal-notifications')));
    await tester.pumpAndSettle();
    expect(
      find.byKey(const ValueKey('daily-goal-notification-time')),
      findsNothing,
    );
    await tester.scrollUntilVisible(
      find.text('Done'),
      150,
      scrollable: find
          .descendant(
            of: find.byType(ListView),
            matching: find.byType(Scrollable),
          )
          .first,
    );
    await tester.runAsync(() async {
      tester.widget<FilledButton>(find.byType(FilledButton)).onPressed!();
      await Future<void>.delayed(const Duration(milliseconds: 200));
    });
    await tester.pumpAndSettle();
    expect(notifier.dailyGoal!.notificationsEnabled, isFalse);
    expect(notifier.dailyGoal!.notificationHour, 8);
    expect(notifier.dailyGoal!.notificationMinute, 45);
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text('Remove goal'),
      200,
      scrollable: find
          .descendant(
            of: find.byType(ListView),
            matching: find.byType(Scrollable),
          )
          .first,
    );
    final savedGoal = notifier.dailyGoal;
    await tester.tap(find.text('Remove goal'));
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsOneWidget);
    expect(notifier.dailyGoal, same(savedGoal));
    await tester.tap(find.widgetWithText(TextButton, 'Cancel'));
    await tester.pumpAndSettle();
    expect(notifier.dailyGoal, same(savedGoal));
    expect(find.byType(DailyWordGoalScreen), findsOneWidget);
    // Start the confirmed removal in the real async zone so disk writes finish.
    await tester.runAsync(() async {
      tester
          .widget<TextButton>(find.widgetWithText(TextButton, 'Remove goal'))
          .onPressed!();
    });
    await tester.pumpAndSettle();
    final confirm = find.descendant(
      of: find.byType(AlertDialog),
      matching: find.widgetWithText(TextButton, 'Remove goal'),
    );
    await tester.runAsync(() async {
      tester.widget<TextButton>(confirm).onPressed!();
      await Future<void>.delayed(const Duration(milliseconds: 200));
    });
    await tester.pumpAndSettle();
    expect(notifier.dailyGoal, isNull);
    expect(find.byType(DailyWordGoalScreen), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
