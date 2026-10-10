import 'dart:async';
import 'package:app/presentation/chats/ai/ai_chat_navigation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  for (final platform in [TargetPlatform.iOS, TargetPlatform.android]) {
    testWidgets(
      'AI opens once, settles after cancelled swipe and rapid reopen',
      (tester) async {
        final navigator = GlobalKey<NavigatorState>();
        final navigation = AiChatNavigation();
        var builds = 0;
        Widget page(BuildContext context) {
          builds++;
          return const Scaffold(
            key: ValueKey('ai-page'),
            body: Text('Conversation'),
          );
        }

        void open() =>
            unawaited(navigation.open(navigator.currentState!, page));
        await tester.pumpWidget(
          MaterialApp(
            theme: ThemeData(platform: platform),
            navigatorKey: navigator,
            home: Scaffold(
              body: TextButton(onPressed: open, child: const Text('Open AI')),
            ),
          ),
        );
        open();
        open();
        open();
        await tester.pumpAndSettle();
        expect(builds, 1);
        expect(
          tester.getTopLeft(find.byKey(const ValueKey('ai-page'))),
          Offset.zero,
        );
        final route = ModalRoute.of(tester.element(find.text('Conversation')))!;
        expect(route.isCurrent, isTrue);
        expect(route.animation!.isCompleted, isTrue);

        if (platform == TargetPlatform.iOS) {
          final gesture = await tester.startGesture(const Offset(5, 300));
          await gesture.moveBy(const Offset(120, 0));
          await tester.pump();
          expect(navigator.currentState!.userGestureInProgress, isTrue);
          open(); // Deep link arriving while the interactive pop is incomplete.
          await gesture.cancel();
          await tester.pumpAndSettle();
          expect(builds, 1);
          expect(route.isCurrent, isTrue);
          expect(route.animation!.isCompleted, isTrue);
          expect(navigator.currentState!.userGestureInProgress, isFalse);
          expect(
            tester.getTopLeft(find.byKey(const ValueKey('ai-page'))),
            Offset.zero,
          );
        }

        navigator.currentState!.pop();
        open(); // The old route has not finished its exit animation yet.
        open();
        await tester.pumpAndSettle();
        expect(builds, 2);
        expect(
          tester.getTopLeft(find.byKey(const ValueKey('ai-page'))),
          Offset.zero,
        );
        expect(
          ModalRoute.of(tester.element(find.text('Conversation')))!.isCurrent,
          isTrue,
        );
        navigator.currentState!.pop();
        await tester.pumpAndSettle();
        expect(find.text('Open AI'), findsOneWidget);
        expect(navigator.currentState!.canPop(), isFalse);
        expect(tester.takeException(), isNull);
      },
    );
  }
}
