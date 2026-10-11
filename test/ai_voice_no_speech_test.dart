import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:app/infrastructure/ai/ai_history_store.dart';
import 'package:app/presentation/chats/ai/ai_chat_controller.dart';
import 'ai_voice_overlap_test.dart' show Recorder, Api, Peer, until;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test(
    'silent recording disappears from memory and disk without a reply or error',
    () async {
      final dir = Directory.systemTemp.createTempSync('ai-no-speech');
      final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
      final peers = <Peer>[];
      server.listen(
        (r) async => peers.add(Peer(await WebSocketTransformer.upgrade(r))),
      );
      final methods = <String>[];
      final messenger =
          TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
      messenger.setMockMethodCallHandler(
        const MethodChannel('com.llfbandit.record/messages'),
        (_) async => null,
      );
      messenger.setMockMethodCallHandler(AiChatController.audio, (call) async {
        methods.add(call.method);
        return call.method == 'storagePath' ? dir.path : null;
      });
      final recorder = Recorder();
      final api = Api(server.port);
      final store = AiHistoryStore('silent-account');
      final chat = AiChatController.forTesting(
        store,
        recorder: recorder,
        api: api,
        voiceMetadata: () async => {},
      );
      try {
        await chat.initialize();
        await chat.record();
        recorder.speak(); // The fixture supplies zero PCM, not actual speech.
        final send = chat.sendRecording();
        await until(() => peers.isNotEmpty);
        await peers.single.committed.future;
        expect(store.messages, hasLength(1));
        final file = File(store.path(store.messages.single.audio!));
        expect(file.existsSync(), true);
        peers.single.socket.add(jsonEncode({'type': 'no_speech'}));
        await send;
        expect(chat.messages, isEmpty);
        expect(chat.failed, false);
        expect(chat.busy, false);
        expect(chat.canRecord, true);
        expect(file.existsSync(), false);
        expect(methods, isNot(contains('startPlayback')));
        final reopened = AiHistoryStore('silent-account');
        await reopened.load();
        expect(reopened.messages, isEmpty);
      } finally {
        chat.dispose();
        api.close();
        for (final peer in peers) {
          await peer.socket.close();
        }
        await server.close(force: true);
        await dir.delete(recursive: true);
        messenger.setMockMethodCallHandler(AiChatController.audio, null);
        messenger.setMockMethodCallHandler(
          const MethodChannel('com.llfbandit.record/messages'),
          null,
        );
      }
    },
  );
}
