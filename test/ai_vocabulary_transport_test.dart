import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:app/infrastructure/ai/ai_api_client.dart';
import 'package:app/infrastructure/ai/ai_history_store.dart';
import 'package:app/infrastructure/ai/ai_vocabulary.dart';
import 'package:app/presentation/chats/ai/ai_chat_controller.dart';
import 'ai_voice_overlap_test.dart' show Recorder, until;

class _Api extends AiApiClient {
  _Api(this.port);
  final int port;
  @override
  Future<WebSocket> voice(
    String owner,
    List<Map<String, String>> history,
    String requestId, {
    required bool hasMetBanteraAi,
    List<Map<String, String>> images = const [],
    bool textOnly = false,
  }) => WebSocket.connect('ws://127.0.0.1:$port');
  @override
  Future<WebSocket> call(
    String owner,
    List<Map<String, String>> history, {
    required bool hasMetBanteraAi,
    bool resuming = false,
    int remainingSeconds = 540,
    String? callbackId,
  }) => WebSocket.connect('ws://127.0.0.1:$port');
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  for (final action in ['emoji', 'add', 'stats', 'latest', 'quiz']) {
    final emojis = action == 'emoji';
    for (final mode in ['voice message', 'retry', 'live call']) {
      final live = mode == 'live call';
      test('$action tool reaches device through $mode controller', () async {
        final dir = Directory.systemTemp.createTempSync('vocab-wire');
        final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
        final toolResult = Completer<Map>();
        WebSocket? peer;
        final nativeAudioReady = Completer<void>();
        var nativeAudioStarted = false;
        final call = {
          'type': 'toolCall',
          'calls': [
            {
              'id': 'v1',
              'name': emojis ? 'send_emojis' : 'manage_vocabulary',
              'args': emojis
                  ? {
                      'emojis': ['🇮🇪', '🇮🇳'],
                    }
                  : {
                      'action': action,
                      'word': 'skewer',
                      'meaning': 'A stick for grilling food.',
                    },
            },
          ],
        };
        server.listen((request) async {
          final socket = await WebSocketTransformer.upgrade(request);
          peer = socket;
          socket.listen((event) {
            if (event is! String) return;
            final frame = jsonDecode(event) as Map;
            if (frame['type'] == 'commit') socket.add(jsonEncode(call));
            if (frame['type'] == 'toolResponse') {
              toolResult.complete(frame);
              if (!live) {
                socket.add(Uint8List(4800));
                socket.add(
                  jsonEncode({
                    'type': 'complete',
                    'inputText': 'Save skewer',
                    'outputText': 'Saved skewer.',
                  }),
                );
              }
            }
          });
          socket.add(jsonEncode({'type': 'ready'}));
          if (live) socket.add(jsonEncode(call));
        });
        final messenger =
            TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
        messenger.setMockMethodCallHandler(
          const MethodChannel('com.llfbandit.record/messages'),
          (_) async => null,
        );
        messenger.setMockMethodCallHandler(
          const MethodChannel('flutter.baseflow.com/permissions/methods'),
          (call) async => call.method == 'requestPermissions' ? {7: 1} : 1,
        );
        messenger.setMockMethodCallHandler(
          const MethodChannel('bantera/ai_audio/input'),
          (_) async => null,
        );
        messenger.setMockMethodCallHandler(AiChatController.audio, (
          call,
        ) async {
          if (call.method == 'storagePath') return dir.path;
          if (live && call.method == 'start') {
            nativeAudioStarted = true;
            await nativeAudioReady.future;
          }
          return null;
        });
        final repository = AiVocabulary(
          'test',
          storagePath: () async => dir.path,
          isActive: () => true,
          language: () => 'en-NZ',
          timeZone: () async => 'Pacific/Auckland',
        );
        if (!emojis && action != 'add') {
          await repository.execute({
            'action': 'add',
            'word': 'skewer',
            'meaning': 'A stick for grilling food.',
          });
        }
        messenger.setMockMethodCallHandler(
          const MethodChannel('FlutterWebRTC.Method'),
          (_) async => {'textureId': 1},
        );
        messenger.setMockMethodCallHandler(
          const MethodChannel('FlutterWebRTC/Texture1'),
          (_) async => null,
        );
        final recorder = Recorder();
        final chat = AiChatController.forTesting(
          AiHistoryStore('test'),
          recorder: recorder,
          api: _Api(server.port),
          vocabulary: repository,
          voiceMetadata: () async => {},
        );
        try {
          await chat.initialize();
          if (live) {
            final starting = chat.startCall();
            await until(() => nativeAudioStarted);
            // iOS completes start only after voice processing and duplex I/O
            // are ready. Gemini must not connect or greet before that point.
            expect(peer, isNull);
            nativeAudioReady.complete();
            await starting;
          } else if (mode == 'retry') {
            final message = AiMessage(
              role: 'user',
              failed: true,
              audio: await chat.store.saveAudio(
                aiWave(Uint8List(16000), 16000),
              ),
            );
            chat.store.messages.add(message);
            await chat.retry(message);
          } else {
            await chat.record();
            recorder.speak();
            await chat.sendRecording();
          }
          final response = await toolResult.future.timeout(
            const Duration(seconds: 5),
          );
          final result = response['responses'][0]['response']['result'];
          if (emojis) {
            expect(result['delivered'], true);
            if (live) await chat.endCall();
            expect(chat.store.messages.last.emojis, ['🇮🇪', '🇮🇳']);
            final reloaded = AiHistoryStore('test');
            await reloaded.load();
            expect(reloaded.messages.last.emojis, ['🇮🇪', '🇮🇳']);
          } else {
            expect(result['ok'], true);
            if (action == 'stats') expect(result['total'], 1);
            if (action == 'quiz' || action == 'latest') {
              expect(result['word']['word'], 'skewer');
            }
            expect((await repository.words()).single.word, 'skewer');
          }
          expect(chat.failed, false);
        } finally {
          if (live) await chat.endCall();
          chat.dispose();
          await peer?.close();
          await server.close(force: true);
          await until(() => !chat.calling);
          await dir.delete(recursive: true);
          messenger.setMockMethodCallHandler(AiChatController.audio, null);
          messenger.setMockMethodCallHandler(
            const MethodChannel('bantera/ai_audio/input'),
            null,
          );
        }
      });
    }
  }
}
