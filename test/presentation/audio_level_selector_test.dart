import 'dart:async';

import 'package:app/core/settings_notifier.dart';
import 'package:app/domain/audio_level.dart';
import 'package:app/l10n/app_localizations.dart';
import 'package:app/presentation/shared/audio_level_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget page({Locale locale = const Locale('en')}) => MaterialApp(
  locale: locale,
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  home: const Scaffold(
    body: Column(
      children: [
        AudioLevelSelector(key: Key('discover'), allowAll: true),
        AudioLevelButtons(key: Key('generate')),
      ],
    ),
  ),
);

void main() {
  testWidgets(
    'Direct generation buttons sync with Discover and preserve All behavior',
    (tester) async {
      unawaited(SettingsNotifier.instance.setAudioLevel(null));
      await tester.pumpWidget(page());
      expect(find.text('All levels'), findsOneWidget);
      expect(
        find.byKey(const Key('audio-level-choice-beginner')),
        findsOneWidget,
      );
      await tester.tap(find.byKey(const Key('discover')));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(ListTile, 'Beginner'));
      await tester.pumpAndSettle();
      expect(find.text('Beginner'), findsNWidgets(2));
      expect(SettingsNotifier.instance.audioLevel, AudioLevel.beginner);
      await tester.tap(find.byKey(const Key('audio-level-choice-advanced')));
      await tester.pumpAndSettle();
      expect(find.text('Advanced'), findsNWidgets(2));
      await tester.tap(find.byKey(const Key('discover')));
      await tester.pumpAndSettle();
      await tester.tapAt(const Offset(10, 10));
      await tester.pumpAndSettle();
      expect(SettingsNotifier.instance.audioLevel, AudioLevel.advanced);
      await tester.tap(find.byKey(const Key('discover')));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(ListTile, 'All levels'));
      await tester.pumpAndSettle();
      expect(find.byType(BottomSheet), findsNothing);
      expect(
        tester
            .widget<Semantics>(
              find.byKey(const Key('audio-level-choice-advanced')),
            )
            .properties
            .selected,
        isFalse,
      );
      expect(SettingsNotifier.instance.audioLevel, isNull);
    },
  );

  testWidgets('Long translated label fits narrow screen at large text size', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 700);
    tester.view.devicePixelRatio = 1;
    tester.platformDispatcher.textScaleFactorTestValue = 1.8;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    unawaited(SettingsNotifier.instance.setAudioLevel(AudioLevel.intermediate));
    await tester.pumpWidget(page(locale: const Locale('pl')));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    await tester.tap(find.byKey(const Key('audio-level-choice-advanced')));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}
