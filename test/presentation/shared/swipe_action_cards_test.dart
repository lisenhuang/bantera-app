import 'package:app/l10n/app_localizations.dart';
import 'package:app/presentation/quick_practice/saved_practice_tile.dart';
import 'package:app/presentation/shared/swipe_action_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
    'reminder and saved-practice cards share one open action and dismiss outside',
    (tester) async {
      var removed = 0, opened = 0, outsideTaps = 0;
      const reminderKey = ValueKey('reminder-card');
      const practiceKey = ValueKey('practice-card');
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 320,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SwipeActionCard(
                      key: reminderKey,
                      onRemove: () => removed++,
                      child: const SizedBox(
                        height: 90,
                        width: double.infinity,
                        child: Text('Reminder'),
                      ),
                    ),
                    SavedPracticeTile(
                      key: practiceKey,
                      cue: 'Saved cue',
                      subtitle: 'en-NZ · A1',
                      onOpen: () => opened++,
                      onRemove: () => removed++,
                    ),
                    TextButton(
                      onPressed: () => outsideTaps++,
                      child: const Text('Outside control'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
      Finder action(Key key) => find.descendant(
        of: find.byKey(key),
        matching: find.byTooltip('Delete'),
      );
      await tester.drag(find.byKey(reminderKey), const Offset(-160, 0));
      await tester.pumpAndSettle();
      expect(action(reminderKey), findsOneWidget);
      expect(action(practiceKey), findsNothing);
      expect(removed, 0);

      await tester.drag(find.byKey(practiceKey), const Offset(-160, 0));
      await tester.pumpAndSettle();
      expect(action(reminderKey), findsNothing);
      expect(action(practiceKey), findsOneWidget);
      expect(removed, 0);

      // Closing by tapping a separate control must not swallow that control's
      // gesture or trigger either of the cards' actions.
      await tester.tap(find.text('Outside control'));
      await tester.pumpAndSettle();
      expect(find.byTooltip('Delete'), findsNothing);
      expect(outsideTaps, 1);
      expect(removed, 0);

      await tester.drag(find.byKey(practiceKey), const Offset(-160, 0));
      await tester.pumpAndSettle();
      await tester.tapAt(tester.getCenter(find.text('Saved cue')));
      await tester.pumpAndSettle();
      expect(find.byTooltip('Delete'), findsNothing);
      expect(opened, 0, reason: 'A content tap first closes the revealed row.');
      await tester.tap(find.text('Saved cue'));
      await tester.pumpAndSettle();
      expect(opened, 1);
      expect(removed, 0);
      expect(tester.takeException(), isNull);
    },
  );
}
