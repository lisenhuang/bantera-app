import 'package:app/presentation/shared/adaptive_layout.dart';
import 'dart:async';
import 'dart:io';
import 'package:app/presentation/quick_practice/practice_speaking_hint_store.dart';
import 'package:app/l10n/app_localizations.dart';
import 'package:app/presentation/quick_practice/practice_record_control.dart';
import 'package:app/presentation/quick_practice/practice_recording_layout.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';

class MemoryHintStore extends PracticeSpeakingHintStore {
  bool dismissed = false;
  @override
  Future<bool> isDismissed() async => dismissed;
  @override
  Future<void> dismiss() async {
    dismissed = true;
  }
}

class RecordingHarness extends StatefulWidget {
  const RecordingHarness({
    super.key,
    this.scrolling = false,
    this.hintStore,
    this.reduceMotion = false,
    this.adaptive = false,
  });
  final PracticeSpeakingHintStore? hintStore;
  final bool reduceMotion;
  final bool scrolling;
  final bool adaptive;
  @override
  State<RecordingHarness> createState() => RecordingHarnessState();
}

class RecordingHarnessState extends State<RecordingHarness> {
  bool recording = false, busy = false, enabled = true;
  int starts = 0, checks = 0, cancels = 0;
  String reading = 'Waiting for pronunciation';
  final scroll = ScrollController();
  void finishBackgroundReading() =>
      setState(() => reading = 'New pronunciation arrived');
  Completer<void>? startup;
  Timer? limit;
  Future<void> start(bool Function() wanted) async {
    setState(() => busy = true);
    await startup?.future;
    if (wanted()) {
      starts++;
      setState(() => recording = true);
      limit = Timer(const Duration(seconds: 30), check);
    }
    setState(() => busy = false);
  }

  Future<void> check() async {
    if (!recording) return;
    limit?.cancel();
    checks++;
    setState(() => recording = false);
  }

  Future<void> cancel() async {
    limit?.cancel();
    cancels++;
    setState(() => recording = false);
  }

  void enable() => setState(() => enabled = true);

  void interrupt() {
    limit?.cancel();
    setState(() {
      recording = false;
      enabled = false;
    });
  }

  @override
  void dispose() {
    limit?.cancel();
    scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final control = PracticeRecordControl(
      hintStore: widget.hintStore ?? MemoryHintStore(),
      enabled: enabled,
      recording: recording,
      busy: busy,
      pulse: const AlwaysStoppedAnimation(0),
      onStart: start,
      onCheck: check,
      onCancel: cancel,
    );
    return MaterialApp(
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(
          context,
        ).copyWith(disableAnimations: widget.reduceMotion),
        child: child!,
      ),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: widget.adaptive
            ? SingleChildScrollView(
                controller: scroll,
                child: PracticeRecordingLayout(
                  pinned: busy || recording,
                  children: [
                    Text(reading),
                    AdaptiveColumns(
                      textScale: 1,
                      first: PracticeRecordingLayout(
                        pinned: busy || recording,
                        children: [Text(reading), const SizedBox(height: 250)],
                      ),
                      second: PracticeRecordingLayout(
                        pinned: busy || recording,
                        children: [
                          Text(reading),
                          control,
                          if (!recording)
                            const SizedBox(
                              height: 200,
                              child: Text('Previous feedback'),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              )
            : widget.scrolling
            ? SingleChildScrollView(
                controller: scroll,
                child: PracticeRecordingLayout(
                  pinned: busy || recording,
                  children: [
                    const SizedBox(height: 400),
                    Text(reading),
                    control,
                    if (!busy && !recording)
                      const SizedBox(
                        height: 250,
                        child: Text('Previous feedback'),
                      ),
                    if (!busy && !recording) const Text('Next practice'),
                  ],
                ),
              )
            : Center(child: control),
      ),
    );
  }
}

void main() {
  final button = find.byKey(const ValueKey('practice-record-button'));
  Future<RecordingHarnessState> mount(WidgetTester tester) async {
    final key = GlobalKey<RecordingHarnessState>();
    await tester.pumpWidget(RecordingHarness(key: key));
    return key.currentState!;
  }

  test('hint dismissal survives a new store instance', () async {
    final directory = await Directory.systemTemp.createTemp(
      'practice-hint-test',
    );
    try {
      final file = File('${directory.path}/hint');
      final store = PracticeSpeakingHintStore(file: file);
      expect(await store.isDismissed(), isFalse);
      await store.dismiss();
      expect(await PracticeSpeakingHintStore(file: file).isDismissed(), isTrue);
    } finally {
      await directory.delete(recursive: true);
    }
  });

  testWidgets('Reduce Motion leaves first-use guidance static', (tester) async {
    await tester.pumpWidget(
      RecordingHarness(hintStore: MemoryHintStore(), reduceMotion: true),
    );
    await tester.pump();
    expect(find.text('Say the correct reply aloud.'), findsOneWidget);
    expect(tester.binding.hasScheduledFrame, isFalse);
    expect(tester.takeException(), isNull);
  });

  testWidgets('first attempt completes guidance and remount keeps it hidden', (
    tester,
  ) async {
    final store = MemoryHintStore();
    await tester.pumpWidget(RecordingHarness(hintStore: store));
    await tester.pumpAndSettle();
    expect(find.text('Say the correct reply aloud.'), findsOneWidget);
    await tester.tap(button);
    await tester.pump();
    await tester.tap(button);
    await tester.pumpAndSettle();
    expect(store.dismissed, isTrue);
    expect(find.text('Say the correct reply aloud.'), findsNothing);
    await tester.pumpWidget(const SizedBox());
    await tester.pumpWidget(RecordingHarness(hintStore: store));
    await tester.pumpAndSettle();
    expect(find.text('Say the correct reply aloud.'), findsNothing);
  });

  testWidgets('hint can be dismissed without recording', (tester) async {
    final store = MemoryHintStore();
    await tester.pumpWidget(RecordingHarness(hintStore: store));
    await tester.pumpAndSettle();
    await tester.tap(
      find.byKey(const ValueKey('dismiss-practice-speaking-hint')),
    );
    await tester.pumpAndSettle();
    expect(store.dismissed, isTrue);
    expect(find.text('Say the correct reply aloud.'), findsNothing);
  });

  testWidgets(
    'wide Practice holds mic position while background content changes',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(1000, 800));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      final key = GlobalKey<RecordingHarnessState>();
      await tester.pumpWidget(RecordingHarness(key: key, adaptive: true));
      final state = key.currentState!;
      final rect = tester.getRect(button);
      final gesture = await tester.startGesture(rect.center);
      await tester.pump(const Duration(milliseconds: 301));
      await tester.pump();
      expect(state.recording, isTrue);
      state.finishBackgroundReading();
      await tester.pump();
      expect(tester.getRect(button), rect);
      expect(find.text('New pronunciation arrived'), findsNothing);
      await gesture.up();
      await tester.pump();
      expect(state.checks, 1);
      expect(find.text('New pronunciation arrived'), findsNWidgets(3));
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'holding retains content, scroll extent and mic position through background updates',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(393, 700));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      final key = GlobalKey<RecordingHarnessState>();
      await tester.pumpWidget(RecordingHarness(key: key, scrolling: true));
      final state = key.currentState!;
      state.scroll.jumpTo(state.scroll.position.maxScrollExtent);
      await tester.pump();
      final position = tester.getRect(button);
      final extent = state.scroll.position.maxScrollExtent;
      state.startup = Completer<void>();
      final gesture = await tester.startGesture(position.center);
      await tester.pump(const Duration(milliseconds: 301));
      expect(tester.getRect(button), position);
      expect(state.scroll.position.maxScrollExtent, extent);
      expect(find.text('Previous feedback'), findsOneWidget);
      state.startup!.complete();
      await tester.pump();
      state.finishBackgroundReading();
      await tester.pump();
      expect(tester.getRect(button), position);
      expect(state.scroll.position.maxScrollExtent, extent);
      expect(find.text('Waiting for pronunciation'), findsOneWidget);
      expect(find.text('New pronunciation arrived'), findsNothing);
      expect(find.text('Previous feedback'), findsOneWidget);
      expect(find.text('Next practice'), findsOneWidget);
      await gesture.up();
      await tester.pump();
      expect(state.checks, 1);
      expect(find.text('New pronunciation arrived'), findsOneWidget);
    },
  );
  testWidgets(
    'tap starts; next tap checks once; hint describes both gestures',
    (tester) async {
      final state = await mount(tester);
      expect(find.text('Tap or hold to answer'), findsOneWidget);
      await tester.tap(button);
      await tester.pump();
      expect(state.starts, 1);
      expect(state.recording, isTrue);
      expect(find.text('Tap to check'), findsOneWidget);
      await tester.tap(button);
      await tester.pump();
      expect(state.checks, 1);
      expect(state.recording, isFalse);
    },
  );
  testWidgets(
    'hold begins at 300 ms, retains release after rebuild, checks once',
    (tester) async {
      final state = await mount(tester);
      final gesture = await tester.startGesture(tester.getCenter(button));
      await tester.pump(const Duration(milliseconds: 299));
      expect(state.starts, 0);
      await tester.pump(const Duration(milliseconds: 2));
      await tester.pump();
      expect(state.starts, 1);
      expect(find.text('Release to check'), findsOneWidget);
      await gesture.up();
      await tester.pump();
      expect(state.checks, 1);
      expect(state.starts, 1);
      expect(state.recording, isFalse);
    },
  );
  testWidgets(
    'release during permission startup prevents late recording or submission',
    (tester) async {
      final state = await mount(tester);
      state.startup = Completer<void>();
      final gesture = await tester.startGesture(tester.getCenter(button));
      await tester.pump(const Duration(milliseconds: 301));
      expect(find.text('Starting microphone…'), findsOneWidget);
      await gesture.up();
      await tester.pump();
      state.startup!.complete();
      await tester.pump();
      expect(state.starts, 0);
      expect(state.checks, 0);
      expect(state.recording, isFalse);
    },
  );
  testWidgets('repeated taps cannot duplicate a pending start', (tester) async {
    final state = await mount(tester);
    state.startup = Completer<void>();
    await tester.tap(button);
    await tester.pump();
    await tester.tap(button, warnIfMissed: false);
    await tester.pump();
    state.startup!.complete();
    await tester.pump();
    expect(state.starts, 1);
    await tester.tap(button);
    await tester.pump();
    expect(state.checks, 1);
  });
  testWidgets(
    'pointer cancellation discards held recording instead of checking',
    (tester) async {
      final state = await mount(tester);
      final gesture = await tester.startGesture(tester.getCenter(button));
      await tester.pump(const Duration(milliseconds: 301));
      await tester.pump();
      await gesture.cancel();
      await tester.pump();
      expect(state.cancels, 1);
      expect(state.checks, 0);
      expect(state.recording, isFalse);
    },
  );
  testWidgets(
    'cancel before threshold never starts, interrupted hold never submits',
    (tester) async {
      final state = await mount(tester);
      var gesture = await tester.startGesture(tester.getCenter(button));
      await tester.pump(const Duration(milliseconds: 100));
      await gesture.cancel();
      await tester.pump();
      expect(state.starts, 0);
      gesture = await tester.startGesture(tester.getCenter(button));
      await tester.pump(const Duration(milliseconds: 301));
      await tester.pump();
      state.interrupt();
      await tester.pump();
      await gesture.up();
      await tester.pump();
      expect(state.checks, 0);
      expect(state.recording, isFalse);
    },
  );
  testWidgets(
    'interruption during startup invalidates intent even after re-enable',
    (tester) async {
      final state = await mount(tester);
      state.startup = Completer<void>();
      await tester.tap(button);
      await tester.pump();
      state.interrupt();
      await tester.pump();
      state.enable();
      await tester.pump();
      state.startup!.complete();
      await tester.pump();
      expect(state.starts, 0);
      expect(state.checks, 0);
    },
  );
  for (final hold in [false, true]) {
    testWidgets(
      '30-second completion followed by ${hold ? "release" : "idle"} does not duplicate check',
      (tester) async {
        final state = await mount(tester);
        TestGesture? gesture;
        if (hold) {
          gesture = await tester.startGesture(tester.getCenter(button));
          await tester.pump(const Duration(milliseconds: 301));
        } else {
          await tester.tap(button);
        }
        await tester.pump();
        await tester.pump(const Duration(seconds: 30));
        await tester.pump();
        await gesture?.up();
        await tester.pump();
        expect(state.checks, 1);
        expect(state.recording, isFalse);
      },
    );
  }
  testWidgets('screen reader can start and check with the button tap action', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    final state = await mount(tester);
    var node = tester.getSemantics(button);
    expect(node.getSemanticsData().hasAction(SemanticsAction.tap), isTrue);
    node.owner!.performAction(node.id, SemanticsAction.tap);
    await tester.pump();
    expect(state.recording, isTrue);
    node = tester.getSemantics(button);
    node.owner!.performAction(node.id, SemanticsAction.tap);
    await tester.pump();
    expect(state.checks, 1);
    handle.dispose();
  });
}
