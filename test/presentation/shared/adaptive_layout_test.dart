import 'package:app/presentation/chats/chat_pane_navigation.dart';
import 'dart:ui' show DisplayFeature, DisplayFeatureType, DisplayFeatureState;
import 'package:app/presentation/shared/adaptive_layout.dart';
import 'package:app/presentation/shared/adaptive_navigation.dart';
import 'package:app/presentation/shared/adaptive_player_frame.dart';
import 'package:app/presentation/shared/adaptive_overlays.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:app/presentation/shared/app_viewport.dart';
import 'package:app/presentation/shared/adaptive_viewport_state.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
    'Duo rail occupies the outer safe strip and pages stay protected',
    (tester) async {
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
      addTearDown(() => debugDefaultTargetPlatformOverride = null);
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(1000, 700);
      tester.view.padding = const FakeViewPadding(right: 80);
      addTearDown(tester.view.reset);
      const channel = MethodChannel('bantera/adaptive_layout');
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        channel,
        (_) async => {'edge': 'right', 'statusBarBottom': 100},
      );
      addTearDown(
        () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
          channel,
          null,
        ),
      );
      await tester.pumpWidget(
        MaterialApp(
          navigatorObservers: [adaptiveViewportObserver],
          builder: (context, child) => AppViewport(child: child!),
          home: Builder(
            builder: (context) => Scaffold(
              body: AdaptiveMainNavigation(
                body: TextButton(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const Scaffold(
                        body: SizedBox.expand(key: Key('page')),
                      ),
                    ),
                  ),
                  child: const Text('Open page'),
                ),
                selectedIndex: 0,
                onSelected: (_) {},
                items: const [
                  BottomNavigationBarItem(
                    icon: Icon(Icons.mic, key: Key('railIcon')),
                    label: 'Practice',
                  ),
                ],
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.getCenter(find.byKey(const Key('railIcon'))).dx, 960);
      await tester.tap(find.text('Open page'));
      await tester.pumpAndSettle();
      expect(tester.getRect(find.byKey(const Key('page'))).right, 920);
      await tester.pumpWidget(const SizedBox());
      await tester.pump();
      debugDefaultTargetPlatformOverride = null;
    },
  );

  for (final edge in NavigationEdge.values) {
    testWidgets('nested chat consumes bottom safe area once with $edge tabs', (
      tester,
    ) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(390, 844);
      tester.view.padding = const FakeViewPadding(bottom: 34);
      tester.view.viewPadding = const FakeViewPadding(bottom: 34);
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        MaterialApp(
          home: AdaptiveLayoutScope(
            data: AdaptiveLayoutData(edge: edge),
            child: Scaffold(
              body: AdaptiveMainNavigation(
                body: Navigator(
                  onGenerateRoute: (_) => MaterialPageRoute<void>(
                    builder: (_) => Scaffold(
                      body: Column(
                        children: [
                          const Expanded(child: SizedBox()),
                          SafeArea(
                            top: false,
                            child: SizedBox(
                              key: const Key('composer'),
                              height: 64,
                              width: double.infinity,
                              child: Builder(
                                builder: (context) {
                                  expect(
                                    MediaQuery.paddingOf(context).bottom,
                                    0,
                                  );
                                  return const Text('Tap or hold to record');
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                selectedIndex: 0,
                onSelected: (_) {},
                items: const [
                  BottomNavigationBarItem(
                    icon: Icon(Icons.chat),
                    label: 'Chats',
                  ),
                ],
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      // Horizontal: composer meets the top of the 72pt tab bar plus 34pt
      // home-indicator area. Vertical: preserve the 34pt bottom safe area.
      expect(
        tester.getRect(find.byKey(const Key('composer'))).bottom,
        edge == NavigationEdge.horizontal ? 844 - 72 - 34 : 844 - 34,
      );
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets(
    'conversation hides tabs, retains state on resize and restores tabs on back',
    (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(390, 844);
      tester.view.padding = const FakeViewPadding(bottom: 34);
      tester.view.viewPadding = const FakeViewPadding(bottom: 34);
      addTearDown(tester.view.reset);
      final navigator = GlobalKey<NavigatorState>();
      var detail = false;
      var edge = NavigationEdge.horizontal;
      late StateSetter update;
      final observer = ChatPaneNavigationObserver((value) {
        tester.binding.addPostFrameCallback((_) {
          if (detail != value) update(() => detail = value);
        });
      });
      final draft = TextEditingController(text: 'Unsent message');
      addTearDown(draft.dispose);
      await tester.pumpWidget(
        MaterialApp(
          home: StatefulBuilder(
            builder: (context, setState) {
              update = setState;
              return AdaptiveLayoutScope(
                data: AdaptiveLayoutData(edge: edge),
                child: Scaffold(
                  body: AdaptiveMainNavigation(
                    visible: !detail,
                    selectedIndex: 0,
                    onSelected: (_) {},
                    items: const [
                      BottomNavigationBarItem(
                        icon: Icon(Icons.chat),
                        label: 'Chats',
                      ),
                    ],
                    body: Navigator(
                      key: navigator,
                      observers: [observer],
                      onGenerateRoute: (_) => MaterialPageRoute<void>(
                        builder: (_) =>
                            const Scaffold(body: Text('Conversation list')),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      );
      await tester.pumpAndSettle();
      // Opening a dialog on the list must not hide tabs.
      final dialog = DialogRoute<void>(
        context: navigator.currentContext!,
        builder: (_) => const AlertDialog(title: Text('Confirm')),
      );
      navigator.currentState!.push(dialog);
      await tester.pumpAndSettle();
      expect(find.text('Chats'), findsOneWidget);
      navigator.currentState!.pop();
      await tester.pumpAndSettle();
      navigator.currentState!.push(
        MaterialPageRoute<void>(
          builder: (_) => Scaffold(
            appBar: AppBar(title: const Text('Conversation')),
            body: SafeArea(
              top: false,
              child: Column(
                children: [
                  Expanded(child: TextField(controller: draft)),
                  const SizedBox(
                    key: Key('fullComposer'),
                    height: 64,
                    width: double.infinity,
                  ),
                ],
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Chats'), findsNothing);
      expect(tester.getRect(find.byKey(const Key('fullComposer'))).bottom, 810);
      final state = tester.state(find.byType(EditableText));
      for (final side in [
        NavigationEdge.right,
        NavigationEdge.left,
        NavigationEdge.horizontal,
      ]) {
        update(() => edge = side);
        tester.view.physicalSize = side == NavigationEdge.horizontal
            ? const Size(390, 844)
            : const Size(1000, 700);
        await tester.pumpAndSettle();
        expect(find.text('Chats'), findsNothing);
        expect(adaptiveViewportState.usesEdgeRail, isFalse);
        expect(tester.state(find.byType(EditableText)), same(state));
        expect(draft.text, 'Unsent message');
      }
      await tester.tap(find.byTooltip('Back'));
      await tester.pumpAndSettle();
      expect(find.text('Conversation list'), findsOneWidget);
      expect(find.text('Chats'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  test('native signals preserve physical bar edge and active fold', () {
    final data = AdaptiveLayoutData.fromMap({
      'edge': 'left',
      'hingeStatus': 2,
      'regions': [
        {'kind': 'division', 'x': 480, 'y': 0, 'width': 40, 'height': 700},
      ],
    });
    expect(data.edge, NavigationEdge.left);
    expect(data.regions.single.state, DisplayFeatureState.postureHalfOpened);
    expect(AdaptiveLayoutData.fromMap({}).edge, NavigationEdge.horizontal);
  });

  testWidgets('resizing preserves draft, focus and state in both panes', (
    tester,
  ) async {
    final controller = TextEditingController(text: 'Unsent draft');
    final focus = FocusNode();
    addTearDown(controller.dispose);
    addTearDown(focus.dispose);
    tester.view.reset();
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    Widget app() => MaterialApp(
      home: Scaffold(
        body: AdaptiveColumns(
          fillHeight: true,
          singlePane: 1,
          textScale: 1,
          first: const Text('Conversations'),
          second: TextField(controller: controller, focusNode: focus),
        ),
      ),
    );
    tester.view.physicalSize = const Size(1000, 800);
    await tester.pumpWidget(app());
    await tester.tap(find.byType(TextField));
    await tester.pump();
    final state = tester.state(find.byType(EditableText));
    tester.view.physicalSize = const Size(390, 844);
    await tester.pump();
    expect(tester.state(find.byType(EditableText)), same(state));
    expect(controller.text, 'Unsent draft');
    expect(focus.hasFocus, isTrue);
    tester.view.physicalSize = const Size(1000, 800);
    await tester.pump();
    expect(tester.state(find.byType(EditableText)), same(state));
    expect(tester.takeException(), isNull);
  });

  testWidgets('book layout keeps both columns out of reserved fold', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(1000, 800);
    addTearDown(tester.view.reset);
    const feature = DisplayFeature(
      bounds: Rect.fromLTWH(460, 0, 80, 800),
      type: DisplayFeatureType.fold,
      state: DisplayFeatureState.postureHalfOpened,
    );
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: AdaptiveColumns(
              textScale: 1,
              regions: const [feature],
              first: const SizedBox(key: Key('a'), height: 100),
              second: const SizedBox(key: Key('b'), height: 200),
            ),
          ),
        ),
      ),
    );
    expect(tester.getRect(find.byKey(const Key('a'))).right, 460);
    expect(tester.getRect(find.byKey(const Key('b'))).left, 540);
  });

  testWidgets(
    'tabletop uses actual horizontal division for playback controls',
    (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(800, 1000);
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AdaptivePlayerFrame(
              regions: const [
                DisplayFeature(
                  bounds: Rect.fromLTWH(0, 470, 800, 60),
                  type: DisplayFeatureType.fold,
                  state: DisplayFeatureState.postureHalfOpened,
                ),
              ],
              content: const SizedBox(key: Key('content')),
              controls: const SizedBox(
                key: Key('controls'),
                width: 400,
                height: 150,
              ),
            ),
          ),
        ),
      );
      expect(tester.getRect(find.byKey(const Key('content'))).bottom, 470);
      expect(tester.getRect(find.byKey(const Key('controls'))).top, 530);
    },
  );

  testWidgets('tab edge changes keep body state and repeated tap behavior', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(1000, 700);
    addTearDown(tester.view.reset);
    var taps = 0;
    Widget app(NavigationEdge edge) => MaterialApp(
      home: AdaptiveLayoutScope(
        data: AdaptiveLayoutData(edge: edge),
        child: Scaffold(
          body: AdaptiveMainNavigation(
            body: const TextField(key: Key('draft')),
            selectedIndex: 0,
            onSelected: (_) => taps++,
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.mic), label: 'Practice'),
              BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'Chats'),
              BottomNavigationBarItem(icon: Icon(Icons.flag), label: 'Goal'),
            ],
          ),
        ),
      ),
    );
    await tester.pumpWidget(app(NavigationEdge.horizontal));
    final state = tester.state(find.byType(EditableText));
    for (final edge in [
      NavigationEdge.right,
      NavigationEdge.left,
      NavigationEdge.horizontal,
    ]) {
      await tester.pumpWidget(app(edge));
      expect(tester.state(find.byType(EditableText)), same(state));
      await tester.tap(find.text('Practice'));
      await tester.tap(find.text('Practice'));
    }
    expect(taps, 6);
    expect(tester.takeException(), isNull);
  });

  testWidgets('large text navigation fits the compact outer display', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(740, 350);
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(
        home: MediaQuery(
          data: const MediaQueryData(textScaler: TextScaler.linear(2.5)),
          child: AdaptiveLayoutScope(
            data: const AdaptiveLayoutData(edge: NavigationEdge.right),
            child: Scaffold(
              body: AdaptiveMainNavigation(
                body: const SizedBox(),
                selectedIndex: 0,
                onSelected: (_) {},
                items: const [
                  BottomNavigationBarItem(
                    icon: Icon(Icons.mic),
                    label: 'Practice',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.chat),
                    label: 'Chats',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.flag),
                    label: 'Goal',
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('dialog anchor selects the clear trailing book pane', (
    tester,
  ) async {
    Offset? anchor;
    await tester.pumpWidget(
      MaterialApp(
        home: AdaptiveLayoutScope(
          data: const AdaptiveLayoutData(
            regions: [
              DisplayFeature(
                bounds: Rect.fromLTWH(480, 0, 40, 800),
                type: DisplayFeatureType.fold,
                state: DisplayFeatureState.postureHalfOpened,
              ),
            ],
          ),
          child: Builder(
            builder: (context) {
              anchor = adaptiveOverlayAnchor(context);
              return const SizedBox();
            },
          ),
        ),
      ),
    );
    expect(anchor, const Offset(521, 0));
  });
}
