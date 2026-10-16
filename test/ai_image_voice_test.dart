import 'dart:convert';
import 'dart:io';
import 'package:app/infrastructure/ai/ai_api_client.dart';
import 'package:app/infrastructure/ai/ai_history_store.dart';
import 'package:app/presentation/chats/ai/ai_chat_controller.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'ai_voice_overlap_test.dart' show Recorder, until;

class ImageApi extends AiApiClient {
  ImageApi(this.port);
  final int port;
  final uploads = <List<Map<String, String>>>[];
  @override
  Future<WebSocket> voice(
    String owner,
    List<Map<String, String>> history,
    String requestId, {
    required bool hasMetBanteraAi,
    List<Map<String, String>> images = const [],
  }) async {
    uploads.add(images);
    return WebSocket.connect('ws://127.0.0.1:$port');
  }

  @override
  Future<Map<String, dynamic>> reply({
    required String owner,
    required List<Map<String, String>> history,
    required String audioPath,
    required String requestId,
    required bool hasMetBanteraAi,
  }) async {
    throw StateError(
      'Image messages must never drop images through audio-only fallback',
    );
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test(
    'attachments lock during capture, stream before Send, persist on failure and resend on Retry',
    () async {
      final dir = Directory.systemTemp.createTempSync('ai-image-turn');
      final file = File('${dir.path}/sample.png')
        ..writeAsBytesSync(img.encodePng(img.Image(width: 12, height: 8)));
      final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
      final sockets = <WebSocket>[];
      var pcmBeforeCommit = 0;
      server.listen((request) async {
        final socket = await WebSocketTransformer.upgrade(request);
        sockets.add(socket);
        final index = sockets.length;
        socket.add(jsonEncode({'type': 'ready', 'acceptImages': true}));
        socket.listen((event) {
          if (event is List<int>) {
            pcmBeforeCommit += event.length;
            return;
          }
          if (jsonDecode(event as String)['type'] != 'commit') return;
          if (index == 1) {
            socket.add(jsonEncode({'type': 'error'}));
          } else {
            socket.add(Uint8List(4800));
            socket.add(
              jsonEncode({
                'type': 'complete',
                'inputText': 'Compare the pictures',
                'outputText': 'Both images have the same shape.',
              }),
            );
          }
        });
      });
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
      final api = ImageApi(server.port);
      final store = AiHistoryStore('image-test');
      final chat = AiChatController.forTesting(
        store,
        recorder: recorder,
        api: api,
        voiceMetadata: () async => {},
      );
      try {
        await chat.initialize();
        await chat.attachImages(List.filled(5, file.path));
        expect(chat.draftImages, hasLength(4));
        final selected = chat.draftImages.first;
        await chat.record();
        expect(chat.canEditImages, false);
        chat.removeDraftImage(selected);
        expect(chat.draftImages, hasLength(4));
        recorder.speak();
        await until(() => pcmBeforeCommit > 0);
        expect(store.messages, isEmpty);
        expect(api.uploads.single, hasLength(4));
        await chat.sendRecording();
        expect(chat.draftImages, isEmpty);
        final message = store.messages.single;
        expect(message.failed, true);
        expect(message.images, hasLength(4));
        expect(File(store.path(message.images.first.file!)).existsSync(), true);
        await chat.retry(message);
        expect(api.uploads, hasLength(2));
        expect(api.uploads.first, api.uploads.last);
        expect(message.failed, false);
        expect(store.messages.last.text, 'Both images have the same shape.');
        final restored = AiHistoryStore('image-test');
        await restored.load();
        expect(restored.messages.first.images, hasLength(4));
      } finally {
        chat.dispose();
        for (final socket in sockets) {
          await socket.close();
        }
        await server.close(force: true);
        messenger.setMockMethodCallHandler(AiChatController.audio, null);
        await dir.delete(recursive: true);
      }
    },
  );
}
