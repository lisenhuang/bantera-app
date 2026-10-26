import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:app/infrastructure/ai/ai_history_store.dart';
import 'package:app/presentation/chats/ai/ai_chat_controller.dart';
import 'ai_voice_overlap_test.dart' show Recorder, Api, Peer, until;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  for (final sample in [
    ('accidental tap', Uint8List(160)),
    ('short nonzero sound', Uint8List.fromList(List.filled(4000, 10))),
    ('long digital silence', Uint8List(32000)),
  ]) {
    test('${sample.$1} is discarded without committing or saving', () async {
      final dir = Directory.systemTemp.createTempSync('ai-empty-input');
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
      messenger.setMockMethodCallHandler(
        AiChatController.audio,
        (call) async => call.method == 'storagePath' ? dir.path : null,
      );
      final recorder = Recorder();
      final api = Api(server.port);
      final store = AiHistoryStore('empty-input');
      final chat = AiChatController.forTesting(
        store,
        recorder: recorder,
        api: api,
        voiceMetadata: () async => {},
      );
      try {
        await chat.initialize();
        await chat.record();
        await until(() => peers.isNotEmpty);
        recorder.input!.add(sample.$2);
        await chat.sendRecording();
        expect(peers.single.committed.isCompleted, false);
        expect(store.messages, isEmpty);
        expect(chat.messages, isEmpty);
        expect(chat.failed, false);
        expect(chat.canRecord, true);
        expect(
          dir
              .listSync(recursive: true)
              .whereType<File>()
              .where((f) => f.path.endsWith('.wav')),
          isEmpty,
        );
        // The discarded input must not prevent the next deliberate message.
        await chat.record();
        recorder.speak();
        final sending = chat.sendRecording();
        await until(() => peers.length == 2);
        await peers.last.committed.future;
        expect(store.messages, hasLength(1));
        expect(store.messages.single.durationMs, 510);
        peers.last.socket.add(jsonEncode({'type': 'no_speech'}));
        await sending;
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
    });
  }
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
        recorder
            .speak(); // The server may still classify nonzero audio as no speech.
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
