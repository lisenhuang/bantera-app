import 'package:app/infrastructure/translation_service.dart';
import 'package:app/l10n/app_localizations.dart';
import 'package:app/presentation/quick_practice/practice_translation_dialogs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const options = [
    TranslationLocaleOption(
      identifier: 'en',
      displayName: 'English',
      isInstalled: true,
    ),
    TranslationLocaleOption(
      identifier: 'ja',
      displayName: 'Japanese',
      isInstalled: false,
    ),
  ];
  for (final size in [
    const Size(393, 852),
    const Size(852, 393),
    const Size(1024, 720),
  ]) {
    testWidgets(
      'language selection fits ${size.width} with large text and keyboard',
      (tester) async {
        await tester.binding.setSurfaceSize(size);
        addTearDown(() => tester.binding.setSurfaceSize(null));
        TranslationLocaleOption? selected;
        await tester.pumpWidget(
          MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            builder: (context, child) => MediaQuery(
              data: MediaQuery.of(
                context,
              ).copyWith(textScaler: const TextScaler.linear(1.8)),
              child: child!,
            ),
            home: Builder(
              builder: (context) => Scaffold(
                body: TextButton(
                  child: const Text('Open'),
                  onPressed: () async {
                    selected =
                        await showModalBottomSheet<TranslationLocaleOption>(
                          context: context,
                          isScrollControlled: true,
                          useSafeArea: true,
                          builder: (_) =>
                              const PracticeTranslationLanguageSheet(
                                options: options,
                              ),
                        );
                  },
                ),
              ),
            ),
          ),
        );
        await tester.tap(find.text('Open'));
        await tester.pumpAndSettle();
        expect(
          find.textContaining('native language is unavailable'),
          findsOneWidget,
        );
        expect(tester.takeException(), isNull);
        final search = find.byType(TextField);
        await tester.ensureVisible(search);
        await tester.enterText(search, 'ja');
        tester.view.viewInsets = FakeViewPadding(
          bottom: 160 * tester.view.devicePixelRatio,
        );
        addTearDown(tester.view.resetViewInsets);
        await tester.pumpAndSettle();
        expect(
          find.byKey(const ValueKey('practice-translation-language-en')),
          findsNothing,
        );
        final japanese = find.byKey(
          const ValueKey('practice-translation-language-ja'),
        );
        await tester.ensureVisible(japanese);
        await tester.pumpAndSettle();
        expect(find.text('Download'), findsOneWidget);
        await tester.tap(japanese);
        await tester.pumpAndSettle();
        expect(selected?.identifier, 'ja');
        expect(tester.takeException(), isNull);
      },
    );
  }
}
