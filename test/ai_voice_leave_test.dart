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
    'leaving mid reply retains both captions and received audio on immediate reopen',
    () async {
      final dir = Directory.systemTemp.createTempSync('ai-leave');
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
        if (call.method == 'playedFrames') return 1200;
        return null;
      });
      final recorder = Recorder();
      final api = Api(server.port);
      final store = AiHistoryStore('leave-account');
      final chat = AiChatController.forTesting(
        store,
        recorder: recorder,
        api: api,
        voiceMetadata: () async => {},
      );
      await chat.initialize();
      await chat.record();
      recorder.speak();
      final sending = chat.sendRecording();
      await until(() => peers.isNotEmpty);
      await peers.first.committed.future;
      peers.first.socket.add(
        jsonEncode({
          'type': 'transcript',
          'role': 'user',
          'text': 'My visible transcript',
        }),
      );
      peers.first.audio('The visible AI reply');
      await until(
        () => chat.voiceReply.message?.text == 'The visible AI reply',
      );
      final responseId = chat.voiceReply.message!.id;
      chat.dispose();
      // Do not await the old send task: reopening must wait for pending disk writes.
      final reopened = AiHistoryStore('leave-account');
      await reopened.load();
      expect(reopened.messages.map((m) => m.role), ['user', 'model']);
      expect(reopened.messages.first.text, 'My visible transcript');
      final reply = reopened.messages.last;
      expect(reply.id, responseId);
      expect(reply.text, 'The visible AI reply');
      expect(reply.failed, false);
      expect(reply.durationMs, 100);
      expect(File(reopened.path(reply.audio!)).lengthSync(), 4844);
      await sending;
      final again = AiHistoryStore('leave-account');
      await again.load();
      expect(
        again.messages.length,
        2,
      ); // Late cancellation cannot remove or duplicate.
      expect(again.messages.first.text, 'My visible transcript');
      api.close();
      for (final peer in peers) {
        await peer.socket.close();
      }
      await server.close(force: true);
      await dir.delete(recursive: true);
    },
  );
}
