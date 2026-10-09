import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:app/infrastructure/ai/ai_history_store.dart';
import 'package:app/presentation/chats/ai/ai_chat_controller.dart';
import 'package:app/presentation/chats/ai/ai_chat_screen.dart';
import 'package:app/l10n/app_localizations.dart';
import 'package:app/core/theme.dart';

class _TranslationController extends AiChatController {
  _TranslationController(super.store) : super.forTesting();
  final translationRequests = <bool>[];
  int sentRecordings = 0,
      cancelledRecordings = 0,
      cancelRequests = 0,
      endedCalls = 0,
      startedCalls = 0;
  @override
  Future<void> startCall() async {
    startedCalls++;
    calling = true;
    changed();
  }

  @override
  Future<void> endCall() async {
    if (!calling) return;
    endedCalls++;
    calling = false;
    connected = false;
    changed();
  }

  Completer<void>? recordingGate;
  @override
  Future<void> record() async {
    await recordingGate?.future;
    recording = true;
    recordingRemaining = 180;
    changed();
  }

  @override
  Future<void> sendRecording() async {
    if (!recording) return;
    sentRecordings++;
    recording = false;
    changed();
  }

  @override
  Future<void> cancelRecording() async {
    cancelRequests++;
    if (!recording) return;
    cancelledRecordings++;
    recording = false;
    changed();
  }

  @override
  void translate(AiMessage message, {bool force = false}) {
    translationRequests.add(force);
    visibleTranslations.add(message.id);
    changed();
  }
}

void main() {
  testWidgets(
    'inline call fits phone width and clear history requires confirmation',
    (tester) async {
      final dir = Directory.systemTemp.createTempSync('bantera-ai-screen-test');
      addTearDown(() => dir.deleteSync(recursive: true));
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final playbackCalls = <MethodCall>[];
      final messenger = tester.binding.defaultBinaryMessenger;
      for (final name in [
        'xyz.luan/audioplayers.global',
        'xyz.luan/audioplayers.global/events',
        'com.llfbandit.record/messages',
      ]) {
        messenger.setMockMethodCallHandler(
          MethodChannel(name),
          (_) async => null,
        );
      }
      messenger.setMockMethodCallHandler(
        const MethodChannel('xyz.luan/audioplayers'),
        (call) async {
          playbackCalls.add(call);
          if (call.method == 'setSourceUrl') {
            final id = (call.arguments as Map)['playerId'];
            Future.microtask(
              () => messenger.handlePlatformMessage(
                'xyz.luan/audioplayers/events/$id',
                const StandardMethodCodec().encodeSuccessEnvelope({
                  'event': 'audio.onPrepared',
                  'value': true,
                }),
                (_) {},
              ),
            );
          }
          if (call.method == 'resume') {
            final id = (call.arguments as Map)['playerId'];
            Future.microtask(
              () => messenger.handlePlatformMessage(
                'xyz.luan/audioplayers/events/$id',
                const StandardMethodCodec().encodeSuccessEnvelope({
                  'event': 'audio.onComplete',
                }),
                (_) {},
              ),
            );
          }
          if (call.method == 'create') {
            final id = (call.arguments as Map)['playerId'];
            messenger.setMockMethodCallHandler(
              MethodChannel('xyz.luan/audioplayers/events/$id'),
              (_) async => null,
            );
          }
          return null;
        },
      );
      messenger.setMockMethodCallHandler(
        const MethodChannel('bantera/ai_audio'),
        (call) async => call.method == 'storagePath' ? dir.path : null,
      );
      final store = AiHistoryStore('test');
      final controller = _TranslationController(store);
      await tester.runAsync(controller.initialize);
      store.messages.add(
        AiMessage(
          role: 'user',
          text: 'I live in Auckland.',
          audio: 'test.wav',
          durationMs: 66000,
          translation: 'Previously generated translation',
          translationLanguage: 'zh-CN',
        ),
      );
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: AiChatScreen(controller: controller),
        ),
      );
      await tester.runAsync(() async {
        await Future<void>.delayed(const Duration(milliseconds: 50));
      });
      await tester.pumpAndSettle();
      expect(find.text('I live in Auckland.'), findsOneWidget);
      expect(find.text('1:06'), findsOneWidget);
      expect(playbackCalls.where((c) => c.method == 'resume'), isEmpty);
      final playRect = tester.getRect(find.byIcon(Icons.play_arrow_rounded));
      final durationRect = tester.getRect(find.text('1:06'));
      final progressRect = tester.getRect(find.byType(LinearProgressIndicator));
      final translateRect = tester.getRect(find.byTooltip('Translate'));
      expect(playRect.center.dx, lessThan(durationRect.center.dx));
      expect(durationRect.right, lessThan(progressRect.left));
      expect(progressRect.right, lessThan(translateRect.left));
      expect(progressRect.width, greaterThan(100));
      for (final rect in [durationRect, progressRect, translateRect]) {
        expect(rect.center.dy, closeTo(playRect.center.dy, 1));
      }
      expect(find.text('Previously generated translation'), findsNothing);
      controller.busy = true;
      controller.changed();
      await tester.pump();
      expect(find.text('Sending audio...'), findsWidgets);
      controller.voiceReply.addAudio(48000, 'en-NZ');
      controller.changed();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 250));
      expect(find.text('Sending audio...'), findsNothing);
      expect(find.text('Bantera AI is replying…'), findsWidgets);
      expect(find.byIcon(Icons.graphic_eq), findsOneWidget);
      expect(controller.messages.length, 2);
      expect(store.messages.length, 1);
      controller.voiceReply.addTranscript('A streamed reply', 'en-NZ');
      controller.changed();
      await tester.pump();
      expect(find.text('A streamed reply'), findsOneWidget);
      final recordButton = tester.widget<IconButton>(
        find.byKey(const Key('voice-tap-record-send')),
      );
      expect(recordButton.onPressed, isNotNull);
      await tester.tap(find.byKey(const Key('voice-tap-record-send')));
      await tester.pump();
      expect(controller.recording, isTrue);
      expect(find.text('3:00'), findsOneWidget);
      expect(find.text('Bantera AI is replying…'), findsOneWidget);
      await tester.tap(find.byTooltip('Cancel'));
      await tester.pump();
      expect(controller.recording, isFalse);
      controller.cancelledRecordings = 0;
      expect(find.text('I live in Auckland.'), findsOneWidget);
      controller.voiceReply.clear();
      controller.busy = false;
      controller.changed();
      await tester.pumpAndSettle();

      for (final theme in [BanteraTheme.lightTheme, BanteraTheme.darkTheme]) {
        await tester.pumpWidget(
          MaterialApp(
            theme: theme,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: AiChatScreen(controller: controller),
          ),
        );
        await tester.pumpAndSettle();
        final transcript = tester.widget<SelectableText>(
          find.byWidgetPredicate(
            (w) => w is SelectableText && w.data == 'I live in Auckland.',
          ),
        );
        expect(transcript.style!.color, theme.colorScheme.onSurface);
        expect(transcript.style!.fontSize, theme.textTheme.bodyLarge!.fontSize);
        final tint = theme.colorScheme.primary.withValues(alpha: .12);
        expect(
          find.byWidgetPredicate(
            (w) =>
                w is Container &&
                w.decoration is BoxDecoration &&
                (w.decoration as BoxDecoration).color == tint,
          ),
          findsOneWidget,
        );
        final background = Color.alphaBlend(
          tint,
          theme.scaffoldBackgroundColor,
        );
        final textLuminance = transcript.style!.color!.computeLuminance();
        final backgroundLuminance = background.computeLuminance();
        final light = textLuminance > backgroundLuminance
            ? textLuminance
            : backgroundLuminance;
        final dark = textLuminance < backgroundLuminance
            ? textLuminance
            : backgroundLuminance;
        expect((light + .05) / (dark + .05), greaterThanOrEqualTo(4.5));
      }
      final translate = find.byTooltip('Translate');
      expect(translate, findsOneWidget);
      final transcript = tester.getRect(find.text('I live in Auckland.'));
      final button = tester.getRect(translate);
      expect(button.bottom, lessThanOrEqualTo(transcript.top));
      expect(button.center.dx, greaterThan(transcript.center.dx));
      await tester.tap(translate);
      await tester.pumpAndSettle();
      expect(find.text('Previously generated translation'), findsOneWidget);
      await tester.tap(find.byTooltip('Retranslate'));
      await tester.pumpAndSettle();
      expect(controller.translationRequests, [false, true]);
      final notice = find.textContaining(
        'Received AI chat history stays on this device.',
      );
      expect(notice, findsOneWidget);
      // The dismissal writes to disk; keep its queued futures outside fake time.
      await tester.runAsync(() => tester.tap(find.byTooltip('Close')));
      await tester.pumpAndSettle();
      expect(notice, findsNothing);
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 50)),
      );
      final reopened = AiChatController.forTesting(AiHistoryStore('test'));
      await tester.runAsync(reopened.initialize);
      expect(reopened.privacyNoticeVisible, isFalse);
      reopened.dispose();
      await tester.tap(find.byIcon(Icons.more_horiz));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Usage'));
      await tester.pumpAndSettle();
      expect(find.byType(AlertDialog), findsOneWidget);
      expect(
        find.textContaining('what the reminder is for before scheduling'),
        findsOneWidget,
      );
      await tester.tap(find.widgetWithText(TextButton, 'Close'));
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.more_horiz));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Privacy notice'));
      await tester.pumpAndSettle();
      expect(find.byType(AlertDialog), findsOneWidget);
      expect(notice, findsOneWidget);
      await tester.tap(find.widgetWithText(TextButton, 'Close'));
      await tester.pumpAndSettle();
      expect(notice, findsNothing);
      expect(find.byType(TextField), findsNothing);
      expect(find.byTooltip('Record a voice message'), findsOneWidget);
      controller.recording = true;
      controller.recordingRemaining = 90;
      controller.changed();
      await tester.pumpAndSettle();
      expect(find.text('1:30'), findsOneWidget);
      expect(find.byTooltip('Cancel'), findsOneWidget);
      expect(tester.takeException(), isNull);
      controller.recording = false;
      controller.changed();
      await tester.pumpAndSettle();
      final hold = find.text('Hold to record audio');
      final gesture = await tester.startGesture(tester.getCenter(hold));
      await tester.pump(const Duration(milliseconds: 600));
      await tester.pump();
      expect(controller.recording, isTrue);
      expect(find.text('3:00'), findsOneWidget);
      expect(find.byTooltip('Cancel'), findsNothing);
      expect(find.textContaining('Release to send'), findsNothing);
      await gesture.up();
      await tester.pumpAndSettle();
      expect(controller.sentRecordings, 1);
      controller.recordingGate = Completer<void>();
      final earlyRelease = await tester.startGesture(tester.getCenter(hold));
      await tester.pump(const Duration(milliseconds: 600));
      await earlyRelease.up();
      controller.recordingGate!.complete();
      await tester.pumpAndSettle();
      expect(controller.recording, isFalse);
      expect(controller.cancelledRecordings, 1);
      expect(controller.sentRecordings, 1);
      controller.recordingGate = null;
      expect(playbackCalls.where((call) => call.method == 'resume'), isEmpty);
      // Only a new voice-message response plays, once; rebuilding/translating
      // it and completing a live call must not replay anything.
      final reply = AiMessage(role: 'model', text: 'Hello', audio: 'reply.wav');
      controller.requestReplyPlayback(reply);
      await tester.pumpAndSettle();
      expect(playbackCalls.where((call) => call.method == 'resume').length, 1);
      controller.changed();
      await tester.pumpAndSettle();
      expect(playbackCalls.where((call) => call.method == 'resume').length, 1);

      controller.calling = true;
      controller.requestReplyPlayback(reply);
      expect(controller.takePlaybackRequest(), isNull);
      controller.connected = true;
      controller.farewell = true;
      controller.remaining = 30;
      controller.changed();
      await tester.pump();
      expect(find.textContaining('0:30'), findsOneWidget);
      final stopsBeforeLock = playbackCalls
          .where((call) => call.method == 'stop')
          .length;
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
      await tester.pump();
      expect(controller.calling, isTrue);
      expect(controller.connected, isTrue);
      expect(controller.endedCalls, 0);
      expect(
        playbackCalls.where((call) => call.method == 'stop').length,
        stopsBeforeLock,
      );
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pump();
      expect(tester.takeException(), isNull);
      controller.calling = false;
      controller.connected = false;
      controller.busy = true;
      final cancelsBeforeBackground = controller.cancelRequests;
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
      await tester.pump();
      expect(controller.cancelRequests, cancelsBeforeBackground);
      expect(controller.busy, isTrue);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      controller.busy = false;
      controller.changed();
      await tester.pump();
      await tester.tap(find.byIcon(Icons.more_horiz));
      await tester.pumpAndSettle();
      // Close the menu and verify that a call does not start before confirmation.
      await tester.tapAt(const Offset(10, 400));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Audio Call'));
      await tester.pumpAndSettle();
      expect(find.text('Start an audio call?'), findsOneWidget);
      expect(controller.startedCalls, 0);
      await tester.tap(find.widgetWithText(TextButton, 'Cancel'));
      await tester.pumpAndSettle();
      expect(controller.startedCalls, 0);
      await tester.tap(find.byTooltip('Audio Call'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(FilledButton, 'Start call'));
      await tester.pumpAndSettle();
      expect(controller.startedCalls, 1);
      controller.calling = false;
      controller.changed();
      await tester.pump();
      await tester.tap(find.byIcon(Icons.more_horiz));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Clear history'));
      await tester.pumpAndSettle();
      expect(find.byType(AlertDialog), findsOneWidget);
      expect(store.messages.length, 1);
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(store.messages.length, 1);
      await tester.tap(find.byIcon(Icons.more_horiz));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Clear history'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(TextButton, 'Clear history'));
      await tester.runAsync(() async {
        await Future<void>.delayed(const Duration(milliseconds: 100));
      });
      await tester.pumpAndSettle();
      expect(store.messages, isEmpty);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
      final longHistory = AiHistoryStore('scroll-test');
      for (var i = 0; i < 100; i++) {
        longHistory.messages.add(
          AiMessage(role: 'user', text: 'History message $i'),
        );
      }
      final historyController = AiChatController.forTesting(longHistory)
        ..loaded = true;
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: AiChatScreen(controller: historyController),
        ),
      );
      // Check the very first layout, without settling an opening animation.
      expect(find.text('History message 99').hitTestable(), findsOneWidget);
      expect(find.text('History message 0').hitTestable(), findsNothing);
      final position = tester
          .widget<ListView>(find.byType(ListView))
          .controller!
          .position;
      expect(position.pixels, 0);
      expect(position.isScrollingNotifier.value, isFalse);
      await tester.pumpWidget(const SizedBox.shrink());
    },
    variant: TargetPlatformVariant.only(TargetPlatform.iOS),
  );
}
