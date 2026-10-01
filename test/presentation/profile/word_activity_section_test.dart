import 'package:app/domain/activity/word_activity.dart';
import 'package:app/l10n/app_localizations.dart';
import 'package:app/presentation/profile/word_activity_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';

void main() {
  for (final locale in AppLocalizations.supportedLocales) {
    testWidgets('word activity fits 320px and enlarged text in $locale', (
      tester,
    ) async {
      final semantics = tester.ensureSemantics();
      tester.view.physicalSize = const Size(320, 700);
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
              child: WordActivitySection(
                today: WordTotals(listened: 1234, spoken: 567),
                week: WordTotals(listened: 12345, spoken: 5678),
                total: WordTotals(listened: 1234567, spoken: 567890),
                onShare: () {},
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      final context = tester.element(find.byType(WordActivitySection));
      final l10n = AppLocalizations.of(context)!;
      expect(find.text(l10n.wordActivityTitle), findsOneWidget);
      expect(find.text(l10n.wordActivityToday), findsOneWidget);
      expect(find.text(l10n.wordActivityThisWeek), findsOneWidget);
      expect(find.text(l10n.wordActivityTotal), findsWidgets);
      final number = NumberFormat.decimalPattern(locale.toLanguageTag());
      for (final period in [
        (id: 'today', listened: 1234, spoken: 567),
        (id: 'week', listened: 12345, spoken: 5678),
        (id: 'total', listened: 1234567, spoken: 567890),
      ]) {
        expect(
          find.bySemanticsLabel(
            l10n.wordActivityListeningSummary(
              period.id,
              number.format(period.listened),
              period.listened,
            ),
          ),
          findsOneWidget,
        );
        expect(
          find.bySemanticsLabel(
            l10n.wordActivitySpeakingSummary(
              period.id,
              number.format(period.spoken),
              period.spoken,
            ),
          ),
          findsOneWidget,
        );
      }
      expect(find.byType(FittedBox), findsNothing);
      expect(
        find.widgetWithText(TextButton, l10n.wordActivityShare),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
      semantics.dispose();
    });
  }

  test('Chinese achievement sentences use the right period and unit', () async {
    final l10n = await AppLocalizations.delegate.load(const Locale('zh'));
    expect(
      l10n.wordActivityListeningSummary('today', '346', 346),
      '今天听了 346 个词',
    );
    expect(
      l10n.wordActivitySpeakingSummary('week', '1,234', 1234),
      '本周说了 1,234 个词',
    );
    expect(
      l10n.wordActivityListeningSummary('total', '99,999', 99999),
      '累计听了 99,999 个词',
    );
  });
}
