import 'package:app/core/theme.dart';
import 'package:app/core/app_resume_notifier.dart';
import 'package:app/core/practice_review_service.dart';
import 'package:app/domain/activity/daily_word_goal.dart';
import 'package:app/domain/activity/word_activity.dart';
import 'package:app/l10n/app_localizations.dart';
import 'package:app/presentation/shared/goal_tab_icon.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const goal = DailyWordGoal(listened: 600, spoken: 400);

  Future<void> mount(
    WidgetTester tester, {
    DailyWordGoal? target = goal,
    WordTotals today = const WordTotals(),
    int selected = 0,
    bool dark = false,
    Locale locale = const Locale('en'),
    double scale = 1,
    ValueChanged<int>? onTap,
    bool settle = true,
    bool reduceMotion = false,
    int replayTick = 0,
  }) async {
    await tester.binding.setSurfaceSize(const Size(320, 600));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      MaterialApp(
        navigatorObservers: [practiceReviewRouteObserver],
        theme: dark ? BanteraTheme.darkTheme : BanteraTheme.lightTheme,
        locale: locale,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: TextScaler.linear(scale),
            disableAnimations: reduceMotion,
          ),
          child: child!,
        ),
        home: Builder(
          builder: (context) {
            final l10n = AppLocalizations.of(context)!;
            return Scaffold(
              bottomNavigationBar: BottomNavigationBar(
                currentIndex: selected,
                unselectedItemColor: Theme.of(
                  context,
                ).colorScheme.onSurfaceVariant,
                onTap: onTap,
                items: [
                  BottomNavigationBarItem(
                    icon: const SizedBox.square(
                      dimension: 36,
                      child: Center(
                        child: Icon(CupertinoIcons.waveform, size: 28),
                      ),
                    ),
                    label: l10n.navPractice,
                  ),
                  BottomNavigationBarItem(
                    icon: const SizedBox.square(
                      dimension: 36,
                      child: Center(
                        child: Icon(CupertinoIcons.chat_bubble_text, size: 28),
                      ),
                    ),
                    label: l10n.chatsTitle,
                  ),
                  BottomNavigationBarItem(
                    icon: GoalTabIcon(
                      goal: target,
                      today: today,
                      replayTick: replayTick,
                    ),
                    label: l10n.navGoal,
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
    if (settle) await tester.pumpAndSettle();
  }

  double ringValue(WidgetTester tester) => tester
      .widget<CircularProgressIndicator>(find.byType(CircularProgressIndicator))
      .value!;

  testWidgets('animates from zero on first appearance and app resume', (
    tester,
  ) async {
    await mount(
      tester,
      today: const WordTotals(listened: 600, spoken: 400),
      settle: false,
    );
    expect(find.text('0%'), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 400));
    expect(ringValue(tester), inExclusiveRange(0, 1));
    await tester.pumpAndSettle();
    expect(find.text('100%'), findsOneWidget);
    AppResumeNotifier.instance.notifyResumed();
    await tester.pump();
    expect(find.text('0%'), findsOneWidget);
    await tester.pumpAndSettle();
    expect(find.text('100%'), findsOneWidget);
  });

  testWidgets('replays when returning from a pushed screen', (tester) async {
    await mount(tester, today: const WordTotals(listened: 500));
    final navigator = Navigator.of(tester.element(find.byType(GoalTabIcon)));
    navigator.push(
      MaterialPageRoute<void>(
        builder: (_) => const Scaffold(body: Text('Details')),
      ),
    );
    await tester.pumpAndSettle();
    AppResumeNotifier.instance.notifyResumed();
    await tester.pump();
    navigator.pop();
    await tester.pump();
    expect(find.text('0%'), findsOneWidget);
    await tester.pumpAndSettle();
    expect(find.text('50.0%'), findsOneWidget);
  });

  testWidgets('normal word updates continue from the displayed value', (
    tester,
  ) async {
    await mount(tester, today: const WordTotals(listened: 500));
    await mount(
      tester,
      today: const WordTotals(listened: 600, spoken: 400),
      settle: false,
    );
    expect(ringValue(tester), .5);
    await tester.pumpAndSettle();
    expect(find.text('100%'), findsOneWidget);
  });

  testWidgets('Goal reselection restarts even during the previous animation', (
    tester,
  ) async {
    const today = WordTotals(listened: 600, spoken: 400);
    await mount(tester, today: today, selected: 2);
    for (var tap = 1; tap <= 3; tap++) {
      await mount(
        tester,
        today: today,
        selected: 2,
        replayTick: tap,
        settle: false,
      );
      expect(ringValue(tester), 0);
      expect(find.text('0%'), findsOneWidget);
      await tester.pump(const Duration(milliseconds: 300));
      expect(ringValue(tester), inExclusiveRange(0, 1));
    }
    await tester.pumpAndSettle();
    expect(find.text('100%'), findsOneWidget);
  });

  testWidgets('reduced motion shows the current percentage immediately', (
    tester,
  ) async {
    await mount(
      tester,
      today: const WordTotals(listened: 600, spoken: 400),
      reduceMotion: true,
      settle: false,
    );
    expect(find.text('100%'), findsOneWidget);
    AppResumeNotifier.instance.notifyResumed();
    await tester.pump();
    expect(find.text('100%'), findsOneWidget);
  });

  testWidgets('updates without selecting tab and caps each target separately', (
    tester,
  ) async {
    await mount(tester, today: const WordTotals(listened: 100, spoken: 1));
    expect(find.text('10.1%'), findsOneWidget);
    await mount(tester, today: const WordTotals(listened: 10000));
    expect(find.text('60.0%'), findsOneWidget);
    await mount(tester, today: const WordTotals(listened: 10000, spoken: 400));
    expect(find.text('100%'), findsOneWidget);
    await mount(tester); // A new day or a language with no activity.
    expect(find.text('0%'), findsOneWidget);
  });

  testWidgets('unfinished goal never displays 100%', (tester) async {
    await mount(
      tester,
      target: const DailyWordGoal(listened: 100000, spoken: 100000),
      today: const WordTotals(listened: 100000, spoken: 99999),
    );
    expect(find.text('99.9%'), findsOneWidget);
    expect(find.text('100%'), findsNothing);
  });

  testWidgets('missing or zero goal shows setup and remains navigable', (
    tester,
  ) async {
    var tapped = -1;
    for (final target in [null, const DailyWordGoal(listened: 0, spoken: 0)]) {
      await mount(tester, target: target, onTap: (index) => tapped = index);
      expect(find.byIcon(Icons.add_rounded), findsOneWidget);
      expect(find.byKey(const ValueKey('goal-tab-percent')), findsNothing);
      expect(
        tester
            .widget<CircularProgressIndicator>(
              find.byType(CircularProgressIndicator),
            )
            .value,
        0,
      );
      await tester.tap(find.byType(GoalTabIcon));
      expect(tapped, 2);
    }
  });

  testWidgets('ring retains selected colour, semantics and fits every locale', (
    tester,
  ) async {
    for (final dark in [false, true]) {
      for (final locale in AppLocalizations.supportedLocales) {
        for (final selected in [0, 2]) {
          await mount(
            tester,
            selected: selected,
            dark: dark,
            locale: locale,
            scale: 2,
            today: const WordTotals(listened: 600, spoken: 400),
          );
          expect(tester.takeException(), isNull);
          final context = tester.element(find.byType(GoalTabIcon));
          final theme = Theme.of(context);
          final ring = tester.widget<CircularProgressIndicator>(
            find.byType(CircularProgressIndicator),
          );
          expect(
            ring.color,
            selected == 2
                ? theme.colorScheme.primary
                : theme.colorScheme.onSurfaceVariant,
          );
          final goalSemantics = tester.widgetList<Semantics>(
            find.descendant(
              of: find.byType(GoalTabIcon),
              matching: find.byType(Semantics),
            ),
          );
          expect(
            goalSemantics.any(
              (widget) =>
                  widget.properties.label ==
                      AppLocalizations.of(context)!.dailyGoalTitle &&
                  widget.properties.value?.contains('100') == true,
            ),
            isTrue,
          );
        }
      }
    }
  });
}
