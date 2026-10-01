import 'package:app/domain/activity/daily_word_goal.dart';
import 'package:app/domain/activity/word_activity.dart';
import 'package:app/l10n/app_localizations.dart';
import 'package:app/presentation/profile/daily_word_goal_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';

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
        expect(find.text('300/600 words', findRichText: true), findsOneWidget);
      }
      if (goal.spoken > 0) {
        expect(bars.last.value, 1);
        expect(find.byIcon(Icons.check_circle_rounded), findsOneWidget);
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
      final l10n = AppLocalizations.of(
        tester.element(find.byType(DailyWordGoalSection)),
      )!;
      final number = NumberFormat.decimalPattern(locale.toLanguageTag());
      expect(
        find.text(
          l10n.dailyGoalProgress(
            number.format(12345678),
            number.format(100000),
          ),
          findRichText: true,
        ),
        findsOneWidget,
      );
      expect(
        find.text(
          l10n.dailyGoalProgress(number.format(99999), number.format(100000)),
          findRichText: true,
        ),
        findsOneWidget,
      );
      expect(find.byType(FittedBox), findsNothing);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets(
    'Chinese daily progress reads naturally and keeps exceeded totals',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('zh'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: DailyWordGoalSection(
              goal: const DailyWordGoal(listened: 300, spoken: 150),
              today: const WordTotals(listened: 346, spoken: 296),
              onEdit: () {},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('346/300 个词', findRichText: true), findsOneWidget);
      expect(find.text('296/150 个词', findRichText: true), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
}
