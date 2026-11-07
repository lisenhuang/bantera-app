import 'dart:convert';
import 'dart:io';
import 'package:app/infrastructure/ai/ai_review_turn.dart';
import 'package:app/infrastructure/ai/ai_voice_stream.dart';
import 'package:app/infrastructure/ai/ai_vocabulary.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/services.dart';
import 'package:app/infrastructure/ai/ai_history_store.dart';
import 'package:app/infrastructure/ai/ai_api_client.dart';
import 'package:app/presentation/chats/ai/ai_chat_controller.dart';

class _ReviewApi extends AiApiClient {
  _ReviewApi(this.port);
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
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test(
    'V3 live call interruption, reconnection, feedback and ordinary conversation',
    () async {
      final root = await Directory.systemTemp.createTemp('review-live');
      final methods = <String>[];
      final messenger =
          TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
      messenger.setMockMethodCallHandler(
        const MethodChannel('com.llfbandit.record/messages'),
        (_) async => null,
      );
      messenger.setMockMethodCallHandler(AiChatController.audio, (call) async {
        methods.add(call.method);
        if (call.method == 'storagePath') return root.path;
        if (call.method == 'playedFrames') return 0;
        return null;
      });
      final vocabulary = AiVocabulary(
        'test',
        storagePath: () async => root.path,
        isActive: () => true,
        language: () => 'en-NZ',
        timeZone: () async => 'UTC',
      );
      final word = (await vocabulary.execute({
        'action': 'add',
        'word': 'give it a go',
        'meaning': 'Try something',
      }))['word'];
      final history = AiHistoryStore('test');
      await history.load();
      final chat = AiChatController.forTesting(history, vocabulary: vocabulary)
        ..loaded = true;
      Future<void> event(Map<String, dynamic> value) =>
          chat.receiveCallEventForTesting(jsonEncode(value));
      Future<void> tool(Map<String, dynamic> args) => event({
        'type': 'toolCall',
        'calls': [
          {'id': 'tool', 'name': 'manage_vocabulary', 'args': args},
        ],
      });
      Future<void> speech(String text) async {
        await chat.receiveCallEventForTesting(Uint8List(4800));
        await event({'type': 'transcript', 'role': 'model', 'text': text});
      }

      try {
        await event({'type': 'ready', 'vocabularyVersion': 3});
        await tool({
          'action': 'review_start',
          'scope': 'all',
          'style': 'explain_meaning',
        });
        await speech('What does banana mean?');
        expect(methods.where((m) => m == 'feed'), isEmpty);
        expect(chat.messages, isEmpty);
        await event({'type': 'interrupted'});
        expect(
          (await vocabulary.reviewState())!['current']['phase'],
          'selected',
        );
        await event({'type': 'ready', 'vocabularyVersion': 3});
        await tool({'action': 'review_next'});
        var state = (await vocabulary.reviewState())!;
        await speech(state['pending']['text']);
        await event({'type': 'turnComplete'});
        expect(chat.messages.last.text, 'What does “give it a go” mean?');
        expect((await vocabulary.words()).single.reviews, 0);
        expect(
          (await vocabulary.reviewState())!['current']['phase'],
          'delivered',
        );
        await event({'type': 'transcript', 'role': 'user', 'text': 'Try it'});
        await tool({'action': 'review_answer'});
        state = (await vocabulary.reviewState())!;
        await tool({
          'action': 'review_feedback',
          'id': word['id'],
          'questionId': state['current']['questionId'],
          'verdict': 'accepted',
        });
        state = (await vocabulary.reviewState())!;
        await speech(state['pending']['text']);
        await event({'type': 'turnComplete'});
        expect((await vocabulary.words()).single.reviews, 1);
        expect(chat.messages.last.text, contains('That works.'));
        expect(
          chat.messages.last.text,
          contains('Your vocabulary review is finished for this session.'),
        );
        await tool({'action': 'review_pause', 'explicitChange': true});
        await speech('How was your day?');
        await event({'type': 'turnComplete'});
        expect(chat.messages.last.text, 'How was your day?');
        expect((await vocabulary.reviewState())!['scope'], 'all');
      } finally {
        chat.dispose();
        await Future<void>.delayed(const Duration(milliseconds: 50));
        messenger.setMockMethodCallHandler(AiChatController.audio, null);
        messenger.setMockMethodCallHandler(
          const MethodChannel('com.llfbandit.record/messages'),
          null,
        );
        await root.delete(recursive: true);
      }
    },
  );

  test(
    'V3 Practice word explanation can authorize ordinary conversation without saving vocabulary',
    () async {
      final root = await Directory.systemTemp.createTemp('review-explanation');
      final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
      WebSocket? peer;
      server.listen((request) async {
        final socket = peer = await WebSocketTransformer.upgrade(request);
        socket.add(
          jsonEncode({
            'type': 'ready',
            'vocabularyVersion': 3,
            'acceptText': true,
          }),
        );
        socket.listen((event) {
          if (event is! String) return;
          final frame = jsonDecode(event) as Map;
          if (frame['type'] == 'commit') {
            socket.add(
              jsonEncode({
                'type': 'toolCall',
                'calls': [
                  {
                    'id': 'mode',
                    'name': 'manage_vocabulary',
                    'args': {'action': 'review_conversation'},
                  },
                ],
              }),
            );
          } else if (frame['type'] == 'toolResponse') {
            expect(
              frame['responses'][0]['response']['result']['normalConversation'],
              true,
            );
            socket.add(Uint8List(4800));
            socket.add(
              jsonEncode({
                'type': 'complete',
                'inputText': 'Explain bank',
                'outputText': 'A bank keeps money.',
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
      messenger.setMockMethodCallHandler(AiChatController.audio, (call) async {
        if (call.method == 'storagePath') return root.path;
        if (call.method == 'playedFrames') return 2400;
        return null;
      });
      final vocabulary = AiVocabulary(
        'test',
        storagePath: () async => root.path,
        isActive: () => true,
        language: () => 'en-NZ',
        timeZone: () async => 'UTC',
      );
      final history = AiHistoryStore('test');
      await history.load();
      final chat = AiChatController.forTesting(
        history,
        api: _ReviewApi(server.port),
        vocabulary: vocabulary,
        voiceMetadata: () async => {},
      )..loaded = true;
      try {
        await chat.explainWord(
          text: 'bank',
          prompt: 'Explain bank',
          language: 'en-NZ',
        );
        expect(chat.messages.last.text, 'A bank keeps money.');
        expect(chat.failed, false);
        expect(await vocabulary.words(), isEmpty);
      } finally {
        chat.dispose();
        await peer?.close();
        await server.close(force: true);
        await Future<void>.delayed(const Duration(milliseconds: 50));
        messenger.setMockMethodCallHandler(AiChatController.audio, null);
        messenger.setMockMethodCallHandler(
          const MethodChannel('com.llfbandit.record/messages'),
          null,
        );
        await root.delete(recursive: true);
      }
    },
  );

  for (final search in [false, true]) {
    test(
      'V3 ordinary voice reply works without review handshake; search=$search',
      () async {
        final root = await Directory.systemTemp.createTemp('ordinary-v3');
        final vocabulary = AiVocabulary(
          'ordinary',
          storagePath: () async => root.path,
          isActive: () => true,
          language: () => 'en-NZ',
          timeZone: () async => 'UTC',
        );
        final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
        WebSocket? peer;
        final gate = AiReviewTurn(vocabulary, 'ordinary');
        final played = <int>[];
        var searched = false;
        server.listen((request) async {
          final socket = peer = await WebSocketTransformer.upgrade(request);
          socket.add(jsonEncode({'type': 'ready', 'vocabularyVersion': 3}));
          void reply() {
            socket.add(Uint8List(4800));
            socket.add(
              jsonEncode({
                'type': 'complete',
                'inputText': 'Show brownie photos',
                'outputText': 'Here are some brownie photos.',
              }),
            );
          }

          socket.listen((frame) {
            if (frame is! String) return;
            final data = jsonDecode(frame) as Map;
            if (data['type'] == 'commit') {
              if (search) {
                socket.add(
                  jsonEncode({
                    'type': 'toolCall',
                    'calls': [
                      {
                        'id': 'photos',
                        'name': 'search_web',
                        'args': {'query': 'images: brownies'},
                      },
                    ],
                  }),
                );
              } else {
                reply();
              }
            } else if (data['type'] == 'toolResponse') {
              reply();
            }
          });
        });
        final stream = AiVoiceStream(
          connect: () => WebSocket.connect('ws://127.0.0.1:${server.port}'),
          reviewTurn: gate,
          onAudio: (b) async => played.addAll(b),
          onReset: () async {},
          onToolCall: (call) async {
            expect(call['name'], 'search_web');
            expect(gate.holdOutput, false);
            searched = true;
            return {'images': <dynamic>[]};
          },
        );
        try {
          final result = await stream.send({});
          expect(result['outputText'], 'Here are some brownie photos.');
          expect(played, hasLength(4800));
          expect(searched, search);
          expect(await vocabulary.reviewState(), isNull);
        } finally {
          await stream.close();
          await peer?.close();
          await server.close(force: true);
          await root.delete(recursive: true);
        }
      },
    );
  }

  for (final match in [true, false]) {
    test(
      'V3 buffers quiz speech; matching=$match, and identity survives separate messages',
      () async {
        final root = await Directory.systemTemp.createTemp('review-wire');
        final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
        final sockets = <WebSocket>[];
        final vocabulary = AiVocabulary(
          'wire',
          storagePath: () async => root.path,
          isActive: () => true,
          language: () => 'en-NZ',
          timeZone: () async => 'UTC',
        );
        await vocabulary.execute({
          'action': 'add',
          'word': 'give it a go',
          'meaning': 'Try something',
        });
        var questionId = '', entryId = '';
        server.listen((request) async {
          final socket = await WebSocketTransformer.upgrade(request);
          sockets.add(socket);
          final answer = sockets.length == 2;
          socket.add(jsonEncode({'type': 'ready', 'vocabularyVersion': 3}));
          socket.listen((event) {
            if (event is! String) return;
            final frame = jsonDecode(event) as Map;
            if (frame['type'] == 'commit') {
              socket.add(
                jsonEncode({
                  'type': 'transcript',
                  'role': 'user',
                  'text': answer ? 'have a try' : 'Review all my words',
                }),
              );
              socket.add(
                jsonEncode({
                  'type': 'toolCall',
                  'calls': [
                    {
                      'id': 'r',
                      'name': 'manage_vocabulary',
                      'args': answer
                          ? {'action': 'review_answer'}
                          : {
                              'action': 'review_start',
                              'scope': 'all',
                              'style': 'guess_expression',
                            },
                    },
                  ],
                }),
              );
            } else if (frame['type'] == 'toolResponse') {
              final response = frame['responses'][0];
              final result = response['response']['result'];
              if (answer && response['id'] == 'r') {
                expect(result['currentId'], entryId);
                expect(result['questionId'], questionId);
                expect(result['scope'], 'all');
                expect(result['style'], 'guess_expression');
                expect(result['phase'], 'attempted');
                socket.add(
                  jsonEncode({
                    'type': 'toolCall',
                    'calls': [
                      {
                        'id': 'feedback',
                        'name': 'manage_vocabulary',
                        'args': {
                          'action': 'review_feedback',
                          'id': entryId,
                          'questionId': questionId,
                          'verdict': 'accepted',
                        },
                      },
                    ],
                  }),
                );
                return;
              }
              questionId = result['questionId'];
              entryId = result['currentId'];
              final text = match
                  ? result['delivery']['text']
                  : 'What does the unsaved word banana mean?';
              socket.add(Uint8List(4800));
              socket.add(
                jsonEncode({
                  'type': 'transcript',
                  'role': 'model',
                  'text': text,
                }),
              );
              socket.add(
                jsonEncode({
                  'type': 'complete',
                  'inputText': answer ? 'have a try' : 'Review all my words',
                  'outputText': text,
                }),
              );
            }
          });
        });
        try {
          for (final turnId in ['question', 'answer']) {
            final gate = AiReviewTurn(vocabulary, turnId);
            final played = <int>[];
            final captions = <String>[];
            final stream = AiVoiceStream(
              connect: () => WebSocket.connect('ws://127.0.0.1:${server.port}'),
              reviewTurn: gate,
              onAudio: (bytes) async => played.addAll(bytes),
              onReset: () async {},
              onToolCall: (call) =>
                  gate.tool(Map<String, dynamic>.from(call['args'])),
              onTranscript: (role, text) {
                if (role == 'model') captions.add(text);
              },
            );
            final result = await stream.send({});
            expect(result['outputText'], isNot(contains('banana')));
            expect(captions.join(), result['outputText']);
            expect(played.length, match ? 4800 : 0);
            expect(result['audio'] == null, !match);
            // Transport success alone is not persistence/receipt acknowledgement.
            expect((await vocabulary.words()).single.reviews, 0);
            await gate.delivered();
            await stream.close();
          }
          expect((await vocabulary.words()).single.reviews, 1);
        } finally {
          for (final socket in sockets) {
            await socket.close();
          }
          await server.close(force: true);
          await root.delete(recursive: true);
        }
      },
    );
  }
}
