import 'package:app/domain/activity/daily_word_goal.dart';
import 'package:app/domain/activity/word_activity.dart';
import 'package:app/l10n/app_localizations.dart';
import 'package:app/presentation/profile/daily_word_goal_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  for (final goal in [
    const DailyWordGoal(listened: 600, spoken: 300),
    const DailyWordGoal(listened: 0, spoken: 300),
    const DailyWordGoal(listened: 600, spoken: 0),
    const DailyWordGoal(listened: 0, spoken: 0),
  ]) {
    testWidgets('progress only shows enabled goals ${goal.toJson()}', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: DailyWordGoalSection(
              goal: goal,
              today: const WordTotals(listened: 300, spoken: 900),
              onEdit: () {},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      final bars = tester
          .widgetList<LinearProgressIndicator>(
            find.byType(LinearProgressIndicator),
          )
          .toList();
      expect(
        bars.length,
        (goal.listened > 0 ? 1 : 0) + (goal.spoken > 0 ? 1 : 0),
      );
      if (goal.listened > 0) {
        expect(bars.first.value, .5);
        expect(find.text('50%'), findsOneWidget);
      }
      if (goal.spoken > 0) {
        expect(bars.last.value, 1);
        expect(find.text('100%'), findsOneWidget);
      }
      expect(tester.takeException(), isNull);
    });
  }

  for (final locale in AppLocalizations.supportedLocales) {
    testWidgets('goal progress fits narrow enlarged $locale', (tester) async {
      tester.view.physicalSize = const Size(320, 700);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        MaterialApp(
          locale: locale,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(
              context,
            ).copyWith(textScaler: const TextScaler.linear(2)),
            child: child!,
          ),
          home: Scaffold(
            body: SingleChildScrollView(
              child: DailyWordGoalSection(
                goal: const DailyWordGoal(listened: 100000, spoken: 100000),
                today: const WordTotals(listened: 12345678, spoken: 99999),
                onEdit: () {},
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  }
}
