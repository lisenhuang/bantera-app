import 'package:app/l10n/app_localizations.dart';
import 'package:app/presentation/chats/swipe_message_action.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget host(Widget child) => MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(
      body: Center(child: SizedBox(width: 320, child: child)),
    ),
  );
  testWidgets(
    'swipe only reveals, explicit action confirms, cancel preserves',
    (tester) async {
      var removed = 0;
      await tester.pumpWidget(
        host(
          Builder(
            builder: (context) => SwipeMessageAction(
              adminAction: true,
              onDelete: () async {
                final yes = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Confirm'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text('Remove'),
                      ),
                    ],
                  ),
                );
                if (yes == true) removed++;
              },
              child: const SizedBox(
                height: 90,
                width: 320,
                child: Text('message'),
              ),
            ),
          ),
        ),
      );
      expect(find.text('Delete'), findsNothing);
      await tester.drag(find.byType(SwipeMessageAction), const Offset(-140, 0));
      await tester.pumpAndSettle();
      expect(removed, 0);
      expect(find.text('Delete'), findsNothing);
      expect(find.byIcon(Icons.delete_outline), findsOneWidget);
      final deleteButton = tester.widget<IconButton>(find.byType(IconButton));
      expect(
        deleteButton.style!.backgroundColor!.resolve({}),
        Colors.transparent,
      );
      expect(tester.getSize(find.byType(IconButton)).height, 48);
      expect(find.byIcon(Icons.admin_panel_settings_outlined), findsOneWidget);
      await tester.tap(find.byTooltip('Delete'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(removed, 0);
      expect(find.text('message'), findsOneWidget);
      await tester.drag(find.byType(SwipeMessageAction), const Offset(-140, 0));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Delete'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Remove'));
      await tester.pumpAndSettle();
      expect(removed, 1);
    },
  );
  testWidgets('long press selects text while swipe deletion is enabled', (
    tester,
  ) async {
    await tester.pumpWidget(
      host(
        SwipeMessageAction(
          onDelete: () async {
            fail('Long press must not invoke deletion');
          },
          child: const SelectableText('Choose a word or sentence'),
        ),
      ),
    );
    await tester.longPressAt(
      tester.getTopLeft(find.text('Choose a word or sentence')) +
          const Offset(24, 8),
    );
    await tester.pumpAndSettle();
    final editable = tester.widget<EditableText>(find.byType(EditableText));
    expect(editable.controller.selection.isValid, isTrue);
    expect(editable.controller.selection.isCollapsed, isFalse);
    expect(find.byType(AlertDialog), findsNothing);
    expect(find.text('Delete'), findsNothing);
  });
  testWidgets(
    'disabled messages cannot reveal deletion and text stays selectable',
    (tester) async {
      await tester.pumpWidget(
        host(
          const SwipeMessageAction(
            child: SelectableText('Choose a word or sentence'),
          ),
        ),
      );
      await tester.drag(find.byType(SwipeMessageAction), const Offset(-140, 0));
      await tester.pumpAndSettle();
      expect(find.text('Delete'), findsNothing);
      await tester.longPressAt(
        tester.getTopLeft(find.text('Choose a word or sentence')) +
            const Offset(24, 8),
      );
      await tester.pumpAndSettle();
      expect(find.byType(AlertDialog), findsNothing);
      expect(find.byType(SelectableText), findsOneWidget);
    },
  );
}
