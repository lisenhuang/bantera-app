import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:record/record.dart';
import 'package:app/infrastructure/ai/ai_api_client.dart';
import 'package:app/infrastructure/ai/ai_history_store.dart';
import 'package:app/presentation/chats/ai/ai_chat_controller.dart';

class Recorder extends AudioRecorder {
  StreamController<Uint8List>? input;
  @override
  Future<bool> hasPermission({bool request = true}) async => true;
  @override
  Future<Stream<Uint8List>> startStream(RecordConfig config) async {
    input = StreamController<Uint8List>(sync: true);
    return input!.stream;
  }

  void speak() => input!.add(Uint8List(3200));
  @override
  Future<String?> stop() async {
    input?.add(Uint8List(320)); // Native recorders may flush a final chunk.
    await input?.close();
    return null;
  }

  @override
  Future<void> cancel() async {
    await input?.close();
  }
}

class Api extends AiApiClient {
  Api(this.port);
  final int port;
  final contexts = <List<Map<String, String>>>[];
  @override
  Future<WebSocket> voice(
    String owner,
    List<Map<String, String>> history,
    String requestId, {
    required bool hasMetBanteraAi,
  }) {
    contexts.add(history);
    return WebSocket.connect('ws://127.0.0.1:$port');
  }
}

class Peer {
  Peer(this.socket) {
    socket.listen((event) {
      if (event is List<int>) bytes += event.length;
      if (event is String && jsonDecode(event)['type'] == 'commit') {
        committed.complete();
      }
    });
    socket.add(jsonEncode({'type': 'ready'}));
  }
  final WebSocket socket;
  int bytes = 0;
  final committed = Completer<void>();
  void audio(String text) {
    socket.add(Uint8List(4800));
    socket.add(
      jsonEncode({'type': 'transcript', 'role': 'model', 'text': text}),
    );
  }

  void complete(String text) => socket.add(
    jsonEncode({
      'type': 'complete',
      'inputText': 'My recorded words',
      'outputText': text,
    }),
  );
}

Future<void> until(bool Function() done) async {
  final deadline = DateTime.now().add(const Duration(seconds: 5));
  while (!done()) {
    if (DateTime.now().isAfter(deadline)) throw TimeoutException('Condition');
    await Future<void>.delayed(const Duration(milliseconds: 5));
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  for (final action in ['send', 'cancel', 'keep recording']) {
    test(
      'record during AI reply: $action preserves its full download',
      () async {
        final dir = Directory.systemTemp.createTempSync('ai-overlap');
        final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
        final peers = <Peer>[];
        server.listen(
          (r) async => peers.add(Peer(await WebSocketTransformer.upgrade(r))),
        );
        final calls = <String>[];
        final messenger =
            TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
        messenger.setMockMethodCallHandler(
          const MethodChannel('com.llfbandit.record/messages'),
          (_) async => null,
        );
        messenger.setMockMethodCallHandler(AiChatController.audio, (
          call,
        ) async {
          calls.add(call.method);
          if (call.method == 'storagePath') return dir.path;
          if (call.method == 'playedFrames') return 1200;
          return null;
        });
        final recorder = Recorder();
        final api = Api(server.port);
        final store = AiHistoryStore('overlap-$action');
        final chat = AiChatController.forTesting(
          store,
          recorder: recorder,
          api: api,
          voiceMetadata: () async => {
            'clock': {'timeZone': 'Pacific/Auckland'},
          },
        );
        try {
          await chat.initialize();
          await chat.record();
          recorder.speak();
          final first = chat.sendRecording();
          await until(() => peers.length == 1);
          await peers.first.committed.future;
          peers.first.audio('First ');
          await until(
            () =>
                calls.contains('feed') &&
                chat.voiceReply.message?.text == 'First',
          );
          expect(chat.canRecord, true);
          final firstId = chat.voiceReply.message!.id;
          await chat.record();
          expect(calls.last, 'stop');
          expect(chat.recording, true);
          recorder.speak();
          final feedsBefore = calls.where((m) => m == 'feed').length;
          Future<void>? second;
          if (action == 'send') second = chat.sendRecording();
          if (action == 'cancel') await chat.cancelRecording();
          peers.first.audio('reply.');
          await until(() => chat.voiceReply.message?.text == 'First reply.');
          expect(calls.where((m) => m == 'feed').length, feedsBefore);
          expect(peers.length, 1); // The first committed socket remains open.
          peers.first.complete('First reply.');
          await first;
          expect(peers.first.bytes, 3520);
          expect(
            File(store.path(store.messages.first.audio!)).lengthSync(),
            44 + 3520,
          );
          final saved = store.messages.singleWhere((m) => m.role == 'model');
          expect(saved.id, firstId);
          expect(saved.text, 'First reply.');
          expect(File(store.path(saved.audio!)).lengthSync(), 44 + 9600);
          expect(saved.failed, false);
          expect(chat.failed, false);
          if (action == 'keep recording') {
            expect(chat.recording, true);
            await until(() => peers.length == 2 && peers.last.bytes == 3200);
            recorder.speak();
            second = chat.sendRecording();
          }
          if (second != null) {
            await until(() => peers.length == 2);
            await peers.last.committed.future;
            expect(
              api.contexts.last.any((m) => m['text'] == 'First reply.'),
              true,
            );
            expect(peers.last.bytes, action == 'keep recording' ? 6720 : 3520);
            peers.last.audio('Second reply.');
            peers.last.complete('Second reply.');
            await second;
            expect(store.messages.map((m) => m.role), [
              'user',
              'model',
              'user',
              'model',
            ]);
            expect(store.messages.last.text, 'Second reply.');
            expect(calls.where((m) => m == 'feed').length, feedsBefore + 1);
          }
          final reloaded = AiHistoryStore('overlap-$action');
          await reloaded.load();
          expect(
            reloaded.messages.where((m) => m.role == 'model').first.text,
            'First reply.',
          );
        } finally {
          await chat.cancelRecording();
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
}
