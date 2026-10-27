import 'dart:async';
import 'package:app/core/practice_review_service.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:app/l10n/app_localizations.dart';
import 'package:app/presentation/quick_practice/quick_practice_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class _Player extends Fake implements AudioPlayer {
  final positions = StreamController<Duration>.broadcast();
  final durations = StreamController<Duration>.broadcast();
  final completions = StreamController<void>.broadcast();
  final sources = <Source>[];
  final rates = <double>[];
  Duration position = Duration.zero;
  int pauses = 0, resumes = 0;
  @override
  PlayerState state = PlayerState.stopped;
  @override
  Stream<Duration> get onPositionChanged => positions.stream;
  @override
  Stream<Duration> get onDurationChanged => durations.stream;
  @override
  Stream<void> get onPlayerComplete => completions.stream;
  @override
  Future<void> stop() async {
    state = PlayerState.stopped;
    position = Duration.zero;
  }

  @override
  Future<void> setSource(Source source) async {
    sources.add(source);
    position = Duration.zero;
    durations.add(const Duration(seconds: 10));
  }

  @override
  Future<void> resume() async {
    resumes++;
    state = PlayerState.playing;
  }

  @override
  Future<void> pause() async {
    pauses++;
    state = PlayerState.paused;
  }

  @override
  Future<void> setPlaybackRate(double rate) async => rates.add(rate);
  @override
  Future<void> dispose() async {
    await positions.close();
    await durations.close();
    await completions.close();
  }
}

// Match MainScaffold: any modal route marks Practice inactive.
class _ObservedPractice extends StatefulWidget {
  const _ObservedPractice({
    required this.observer,
    required this.active,
    required this.builder,
  });
  final PracticeRouteObserver observer;
  final bool active;
  final Widget Function(bool active) builder;
  @override
  State<_ObservedPractice> createState() => _ObservedPracticeState();
}

class _ObservedPracticeState extends State<_ObservedPractice> with RouteAware {
  bool covered = false;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    widget.observer.subscribe(this, ModalRoute.of(context)!);
  }

  @override
  void didPushNext() => setState(() => covered = true);
  @override
  void didPopNext() => setState(() => covered = false);
  @override
  void dispose() {
    widget.observer.unsubscribe(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      widget.builder(widget.active && !covered);
}

void main() {
  testWidgets('speed changes and repeated play taps preserve paused position', (
    tester,
  ) async {
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.binding.setSurfaceSize(const Size(393, 1000));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final player = _Player();
    final key = GlobalKey();
    final observer = PracticeRouteObserver();
    Widget screen(bool active) => MaterialApp(
      navigatorObservers: [observer],
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: _ObservedPractice(
        observer: observer,
        active: active,
        builder: (active) => QuickPracticeScreen.preview(
          key: key,
          active: active,
          previewPlayer: player,
          previewExercise: const {
            'id': 'speed-test',
            'level': 'A1',
            'cue': 'Where is the station?',
            'cueAudioUrl': 'https://example.org/cue.mp3',
            'choices': [
              {
                'text': 'It is nearby.',
                'audioUrl': 'https://example.org/one.mp3',
              },
              {
                'text': 'It is far away.',
                'audioUrl': 'https://example.org/two.mp3',
              },
            ],
          },
        ),
      ),
    );
    await tester.pumpWidget(screen(true));
    await tester.pumpAndSettle();
    final speed = find.byKey(const ValueKey('practice-playback-speed'));
    Future<void> chooseSpeed(double value) async {
      await tester.tap(speed);
      await tester.pumpAndSettle();
      expect(find.byType(MenuItemButton), findsNWidgets(5));
      expect(
        find.byKey(const ValueKey('practice-speed-selected')),
        findsOneWidget,
      );
      await tester.tap(find.byKey(ValueKey('practice-speed-$value')));
      await tester.pumpAndSettle();
    }

    final cue = find.byKey(const ValueKey('practice-play-cue'));
    final option = find.byKey(const ValueKey('practice-play-option0'));
    expect(find.text('1×'), findsOneWidget);
    await chooseSpeed(1.25);
    expect(find.text('1.25×'), findsOneWidget);
    await tester.tap(cue);
    await tester.pumpAndSettle();
    expect(player.rates.last, 1.25);
    expect(player.state, PlayerState.playing);
    player.position = const Duration(seconds: 4);
    player.positions.add(player.position);
    await tester.pumpAndSettle();
    await tester.tap(cue);
    await tester.pumpAndSettle();
    expect(player.state, PlayerState.paused);
    expect(find.byTooltip('Resume audio'), findsOneWidget);
    await chooseSpeed(1.5);
    expect(player.rates.last, 1.5);
    expect(find.text('1.5×'), findsOneWidget);
    await chooseSpeed(.5);
    expect(player.rates.last, .5);
    expect(player.state, PlayerState.paused);
    await tester.tap(cue);
    await tester.pumpAndSettle();
    expect(player.position, const Duration(seconds: 4));
    expect(player.sources, hasLength(1));
    expect(player.resumes, 2);
    expect(player.pauses, 1);
    expect(find.byTooltip('Pause audio'), findsOneWidget);
    await chooseSpeed(.75);
    expect(player.rates.last, .75);
    expect(player.position, const Duration(seconds: 4));
    await chooseSpeed(1.0);
    expect(find.text('1×'), findsOneWidget);
    await tester.tap(option);
    await tester.pumpAndSettle();
    expect(player.sources, hasLength(2));
    expect(player.position, Duration.zero);
    player.position = const Duration(seconds: 2);
    await tester.tap(option);
    await tester.pumpAndSettle();
    await tester.tap(option);
    await tester.pumpAndSettle();
    expect(player.position, const Duration(seconds: 2));
    expect(player.sources, hasLength(2));
    player.state = PlayerState.completed;
    player.completions.add(null);
    await tester.pumpAndSettle();
    await tester.tap(option);
    await tester.pumpAndSettle();
    expect(player.sources, hasLength(3));
    expect(player.position, Duration.zero);
    await tester.pumpWidget(screen(false));
    await tester.pumpAndSettle();
    expect(player.state, PlayerState.stopped);
    expect(tester.takeException(), isNull);
  });
}
