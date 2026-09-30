import 'dart:async';

import 'package:app/core/settings_notifier.dart';
import 'package:app/domain/audio_level.dart';
import 'package:app/infrastructure/transcription_locale_option.dart';
import 'package:app/l10n/app_localizations.dart';
import 'package:app/presentation/discover/discover_filters.dart';
import 'package:app/presentation/shared/audio_level_selector.dart';
import 'package:app/presentation/shared/language_picker_totals.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget page(String language, {Locale locale = const Locale('en')}) {
  var allAccents = false;
  return MaterialApp(
    locale: locale,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: StatefulBuilder(
          builder: (context, setState) => DiscoverFilters(
            learningLanguage: language,
            allAccents: allAccents,
            onAccentChanged: (value) => setState(() => allAccents = value),
          ),
        ),
      ),
    ),
  );
}

void main() {
  testWidgets(
    'language totals deduplicate accents and distinguish Cantonese from Mandarin',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const Scaffold(
            body: LanguagePickerTotals(
              identifiers: [
                'en-NZ',
                'en-US',
                'en_NZ',
                'zh-CN',
                'zh-TW',
                'zh-HK',
                'yue-CN',
                '',
              ],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('3 languages · 6 accents'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets('Discover badge omits level icon but selection rows include it', (
    tester,
  ) async {
    unawaited(SettingsNotifier.instance.setAudioLevel(AudioLevel.beginner));
    await tester.pumpWidget(page('en-NZ'));
    await tester.pumpAndSettle();
    expect(find.byType(AudioLevelIcon), findsNothing);
    await tester.tap(find.byType(AudioLevelSelector));
    await tester.pumpAndSettle();
    expect(find.byType(AudioLevelIcon), findsNWidgets(3));
    expect(find.widgetWithText(ListTile, 'Beginner'), findsOneWidget);
  });
  test('Accent filter uses exact learning locale until All is selected', () {
    for (final entry in {
      'en-NZ': 'en',
      'fr-CA': 'fr',
      'de-CH': 'de',
      'it-CH': 'it',
      'pt-BR': 'pt',
      'es-MX': 'es',
    }.entries) {
      expect(discoverAccentLanguageCode(entry.key, false), entry.key);
      expect(
        discoverAccentLanguageCode(entry.key, true),
        entry.key.split('-').first,
      );
      expect(discoverAccentLabel(entry.key, true), entry.value);
      expect(discoverAccentLabel(entry.key, false), entry.key);
    }
    expect(discoverAccentLanguageCode('zh-TW', true), 'zh-TW');
    expect(discoverVariantLanguageCode('ja-JP'), isNull);
    expect(discoverVariantLanguageCode(' en_NZ '), 'en');
  });

  test('Taiwan Mandarin naming handles API and native locale spellings', () {
    for (final code in ['zh-TW', 'ZH_TW', 'zh-Hant-TW']) {
      final option = TranscriptionLocaleOption(
        identifier: code,
        displayName: 'Chinese (Taiwan)',
        isInstalled: false,
      );
      expect(option.displayName, 'Mandarin (Taiwan)');
      expect(discoverAccentLabel(code, false), code);
    }
    expect(localeDisplayName('zh-CN', 'Chinese'), 'Mandarin (Mainland China)');
    expect(
      localeDisplayName('zh-HK', 'Chinese (Hong Kong)'),
      'Cantonese (Hong Kong)',
    );
  });

  for (final entry in {'en-NZ': 'en', 'fr-CA': 'fr'}.entries) {
    testWidgets('${entry.key} defaults, selects All and dismisses safely', (
      tester,
    ) async {
      await tester.pumpWidget(page(entry.key));
      expect(
        find.descendant(
          of: find.byKey(const Key('discover-accent-selector')),
          matching: find.byIcon(Icons.keyboard_arrow_down),
        ),
        findsOneWidget,
      );
      expect(find.text(entry.key), findsOneWidget);
      expect(find.text(entry.value), findsNothing);
      await tester.tap(find.byKey(const Key('discover-accent-selector')));
      await tester.pumpAndSettle();
      final l10n = AppLocalizations.of(
        tester.element(find.byType(DiscoverFilters)),
      )!;
      final exactLabel = discoverAccentOptionLabel(entry.key, false, l10n);
      final allLabel = discoverAccentOptionLabel(entry.key, true, l10n);
      expect(
        exactLabel,
        entry.key == 'en-NZ' ? 'English · New Zealand' : 'French · Canada',
      );
      expect(
        tester
            .widget<ListTile>(find.widgetWithText(ListTile, exactLabel))
            .selected,
        isTrue,
      );
      await tester.tap(find.widgetWithText(ListTile, allLabel));
      await tester.pumpAndSettle();
      expect(find.text(entry.value), findsOneWidget);
      await tester.tap(find.byKey(const Key('discover-accent-selector')));
      await tester.pumpAndSettle();
      await tester.tapAt(const Offset(10, 10));
      await tester.pumpAndSettle();
      expect(find.text(entry.value), findsOneWidget);
      await tester.tap(find.byKey(const Key('discover-accent-selector')));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(ListTile, exactLabel));
      await tester.pumpAndSettle();
      expect(find.text(entry.key), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }

  for (final language in ['zh-TW', 'ja-JP', 'ko-KR']) {
    testWidgets('$language is a static label with no accent menu', (
      tester,
    ) async {
      await tester.pumpWidget(page(language));
      final accent = find.byKey(const Key('discover-accent-selector'));
      expect(tester.widget(accent), isA<Container>());
      expect(
        find.descendant(
          of: accent,
          matching: find.byIcon(Icons.keyboard_arrow_down),
        ),
        findsNothing,
      );
      await tester.tap(accent);
      await tester.pumpAndSettle();
      expect(find.byType(BottomSheet), findsNothing);
      expect(find.text(language), findsOneWidget);
      await tester.tap(find.byType(AudioLevelSelector));
      await tester.pumpAndSettle();
      expect(find.byType(BottomSheet), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('Accent and long translated level fit one row with large text', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 700);
    tester.view.devicePixelRatio = 1;
    tester.platformDispatcher.textScaleFactorTestValue = 1.8;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    unawaited(SettingsNotifier.instance.setAudioLevel(AudioLevel.intermediate));
    await tester.pumpWidget(page('zh-TW', locale: const Locale('pl')));
    await tester.pumpAndSettle();
    expect(find.text('zh-TW'), findsOneWidget);
    expect(find.text('Mandarin (Taiwan)'), findsNothing);
    expect(find.textContaining('Chinese'), findsNothing);
    final accent = tester.getRect(
      find.byKey(const Key('discover-accent-selector')),
    );
    final level = tester.getRect(find.byType(AudioLevelSelector));
    expect(accent.right, lessThan(level.left));
    expect(accent.center.dy, closeTo(level.center.dy, 1));
    expect(accent.left, greaterThanOrEqualTo(16));
    expect(level.right, lessThanOrEqualTo(304));
    expect(tester.takeException(), isNull);
    await tester.tap(find.byKey(const Key('discover-accent-selector')));
    await tester.pumpAndSettle();
    expect(find.byType(BottomSheet), findsNothing);
    expect(find.textContaining('Chinese'), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
