import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:app/l10n/app_localizations.dart';
import 'package:app/presentation/chats/voice_message_composer.dart';
import 'package:app/presentation/chats/chat_recording_countdown.dart';

class Harness extends StatefulWidget {
  const Harness({
    super.key,
    this.locale = const Locale('en'),
    this.maxSeconds = 180,
  });
  final Locale locale;
  final int maxSeconds;
  @override
  State<Harness> createState() => HarnessState();
}

class HarnessState extends State<Harness> {
  int sent = 0, cancelled = 0, starts = 0, remaining = 180, elapsed = 0;
  bool recording = false, enabled = true;
  Completer<void>? startGate;
  late final timer = ChatRecordingCountdown(
    maxSeconds: widget.maxSeconds,
    elapsedMilliseconds: () => elapsed,
    onTick: (value) => setState(() => remaining = value),
    onExpired: send,
  );
  Future<void> send() async {
    if (!recording) return;
    setState(() {
      recording = false;
      sent++;
    });
    timer.cancel();
  }

  void disable() => setState(() => enabled = false);

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => MaterialApp(
    locale: widget.locale,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(
      body: Align(
        alignment: Alignment.bottomCenter,
        child: VoiceMessageComposer(
          enabled: enabled,
          recording: recording,
          remainingSeconds: remaining,
          onStart: () async {
            starts++;
            await startGate?.future;
            setState(() {
              recording = true;
              elapsed = 0;
            });
            timer.start();
          },
          onSend: send,
          onCancel: () async {
            setState(() {
              recording = false;
              cancelled++;
            });
            timer.cancel();
          },
        ),
      ),
    ),
  );
}

final recordButton = find.byKey(const Key('voice-record-button'));

void main() {
  testWidgets('same wide button taps to record, taps to send, and can cancel', (
    tester,
  ) async {
    final key = GlobalKey<HarnessState>();
    await tester.pumpWidget(Harness(key: key));
    expect(find.text('Tap or hold to record'), findsOneWidget);
    expect(find.byType(IconButton), findsNothing);
    await tester.tap(recordButton);
    await tester.pump();
    expect(key.currentState!.starts, 1);
    expect(find.text('Tap to send'), findsOneWidget);
    expect(find.text('3:00'), findsOneWidget);
    expect(find.byTooltip('Cancel'), findsOneWidget);
    expect(find.textContaining('release to send'), findsNothing);
    await tester.tap(recordButton);
    await tester.pump();
    expect(key.currentState!.sent, 1);
    expect(find.text('3:00'), findsNothing);
    await tester.tap(recordButton);
    await tester.pump();
    await tester.tap(find.byTooltip('Cancel'));
    await tester.pump();
    expect(key.currentState!.cancelled, 1);
    expect(key.currentState!.sent, 1);
  });

  testWidgets('299ms tap stays recording; 300ms hold releases to send once', (
    tester,
  ) async {
    final key = GlobalKey<HarnessState>();
    await tester.pumpWidget(Harness(key: key));
    final tap = await tester.startGesture(tester.getCenter(recordButton));
    await tester.pump(const Duration(milliseconds: 299));
    expect(key.currentState!.starts, 0);
    await tap.up();
    await tester.pump();
    expect(key.currentState!.recording, isTrue);
    expect(key.currentState!.sent, 0);
    await tester.tap(find.byTooltip('Cancel'));
    await tester.pump();
    final hold = await tester.startGesture(tester.getCenter(recordButton));
    await tester.pump(const Duration(milliseconds: 301));
    expect(key.currentState!.recording, isTrue);
    expect(find.text('Recording... release to send'), findsOneWidget);
    expect(find.byTooltip('Cancel'), findsNothing);
    await hold.up();
    await tester.pump();
    expect(key.currentState!.sent, 1);
    expect(key.currentState!.starts, 2);
    expect(key.currentState!.recording, isFalse);
  });

  testWidgets('hold expiry sends once even when finger releases later', (
    tester,
  ) async {
    final key = GlobalKey<HarnessState>();
    await tester.pumpWidget(Harness(key: key));
    final hold = await tester.startGesture(tester.getCenter(recordButton));
    await tester.pump(const Duration(milliseconds: 301));
    key.currentState!.elapsed = 179000;
    await tester.pump(const Duration(milliseconds: 250));
    expect(find.text('0:01'), findsOneWidget);
    key.currentState!.elapsed = 180001;
    await tester.pump(const Duration(milliseconds: 250));
    await tester.pump();
    expect(key.currentState!.sent, 1);
    await hold.up();
    await tester.pump();
    expect(key.currentState!.sent, 1);
  });

  testWidgets('OS pointer cancellation cancels a hold without sending', (
    tester,
  ) async {
    final key = GlobalKey<HarnessState>();
    await tester.pumpWidget(Harness(key: key));
    final hold = await tester.startGesture(tester.getCenter(recordButton));
    await tester.pump(const Duration(milliseconds: 301));
    await hold.cancel();
    await tester.pump();
    expect(key.currentState!.cancelled, 1);
    expect(key.currentState!.sent, 0);
    expect(key.currentState!.recording, isFalse);
  });

  testWidgets('released hold during delayed permission cancels after startup', (
    tester,
  ) async {
    final key = GlobalKey<HarnessState>();
    await tester.pumpWidget(Harness(key: key));
    key.currentState!.startGate = Completer<void>();
    final hold = await tester.startGesture(tester.getCenter(recordButton));
    await tester.pump(const Duration(milliseconds: 301));
    await hold.up();
    await tester.pump();
    key.currentState!.startGate!.complete();
    await tester.pump();
    expect(key.currentState!.starts, 1);
    expect(key.currentState!.cancelled, 1);
    expect(key.currentState!.sent, 0);
    expect(key.currentState!.recording, isFalse);
  });

  testWidgets('pending tap startup cannot start a duplicate recording', (
    tester,
  ) async {
    final key = GlobalKey<HarnessState>();
    await tester.pumpWidget(Harness(key: key));
    key.currentState!.startGate = Completer<void>();
    await tester.tap(recordButton);
    await tester.pump();
    await tester.tap(recordButton);
    await tester.pump();
    expect(key.currentState!.starts, 1);
    key.currentState!.startGate!.complete();
    await tester.pumpAndSettle();
    expect(key.currentState!.recording, isTrue);
    expect(key.currentState!.sent, 0);
    await tester.tap(recordButton);
    await tester.pump();
    expect(key.currentState!.sent, 1);
  });

  testWidgets('disabled control ignores tap and hold', (tester) async {
    final key = GlobalKey<HarnessState>();
    await tester.pumpWidget(Harness(key: key));
    key.currentState!.disable();
    await tester.pump();
    await tester.tap(recordButton);
    final hold = await tester.startGesture(tester.getCenter(recordButton));
    await tester.pump(const Duration(milliseconds: 301));
    await hold.up();
    await tester.pump();
    expect(key.currentState!.starts, 0);
    expect(key.currentState!.sent, 0);
  });

  testWidgets('accessibility activation supports tap recording and send', (
    tester,
  ) async {
    final key = GlobalKey<HarnessState>();
    await tester.pumpWidget(Harness(key: key));
    tester.semantics.tap(find.semantics.byLabel('Tap or hold to record'));
    await tester.pump();
    expect(key.currentState!.recording, isTrue);
    tester.semantics.tap(find.semantics.byLabel('Tap to send'));
    await tester.pump();
    expect(key.currentState!.sent, 1);
  });

  testWidgets(
    'group limit expires in tap mode without extending its allowance',
    (tester) async {
      final key = GlobalKey<HarnessState>();
      await tester.pumpWidget(Harness(key: key, maxSeconds: 60));
      await tester.tap(recordButton);
      await tester.pump();
      expect(find.text('1:00'), findsOneWidget);
      key.currentState!.elapsed = 60001;
      await tester.pump(const Duration(milliseconds: 250));
      expect(key.currentState!.sent, 1);
      expect(key.currentState!.recording, isFalse);
    },
  );

  testWidgets('localized labels fit a narrow phone with large text', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 700);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    tester.platformDispatcher.textScaleFactorTestValue = 1.8;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    for (final locale in AppLocalizations.supportedLocales) {
      final key = GlobalKey<HarnessState>();
      await tester.pumpWidget(Harness(key: key, locale: locale));
      await tester.pumpAndSettle();
      await tester.tap(recordButton);
      await tester.pump();
      expect(find.text('3:00'), findsOneWidget);
      expect(tester.takeException(), isNull, reason: locale.toString());
      await tester.tap(recordButton);
      await tester.pump();
      expect(key.currentState!.sent, 1);
    }
  });
}
