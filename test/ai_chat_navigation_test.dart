import 'dart:async';
import 'package:app/presentation/chats/ai/ai_chat_navigation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('word explanation waits for Back when AI is already open', (
    tester,
  ) async {
    final navigator = GlobalKey<NavigatorState>();
    final navigation = AiChatNavigation();
    var returnedToPractice = false;
    var builds = 0;
    Widget page(BuildContext context) {
      builds++;
      return Scaffold(appBar: AppBar(title: const Text('AI explanation')));
    }

    await tester.pumpWidget(
      MaterialApp(
        navigatorKey: navigator,
        home: const Scaffold(body: Text('Practice origin')),
      ),
    );
    unawaited(navigation.open(navigator.currentState!, page));
    await tester.pumpAndSettle();
    // Practice reuses the same AI conversation; it must wait for that route's
    // actual dismissal before running its origin-restoration callback.
    unawaited(
      navigation.open(navigator.currentState!, page).then((_) {
        returnedToPractice = true;
      }),
    );
    await tester.pumpAndSettle();
    expect(builds, 1);
    expect(returnedToPractice, isFalse);
    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
    expect(returnedToPractice, isTrue);
    expect(find.text('Practice origin'), findsOneWidget);
  });

  testWidgets('Practice explanation returns directly during every Back frame', (
    tester,
  ) async {
    final root = GlobalKey<NavigatorState>();
    final pane = GlobalKey<NavigatorState>();
    final navigation = AiChatNavigation();
    var activeViews = 0;
    var readyAfterDisposal = false;
    Widget page(BuildContext context) => _TrackedChat(
      onMount: () => activeViews++,
      onDispose: () => activeViews--,
    );
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(platform: TargetPlatform.iOS),
        navigatorKey: root,
        home: Scaffold(
          body: Stack(
            children: [
              const Center(child: Text('Practice origin')),
              Offstage(
                offstage: true,
                child: Navigator(
                  key: pane,
                  onGenerateRoute: (_) => MaterialPageRoute<void>(
                    builder: (_) => const Scaffold(body: Text('Chats list')),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
    // An earlier chat can still be retained in the hidden Chats pane.
    unawaited(navigation.open(pane.currentState!, page));
    await tester.pumpAndSettle();
    expect(activeViews, 1);
    unawaited(
      navigation.open(
        root.currentState!,
        page,
        onReady: () {
          readyAfterDisposal = activeViews == 0;
        },
      ),
    );
    await tester.pumpAndSettle();
    expect(readyAfterDisposal, isTrue);
    expect(activeViews, 1);
    expect(pane.currentState!.canPop(), isFalse);
    expect(root.currentState!.canPop(), isTrue);
    // The interactive iOS gesture must reveal Practice immediately, not Chats.
    final gesture = await tester.startGesture(const Offset(5, 300));
    await gesture.moveBy(const Offset(160, 0));
    await tester.pump();
    expect(find.text('Practice origin'), findsOneWidget);
    expect(find.text('Chats list'), findsNothing);
    await gesture.cancel();
    await tester.pumpAndSettle();
    await tester.tap(find.byType(BackButton));
    for (var frame = 0; frame < 40; frame++) {
      await tester.pump(const Duration(milliseconds: 16));
      expect(find.text('Chats list'), findsNothing);
    }
    await tester.pumpAndSettle();
    expect(find.text('Practice origin'), findsOneWidget);
    expect(activeViews, 0);
    expect(root.currentState!.canPop(), isFalse);
    expect(tester.takeException(), isNull);
  });

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

class _TrackedChat extends StatefulWidget {
  const _TrackedChat({required this.onMount, required this.onDispose});
  final VoidCallback onMount;
  final VoidCallback onDispose;
  @override
  State<_TrackedChat> createState() => _TrackedChatState();
}

class _TrackedChatState extends State<_TrackedChat> {
  @override
  void initState() {
    super.initState();
    widget.onMount();
  }

  @override
  void dispose() {
    widget.onDispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('AI explanation')),
    body: const Text('AI conversation'),
  );
}
