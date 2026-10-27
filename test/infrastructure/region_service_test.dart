import 'dart:async';

import 'package:app/core/app_locale.dart';
import 'package:app/infrastructure/region_service.dart';
import 'package:app/infrastructure/transcription_locale_option.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('regional learning-language ordering', () {
    final choices = ['en-NZ', 'en-US', 'en-GB', 'ja-JP', 'MI_nz']
        .map(
          (code) => TranscriptionLocaleOption(
            identifier: code,
            displayName: code,
            isInstalled: false,
          ),
        )
        .toList();
    for (final country in ['NZ', 'US', 'CN', null]) {
      for (final admin in [true, false]) {
        test('$country admin=$admin respects region and role', () async {
          final service = RegionService.forTesting(
            countryLookup: () async => country,
            appLocale: () => const Locale('en'),
          );
          final result = await service.profileLanguageOptions(
            choices,
            isAdmin: admin,
          );
          expect(
            result.map((o) => o.identifier),
            country == 'NZ'
                ? [if (admin) 'mi-NZ', 'en-NZ', 'en-US', 'en-GB', 'ja-JP']
                : ['en-US', 'en-GB', 'en-NZ', 'ja-JP', if (admin) 'mi-NZ'],
          );
          final native = await service.profileLanguageOptions(
            choices,
            isAdmin: admin,
            nativeLanguage: true,
          );
          expect(native.map((o) => o.identifier), [
            'en-NZ',
            'en-US',
            'en-GB',
            'ja-JP',
          ]);
          service.dispose();
        });
      }
    }
    test(
      'cached NZ ordering is restored after moving away or failed lookup',
      () async {
        String? country = 'NZ';
        final service = RegionService.forTesting(
          countryLookup: () async => country,
          appLocale: () => const Locale('en'),
        );
        var cached = await service.profileLanguageOptions(
          choices,
          isAdmin: true,
        );
        expect(cached.first.identifier, 'mi-NZ');
        for (final next in ['US', null]) {
          country = next;
          await service.isOutsideMainlandChina(refresh: true);
          cached = await service.profileLanguageOptions(cached, isAdmin: true);
          expect(cached.map((o) => o.identifier), [
            'en-US',
            'en-GB',
            'en-NZ',
            'ja-JP',
            'mi-NZ',
          ]);
        }
        service.dispose();
      },
    );
  });

  group('IP-based chat visibility', () {
    for (final country in ['CN', ' cn ', null, 'XX', 'T1', 'invalid']) {
      test('hides group chats and DM call controls for $country', () async {
        final service = RegionService.forTesting(
          countryLookup: () async => country,
          appLocale: () => const Locale('en'),
        );
        expect(service.showSocialChatFeatures, isFalse);
        expect(await service.isOutsideMainlandChina(), isFalse);
        expect(service.showSocialChatFeatures, isFalse);
        service.dispose();
      });
    }

    for (final country in ['HK', 'MO', 'TW', 'NZ', 'US']) {
      test('shows chat features for $country even with Chinese UI', () async {
        final service = RegionService.forTesting(
          countryLookup: () async => country,
          appLocale: () => const Locale('zh', 'CN'),
        );
        expect(service.showSocialChatFeatures, isFalse);
        expect(await service.isOutsideMainlandChina(), isTrue);
        expect(service.showSocialChatFeatures, isTrue);
        service.dispose();
      });
    }

    test(
      'notifies when a network change hides or restores chat features',
      () async {
        String? country = 'NZ';
        final service = RegionService.forTesting(
          countryLookup: () async => country,
          appLocale: () => const Locale('en'),
        );
        final changes = <bool>[];
        service.addListener(() => changes.add(service.showSocialChatFeatures));
        await service.isOutsideMainlandChina();
        country = 'CN';
        await service.isOutsideMainlandChina(refresh: true);
        country = 'HK';
        await service.isOutsideMainlandChina(refresh: true);
        country = null;
        await service.isOutsideMainlandChina(refresh: true);
        country = 'NZ';
        await service.isOutsideMainlandChina();
        expect(changes, [true, false, true, false, true]);
        service.dispose();
      },
    );

    test(
      'deduplicates in-flight requests and never flashes controls at startup',
      () async {
        final country = Completer<String?>();
        var requests = 0;
        final service = RegionService.forTesting(
          countryLookup: () {
            requests++;
            return country.future;
          },
          appLocale: () => const Locale('en'),
        );
        final first = service.isOutsideMainlandChina();
        final second = service.isOutsideMainlandChina(refresh: true);
        expect(service.showSocialChatFeatures, isFalse);
        expect(requests, 1);
        country.complete('CN');
        expect(await first, isFalse);
        expect(await second, isFalse);
        service.dispose();
      },
    );

    test(
      'retries a thrown lookup instead of permanently caching failure',
      () async {
        var requests = 0;
        final service = RegionService.forTesting(
          countryLookup: () {
            if (++requests == 1) throw StateError('offline');
            return Future.value('NZ');
          },
          appLocale: () => const Locale('en'),
        );
        expect(await service.isOutsideMainlandChina(), isFalse);
        expect(await service.isOutsideMainlandChina(), isTrue);
        expect(requests, 2);
        service.dispose();
      },
    );
  });

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
