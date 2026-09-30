import 'package:app/l10n/app_localizations.dart';
import 'package:app/presentation/profile/goal_reminder_time_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  for (final confirm in [true, false]) {
    testWidgets(
      'two wheels ${confirm ? 'confirm chosen time' : 'cancel without changing time'}',
      (tester) async {
        GoalReminderSelection? result;
        await tester.pumpWidget(
          MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Builder(
              builder: (context) => Scaffold(
                body: TextButton(
                  onPressed: () async {
                    result = await showGoalReminderTimePicker(
                      context,
                      initialTime: const TimeOfDay(hour: 19, minute: 0),
                    );
                  },
                  child: const Text('Open'),
                ),
              ),
            ),
          ),
        );
        await tester.tap(find.text('Open'));
        await tester.pumpAndSettle();
        expect(find.byType(CupertinoPicker), findsNWidgets(2));
        final wheels = tester
            .widgetList<CupertinoPicker>(find.byType(CupertinoPicker))
            .toList();
        wheels[0].scrollController!.jumpToItem(8);
        wheels[1].scrollController!.jumpToItem(45);
        await tester.pumpAndSettle();
        // First-use defaults to Monday through Friday.
        expect(find.text('Weekdays'), findsOneWidget);
        await tester.tap(find.byKey(const ValueKey('reminder-weekday-6')));
        await tester.tap(find.byKey(const ValueKey('reminder-weekday-6')));
        await tester.pumpAndSettle();
        expect(find.text('Weekdays'), findsOneWidget);
        await tester.tap(find.text(confirm ? 'Confirm' : 'Cancel'));
        await tester.pumpAndSettle();
        expect(
          result?.time,
          confirm ? const TimeOfDay(hour: 8, minute: 45) : null,
        );
        if (confirm) expect(result!.weekdays, [1, 2, 3, 4, 5]);
        expect(find.byType(CupertinoDatePicker), findsNothing);
        expect(tester.takeException(), isNull);
      },
    );
  }
}
