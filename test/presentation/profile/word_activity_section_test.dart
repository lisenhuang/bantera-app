import 'package:app/domain/activity/word_activity.dart';
import 'package:app/l10n/app_localizations.dart';
import 'package:app/presentation/profile/word_activity_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  for (final locale in AppLocalizations.supportedLocales) {
    testWidgets('word activity fits 320px and enlarged text in $locale', (
      tester,
    ) async {
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
      expect(find.text(l10n.wordActivityTotal), findsOneWidget);
      expect(find.text(l10n.wordActivityListened), findsNWidgets(3));
      expect(
        find.widgetWithText(TextButton, l10n.wordActivityShare),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    });
  }
}
