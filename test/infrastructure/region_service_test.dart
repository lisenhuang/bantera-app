import 'dart:async';

import 'package:app/core/app_locale.dart';
import 'package:app/infrastructure/region_service.dart';
import 'package:app/infrastructure/transcription_locale_option.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const options = [
    TranscriptionLocaleOption(
      identifier: 'zh-CN',
      displayName: 'Mandarin',
      isInstalled: false,
    ),
    TranscriptionLocaleOption(
      identifier: 'zh-HK',
      displayName: 'Cantonese',
      isInstalled: false,
    ),
    TranscriptionLocaleOption(
      identifier: 'zh-TW',
      displayName: 'Mandarin (Taiwan)',
      isInstalled: false,
    ),
    TranscriptionLocaleOption(
      identifier: 'zh_Hant_TW',
      displayName: 'Taiwan variant',
      isInstalled: false,
    ),
    TranscriptionLocaleOption(
      identifier: 'en-US',
      displayName: 'English',
      isInstalled: false,
    ),
  ];

  group('language picker visibility', () {
    test(
      'Simplified Chinese hides Taiwan without requesting the country',
      () async {
        var lookups = 0;
        final service = RegionService.forTesting(
          appLocale: () => AppLocalePreference.zhCn.explicitLocale!,
          countryLookup: () async {
            lookups++;
            return 'NZ';
          },
        );
        expect(
          (await service.filterLanguageOptions(
            options,
          )).map((o) => o.identifier),
          ['zh-CN', 'zh-HK', 'en-US'],
        );
        expect(lookups, 0);
      },
    );

    test(
      'system default and explicit UI choices use the effective app locale',
      () async {
        var preference = AppLocalePreference.system;
        var platform = const Locale.fromSubtags(
          languageCode: 'zh',
          scriptCode: 'Hans',
          countryCode: 'SG',
        );
        final service = RegionService.forTesting(
          appLocale: () => resolveAppLocale(
            preference: preference,
            platformLocale: platform,
          ),
          countryLookup: () async => 'NZ',
        );
        expect((await service.filterLanguageOptions(options)).length, 3);
        platform = const Locale('zh', 'HK');
        expect(await service.filterLanguageOptions(options), options);
        preference = AppLocalePreference.zhCn;
        expect((await service.filterLanguageOptions(options)).length, 3);
        preference = AppLocalePreference.en;
        platform = const Locale('zh', 'CN');
        expect(await service.filterLanguageOptions(options), options);
      },
    );

    test(
      'cached outside-China result cannot override a changed app language',
      () async {
        var locale = const Locale('en');
        var lookups = 0;
        final service = RegionService.forTesting(
          appLocale: () => locale,
          countryLookup: () async {
            lookups++;
            return 'NZ';
          },
        );
        expect(await service.filterLanguageOptions(options), options);
        locale = AppLocalePreference.zhCn.explicitLocale!;
        expect((await service.filterLanguageOptions(options)).length, 3);
        locale = AppLocalePreference.zhHant.explicitLocale!;
        expect(await service.filterLanguageOptions(options), options);
        expect(lookups, 1);
      },
    );

    test(
      'locale changes during country lookup are applied before returning',
      () async {
        var locale = const Locale('en');
        final country = Completer<String?>();
        final service = RegionService.forTesting(
          appLocale: () => locale,
          countryLookup: () => country.future,
        );
        final result = service.filterLanguageOptions(options);
        locale = AppLocalePreference.zhCn.explicitLocale!;
        country.complete('NZ');
        expect((await result).map((o) => o.identifier), [
          'zh-CN',
          'zh-HK',
          'en-US',
        ]);
      },
    );

    test(
      'English still hides Taiwan for mainland China or failed lookups',
      () async {
        for (final country in ['CN', null]) {
          final service = RegionService.forTesting(
            appLocale: () => const Locale('en'),
            countryLookup: () async => country,
          );
          expect(
            (await service.filterLanguageOptions(
              options,
            )).map((o) => o.identifier),
            ['zh-CN', 'zh-HK', 'en-US'],
          );
        }
      },
    );
  });

  group('parseTraceCountry', () {
    test('reads the loc line', () {
      const body =
          'fl=46f85\nh=api.bantera.app\nip=1.2.3.4\nloc=CN\ntls=TLSv1.3\n';
      expect(RegionService.parseTraceCountry(body), 'CN');
    });

    test('returns null when missing or malformed', () {
      expect(RegionService.parseTraceCountry('fl=1\nh=x\n'), isNull);
      expect(RegionService.parseTraceCountry('loc=\n'), isNull);
      expect(RegionService.parseTraceCountry('loc=XX1\n'), isNull);
    });
  });

  group('isTaiwanChineseLocale', () {
    test('matches every spelling of Chinese (Taiwan)', () {
      for (final id in ['zh-TW', 'zh_TW', 'zh-Hant-TW', 'ZH-tw']) {
        expect(RegionService.isTaiwanChineseLocale(id), isTrue, reason: id);
      }
    });

    test('keeps other Chinese variants', () {
      for (final id in ['zh', 'zh-CN', 'zh-HK', 'zh-Hant', 'yue-CN', 'en-TW']) {
        expect(RegionService.isTaiwanChineseLocale(id), isFalse, reason: id);
      }
    });
  });
}
