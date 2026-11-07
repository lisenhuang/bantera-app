import 'package:app/l10n/app_localizations.dart';
import 'package:app/presentation/chats/ai/ai_vocabulary_review_help.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('review guide fits all locales, dark mode and large text', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    for (final locale in AppLocalizations.supportedLocales) {
      for (final brightness in Brightness.values) {
        final l = lookupAppLocalizations(locale);
        await tester.pumpWidget(
          MaterialApp(
            key: ValueKey('$locale-$brightness'),
            locale: locale,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            theme: ThemeData(
              colorSchemeSeed: Colors.deepPurple,
              brightness: brightness,
            ),
            builder: (context, child) => MediaQuery(
              data: MediaQuery.of(
                context,
              ).copyWith(textScaler: TextScaler.linear(2)),
              child: child!,
            ),
            home: Builder(
              builder: (context) => Scaffold(
                body: TextButton(
                  onPressed: () => showDialog<void>(
                    context: context,
                    builder: (_) => const AiVocabularyReviewHelp(),
                  ),
                  child: const Text('Open'),
                ),
              ),
            ),
          ),
        );
        await tester.tap(find.text('Open'));
        await tester.pumpAndSettle();
        expect(
          find.byKey(const ValueKey('vocabulary-review-chart')),
          findsOneWidget,
        );
        expect(tester.takeException(), isNull, reason: '$locale $brightness');
        // Even on a small phone at 200% text, users can scroll the explanation
        // and dismiss it without needing to scroll to the bottom first.
        await tester.ensureVisible(find.text(l.vocabReviewDueNote));
        await tester.pumpAndSettle();
        expect(
          tester.takeException(),
          isNull,
          reason: '$locale $brightness scrolled',
        );
        await tester.tap(find.text(l.vocabReviewGotIt));
        await tester.pumpAndSettle();
        expect(find.byType(AiVocabularyReviewHelp), findsNothing);
      }
    }
  });

  testWidgets('guide exposes localized meaning without numeric memory claims', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const AiVocabularyReviewHelp(),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Without review'), findsOneWidget);
    expect(find.text('With reviews'), findsOneWidget);
    expect(find.textContaining('3 → 7 → 14 → 30'), findsOneWidget);
    expect(
      find.textContaining('After that, review every 30 days'),
      findsOneWidget,
    );
    expect(find.textContaining('not a measure of your memory'), findsOneWidget);
    expect(find.textContaining('%'), findsNothing);
    expect(tester.getSemantics(find.text('With reviews')).label, 'With reviews');
    semantics.dispose();
  });
}
