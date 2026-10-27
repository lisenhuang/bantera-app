import 'package:app/domain/activity/daily_word_goal.dart';
import 'package:app/domain/activity/word_activity.dart';
import 'package:app/l10n/app_localizations.dart';
import 'package:app/presentation/profile/goal_motion.dart';
import 'package:app/presentation/profile/daily_word_goal_section.dart';
import 'package:app/presentation/profile/word_activity_trend.dart';
import 'package:app/presentation/shared/animated_tab_icon.dart';
import 'package:app/presentation/leaderboard/leaderboard_motion.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget app(Widget child, {bool reduced = false}) => MaterialApp(
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  builder: (context, child) => MediaQuery(
    data: MediaQuery.of(context).copyWith(disableAnimations: reduced),
    child: child!,
  ),
  home: Scaffold(body: child),
);
void main() {
  testWidgets(
    'Goal bars finish before checkmarks and replay on return and retap',
    (tester) async {
      var active = true, tick = 0;
      late StateSetter update;
      await tester.pumpWidget(
        app(
          StatefulBuilder(
            builder: (context, setState) {
              update = setState;
              return GoalMotion(
                active: active,
                replayTick: tick,
                child: DailyWordGoalSection(
                  goal: const DailyWordGoal(listened: 100, spoken: 100),
                  today: const WordTotals(listened: 100, spoken: 50),
                  onEdit: () {},
                ),
              );
            },
          ),
        ),
      );
      double bar() => tester
          .widgetList<LinearProgressIndicator>(
            find.byType(LinearProgressIndicator),
          )
          .first
          .value!;
      double check() => tester
          .widget<Opacity>(
            find
                .ancestor(
                  of: find.byIcon(Icons.check_circle_rounded),
                  matching: find.byType(Opacity),
                )
                .first,
          )
          .opacity;
      expect(bar(), 0);
      expect(check(), 0);
      await tester.pump(const Duration(milliseconds: 450));
      expect(bar(), inExclusiveRange(0, 1));
      expect(check(), 0);
      await tester.pump(const Duration(milliseconds: 450));
      expect(bar(), 1);
      expect(check(), closeTo(0, .001));
      await tester.pump(const Duration(milliseconds: 175));
      expect(check(), inExclusiveRange(0, 1));
      await tester.pumpAndSettle();
      expect(check(), 1);
      update(() => tick++);
      await tester.pump();
      expect(bar(), 0);
      expect(check(), 0);
      update(() => active = false);
      await tester.pump();
      update(() => active = true);
      await tester.pump();
      expect(bar(), 0);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets('Reduce Motion shows final counts, bars and badge immediately', (
    tester,
  ) async {
    await tester.pumpWidget(
      app(
        GoalMotion(
          active: true,
          replayTick: 1,
          child: DailyWordGoalSection(
            goal: const DailyWordGoal(listened: 100, spoken: 100),
            today: const WordTotals(listened: 100, spoken: 50),
            onEdit: () {},
          ),
        ),
        reduced: true,
      ),
    );
    expect(
      tester
          .widgetList<LinearProgressIndicator>(
            find.byType(LinearProgressIndicator),
          )
          .first
          .value,
      1,
    );
    expect(
      tester
          .widget<Opacity>(
            find
                .ancestor(
                  of: find.byIcon(Icons.check_circle_rounded),
                  matching: find.byType(Opacity),
                )
                .first,
          )
          .opacity,
      1,
    );
  });
  testWidgets('chart draws on entry and restarts for each range selection', (
    tester,
  ) async {
    await tester.pumpWidget(
      app(
        WordActivityTrend(
          history: const {'2026-10-27': WordTotals(spoken: 100)},
          now: DateTime(2026, 10, 27),
        ),
      ),
    );
    double reveal() {
      final plot = find.byKey(const ValueKey('activity-trend-plot'));
      final painter = tester
          .widget<CustomPaint>(
            find.descendant(of: plot, matching: find.byType(CustomPaint)),
          )
          .painter;
      return (painter as dynamic).reveal as double;
    }

    expect(reveal(), 0);
    await tester.pump(const Duration(milliseconds: 500));
    expect(reveal(), inExclusiveRange(0, 1));
    await tester.pumpAndSettle();
    expect(reveal(), 1);
    await tester.tap(find.byType(ChoiceChip).at(1));
    await tester.pump();
    expect(reveal(), 0);
    await tester.pumpAndSettle();
    await tester.tap(find.byType(ChoiceChip).at(2));
    await tester.pump();
    expect(reveal(), 0);
    await tester.pumpAndSettle();
  });
  for (final kind in AnimatedTabKind.values) {
    testWidgets(
      '$kind tab animates once per tap then rests without moving hit area',
      (tester) async {
        var tick = 0;
        late StateSetter update;
        await tester.pumpWidget(
          app(
            StatefulBuilder(
              builder: (context, setState) {
                update = setState;
                return AnimatedTabIcon(
                  kind: kind,
                  selected: true,
                  replayTick: tick,
                );
              },
            ),
          ),
        );
        final key = ValueKey(
          kind == AnimatedTabKind.practice
              ? 'practice-tab-motion'
              : 'chat-tab-motion',
        );
        double phase() =>
            (tester.widget<CustomPaint>(find.byKey(key)).painter as dynamic)
                    .phase
                as double;
        final rect = tester.getRect(find.byType(AnimatedTabIcon));
        expect(phase(), 1);
        update(() => tick++);
        await tester.pump();
        expect(phase(), 0);
        await tester.pump(const Duration(milliseconds: 500));
        expect(phase(), closeTo(.5, .01));
        expect(tester.getRect(find.byType(AnimatedTabIcon)), rect);
        await tester.pumpAndSettle();
        expect(phase(), 1);
        await tester.pump(const Duration(seconds: 2));
        expect(phase(), 1);
        update(() => tick++);
        await tester.pump();
        expect(phase(), 0);
        await tester.pumpAndSettle();
      },
    );
  }
  testWidgets(
    'leaderboard entry counts from zero but updates continue from current value',
    (tester) async {
      var value = 1000;
      late StateSetter update;
      await tester.pumpWidget(
        app(
          StatefulBuilder(
            builder: (_, setState) {
              update = setState;
              return AnimatedSpokenCount(
                value: value,
                fromZero: true,
                locale: 'en',
                style: const TextStyle(),
              );
            },
          ),
        ),
      );
      expect(find.text('0'), findsOneWidget);
      await tester.pumpAndSettle();
      expect(find.text('1,000'), findsOneWidget);
      update(() => value = 1100);
      await tester.pump();
      expect(find.text('1,000'), findsOneWidget);
      await tester.pumpAndSettle();
      expect(find.text('1,100'), findsOneWidget);
    },
  );
}
