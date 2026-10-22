import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:app/infrastructure/ai/ai_api_client.dart';
import 'package:app/infrastructure/ai/ai_history_store.dart';
import 'package:app/infrastructure/ai/ai_image_search.dart';
import 'package:app/infrastructure/ai/ai_voice_stream.dart';
import 'package:app/infrastructure/ai/ai_word_explanation.dart';
import 'package:app/presentation/chats/ai/ai_chat_controller.dart';

class _Api extends AiApiClient {
  _Api(this.port);
  final int port;
  final modes = <bool>[];
  @override
  Future<WebSocket> voice(
    String owner,
    List<Map<String, String>> history,
    String requestId, {
    required bool hasMetBanteraAi,
    List<Map<String, String>> images = const [],
    bool textOnly = false,
  }) {
    modes.add(textOnly);
    return WebSocket.connect('ws://127.0.0.1:$port');
  }
}

class _Images extends AiImageSearch {
  String? query;
  @override
  Future<List<AiDownloadedImage>> search(String query) async {
    this.query = query;
    return [
      (
        image: const AiImageAttachment(
          title: 'Passport cover',
          url: 'https://example.org/passport.jpg',
          sourceUrl: 'https://example.org/passport',
          author: '',
          license: '',
          mime: 'image/jpeg',
        ),
        bytes: Uint8List.fromList([1, 2, 3]),
      ),
    ];
  }
}

class _Controller extends AiChatController {
  _Controller(
    super.store, {
    required super.api,
    required super.voiceMetadata,
    super.imageSearch,
  }) : super.forTesting();
  int heard = 0;
  @override
  Future<void> recordListened(int count, String language) async {
    heard += count;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const request = AiWordExplanation(
    owner: 'test',
    selection: '行',
    sentence: '銀行在哪裡？',
    start: 1,
    end: 2,
    language: 'zh-HK',
    displayText: 'Explain 行 in 銀行在哪裡？',
  );
  test(
    'character prompt includes exact range, whole sentence, optional images and later save consent',
    () {
      final data = jsonDecode(request.prompt.split('\n').last);
      expect(data['selection'], '行');
      expect(data['sentence'], '銀行在哪裡？');
      expect(data['selectionStart'], 1);
      expect(data['selectionEnd'], 2);
      expect(
        request.prompt,
        contains('one character rather than a complete word'),
      );
      expect(request.prompt, contains('nearby characters'));
      expect(request.prompt, contains('Images are optional'));
      expect(request.prompt, contains('current saved Practice level'));
      expect(request.prompt, contains('selected easier review level'));
      expect(request.prompt, contains('images: passport document cover'));
      expect(request.prompt, contains('before finishing the reply'));
      expect(request.prompt, contains('abstract, grammatical or figurative'));
      expect(request.prompt, contains('Do not search for videos'));
      expect(request.prompt, contains('explicitly agree in a later reply'));
    },
  );
  test(
    'text turn delivers searched images, streams captions/audio and blocks premature vocabulary save without microphone input',
    () async {
      final dir = await Directory.systemTemp.createTemp('word-turn');
      final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
      final commits = <Map>[];
      final tools = <Map>[];
      final binary = <dynamic>[];
      final native = <String>[];
      server.listen((request) async {
        final socket = await WebSocketTransformer.upgrade(request);
        socket.listen((event) {
          if (event is! String) {
            binary.add(event);
            return;
          }
          final frame = jsonDecode(event) as Map;
          if (frame['type'] == 'commit') {
            commits.add(frame);
            socket.add(
              jsonEncode({
                'type': 'transcript',
                'role': 'user',
                'text': frame['text'],
              }),
            );
            socket.add(jsonEncode({'type': 'reset'}));
            socket.add(
              jsonEncode({
                'type': 'toolCall',
                'calls': [
                  {
                    'id': 'v1',
                    'name': 'manage_vocabulary',
                    'args': {'action': 'add', 'word': '銀行'},
                  },
                  {
                    'id': 'i1',
                    'name': 'search_web',
                    'args': {'query': 'images: passport document cover'},
                  },
                ],
              }),
            );
          }
          if (frame['type'] == 'toolResponse') {
            tools.add(frame);
            socket.add(Uint8List(4800));
            socket.add(
              jsonEncode({
                'type': 'transcript',
                'role': 'model',
                'text': '銀行 means bank.',
              }),
            );
            socket.add(
              jsonEncode({
                'type': 'complete',
                'inputText': commits.last['text'],
                'outputText': '銀行 means bank.',
              }),
            );
          }
        });
        socket.add(jsonEncode({'type': 'ready', 'acceptText': true}));
      });
      final messenger =
          TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
      messenger.setMockMethodCallHandler(AiChatController.audio, (call) async {
        native.add(call.method);
        if (call.method == 'storagePath') return dir.path;
        if (call.method == 'playedFrames') return 2400;
        return null;
      });
      messenger.setMockMethodCallHandler(
        const MethodChannel('com.llfbandit.record/messages'),
        (call) async {
          if (call.method.contains('start')) {
            fail('Text cannot start a recorder');
          }
          return null;
        },
      );
      final store = AiHistoryStore('test');
      await store.load();
      store.hasMetBanteraAi = true;
      final api = _Api(server.port);
      final imageSearch = _Images();
      final controller = _Controller(
        store,
        api: api,
        voiceMetadata: () async => {},
        imageSearch: imageSearch,
      )..loaded = true;
      try {
        final sending = controller.explainWord(
          text: request.displayText,
          prompt: request.prompt,
          language: request.language,
        );
        await controller.explainWord(
          text: 'duplicate',
          prompt: request.prompt,
          language: request.language,
        );
        await sending;
        expect(commits, hasLength(1));
        expect(commits.single['text'], request.prompt);
        expect(api.modes, [true]);
        expect(binary, isEmpty);
        expect(native, contains('startPlayback'));
        expect(native, isNot(contains('start')));
        final responses = tools.single['responses'] as List;
        final tool = responses.first as Map;
        expect(tool['response']['result']['confirmationRequired'], true);
        expect(responses.last['response']['result']['delivered'], true);
        expect(imageSearch.query, 'passport document cover');
        expect(store.messages.last.images.single.title, 'Passport cover');
        expect(store.messages.last.imageSearchStatus, 'complete');
        expect(store.messages.first.text, request.displayText);
        expect(store.messages.first.audio, isNull);
        expect(store.messages.last.text, '銀行 means bank.');
        expect(store.messages.last.audio, isNotNull);
        final reloaded = AiHistoryStore('test');
        await reloaded.load();
        expect(reloaded.messages.first.textRequest, request.prompt);
        expect(reloaded.messages.last.images.single.title, 'Passport cover');
        expect(
          await File(
            reloaded.path(reloaded.messages.last.images.single.file!),
          ).readAsBytes(),
          [1, 2, 3],
        );
        expect(controller.failed, false);
        expect(controller.heard, 4);
      } finally {
        controller.dispose();
        await Future<void>.delayed(const Duration(milliseconds: 40));
        await server.close(force: true);
        messenger.setMockMethodCallHandler(AiChatController.audio, null);
        messenger.setMockMethodCallHandler(
          const MethodChannel('com.llfbandit.record/messages'),
          null,
        );
        await dir.delete(recursive: true);
      }
    },
  );
  test(
    'old backend cannot silently treat text as a silent recording',
    () async {
      final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
      final sent = <dynamic>[];
      server.listen((request) async {
        final peer = await WebSocketTransformer.upgrade(request);
        peer.listen(sent.add);
        peer.add(jsonEncode({'type': 'ready', 'acceptImages': true}));
      });
      final stream = AiVoiceStream(
        connect: () => WebSocket.connect('ws://127.0.0.1:${server.port}'),
        requiresText: true,
        onAudio: (_) async => fail('No audio expected'),
        onReset: () async {},
      );
      try {
        await expectLater(
          stream.send({}, text: request.prompt),
          throwsA(isA<AiVoiceFailure>()),
        );
        expect(stream.committed, false);
        expect(sent, isEmpty);
      } finally {
        await stream.close();
        await server.close(force: true);
      }
    },
  );
}
