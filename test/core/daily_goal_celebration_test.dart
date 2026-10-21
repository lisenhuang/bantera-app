import 'dart:io';
import 'dart:convert';
import 'dart:async';
import 'package:app/core/daily_goal_celebration.dart';
import 'package:app/domain/activity/daily_word_goal.dart';
import 'package:app/domain/activity/word_activity.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('both targets must be met and zero targets are not an achievement', () {
    expect(
      DailyGoalCelebration.reached(
        const DailyWordGoal(listened: 10, spoken: 5),
        const WordTotals(listened: 10, spoken: 4),
      ),
      false,
    );
    expect(
      DailyGoalCelebration.reached(
        const DailyWordGoal(listened: 10, spoken: 5),
        const WordTotals(listened: 10, spoken: 5),
      ),
      true,
    );
    expect(
      DailyGoalCelebration.reached(
        const DailyWordGoal(listened: 0, spoken: 0),
        const WordTotals(),
      ),
      false,
    );
  });
  test(
    'achievement survives restart, isolates accounts, defers safely, and resets each local day',
    () async {
      final dir = Directory.systemTemp.createTempSync('goal-test');
      addTearDown(() => dir.deleteSync(recursive: true));
      var now = DateTime(2026, 10, 19, 23, 59);
      final file = File('${dir.path}/goals.json');
      var shown = 0;
      var safe = false;
      Future<bool> present(String owner) =>
          DailyGoalCelebration(
            file: () async => file,
            now: () => now,
          ).presentIfEligible(
            owner: owner,
            goal: const DailyWordGoal(listened: 10, spoken: 5),
            totals: const WordTotals(listened: 10, spoken: 5),
            isSafe: () => safe,
            present: () async {
              shown++;
            },
          );
      expect(await present('a'), false);
      safe = true;
      expect(await present('a'), true);
      expect(await present('a'), false);
      expect(await present('b'), true);
      now = now.add(const Duration(minutes: 2));
      expect(await present('a'), true);
      expect(shown, 3);
    },
  );
  group('repeat completion', () {
    late Directory dir;
    late File file;
    late DailyGoalCelebration celebration;
    var shown = 0;
    var safe = true;
    const firstGoal = DailyWordGoal(listened: 10, spoken: 5);
    const higherGoal = DailyWordGoal(listened: 20, spoken: 10);
    const firstTotals = WordTotals(listened: 10, spoken: 5);
    const higherTotals = WordTotals(listened: 20, spoken: 10);

    DailyGoalCelebration make() => DailyGoalCelebration(
      file: () async => file,
      now: () => DateTime(2026, 10, 21),
    );
    Future<bool> check({
      DailyWordGoal? goal = firstGoal,
      WordTotals totals = firstTotals,
      String language = 'en-US',
      bool Function()? current,
    }) => celebration.presentIfEligible(
      owner: 'a',
      goal: goal,
      totals: totals,
      language: language,
      isCurrent: current,
      isSafe: () => safe,
      present: () async {
        shown++;
      },
    );

    setUp(() {
      dir = Directory.systemTemp.createTempSync('repeat-goal');
      file = File('${dir.path}/goals.json');
      celebration = make();
      shown = 0;
      safe = true;
    });
    tearDown(() => dir.deleteSync(recursive: true));

    test(
      'raising the goal arms another celebration that survives restart',
      () async {
        expect(await check(), true);
        safe =
            false; // Goal changes are still observed during unsafe UI periods.
        expect(await check(goal: higherGoal), false);
        celebration = make();
        expect(await check(goal: higherGoal, totals: higherTotals), false);
        safe = true;
        expect(await check(goal: higherGoal, totals: higherTotals), true);
        expect(await check(goal: higherGoal, totals: higherTotals), false);
        celebration = make();
        expect(await check(goal: higherGoal, totals: higherTotals), false);
        expect(shown, 2);
      },
    );

    test(
      'every below-to-complete crossing celebrates, including the same target',
      () async {
        expect(await check(), true);
        for (var i = 0; i < 3; i++) {
          expect(
            await check(totals: const WordTotals(listened: 10, spoken: 4)),
            false,
          );
          expect(await check(), true);
          expect(await check(), false);
        }
        expect(shown, 4);
      },
    );

    test(
      'staying complete while targets or reminder settings change does not repeat',
      () async {
        expect(await check(), true);
        expect(
          await check(goal: const DailyWordGoal(listened: 5, spoken: 2)),
          false,
        );
        expect(
          await check(
            goal: const DailyWordGoal(
              listened: 10,
              spoken: 5,
              notificationHour: 21,
            ),
          ),
          false,
        );
        expect(await check(goal: null), false);
        expect(await check(), false);
        expect(shown, 1);
      },
    );

    test(
      'switching languages does not rearm an already-completed language',
      () async {
        expect(await check(), true);
        expect(
          await check(language: 'ja-JP', totals: const WordTotals()),
          false,
        );
        expect(await check(language: 'en_us'), false);
        expect(await check(language: 'ja-JP'), true);
        expect(await check(), false);
        expect(shown, 2);
      },
    );

    test(
      'legacy once-per-day records rearm after the increased goal is observed',
      () async {
        await file.writeAsString(jsonEncode({'a': '2026-10-21'}));
        expect(await check(), false);
        expect(await check(goal: higherGoal), false);
        celebration = make();
        expect(await check(goal: higherGoal, totals: higherTotals), true);
        expect(shown, 1);
      },
    );

    test('stale below-goal observations cannot rearm completion', () async {
      expect(await check(), true);
      expect(await check(goal: higherGoal, current: () => false), false);
      expect(await check(), false);
      expect(shown, 1);
    });

    test('losing presentation safety restores eligibility', () async {
      var safetyChecks = 0;
      expect(
        await celebration.presentIfEligible(
          owner: 'a',
          goal: firstGoal,
          totals: firstTotals,
          language: 'en-US',
          isSafe: () => ++safetyChecks < 3,
          present: () async {
            shown++;
          },
        ),
        false,
      );
      expect(shown, 0);
      expect(await check(), true);
    });

    test(
      'concurrent notifications cannot display duplicate celebrations',
      () async {
        final close = Completer<void>();
        final opened = Completer<void>();
        final pending = celebration.presentIfEligible(
          owner: 'a',
          goal: firstGoal,
          totals: firstTotals,
          language: 'en-US',
          isSafe: () => true,
          present: () async {
            shown++;
            opened.complete();
            await close.future;
          },
        );
        await opened.future;
        expect(await check(), false);
        close.complete();
        expect(await pending, true);
        expect(shown, 1);
      },
    );
  });
}
