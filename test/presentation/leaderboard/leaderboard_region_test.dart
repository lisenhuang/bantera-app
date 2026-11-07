import 'dart:async';

import 'package:app/infrastructure/region_service.dart';
import 'package:app/l10n/app_localizations.dart';
import 'package:app/presentation/leaderboard/speaking_leaderboard.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

SpeakingReport report({bool onlyTaiwan = false, bool more = false}) =>
    SpeakingReport({
      'fromDate': '2026-11-01',
      'throughDate': '2026-11-07',
      'hasMore': more,
      'offset': 0,
      'you': {'rank': 8},
      'rows': [
        {
          'key': 'tw',
          'name': 'TaiwanLearner',
          'rank': 1,
          'spokenWords': 100,
          'learningLanguage': 'zh-TW',
        },
        if (!onlyTaiwan)
          {
            'key': 'nz',
            'name': 'NZLearner',
            'rank': 2,
            'spokenWords': 90,
            'learningLanguage': 'en-NZ',
          },
      ],
    });

Future<void> mount(
  WidgetTester tester,
  RegionService region,
  SpeakingReport data, {
  Future<void> Function()? loadMore,
}) => tester.pumpWidget(
  MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: SpeakingLeaderboardView(
      report: data,
      regionService: region,
      onRefresh: () async {},
      onLoadMore: loadMore,
    ),
  ),
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const channel = MethodChannel('bantera/callkit');
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
  tearDown(() => messenger.setMockMethodCallHandler(channel, null));

  for (final country in ['CN', 'NZ', null]) {
    for (final policy in [true, false, null]) {
      testWidgets('IP=$country native=$policy filters cached rows', (
        tester,
      ) async {
        messenger.setMockMethodCallHandler(channel, (_) async => policy);
        final region = RegionService.forTesting(
          isIOS: true,
          countryLookup: () async => country,
          // Display language alone must not classify the viewer's region.
          appLocale: () => const Locale('zh', 'CN'),
        );
        final data = report();
        await mount(tester, region, data);
        await tester.pumpAndSettle();
        expect(
          find.text('TaiwanLearner'),
          country == 'NZ' && policy == true ? findsOneWidget : findsNothing,
        );
        expect(find.text('NZLearner'), findsOneWidget);
        expect(data.rows.length, 2);
        expect(data.rows.last['rank'], 2);
        await tester.pumpWidget(const SizedBox());
        region.dispose();
      });
    }
  }

  testWidgets('pending and failed native check never flash Taiwan rows', (
    tester,
  ) async {
    final policy = Completer<bool>();
    messenger.setMockMethodCallHandler(channel, (_) => policy.future);
    final region = RegionService.forTesting(
      isIOS: true,
      countryLookup: () async => 'NZ',
      appLocale: () => const Locale('en'),
    );
    await mount(tester, region, report());
    await tester.pump();
    expect(find.text('TaiwanLearner'), findsNothing);
    policy.completeError(PlatformException(code: 'unavailable'));
    await tester.pumpAndSettle();
    expect(find.text('TaiwanLearner'), findsNothing);
    await tester.pumpWidget(const SizedBox());
    region.dispose();
  });

  testWidgets(
    'resume rechecks phone policy and IP with the same cached report',
    (tester) async {
      var allowed = true;
      var country = 'NZ';
      messenger.setMockMethodCallHandler(channel, (_) async => allowed);
      final region = RegionService.forTesting(
        isIOS: true,
        countryLookup: () async => country,
        appLocale: () => const Locale('en'),
      );
      await mount(tester, region, report());
      await tester.pumpAndSettle();
      expect(find.text('TaiwanLearner'), findsOneWidget);
      for (final next in [(false, 'NZ'), (true, 'NZ'), (true, 'CN')]) {
        allowed = next.$1;
        country = next.$2;
        tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
        tester.binding.handleAppLifecycleStateChanged(
          AppLifecycleState.resumed,
        );
        await tester.pumpAndSettle();
        expect(
          find.text('TaiwanLearner'),
          allowed && country == 'NZ' ? findsOneWidget : findsNothing,
        );
      }
      await tester.pumpWidget(const SizedBox());
      region.dispose();
    },
  );

  testWidgets(
    'all hidden page still offers pagination and keeps server offset',
    (tester) async {
      final region = RegionService.forTesting(
        isIOS: false,
        countryLookup: () async => 'CN',
        appLocale: () => const Locale('en'),
      );
      final data = report(onlyTaiwan: true, more: true);
      var loaded = false;
      await mount(
        tester,
        region,
        data,
        loadMore: () async {
          loaded = true;
        },
      );
      await tester.pumpAndSettle();
      expect(find.text('TaiwanLearner'), findsNothing);
      expect(data.nextOffset, 1);
      await tester.tap(find.text('Load more'));
      expect(loaded, isTrue);
      await tester.pumpWidget(const SizedBox());
      region.dispose();
    },
  );

  test('flag filtering follows the actual displayed language variants', () {
    for (final code in ['zh-TW', 'zh_tw', 'zh-Hant-TW']) {
      expect(
        leaderboardRowLanguageLabel({
          'learningLanguage': code,
        }).contains('🇹🇼'),
        isTrue,
      );
    }
    expect(
      leaderboardRowLanguageLabel({
        'learningLanguage': 'zh-CN',
      }).contains('🇹🇼'),
      isFalse,
    );
  });
}
