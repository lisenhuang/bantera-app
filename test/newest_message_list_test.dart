import 'package:app/presentation/chats/newest_message_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget chat(int count, {bool mine = false}) => MaterialApp(
  home: Scaffold(
    body: NewestMessageList(
      newestMessageId: 'message-$count',
      newestIsMine: mine,
      messageIds: List.generate(count, (index) => 'message-${index + 1}'),
      itemBuilder: (_, index) => SizedBox(
        height: index.isEven ? 140 : 260,
        child: Text('Message ${index + 1}'),
      ),
    ),
  ),
);

void main() {
  testWidgets(
    'opens at newest on the first frame with variable height history',
    (tester) async {
      await tester.pumpWidget(chat(80));
      expect(find.text('Message 80').hitTestable(), findsOneWidget);
      expect(find.text('Message 1'), findsNothing);
      var state = tester.state<ScrollableState>(find.byType(Scrollable));
      expect(state.position.pixels, 0);
      expect(state.position.isScrollingNotifier.value, isFalse);
      // Remote history arrives after cached messages. It must not animate down.
      await tester.pumpWidget(chat(100));
      state = tester.state<ScrollableState>(find.byType(Scrollable));
      expect(find.text('Message 100').hitTestable(), findsOneWidget);
      expect(state.position.pixels, 0);
      expect(state.position.isScrollingNotifier.value, isFalse);
    },
  );

  testWidgets('can read older messages and return instantly after sending', (
    tester,
  ) async {
    await tester.pumpWidget(chat(80));
    await tester.drag(find.byType(ListView), const Offset(0, 500));
    await tester.pumpAndSettle();
    var state = tester.state<ScrollableState>(find.byType(Scrollable));
    expect(state.position.pixels, greaterThan(80));
    final offset = state.position.pixels;
    await tester.pumpWidget(chat(81));
    expect(state.position.pixels, offset);
    await tester.pumpWidget(chat(82, mine: true));
    await tester.pump();
    state = tester.state<ScrollableState>(find.byType(Scrollable));
    expect(find.text('Message 82').hitTestable(), findsOneWidget);
    expect(state.position.pixels, 0);
    expect(state.position.isScrollingNotifier.value, isFalse);
  });
}
