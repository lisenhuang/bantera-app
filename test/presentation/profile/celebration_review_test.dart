import 'package:app/core/practice_review_service.dart';
import 'package:app/domain/activity/word_activity.dart';
import 'package:app/l10n/app_localizations.dart';
import 'package:app/presentation/shared/daily_goal_celebration_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  for (final dismissal in ['continue', 'outside', 'back']) {
    testWidgets('native review follows $dismissal dismissal, after animation', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(393, 852));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      var requests = 0;
      final observer = PracticeRouteObserver();
      final review = PracticeReviewService(
        enabled: true,
        currentOwner: () => 'learner',
        isAvailable: () async => true,
        requestReview: () async {
          requests++;
        },
      );
      await tester.pumpWidget(
        MaterialApp(
          navigatorObservers: [observer],
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Builder(
            builder: (context) => Scaffold(
              body: TextButton(
                child: const Text('Complete goal'),
                onPressed: () => review.requestAfterCelebration(
                  dismissed: showDailyGoalCelebration(
                    context,
                    totals: const WordTotals(listened: 600, spoken: 300),
                  ),
                  isSafe: () => observer.top is PageRoute,
                ),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Complete goal'));
      await tester.pump();
      await tester.pump(const Duration(seconds: 5));
      expect(find.byType(DailyGoalCelebrationDialog), findsOneWidget);
      expect(requests, 0);
      switch (dismissal) {
        case 'continue':
          await tester.tap(find.text('Keep practising'));
        case 'outside':
          await tester.tapAt(const Offset(5, 5));
        case 'back':
          await tester.binding.handlePopRoute();
      }
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.byType(DailyGoalCelebrationDialog), findsNothing);
      expect(requests, 0);
      await tester.pump(const Duration(milliseconds: 150));
      expect(requests, 1);
      await tester.pump(const Duration(seconds: 5));
      expect(requests, 1);
    });
  }
}
