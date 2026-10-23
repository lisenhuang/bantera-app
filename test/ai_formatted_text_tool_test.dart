import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:app/infrastructure/ai/ai_formatted_text_tool.dart';
import 'package:app/infrastructure/ai/ai_history_store.dart';
import 'package:app/presentation/chats/ai/ai_chat_controller.dart';
import 'package:app/presentation/chats/ai/ai_voice_reply_state.dart';
import 'ai_voice_overlap_test.dart' show Recorder, Api, Peer, until;

const markdown =
    '## Travel documents\n\n**Passport** identifies you.\n\n'
    '| Document | Purpose |\n| --- | --- |\n| Passport | Identity |\n| Visa | Entry permission |';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test(
    'formatted answer survives completion without replacing spoken transcript',
    () {
      final state = AiVoiceReplyState();
      final message = state.ensure('en');
      expect(
        AiFormattedTextTool.deliver({
          'markdown': markdown,
        }, message)['delivered'],
        true,
      );
      state.addTranscript('Here is a comparison.', 'en');
      final completed = state.complete(
        'Here is a comparison.',
        'reply.wav',
        'en',
      );
      final restored = AiMessage.fromJson(completed.toJson());
      expect(restored.displayText, markdown);
      expect(restored.text, 'Here is a comparison.');
      final context = AiHistoryStore.contextFor([restored]).single;
      expect(context['text'], markdown);
      expect(context['resumeText'], 'Here is a comparison.');
      expect(
        AiMessage.fromJson(
          AiMessage(role: 'model', text: 'Old reply').toJson(),
        ).displayText,
        'Old reply',
      );
    },
  );

  test(
    'invalid input cannot erase an existing formatted answer and reset clears it',
    () {
      final state = AiVoiceReplyState();
      final message = state.ensure('en');
      AiFormattedTextTool.deliver({'markdown': markdown}, message);
      for (final value in [null, 1, '', ' ', 'a' * 8001, 'Bad\u0000text']) {
        expect(
          AiFormattedTextTool.deliver({
            'markdown': value,
          }, message)['delivered'],
          false,
        );
        expect(message.formattedText, markdown);
      }
      state.resetAttempt();
      expect(message.formattedText, isNull);
    },
  );

  test(
    'voice WebSocket tool delivery persists after leaving and reopening chat',
    () async {
      final dir = Directory.systemTemp.createTempSync('ai-formatted');
      final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
      final peers = <Peer>[];
      server.listen(
        (r) async => peers.add(Peer(await WebSocketTransformer.upgrade(r))),
      );
      final messenger =
          TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
      messenger.setMockMethodCallHandler(
        const MethodChannel('com.llfbandit.record/messages'),
        (_) async => null,
      );
      messenger.setMockMethodCallHandler(AiChatController.audio, (call) async {
        if (call.method == 'storagePath') return dir.path;
        if (call.method == 'playedFrames') return 0;
        return null;
      });
      final recorder = Recorder();
      final api = Api(server.port);
      final store = AiHistoryStore('formatted');
      final chat = AiChatController.forTesting(
        store,
        recorder: recorder,
        api: api,
        voiceMetadata: () async => {},
      );
      try {
        await chat.initialize();
        await chat.record();
        recorder.speak();
        final sending = chat.sendRecording();
        await until(() => peers.isNotEmpty);
        await peers.single.committed.future;
        peers.single.socket.add(
          jsonEncode({
            'type': 'toolCall',
            'calls': [
              {
                'id': 'format-1',
                'name': AiFormattedTextTool.name,
                'args': {'markdown': markdown},
              },
            ],
          }),
        );
        await until(() => chat.messages.last.formattedText != null);
        expect(chat.messages.last.displayText, markdown);
        await chat.detachChat();
        peers.single.audio('Here is a comparison.');
        peers.single.complete('Here is a comparison.');
        await sending;
        final reopened = AiHistoryStore('formatted');
        await reopened.load();
        expect(reopened.messages.last.displayText, markdown);
        expect(reopened.messages.last.text, 'Here is a comparison.');
        expect(reopened.messages.last.audio, isNotNull);
      } finally {
        chat.dispose();
        api.close();
        for (final peer in peers) {
          await peer.socket.close();
        }
        await server.close(force: true);
        await dir.delete(recursive: true);
      }
    },
  );
}
