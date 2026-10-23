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
    'leaving stops playback but keeps receiving on the same conversation and saves the full reply',
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
      final calls = <String>[];
      messenger.setMockMethodCallHandler(AiChatController.audio, (call) async {
        calls.add(call.method);
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
      await chat.detachChat();
      expect(chat.available, true);
      final feeds = calls.where((m) => m == 'feed').length;
      peers.first.audio(' continues after leaving.');
      await until(() => chat.messages.any((m) => m.text.endsWith('leaving.')));
      expect(calls.where((m) => m == 'feed').length, feeds);
      chat.attachChat();
      expect(
        chat.messages.singleWhere((m) => m.id == responseId).text,
        'The visible AI reply continues after leaving.',
      );
      peers.first.audio(' And after returning.');
      peers.first.complete(
        'The visible AI reply continues after leaving. And after returning.',
      );
      await sending;
      // Reopening does not unexpectedly restart the interrupted automatic audio.
      expect(calls.where((m) => m == 'feed').length, feeds);
      final reopened = AiHistoryStore('leave-account');
      await reopened.load();
      expect(reopened.messages.map((m) => m.role), ['user', 'model']);
      final reply = reopened.messages.last;
      expect(reply.id, responseId);
      expect(reply.text, endsWith('And after returning.'));
      expect(reply.failed, false);
      expect(File(reopened.path(reply.audio!)).lengthSync(), 44 + 14400);
      chat.dispose();
      api.close();
      for (final peer in peers) {
        await peer.socket.close();
      }
      await server.close(force: true);
      await dir.delete(recursive: true);
    },
  );
}
