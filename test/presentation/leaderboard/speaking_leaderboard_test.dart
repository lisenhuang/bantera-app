import 'dart:io';
import 'package:app/core/theme.dart';
import 'package:app/domain/activity/word_activity.dart';
import 'package:app/l10n/app_localizations.dart';
import 'package:app/presentation/leaderboard/speaking_leaderboard.dart';
import 'package:app/presentation/profile/word_activity_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

Map<String, dynamic> entry(int i, {bool mine = false, bool hidden = false}) => {
  'key': '$i',
  'rank': i == 3 ? 2 : i,
  'name': [
    '',
    'Maya Chen',
    'Oliver Bennett',
    'Sofia Martínez',
    'Luca Moretti',
    'Aiko Tanaka',
    'Noah Williams',
  ][i < 7 ? i : 6],
  'avatarUrl': null,
  'isMe': mine,
  'profileHidden': hidden,
  'spokenWords': mine ? 12450 : 31000 - (i == 3 ? 2 : i) * 800,
  'learningLanguage': i.isEven ? 'en-US' : 'ja-JP',
};
SpeakingReport sample({int me = 42, bool hidden = false, bool empty = false}) =>
    SpeakingReport({
      'fromDate': '2026-09-22',
      'throughDate': '2026-10-21',
      'timeZone': 'UTC',
      'asOf': '2026-10-21T10:00:00Z',
      'showProfile': !hidden,
      'limit': 100,
      'offset': 0,
      'hasMore': false,
      'rows': empty
          ? <Map<String, dynamic>>[]
          : [
              for (var i = 1; i <= 10; i++)
                {
                  ...entry(i, mine: i == me, hidden: i == me && hidden),
                  if (me <= 10 && i >= me)
                    'spokenWords': 12450 - (i - me) * 800,
                  if (me <= 3 && i >= me) 'rank': i,
                },
            ],
      'you': empty
          ? {
              ...entry(42, mine: true, hidden: true),
              'rank': null,
              'spokenWords': 0,
              'learningLanguage': 'ja-JP',
            }
          : entry(me, mine: true, hidden: hidden),
      'includesLegacyDates': false,
    });

// Design references use system Arial and Apple Color Emoji on macOS. Keep
// all behavioral/layout assertions on Linux CI without comparing different fonts.
Future<void> expectMacDesign(Finder finder, String path) async {
  if (Platform.isMacOS) await expectLater(finder, matchesGoldenFile(path));
}

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await (FontLoader(
      'MaterialIcons',
    )..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'))).load();
    final emoji = File('/System/Library/Fonts/Apple Color Emoji.ttc');
    if (emoji.existsSync()) {
      await (FontLoader('Apple Color Emoji')..addFont(
            Future.value(ByteData.sublistView(await emoji.readAsBytes())),
          ))
          .load();
    }
    final font = File('/System/Library/Fonts/Supplemental/Arial.ttf');
    if (font.existsSync()) {
      await (FontLoader('Roboto')..addFont(
            Future.value(ByteData.sublistView(await font.readAsBytes())),
          ))
          .load();
    }
  });
  Future<void> mount(
    WidgetTester tester,
    Widget home, {
    bool dark = false,
    bool settle = true,
    double width = 393,
    double height = 852,
    double scale = 1,
    Locale locale = const Locale('en'),
  }) async {
    await tester.binding.setSurfaceSize(Size(width, height));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: (dark ? BanteraTheme.darkTheme : BanteraTheme.lightTheme)
            .copyWith(
              textTheme:
                  (dark ? BanteraTheme.darkTheme : BanteraTheme.lightTheme)
                      .textTheme
                      .apply(fontFamilyFallback: const ['Apple Color Emoji']),
            ),
        locale: locale,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: TextScaler.linear(scale)),
          child: child!,
        ),
        home: home,
      ),
    );
    if (settle)
      await tester.pumpAndSettle();
    else
      await tester.pump();
  }

  Widget view({
    SpeakingReport? report,
    bool loading = false,
    bool failed = false,
  }) => SpeakingLeaderboardView(
    report: report,
    loading: loading,
    failed: failed,
    onRefresh: () async {},
  );

  testWidgets('configured report labels stay with their cached values', (
    tester,
  ) async {
    final report = SpeakingReport({...sample().data, 'periodDays': 14});
    await mount(
      tester,
      Scaffold(body: SpeakingLeaderboardCard(preview: report)),
    );
    expect(find.text('Last 14 days'), findsOneWidget);
    await mount(tester, view(report: report));
    expect(find.text('Last 14 days'), findsOneWidget);
    expect(find.text('Last 30 days'), findsNothing);
    await tester.scrollUntilVisible(
      find.text(
        AppLocalizations.of(
          tester.element(find.byType(SpeakingLeaderboardView)),
        )!.leaderboardPeriodFootnote,
      ),
      400,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.textContaining('previous 29 days'), findsNothing);
    await mount(tester, view(failed: true));
    expect(find.text('Last 30 days'), findsNothing);
    await mount(
      tester,
      Scaffold(body: SpeakingLeaderboardCard(preview: sample())),
    );
    expect(find.text('Last 30 days'), findsOneWidget);
  });

  for (final replaceKey in [false, true]) {
    testWidgets(
      'losing admin privileges dismisses owned person dialog, key replacement=$replaceKey',
      (tester) async {
        var admin = true;
        late StateSetter update;
        final report = sample();
        (report.data['rows'] as List).first.addAll({
          'adminUserId': 'person',
          'nativeLanguage': 'zh-CN',
          'nativeLanguageFlag': '🇨🇳',
          'ipCountryCode': 'NZ',
          'ipCountryFlag': '🇳🇿',
        });
        await mount(
          tester,
          StatefulBuilder(
            builder: (context, setState) {
              update = setState;
              return SpeakingLeaderboardView(
                key: ValueKey(replaceKey ? admin : true),
                report: report,
                onPeriodChanged: admin ? (_) {} : null,
                onOpenChat: admin ? (_) async {} : null,
                onRefresh: () async {},
              );
            },
          ),
        );
        await tester.tap(find.text('Maya'));
        await tester.pumpAndSettle();
        expect(find.text('zh-CN 🇨🇳'), findsOneWidget);
        expect(find.text('ja-JP 🇯🇵'), findsOneWidget);
        expect(find.text('NZ 🇳🇿'), findsOneWidget);
        update(() => admin = false);
        await tester.pumpAndSettle();
        expect(find.byType(AlertDialog), findsNothing);
        expect(find.byType(ChoiceChip), findsNothing);
        await tester.tap(find.text('Maya'));
        await tester.pumpAndSettle();
        expect(find.byType(AlertDialog), findsNothing);
        expect(tester.takeException(), isNull);
      },
    );
  }

  testWidgets('admin periods have shield and remain selectable while loading', (
    tester,
  ) async {
    var selected = 30;
    await mount(
      tester,
      SpeakingLeaderboardView(
        loading: true,
        days: 7,
        onPeriodChanged: (days) => selected = days,
        onRefresh: () async {},
      ),
      settle: false,
    );
    expect(find.byIcon(Icons.admin_panel_settings_outlined), findsOneWidget);
    expect(find.text('30 days'), findsOneWidget);
    expect(find.text('7 days'), findsOneWidget);
    expect(find.text('24H'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('leaderboard-period-1')));
    expect(selected, 1);
    await tester.tap(find.byKey(const ValueKey('leaderboard-period-30')));
    expect(selected, 30);
  });

  testWidgets('ordinary leaderboard has no admin choices or row action', (
    tester,
  ) async {
    final report = sample();
    (report.data['rows'] as List).first['adminUserId'] = 'person';
    await mount(tester, view(report: report));
    expect(find.byType(ChoiceChip), findsNothing);
    expect(find.byIcon(Icons.admin_panel_settings_outlined), findsNothing);
    await tester.tap(find.text('Maya'));
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsNothing);
  });

  testWidgets(
    'admin chat opens only after shield confirmation, never for self',
    (tester) async {
      final report = sample(me: 2);
      for (final row in report.data['rows'] as List) {
        row['adminUserId'] = row['key'];
      }
      final opened = <String>[];
      await mount(
        tester,
        SpeakingLeaderboardView(
          report: report,
          onPeriodChanged: (_) {},
          onOpenChat: (row) async => opened.add(row['adminUserId'] as String),
          onRefresh: () async {},
        ),
      );
      await tester.tap(find.text('Oliver · You'));
      await tester.pumpAndSettle();
      expect(find.byType(AlertDialog), findsNothing);
      await tester.tap(find.text('Maya'));
      await tester.pumpAndSettle();
      expect(find.text('Open a direct chat with Maya?'), findsOneWidget);
      expect(
        find.descendant(
          of: find.byType(AlertDialog),
          matching: find.byIcon(Icons.admin_panel_settings_outlined),
        ),
        findsOneWidget,
      );
      expect(opened, isEmpty);
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(opened, isEmpty);
      await tester.tap(find.text('Maya'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(FilledButton, 'Message'));
      await tester.pumpAndSettle();
      expect(opened, ['1']);
    },
  );

  for (final locale in AppLocalizations.supportedLocales) {
    testWidgets('admin controls wrap at 320px with large text $locale', (
      tester,
    ) async {
      final report = sample();
      (report.data['rows'] as List).first.addAll({
        'adminUserId': 'person',
        'nativeLanguage': 'en-NZ',
        'nativeLanguageFlag': '🇳🇿',
      });
      await mount(
        tester,
        SpeakingLeaderboardView(
          report: report,
          onOpenChat: (_) async {},
          days: 1,
          onPeriodChanged: (_) {},
          onRefresh: () async {},
        ),
        width: 320,
        height: 700,
        scale: 2,
        locale: locale,
      );
      expect(tester.takeException(), isNull);
      expect(find.byType(ChoiceChip), findsNWidgets(3));
      await tester.ensureVisible(find.text('Maya'));
      await tester.tap(find.text('Maya'));
      await tester.pumpAndSettle();
      final l = AppLocalizations.of(tester.element(find.byType(AlertDialog)))!;
      expect(l.leaderboardPeriodScope(14), contains('14'));
      expect(l.leaderboardPeriodScope(14), isNot(contains('#')));
      expect(find.text(l.leaderboardNativeLanguage), findsOneWidget);
      expect(find.text(l.leaderboardLearningLanguage), findsOneWidget);
      expect(find.text(l.leaderboardIpCountry), findsOneWidget);
      expect(find.text('en-NZ 🇳🇿'), findsOneWidget);
      expect(find.text(l.permissionStatusUnknown), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }

  for (final dark in [false, true]) {
    testWidgets(
      'leaderboard with current learning language design dark=$dark',
      (tester) async {
        await mount(tester, view(report: sample()), dark: dark);
        expect(find.byKey(const ValueKey('your-position-dock')), findsNothing);
        await expectMacDesign(
          find.byType(MaterialApp),
          'goldens/leaderboard-${dark ? 'dark' : 'light'}.png',
        );
        expect(find.text('Japanese 🇯🇵'), findsWidgets);
        expect(find.text('Language breakdown'), findsNothing);
        expect(find.text('Last 30 days'), findsOneWidget);
        expect(find.textContaining('All languages'), findsNothing);
      },
    );
    testWidgets('Goal entry design dark=$dark', (tester) async {
      await mount(
        tester,
        Scaffold(
          appBar: AppBar(title: const Text('Bantera App')),
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: 2,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.graphic_eq),
                label: 'Practice',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.chat_bubble_outline),
                label: 'Chats',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.donut_large),
                label: 'Goal',
              ),
            ],
          ),
          body: SingleChildScrollView(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                  child: SpeakingLeaderboardCard(preview: sample()),
                ),
                const Padding(
                  padding: EdgeInsets.all(20),
                  child: Row(
                    children: [
                      Icon(
                        Icons.check_circle_outline,
                        size: 32,
                        color: Color(0xFF6B4EE6),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Daily goal · 72% complete',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                WordActivitySection(
                  today: const WordTotals(listened: 1240, spoken: 720),
                  week: const WordTotals(listened: 18460, spoken: 12450),
                  total: const WordTotals(listened: 86420, spoken: 49820),
                ),
              ],
            ),
          ),
        ),
        dark: dark,
      );
      await expectMacDesign(
        find.byType(MaterialApp),
        'goldens/goal-${dark ? 'dark' : 'light'}.png',
      );
      expect(find.text('Last 30 days'), findsOneWidget);
      expect(find.byIcon(Icons.emoji_events_outlined), findsOneWidget);
    });
  }
  testWidgets(
    'own position stays in the normal list without visibility controls',
    (tester) async {
      await mount(tester, view(report: sample(me: 10)));
      expect(find.byKey(const ValueKey('your-position-dock')), findsNothing);
      expect(find.byIcon(Icons.visibility_outlined), findsNothing);
      expect(find.byIcon(Icons.visibility_off_outlined), findsNothing);
      expect(find.textContaining('· You').hitTestable(), findsNothing);
      await tester.scrollUntilVisible(
        find.textContaining('· You'),
        300,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(find.textContaining('· You'));
      await tester.pumpAndSettle();
      expect(find.byType(AlertDialog), findsNothing);
      expect(find.textContaining('Noah · You'), findsOneWidget);
    },
  );
  testWidgets('more ranking pages are reachable from the normal list', (
    tester,
  ) async {
    final report = sample();
    report.data['hasMore'] = true;
    var requested = 0;
    await mount(
      tester,
      SpeakingLeaderboardView(
        report: report,
        onRefresh: () async {},
        onLoadMore: () async {
          requested++;
        },
      ),
    );
    await tester.drag(find.byType(ListView), const Offset(0, -1600));
    await tester.pumpAndSettle();
    expect(requested, greaterThan(0));
    expect(find.byKey(const ValueKey('your-position-dock')), findsNothing);
  });
  testWidgets('names remain visible even with an obsolete hidden preference', (
    tester,
  ) async {
    await mount(tester, view(report: sample(me: 2, hidden: true)));
    expect(find.text('Oliver · You'), findsOneWidget);
    expect(find.text('Private learner · You'), findsNothing);
    expect(find.text('12,450'), findsOneWidget);
  });
  testWidgets('empty no-speaking and error states remain actionable', (
    tester,
  ) async {
    await mount(tester, view(report: sample(empty: true)));
    expect(find.textContaining('Speak in Practice'), findsOneWidget);
    await expectMacDesign(find.byType(MaterialApp), 'goldens/empty.png');
    await mount(tester, view(failed: true));
    expect(find.text('Refresh'), findsOneWidget);
    await expectMacDesign(find.byType(MaterialApp), 'goldens/error.png');
  });
  for (final locale in AppLocalizations.supportedLocales) {
    testWidgets('320px large text $locale', (tester) async {
      final report = sample();
      report.data['you']['name'] =
          'A very long display name with several family names';
      await mount(
        tester,
        view(report: report),
        width: 320,
        height: 700,
        scale: 2,
        locale: locale,
      );
      expect(tester.takeException(), isNull);
    });
  }
  test(
    'UTC speaking snapshots preserve language contributions and old history',
    () {
      final ledger = WordActivityLedger.fromJson({
        'deviceId': 'test',
        'local': {
          '2026-10-20|en': {'spokenWords': 8000},
          '2026-10-20|ja': {'spokenWords': 4450},
        },
      });
      expect(
        ledger.speakingUtc.values.fold<int>(0, (n, e) => n + e.spoken),
        12450,
      );
      ledger.record(
        DateTime.parse('2026-10-21T00:30:00+13:00'),
        const WordTotals(spoken: 5),
        language: 'fr',
      );
      expect(ledger.speakingUtc['2026-10-20|fr']!.spoken, 5);
      final reload = WordActivityLedger.fromJson(ledger.toJson());
      expect(
        reload.speakingUtc.values.fold<int>(0, (n, e) => n + e.spoken),
        12455,
      );
      expect(reload.speakingLegacyThrough, isNotNull);
    },
  );
}
