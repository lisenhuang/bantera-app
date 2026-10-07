import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:app/l10n/app_localizations.dart';
import 'package:app/presentation/chats/voice_message_composer.dart';
import 'package:app/presentation/chats/chat_recording_countdown.dart';

class Harness extends StatefulWidget {
  const Harness({super.key});
  @override
  State<Harness> createState() => HarnessState();
}

class HarnessState extends State<Harness> {
  int sent = 0, cancelled = 0, starts = 0, remaining = 180, elapsed = 0;
  bool recording = false;
  late final timer = ChatRecordingCountdown(
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

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(
      body: Align(
        alignment: Alignment.bottomCenter,
        child: VoiceMessageComposer(
          enabled: true,
          recording: recording,
          remainingSeconds: remaining,
          onStart: () async {
            setState(() {
              recording = true;
              starts++;
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

void main() {
  testWidgets(
    'tap records then sends, with countdown and cancel for hands-free',
    (tester) async {
      final key = GlobalKey<HarnessState>();
      await tester.pumpWidget(Harness(key: key));
      await tester.tap(find.byKey(const Key('voice-tap-record-send')));
      await tester.pump();
      expect(key.currentState!.starts, 1);
      expect(find.text('3:00'), findsOneWidget);
      expect(find.byTooltip('Cancel'), findsOneWidget);
      expect(find.textContaining('release to send'), findsNothing);
      await tester.tap(find.byKey(const Key('voice-tap-record-send')));
      await tester.pump();
      expect(key.currentState!.sent, 1);
      expect(find.text('3:00'), findsNothing);
      await tester.tap(find.byKey(const Key('voice-tap-record-send')));
      await tester.pump();
      await tester.tap(find.byTooltip('Cancel'));
      await tester.pump();
      expect(key.currentState!.cancelled, 1);
      expect(key.currentState!.sent, 1);
    },
  );
  testWidgets('hold has no cancel, expiry sends once even before release', (
    tester,
  ) async {
    final key = GlobalKey<HarnessState>();
    await tester.pumpWidget(Harness(key: key));
    final hold = await tester.startGesture(
      tester.getCenter(find.byKey(const Key('voice-hold-record'))),
    );
    await tester.pump(const Duration(milliseconds: 600));
    expect(key.currentState!.recording, isTrue);
    expect(find.byTooltip('Cancel'), findsNothing);
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
}
