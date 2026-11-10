import 'dart:convert';
import 'dart:io';

import 'package:app/infrastructure/ai/ai_history_store.dart';
import 'package:app/infrastructure/ai/ai_review_turn.dart';
import 'package:app/infrastructure/ai/ai_voice_stream.dart';
import 'package:app/infrastructure/ai/ai_vocabulary.dart';
import 'package:app/presentation/chats/ai/ai_chat_controller.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

const _addAntidote = <String, dynamic>{
  'action': 'add',
  'word': 'antidote',
  'meaning': 'A medicine that stops a poison from working',
  'example': 'The doctor gave her an antidote.',
};

class _Reply {
  _Reply(this.result, this.played, this.captions, this.toolResults, this.gate);
  final Map<String, dynamic> result;
  final List<int> played;
  final List<String> captions;
  final List<Map<String, dynamic>> toolResults;
  final AiReviewTurn gate;
}

/// Exercises the real socket event queue, including audio arriving before tool
/// results, rather than only checking the gate's booleans in isolation.
Future<_Reply> _voiceReply(
  AiVocabulary vocabulary, {
  required int version,
  required String turn,
  required String input,
  required String output,
  List<Map<String, dynamic>> tools = const [],
  bool preToolAudio = true,
}) async {
  final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
  WebSocket? peer;
  final gate = AiReviewTurn(vocabulary, turn);
  final played = <int>[], captions = <String>[];
  final results = <Map<String, dynamic>>[];
  server.listen((request) async {
    final socket = peer = await WebSocketTransformer.upgrade(request);
    socket.add(jsonEncode({'type': 'ready', 'vocabularyVersion': version}));
    var nextTool = 0;
    void advance() {
      if (nextTool < tools.length) {
        final index = nextTool++;
        socket.add(
          jsonEncode({
            'type': 'toolCall',
            'calls': [
              {
                'id': 'tool-$index',
                'name': 'manage_vocabulary',
                'args': tools[index],
              },
            ],
          }),
        );
      } else {
        socket.add(Uint8List(2400));
        socket.add(
          jsonEncode({'type': 'transcript', 'role': 'model', 'text': output}),
        );
        socket.add(
          jsonEncode({
            'type': 'complete',
            'inputText': input,
            'outputText': output,
          }),
        );
      }
    }

    socket.listen((event) {
      if (event is! String) return;
      final frame = jsonDecode(event) as Map;
      if (frame['type'] == 'commit') {
        socket.add(
          jsonEncode({'type': 'transcript', 'role': 'user', 'text': input}),
        );
        if (preToolAudio) socket.add(Uint8List(2400));
        advance();
      } else if (frame['type'] == 'toolResponse') {
        final response = frame['responses'][0]['response']['result'];
        results.add(Map<String, dynamic>.from(response as Map));
        advance();
      }
    });
  });
  final stream = AiVoiceStream(
    connect: () => WebSocket.connect('ws://127.0.0.1:${server.port}'),
    reviewTurn: gate,
    onAudio: (audio) async => played.addAll(audio),
    onReset: () async {},
    onTranscript: (role, text) {
      if (role == 'model') captions.add(text);
    },
    onToolCall: (call) =>
        gate.tool(Map<String, dynamic>.from(call['args'] as Map)),
  );
  try {
    final result = await stream.send({});
    return _Reply(result, played, captions, results, gate);
  } finally {
    await stream.close();
    await peer?.close();
    await server.close(force: true);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late Directory root;
  late AiVocabulary vocabulary;
  setUp(() async {
    root = await Directory.systemTemp.createTemp('review-conversation');
    vocabulary = AiVocabulary(
      'test',
      storagePath: () async => root.path,
      isActive: () => true,
      language: () => 'en-NZ',
      timeZone: () async => 'UTC',
    );
  });
  tearDown(() async => root.delete(recursive: true));

  Future<Map<String, dynamic>> seedReview({bool paused = false}) async {
    await vocabulary.execute({
      'action': 'add',
      'word': 'give it a go',
      'meaning': 'Try something',
    });
    final result = await vocabulary.reviewTool(
      {'action': 'review_start', 'scope': 'all', 'style': 'explain_meaning'},
      turnId: 'earlier-question',
      input: 'Review my saved words',
    );
    expect(
      await vocabulary.reviewDelivered(
        'earlier-question',
        result['delivery']['token'],
      ),
      true,
    );
    if (paused) {
      await vocabulary.reviewTool(
        {'action': 'review_pause', 'explicitChange': true},
        turnId: 'pause',
        input: 'Stop for now',
      );
    }
    return (await vocabulary.reviewState())!;
  }

  void expectOrdinary(_Reply reply, String text) {
    expect(reply.result['outputText'], text);
    expect(reply.result['audio'], isNotNull);
    expect(
      reply.played,
      hasLength(4800),
      reason: 'No discarded or double-played audio',
    );
    expect(reply.captions.join(), text);
    expect(reply.gate.holdOutput, false);
  }

  for (final version in [3, 4]) {
    for (final prior in ['none', 'active', 'paused']) {
      for (final statusFirst in [true, false]) {
        test(
          'V$version antidote conversation, prior=$prior, statusFirst=$statusFirst',
          () async {
            final before = prior == 'none'
                ? null
                : await seedReview(paused: prior == 'paused');
            const definition =
                'An antidote is a medicine that stops a poison from working.';
            expectOrdinary(
              await _voiceReply(
                vocabulary,
                version: version,
                turn: 'definition',
                input: 'What does antidote mean?',
                output: definition,
                tools: [
                  {'action': 'review_status'},
                ],
              ),
              definition,
            );

            final addTools = [
              if (statusFirst) {'action': 'review_status'},
              _addAntidote,
              if (!statusFirst) {'action': 'review_status'},
            ];
            const example =
                'The doctor gave her an antidote. I saved antidote to your vocabulary.';
            final saved = await _voiceReply(
              vocabulary,
              version: version,
              turn: 'save',
              input:
                  'Make example sentences and add antidote to my vocabulary list.',
              output: example,
              tools: addTools,
            );
            expectOrdinary(saved, example);
            expect(saved.toolResults[statusFirst ? 1 : 0]['ok'], true);
            expect(
              (await vocabulary.words()).where((w) => w.word == 'antidote'),
              hasLength(1),
            );

            const translation = 'Yes, antidote means 解药 in Chinese.';
            expectOrdinary(
              await _voiceReply(
                vocabulary,
                version: version,
                turn: 'translation',
                input: 'Does antidote mean 解药?',
                output: translation,
                tools: [
                  {'action': 'review_status'},
                  {'action': 'list', 'query': 'antidote'},
                  {'action': 'review_status'},
                ],
              ),
              translation,
            );
            const greeting =
                'Good evening! What would you like to practise today?';
            expectOrdinary(
              await _voiceReply(
                vocabulary,
                version: version,
                turn: 'greeting',
                input: 'Good evening, Bantera.',
                output: greeting,
              ),
              greeting,
            );
            expect(
              (await vocabulary.words()).every((w) => w.reviews == 0),
              true,
            );
            final after = await vocabulary.reviewState();
            if (before == null) {
              expect(after, isNull);
            } else {
              expect(after!['id'], before['id']);
              for (final key in [
                'scope',
                'style',
                'cutoff',
                'pool',
                'current',
                'completed',
                'skipped',
              ]) {
                expect(
                  after[key],
                  before[key],
                  reason: 'Ordinary conversation preserves $key',
                );
              }
              expect(after['paused'], true);
            }
          },
        );
      }
    }

    test(
      'V$version display tools release held live speech once, never quiz output',
      () async {
        await seedReview();
        final messenger =
            TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
        var playedBytes = 0;
        messenger.setMockMethodCallHandler(
          const MethodChannel('com.llfbandit.record/messages'),
          (_) async => null,
        );
        messenger.setMockMethodCallHandler(AiChatController.audio, (
          call,
        ) async {
          if (call.method == 'storagePath') return root.path;
          if (call.method == 'playedFrames') return 0;
          if (call.method == 'feed') {
            playedBytes += (call.arguments as Uint8List).length;
          }
          return null;
        });
        final history = AiHistoryStore('test');
        await history.load();
        final chat = AiChatController.forTesting(
          history,
          vocabulary: vocabulary,
        )..loaded = true;
        Future<void> event(Map<String, dynamic> frame) =>
            chat.receiveCallEventForTesting(jsonEncode(frame));
        Future<void> tool(String name, Map<String, dynamic> args) => event({
          'type': 'toolCall',
          'calls': [
            {'id': 'tool', 'name': name, 'args': args},
          ],
        });
        const markdown =
            '- The doctor gave her an antidote.\n- There is no antidote for this poison.';
        try {
          await event({'type': 'ready', 'vocabularyVersion': version});
          await event({
            'type': 'transcript',
            'role': 'user',
            'text': 'Give two examples of antidote.',
          });
          await chat.receiveCallEventForTesting(Uint8List(2400));
          await event({
            'type': 'transcript',
            'role': 'model',
            'text': 'Here are ',
          });
          await tool('display_formatted_text', {'markdown': markdown});
          await tool('send_emojis', {
            'emojis': ['😊'],
          });
          await chat.receiveCallEventForTesting(Uint8List(2400));
          await event({
            'type': 'transcript',
            'role': 'model',
            'text': 'two examples.',
          });
          await event({'type': 'turnComplete'});
          expect(chat.messages.last.text, 'Here are two examples.');
          expect(chat.messages.last.formattedText, markdown);
          expect(chat.messages.last.emojis, ['😊']);
          expect(playedBytes, 4800);

          await event({
            'type': 'transcript',
            'role': 'user',
            'text': 'Continue my vocabulary review.',
          });
          await tool('manage_vocabulary', {'action': 'review_next'});
          final expected = (await vocabulary.reviewState())!['pending']['text'];
          await tool('display_formatted_text', {
            'markdown': 'An invented unsaved quiz answer.',
          });
          await tool('send_emojis', {
            'emojis': ['✅'],
          });
          await chat.receiveCallEventForTesting(Uint8List(4800));
          await event({
            'type': 'transcript',
            'role': 'model',
            'text': 'Your review is finished.',
          });
          await event({'type': 'turnComplete'});
          expect(chat.messages.last.text, expected);
          expect(chat.messages.last.formattedText, isNull);
          expect(chat.messages.last.emojis, isEmpty);
          expect(
            playedBytes,
            4800,
            reason: 'Unvalidated quiz audio must remain silent',
          );
          expect((await vocabulary.words()).single.reviews, 0);
        } finally {
          chat.dispose();
          await Future<void>.delayed(const Duration(milliseconds: 50));
          messenger.setMockMethodCallHandler(AiChatController.audio, null);
          messenger.setMockMethodCallHandler(
            const MethodChannel('com.llfbandit.record/messages'),
            null,
          );
        }
      },
    );

    test(
      'V$version actual invalid review cannot escape via status or add',
      () async {
        await seedReview();
        final before = (await vocabulary.reviewState())!;
        final reply = await _voiceReply(
          vocabulary,
          version: version,
          turn: 'invalid-feedback',
          // Actual review tools must authorize their delivery before speech.
          // Late tools after ordinary speech have a separate latency regression.
          preToolAudio: false,
          input: 'My answer is hello',
          output: 'That is correct. Your review is complete.',
          tools: [
            {
              'action': 'review_feedback',
              'id': 'invented',
              'questionId': 'invented',
              'verdict': 'accepted',
            },
            {'action': 'review_status'},
            _addAntidote,
            {'action': 'review_conversation'},
          ],
        );
        expect(reply.gate.holdOutput, true);
        expect(reply.result['outputText'], AiReviewTurn.notReady);
        expect(reply.result['audio'], isNull);
        expect(reply.played, isEmpty);
        expect(await reply.gate.delivered(), isNull);
        final after = (await vocabulary.reviewState())!;
        expect(after['current'], before['current']);
        expect(after['completed'], isEmpty);
        expect((await vocabulary.words()).every((w) => w.reviews == 0), true);
      },
    );

    test(
      'V$version live call notebook actions preserve conversation and review progress',
      () async {
        final before = await seedReview();
        final messenger =
            TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
        var playedBytes = 0;
        messenger.setMockMethodCallHandler(
          const MethodChannel('com.llfbandit.record/messages'),
          (_) async => null,
        );
        messenger.setMockMethodCallHandler(AiChatController.audio, (
          call,
        ) async {
          if (call.method == 'storagePath') return root.path;
          if (call.method == 'playedFrames') return 0;
          if (call.method == 'feed') {
            playedBytes += (call.arguments as Uint8List).length;
          }
          return null;
        });
        final history = AiHistoryStore('test');
        await history.load();
        final chat = AiChatController.forTesting(
          history,
          vocabulary: vocabulary,
        )..loaded = true;
        Future<void> event(Map<String, dynamic> value) =>
            chat.receiveCallEventForTesting(jsonEncode(value));
        Future<void> turn(
          String input,
          String output,
          List<Map<String, dynamic>> tools,
        ) async {
          await event({'type': 'transcript', 'role': 'user', 'text': input});
          await chat.receiveCallEventForTesting(Uint8List(2400));
          for (final args in tools) {
            await event({
              'type': 'toolCall',
              'calls': [
                {'id': 'tool', 'name': 'manage_vocabulary', 'args': args},
              ],
            });
          }
          await chat.receiveCallEventForTesting(Uint8List(2400));
          await event({'type': 'transcript', 'role': 'model', 'text': output});
          await event({'type': 'turnComplete'});
          expect(chat.messages.last.text, output);
        }

        try {
          await event({'type': 'ready', 'vocabularyVersion': version});
          await turn(
            'What does antidote mean?',
            'An antidote stops poison from working.',
            [
              {'action': 'review_status'},
            ],
          );
          await turn(
            'Add antidote and give an example.',
            'The doctor gave her an antidote. Saved.',
            [
              {'action': 'review_status'},
              _addAntidote,
              {'action': 'review_status'},
            ],
          );
          await turn('Does it mean 解药?', 'Yes, it means 解药.', [
            {'action': 'list', 'query': 'antidote'},
            {'action': 'review_status'},
          ]);
          await turn('Good evening', 'Good evening!', []);
          expect(playedBytes, 4 * 4800);
          expect(
            (await vocabulary.words()).where((w) => w.word == 'antidote'),
            hasLength(1),
          );
          expect((await vocabulary.words()).every((w) => w.reviews == 0), true);
          final after = (await vocabulary.reviewState())!;
          expect(after['current'], before['current']);
          expect(after['cutoff'], before['cutoff']);
          expect(after['scope'], before['scope']);
          expect(after['paused'], true);
          expect(after['completed'], isEmpty);
        } finally {
          chat.dispose();
          await Future<void>.delayed(const Duration(milliseconds: 50));
          messenger.setMockMethodCallHandler(AiChatController.audio, null);
          messenger.setMockMethodCallHandler(
            const MethodChannel('com.llfbandit.record/messages'),
            null,
          );
        }
      },
    );
  }
}
