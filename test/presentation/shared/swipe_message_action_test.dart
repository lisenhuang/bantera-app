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
        Theme.of(
          tester.element(find.byType(IconButton)),
        ).colorScheme.errorContainer,
      );
      expect(tester.getSize(find.byType(IconButton)), const Size(52, 52));
      expect(deleteButton.style!.shape!.resolve({}), isA<CircleBorder>());
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

  testWidgets('Save and Delete are circular buttons in one row', (
    tester,
  ) async {
    var saved = 0;
    var deleted = 0;
    await tester.pumpWidget(
      host(
        SwipeMessageAction(
          onSave: () async => saved++,
          onDelete: () async => deleted++,
          child: const SizedBox(
            width: 320,
            height: 24,
            child: Text('Short message'),
          ),
        ),
      ),
    );
    expect(find.byTooltip('Save dialogue'), findsNothing);
    await tester.drag(find.byType(SwipeMessageAction), const Offset(-180, 0));
    await tester.pumpAndSettle();
    final save = find.byTooltip('Save dialogue');
    final delete = find.byTooltip('Delete');
    expect(tester.getSize(save), const Size(52, 52));
    expect(tester.getSize(delete), const Size(52, 52));
    expect(tester.getCenter(save).dy, tester.getCenter(delete).dy);
    expect(tester.getRect(save).right, lessThan(tester.getRect(delete).left));
    for (final finder in [save, delete]) {
      final button = tester.widget<IconButton>(
        find.ancestor(of: finder, matching: find.byType(IconButton)),
      );
      expect(button.style!.shape!.resolve({}), isA<CircleBorder>());
    }
    await tester.tap(save);
    await tester.pumpAndSettle();
    expect(saved, 1);
    expect(deleted, 0);
    expect(find.byTooltip('Delete'), findsNothing);
    await tester.drag(find.byType(SwipeMessageAction), const Offset(-180, 0));
    await tester.pumpAndSettle();
    await tester.tap(delete);
    await tester.pumpAndSettle();
    expect(saved, 1);
    expect(deleted, 1);
    expect(tester.takeException(), isNull);
  });

  testWidgets('only one bubble opens and outside taps remain usable', (
    tester,
  ) async {
    var outsideTaps = 0;
    var contentTaps = 0;
    await tester.pumpWidget(
      host(
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SwipeMessageAction(
              key: const ValueKey('ai-row'),
              onSave: () async {},
              onDelete: () async {},
              child: SizedBox(
                width: 320,
                height: 90,
                child: TextButton(
                  onPressed: () => contentTaps++,
                  child: const Text('AI bubble'),
                ),
              ),
            ),
            SwipeMessageAction(
              key: const ValueKey('dm-row'),
              onDelete: () async {},
              child: const SizedBox(
                width: 320,
                height: 90,
                child: Text('DM bubble'),
              ),
            ),
            TextButton(
              onPressed: () => outsideTaps++,
              child: const Text('Elsewhere'),
            ),
          ],
        ),
      ),
    );
    final first = find.byKey(const ValueKey('ai-row'));
    final second = find.byKey(const ValueKey('dm-row'));
    await tester.drag(first, const Offset(-180, 0));
    await tester.pumpAndSettle();
    expect(find.byTooltip('Save dialogue'), findsOneWidget);
    await tester.drag(second, const Offset(-180, 0));
    await tester.pumpAndSettle();
    expect(find.byTooltip('Save dialogue'), findsNothing);
    expect(find.byTooltip('Delete'), findsOneWidget);
    await tester.tap(find.text('Elsewhere'));
    await tester.pumpAndSettle();
    expect(outsideTaps, 1);
    expect(find.byTooltip('Delete'), findsNothing);
    await tester.drag(first, const Offset(-180, 0));
    await tester.pumpAndSettle();
    await tester.tapAt(tester.getTopLeft(first) + const Offset(60, 40));
    await tester.pumpAndSettle();
    expect(contentTaps, 0);
    expect(find.byTooltip('Save dialogue'), findsNothing);
    await tester.tap(find.text('AI bubble'));
    await tester.pumpAndSettle();
    expect(contentTaps, 1);
  });

  testWidgets('a second pointer closes the first still-dragging bubble', (
    tester,
  ) async {
    await tester.pumpWidget(
      host(
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SwipeMessageAction(
              key: const ValueKey('first-row'),
              onSave: () async {},
              onDelete: () async {},
              child: const SizedBox(
                width: 320,
                height: 90,
                child: Text('First'),
              ),
            ),
            SwipeMessageAction(
              key: const ValueKey('second-row'),
              onDelete: () async {},
              child: const SizedBox(
                width: 320,
                height: 90,
                child: Text('Second'),
              ),
            ),
          ],
        ),
      ),
    );
    final first = await tester.startGesture(
      tester.getCenter(find.byKey(const ValueKey('first-row'))),
      pointer: 1,
    );
    await first.moveBy(const Offset(-180, 0));
    await tester.pump();
    final second = await tester.startGesture(
      tester.getCenter(find.byKey(const ValueKey('second-row'))),
      pointer: 2,
    );
    await second.moveBy(const Offset(-180, 0));
    await tester.pump();
    await first.moveBy(const Offset(-20, 0));
    await first.up();
    await second.up();
    await tester.pumpAndSettle();
    expect(find.byTooltip('Save dialogue'), findsNothing);
    expect(find.byTooltip('Delete'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
  testWidgets('actions stay beside a swipe on a very tall bubble', (
    tester,
  ) async {
    var saved = 0;
    await tester.pumpWidget(
      host(
        ListView(
          children: [
            SwipeMessageAction(
              onSave: () async => saved++,
              onDelete: () async {},
              child: const SizedBox(
                width: 320,
                height: 3000,
                child: Text('Long response'),
              ),
            ),
          ],
        ),
      ),
    );
    final start =
        tester.getTopLeft(find.byType(SwipeMessageAction)) +
        const Offset(250, 120);
    await tester.dragFrom(start, const Offset(-180, 0));
    await tester.pumpAndSettle();
    final button = find.byTooltip('Save dialogue');
    expect(tester.getCenter(button).dy, closeTo(start.dy, 1));
    await tester.tap(button);
    await tester.pumpAndSettle();
    expect(saved, 1);
    expect(tester.takeException(), isNull);
  });
}
