import 'package:app/core/practice_review_service.dart';
import 'package:app/core/theme.dart';
import 'package:app/l10n/app_localizations.dart';
import 'package:app/presentation/quick_practice/practice_level_celebration.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('only an earned increase after an established level celebrates', () {
    expect(PracticeLevelPromotion.earned(null, 'A1'), false);
    expect(PracticeLevelPromotion.earned('A0', 'A1'), true);
    expect(PracticeLevelPromotion.earned('A1', 'A2'), true);
    expect(PracticeLevelPromotion.earned('A2', 'A2'), false);
    expect(PracticeLevelPromotion.earned('B1', 'A2'), false);
    expect(PracticeLevelPromotion.earned('C2', null), false);
  });
  for (final reduced in [false, true]) {
    testWidgets(
      'celebration closes before native review, reduced motion=$reduced',
      (tester) async {
        await tester.binding.setSurfaceSize(const Size(393, 852));
        addTearDown(() => tester.binding.setSurfaceSize(null));
        var requests = 0;
        final review = PracticeReviewService(
          enabled: true,
          currentOwner: () => 'learner',
          isAvailable: () async => true,
          requestReview: () async {
            requests++;
          },
          dismissalDelay: Duration.zero,
        );
        await tester.pumpWidget(
          MaterialApp(
            theme: BanteraTheme.lightTheme,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            builder: (context, child) => MediaQuery(
              data: MediaQuery.of(context).copyWith(disableAnimations: reduced),
              child: child!,
            ),
            home: Builder(
              builder: (context) => Scaffold(
                body: TextButton(
                  onPressed: () => review.requestAfterCelebration(
                    dismissed: showPracticeLevelCelebration(
                      context,
                      before: 'A1',
                      after: 'A2',
                    ),
                    isSafe: () => true,
                  ),
                  child: const Text('Promote'),
                ),
              ),
            ),
          ),
        );
        await tester.tap(find.text('Promote'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 400));
        expect(find.text('You reached A2'), findsOneWidget);
        expect(
          find.byType(ConfettiWidget),
          reduced ? findsNothing : findsNWidgets(2),
        );
        expect(requests, 0);
        expect(tester.takeException(), isNull);
        await tester.tap(
          find.byKey(const ValueKey('practice-level-celebration-continue')),
        );
        await tester.pumpAndSettle();
        expect(requests, 1);
        expect(
          find.byKey(const ValueKey('practice-level-celebration')),
          findsNothing,
        );
      },
    );
  }
}
