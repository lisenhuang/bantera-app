import 'dart:io';
import 'dart:ui' as ui;

import 'package:app/core/theme.dart';
import 'package:app/domain/activity/daily_word_goal.dart';
import 'package:app/domain/activity/word_activity.dart';
import 'package:app/l10n/app_localizations.dart';
import 'package:app/presentation/profile/daily_word_goal_section.dart';
import 'package:app/presentation/profile/word_activity_section.dart';
import 'package:app/presentation/profile/word_activity_trend.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final now = DateTime(2026, 10, 1);
  final history = <String, WordTotals>{
    '2026-09-25': const WordTotals(listened: 420, spoken: 160),
    '2026-09-26': const WordTotals(listened: 960, spoken: 380),
    '2026-09-27': const WordTotals(listened: 680, spoken: 210),
    '2026-09-29': const WordTotals(listened: 1080, spoken: 480),
    '2026-09-30': const WordTotals(listened: 800, spoken: 324),
    '2026-10-01': const WordTotals(listened: 1480, spoken: 296),
  };
  setUpAll(() async {
    if (Platform.environment['BANTERA_PROFILE_PREVIEWS'] == null) return;
    for (final entry in {
      'PreviewLatin': '/System/Library/Fonts/Supplemental/Arial.ttf',
      'PreviewChinese': '/System/Library/Fonts/Hiragino Sans GB.ttc',
    }.entries) {
      await (FontLoader(entry.key)..addFont(
            File(entry.value).readAsBytes().then(ByteData.sublistView),
          ))
          .load();
    }
    await (FontLoader(
      'MaterialIcons',
    )..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'))).load();
  });

  test(
    'calendar history fills missing days, filters future days, and covers all history',
    () {
      final data = {
        ...history,
        '2026-10-02': const WordTotals(listened: 99999),
      };
      final days = activityTrendDays(data, now, 7);
      expect(days.length, 7);
      expect(days[3].date, DateTime(2026, 9, 28));
      expect(days[3].totals.listened, 0);
      expect(days.last.totals.listened, 1480);
      expect(activityTrendDays(data, now, 30).length, 30);
      expect(activityTrendDays(data, now, null).length, 7);
      expect(activityTrendDays({}, now, null).length, 1);
    },
  );

  testWidgets('selected ranges change both summary totals', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: WordActivityTrend(
            now: now,
            history: {
              '2026-10-01': const WordTotals(listened: 10, spoken: 5),
              '2026-09-15': const WordTotals(listened: 20, spoken: 8),
              '2026-08-01': const WordTotals(listened: 30, spoken: 9),
              '2026-10-02': const WordTotals(listened: 900, spoken: 900),
            },
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    final l = AppLocalizations.of(
      tester.element(find.byType(WordActivityTrend)),
    )!;
    expect(find.text('Listening  10'), findsOneWidget);
    expect(find.text('Speaking  5'), findsOneWidget);
    await tester.tap(find.text(l.wordActivityThirtyDays));
    await tester.pumpAndSettle();
    expect(find.text('Listening  30'), findsOneWidget);
    expect(find.text('Speaking  13'), findsOneWidget);
    await tester.tap(find.text(l.wordActivityAllTime));
    await tester.pumpAndSettle();
    expect(find.text('Listening  60'), findsOneWidget);
    expect(find.text('Speaking  22'), findsOneWidget);
  });

  for (final locale in AppLocalizations.supportedLocales) {
    testWidgets(
      'populated chart is accessible and fits enlarged text: $locale',
      (tester) async {
        tester.view.physicalSize = const Size(320, 1000);
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
                child: WordActivityTrend(history: history, now: now),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        final l10n = AppLocalizations.of(
          tester.element(find.byType(WordActivityTrend)),
        )!;
        await tester.tap(
          find.widgetWithText(ChoiceChip, l10n.wordActivityThirtyDays),
        );
        await tester.pumpAndSettle();
        expect(
          tester
              .widget<ChoiceChip>(
                find.widgetWithText(ChoiceChip, l10n.wordActivityThirtyDays),
              )
              .selected,
          isTrue,
        );
        expect(tester.takeException(), isNull);
      },
    );
  }

  testWidgets(
    'chart selects exact daily totals and preserves the share action',
    (tester) async {
      var shares = 0;
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: SingleChildScrollView(
              child: WordActivitySection(
                today: history.values.last,
                week: const WordTotals(),
                total: const WordTotals(),
                history: history,
                now: now,
                onShare: () => shares++,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(TextButton, 'Share'));
      expect(shares, 1);
      await tester.ensureVisible(
        find.byKey(const ValueKey('activity-trend-plot')),
      );
      final plot = tester.getRect(
        find.byKey(const ValueKey('activity-trend-plot')),
      );
      await tester.tapAt(Offset(plot.left + 6, plot.center.dy));
      await tester.pump();
      expect(find.text('Listening  5,420'), findsOneWidget);
      expect(find.text('Speaking  1,850'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  for (final dark in [false, true]) {
    testWidgets('profile visual preview ${dark ? 'dark' : 'light'}', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(393, 1150);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final capture = GlobalKey();
      final base = dark ? BanteraTheme.darkTheme : BanteraTheme.lightTheme;
      final output = Platform.environment['BANTERA_PROFILE_PREVIEWS'];
      final theme = output == null
          ? base
          : base.copyWith(
              textTheme: base.textTheme.apply(fontFamily: 'PreviewChinese'),
            );
      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          locale: const Locale('zh'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: RepaintBoundary(
            key: capture,
            child: Scaffold(
              appBar: AppBar(title: const Text('我的')),
              body: SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 16),
                    DailyWordGoalSection(
                      goal: const DailyWordGoal(listened: 300, spoken: 150),
                      today: history.values.last,
                      onEdit: () {},
                    ),
                    const SizedBox(height: 24),
                    WordActivitySection(
                      today: history.values.last,
                      week: const WordTotals(listened: 3360, spoken: 1100),
                      total: const WordTotals(listened: 5420, spoken: 1850),
                      history: history,
                      now: now,
                      onShare: () {},
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      if (output != null) {
        final boundary =
            capture.currentContext!.findRenderObject()!
                as RenderRepaintBoundary;
        await tester.runAsync(() async {
          final image = await boundary.toImage(pixelRatio: 2);
          final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
          await Directory(output).create(recursive: true);
          await File(
            '$output/profile-${dark ? 'dark' : 'light'}.png',
          ).writeAsBytes(bytes!.buffer.asUint8List());
          image.dispose();
        });
        await tester.pump();
      }
    });
  }
}
