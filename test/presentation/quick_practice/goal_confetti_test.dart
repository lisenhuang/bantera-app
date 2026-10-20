import 'package:app/domain/activity/word_activity.dart';
import 'package:app/l10n/app_localizations.dart';
import 'package:app/presentation/shared/daily_goal_celebration_dialog.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Future<void> open(WidgetTester tester, {bool reducedMotion = false}) async {
    await tester.binding.setSurfaceSize(const Size(393, 852));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(disableAnimations: reducedMotion),
          child: child!,
        ),
        home: Builder(
          builder: (rootContext) => Scaffold(
            body: TextButton(
              child: const Text('Open lesson'),
              onPressed: () => Navigator.of(rootContext).push(
                MaterialPageRoute<void>(
                  builder: (_) => Scaffold(
                    appBar: AppBar(title: const Text('Lesson details')),
                    body: TextButton(
                      child: const Text('Complete goal'),
                      onPressed: () => showDailyGoalCelebration(
                        rootContext,
                        totals: const WordTotals(listened: 600, spoken: 300),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Open lesson'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Complete goal'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
  }

  testWidgets(
    'root celebration overlays a pushed page and confetti does not block Continue',
    (tester) async {
      await open(tester);
      expect(find.text('Today’s goals reached'), findsOneWidget);
      final overlay = find.byKey(const ValueKey('goal-full-screen-confetti'));
      expect(tester.getSize(overlay), const Size(393, 852));
      expect(find.byType(ConfettiWidget), findsNWidgets(2));
      await tester.tap(find.text('Keep practising'));
      await tester.pumpAndSettle();
      expect(find.text('Lesson details'), findsOneWidget);
      expect(find.byType(ConfettiWidget), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets('Reduce Motion keeps the modal but suppresses confetti', (
    tester,
  ) async {
    await open(tester, reducedMotion: true);
    expect(find.text('Today’s goals reached'), findsOneWidget);
    expect(find.byType(ConfettiWidget), findsNothing);
    await tester.pumpWidget(const SizedBox());
  });
  testWidgets(
    'confetti ends after four seconds without dismissing the achievement',
    (tester) async {
      await open(tester);
      await tester.pump(const Duration(seconds: 4));
      expect(find.byType(ConfettiWidget), findsNothing);
      expect(find.text('Today’s goals reached'), findsOneWidget);
      await tester.pumpWidget(const SizedBox());
    },
  );
  testWidgets('backgrounding removes particles without replay on resume', (
    tester,
  ) async {
    await open(tester);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    await tester.pump();
    expect(find.byType(ConfettiWidget), findsNothing);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pump();
    expect(find.byType(ConfettiWidget), findsNothing);
    await tester.pumpWidget(const SizedBox());
  });
}
