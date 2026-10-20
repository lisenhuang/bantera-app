import 'package:app/domain/activity/daily_word_goal.dart';
import 'package:app/domain/activity/word_activity.dart';
import 'package:app/l10n/app_localizations.dart';
import 'package:app/presentation/quick_practice/practice_header.dart';
import 'package:app/presentation/quick_practice/practice_word_flight.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
    'correct answer flies to Set goal and launches rocket without a goal',
    (tester) async {
      final flight = PracticeWordFlight();
      final source = GlobalKey(), target = GlobalKey();
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Builder(
            builder: (context) => Scaffold(
              appBar: PracticeHeader(
                goal: null,
                today: const WordTotals(),
                onGoalPressed: () {},
                goalAnchor: target,
              ),
              body: Center(
                child: TextButton(
                  key: source,
                  child: const Text('Correct'),
                  onPressed: () =>
                      flight.show(context, source, target, outcome: 'correct'),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Correct'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 2050));
      final painter =
          tester
                  .widget<CustomPaint>(
                    find.byKey(const ValueKey('practice-word-flight')),
                  )
                  .painter!
              as WordFlightPainter;
      expect(
        painter.end,
        tester.getCenter(find.byKey(const ValueKey('practice-set-goal'))),
      );
      expect(painter.particleProgress, 1);
      expect(painter.rocketProgress, closeTo(.5, .01));
      expect(find.byKey(const ValueKey('practice-goal-percent')), findsNothing);
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('practice-set-goal')), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
  for (final outcome in ['incorrect', 'unclear', null]) {
    testWidgets('no celebration but credit proceeds for $outcome', (
      tester,
    ) async {
      final flight = PracticeWordFlight();
      final source = GlobalKey(), target = GlobalKey();
      var words = 0;
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: Column(
                children: [
                  SizedBox(key: target, width: 48, height: 48),
                  TextButton(
                    key: source,
                    onPressed: () async {
                      await flight.show(
                        context,
                        source,
                        target,
                        outcome: outcome,
                      );
                      words += 8;
                    },
                    child: const Text('Submit'),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Submit'));
      await tester.pump();
      expect(words, 8);
      expect(find.byKey(const ValueKey('practice-word-flight')), findsNothing);
      flight.cancel();
    });
  }
  for (final reduced in [false, true]) {
    testWidgets(
      'word particles arrive before goal increments, reduced=$reduced',
      (tester) async {
        final flight = PracticeWordFlight();
        final source = GlobalKey(), target = GlobalKey();
        final spoken = ValueNotifier(0);
        addTearDown(flight.cancel);
        addTearDown(spoken.dispose);
        await tester.binding.setSurfaceSize(const Size(393, 852));
        addTearDown(() => tester.binding.setSurfaceSize(null));
        await tester.pumpWidget(
          MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            builder: (context, child) => MediaQuery(
              data: MediaQuery.of(context).copyWith(disableAnimations: reduced),
              child: child!,
            ),
            home: Builder(
              builder: (context) => ValueListenableBuilder<int>(
                valueListenable: spoken,
                builder: (_, words, _) => Scaffold(
                  appBar: PracticeHeader(
                    goal: const DailyWordGoal(listened: 0, spoken: 100),
                    today: WordTotals(spoken: words),
                    onGoalPressed: () {},
                    goalAnchor: target,
                  ),
                  body: Align(
                    alignment: const Alignment(0, .7),
                    child: SizedBox(
                      key: source,
                      width: 76,
                      height: 76,
                      child: FilledButton(
                        onPressed: () async {
                          await flight.show(
                            context,
                            source,
                            target,
                            outcome: 'correct',
                          );
                          spoken.value += 10;
                        },
                        child: const Icon(Icons.mic),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
        await tester.tap(find.byIcon(Icons.mic));
        await tester.pump();
        final particles = find.byKey(const ValueKey('practice-word-flight'));
        if (reduced) {
          await tester.pump();
          expect(particles, findsNothing);
          expect(find.text('10.0%'), findsOneWidget);
        } else {
          expect(particles, findsOneWidget);
          expect(find.text('0.0%'), findsOneWidget);
          await tester.pump(const Duration(milliseconds: 800));
          final paint =
              tester.widget<CustomPaint>(particles).painter!
                  as WordFlightPainter;
          expect(paint.particleProgress, closeTo(.5, .01));
          expect(paint.rocketProgress, 0);
          expect(paint.start, tester.getCenter(find.byKey(source)));
          expect(paint.end, tester.getCenter(find.byKey(target)));
          expect(spoken.value, 0);
          await tester.pump(const Duration(milliseconds: 1250));
          final launch =
              tester.widget<CustomPaint>(particles).painter!
                  as WordFlightPainter;
          expect(launch.particleProgress, 1);
          expect(launch.rocketProgress, closeTo(.5, .01));
          expect(spoken.value, 0);
          expect(find.text('0.0%'), findsOneWidget);
          await tester.pump(const Duration(milliseconds: 475));
          await tester.pump();
          await tester.pump();
          expect(particles, findsNothing);
          expect(spoken.value, 10);
          await tester.pump(const Duration(milliseconds: 300));
          final ring = tester.widget<CircularProgressIndicator>(
            find.byType(CircularProgressIndicator),
          );
          expect(ring.value, greaterThan(0));
          expect(ring.value, lessThan(.1));
          await tester.pumpAndSettle();
          expect(find.text('10.0%'), findsOneWidget);
        }
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox());
      },
    );
  }
  testWidgets(
    'cancelling the effect releases credit once and removes overlay',
    (tester) async {
      final flight = PracticeWordFlight();
      final source = GlobalKey(), target = GlobalKey();
      var completed = 0;
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: Column(
                children: [
                  SizedBox(key: target, width: 48, height: 48),
                  TextButton(
                    key: source,
                    onPressed: () async {
                      await flight.show(
                        context,
                        source,
                        target,
                        outcome: 'correct',
                      );
                      completed++;
                    },
                    child: const Text('Record'),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Record'));
      await tester.pump();
      flight.cancel();
      flight.cancel();
      await tester.pumpAndSettle();
      expect(completed, 1);
      expect(find.byKey(const ValueKey('practice-word-flight')), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );
}
