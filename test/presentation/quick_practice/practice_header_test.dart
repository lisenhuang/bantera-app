import 'dart:io';
import 'package:flutter/services.dart';
import 'package:app/core/theme.dart';
import 'package:app/domain/activity/daily_word_goal.dart';
import 'package:app/domain/activity/word_activity.dart';
import 'package:app/l10n/app_localizations.dart';
import 'package:app/presentation/quick_practice/practice_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await (FontLoader(
      'MaterialIcons',
    )..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'))).load();
    final font = File('/System/Library/Fonts/Supplemental/Arial.ttf');
    if (font.existsSync()) {
      await (FontLoader('Roboto')..addFont(
            Future.value(ByteData.sublistView(await font.readAsBytes())),
          ))
          .load();
    }
  });
  const goal = DailyWordGoal(listened: 600, spoken: 400);
  test(
    'each goal contributes capped words; excess listening cannot mask speaking',
    () {
      expect(
        practiceGoalProgress(goal, const WordTotals(listened: 100, spoken: 1)),
        .101,
      );
      expect(practiceGoalProgress(goal, const WordTotals(listened: 10000)), .6);
      expect(
        practiceGoalProgress(
          goal,
          const WordTotals(listened: 10000, spoken: 400),
        ),
        1,
      );
      expect(practiceGoalProgress(null, const WordTotals()), isNull);
      expect(
        practiceGoalProgress(
          const DailyWordGoal(listened: 0, spoken: 0),
          const WordTotals(),
        ),
        isNull,
      );
      expect(
        practiceGoalProgress(
          const DailyWordGoal(listened: 0, spoken: 200),
          const WordTotals(listened: 500, spoken: 100),
        ),
        .5,
      );
    },
  );
  Future<void> mount(
    WidgetTester tester, {
    DailyWordGoal? target = goal,
    WordTotals today = const WordTotals(listened: 100, spoken: 1),
    bool dark = false,
    double width = 393,
    double scale = 1,
    Locale locale = const Locale('en'),
    VoidCallback? onTap,
    VoidCallback? onDialogues,
    TargetPlatform platform = TargetPlatform.iOS,
  }) async {
    await tester.binding.setSurfaceSize(Size(width, 400));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: (dark ? BanteraTheme.darkTheme : BanteraTheme.lightTheme)
            .copyWith(platform: platform),
        locale: locale,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: TextScaler.linear(scale)),
          child: child!,
        ),
        home: Scaffold(
          appBar: PracticeHeader(
            onLongerDialogues: onDialogues ?? () {},
            goal: target,
            today: today,
            onGoalPressed: onTap ?? () {},
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('title stays centred with goal left and menu right', (
    tester,
  ) async {
    var taps = 0;
    await mount(tester, onTap: () => taps++);
    expect(find.text('10.1%'), findsOneWidget);
    final title = tester.getCenter(
      find.byKey(const ValueKey('practice-title')),
    );
    expect(title.dx, closeTo(393 / 2, .1));
    expect(
      tester.getSize(find.byKey(const ValueKey('practice-header-bar'))).height,
      kToolbarHeight,
    );
    expect(find.byIcon(Icons.check_circle_rounded), findsNothing);
    expect(
      tester.getCenter(find.byKey(const ValueKey('practice-goal-ring'))).dx,
      lessThan(title.dx),
    );
    expect(find.byKey(const ValueKey('practice-level')), findsNothing);
    expect(
      tester.getCenter(find.byKey(const ValueKey('practice-more-menu'))).dx,
      greaterThan(title.dx),
    );
    await tester.tap(find.byKey(const ValueKey('practice-goal-ring')));
    expect(taps, 1);
  });
  testWidgets(
    'missing goal shows actionable setup instead of a misleading zero',
    (tester) async {
      var taps = 0;
      await mount(tester, target: null, onTap: () => taps++);
      expect(find.text('Set goal'), findsOneWidget);
      expect(find.byKey(const ValueKey('practice-goal-ring')), findsNothing);
      await tester.tap(find.text('Set goal'));
      expect(taps, 1);
    },
  );
  testWidgets(
    'word changes update percentage and unfinished goals never round to 100',
    (tester) async {
      await mount(tester, today: const WordTotals());
      expect(find.text('0.0%'), findsOneWidget);
      await mount(
        tester,
        target: const DailyWordGoal(listened: 100000, spoken: 100000),
        today: const WordTotals(listened: 100000, spoken: 99999),
      );
      expect(find.text('99.9%'), findsOneWidget);
      await mount(tester, today: const WordTotals(listened: 600, spoken: 400));
      expect(find.text('100.0%'), findsOneWidget);
    },
  );
  testWidgets('localised setup and ring fit a small screen with large text', (
    tester,
  ) async {
    for (final target in [null, goal]) {
      await mount(
        tester,
        target: target,
        width: 320,
        scale: 1.7,
        dark: true,
        locale: const Locale('de'),
      );
      expect(tester.takeException(), isNull);
      expect(
        tester.getCenter(find.byKey(const ValueKey('practice-title'))).dx,
        closeTo(160, .1),
      );
    }
  });
  for (final platform in [TargetPlatform.iOS, TargetPlatform.android]) {
    for (final dark in [false, true]) {
      testWidgets('overflow menu fits $platform dark=$dark at large text', (
        tester,
      ) async {
        var opened = 0;
        await mount(
          tester,
          width: 320,
          scale: 2,
          dark: dark,
          platform: platform,
          onDialogues: () => opened++,
        );
        final menu = find.byKey(const ValueKey('practice-more-menu'));
        expect(tester.getSize(menu), const Size(48, 48));
        expect(tester.getCenter(menu).dx, greaterThan(160));
        expect(
          tester.getCenter(find.byKey(const ValueKey('practice-title'))).dx,
          closeTo(160, .1),
        );
        expect(
          tester
              .getSize(find.byKey(const ValueKey('practice-header-bar')))
              .height,
          kToolbarHeight,
        );
        expect(tester.widget<PopupMenuButton<String>>(menu).tooltip, 'More');
        await tester.tap(menu);
        await tester.pumpAndSettle();
        final item = find.byType(PopupMenuItem<String>);
        expect(item, findsOneWidget);
        expect(
          find.descendant(of: item, matching: find.byType(Icon)),
          findsNothing,
        );
        expect(find.text('Longer dialogues'), findsOneWidget);
        expect(tester.takeException(), isNull);
        await tester.tap(find.text('Longer dialogues'));
        await tester.pumpAndSettle();
        expect(opened, 1);
      });
    }
  }

  testWidgets('daily goal ring light and dark design captures', (tester) async {
    for (final dark in [false, true]) {
      await mount(tester, dark: dark);
      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile(
          'goldens/practice-header-${dark ? "dark" : "light"}.png',
        ),
      );
    }
  });
}
