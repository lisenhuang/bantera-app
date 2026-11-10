import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:app/infrastructure/ai/ai_review_turn.dart';
import 'package:app/infrastructure/ai/ai_history_store.dart';
import 'package:app/presentation/chats/ai/ai_chat_controller.dart';
import 'package:flutter/services.dart';
import 'package:app/infrastructure/ai/ai_voice_stream.dart';
import 'package:app/infrastructure/ai/ai_vocabulary.dart';
import 'package:flutter_test/flutter_test.dart';

/// A real socket with an explicit event-queue barrier. Tests inspect playback
/// while completion is deliberately withheld, rather than measuring wall time.
class _VoicePeer {
  _VoicePeer(this.vocabulary);
  final AiVocabulary vocabulary;
  late HttpServer server;
  late WebSocket socket;
  late AiVoiceStream stream;
  late AiReviewTurn review;
  late Future<Map<String, dynamic>> reply;
  final played = <int>[];
  final captions = <String>[];
  final barriers = <String, Completer<void>>{};
  final toolReplies = <String, Completer<Map<String, dynamic>>>{};
  var resets = 0;
  var opened = false;
  var completeReceived = false;
  var serial = 0;

  Future<void> open(int version) async {
    server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    opened = true;
    final committed = Completer<void>();
    server.listen((request) async {
      socket = await WebSocketTransformer.upgrade(request);
      socket.add(jsonEncode({'type': 'ready', 'vocabularyVersion': version}));
      socket.listen((frame) {
        if (frame is! String) return;
        final value = jsonDecode(frame) as Map;
        if (value['type'] == 'commit') committed.complete();
        if (value['type'] == 'toolResponse') {
          for (final response in value['responses'] as List) {
            toolReplies
                .remove(response['id'])!
                .complete(
                  Map<String, dynamic>.from(
                    response['response']['result'] as Map,
                  ),
                );
          }
        }
      });
    });
    review = AiReviewTurn(vocabulary, 'latency-test');
    stream = AiVoiceStream(
      connect: () => WebSocket.connect('ws://127.0.0.1:${server.port}'),
      reviewTurn: review,
      onAudio: (pcm) async => played.addAll(pcm),
      onReset: () async => resets++,
      onTranscript: (role, text) {
        if (role == 'model') captions.add(text);
        if (role == 'user') barriers.remove(text)?.complete();
      },
      onToolCall: (call) =>
          review.tool(Map<String, dynamic>.from(call['args'] as Map)),
    );
    reply = stream.send({}).then((value) {
      completeReceived = true;
      return value;
    });
    reply.ignore();
    await committed.future;
  }

  void frame(Map<String, dynamic> value) => socket.add(jsonEncode(value));
  void audio(int value) => socket.add(Uint8List.fromList([value, 0, value, 0]));
  void text(String value) =>
      frame({'type': 'transcript', 'role': 'model', 'text': value});

  Future<void> flush() {
    final marker = 'barrier-${serial++}';
    final done = barriers[marker] = Completer<void>();
    frame({'type': 'transcript', 'role': 'user', 'text': marker});
    return done.future.timeout(const Duration(seconds: 5));
  }

  Future<Map<String, dynamic>> tool(Map<String, dynamic> args) {
    final id = 'tool-${serial++}';
    final done = toolReplies[id] = Completer<Map<String, dynamic>>();
    frame({
      'type': 'toolCall',
      'calls': [
        {'id': id, 'name': 'manage_vocabulary', 'args': args},
      ],
    });
    return done.future.timeout(const Duration(seconds: 5));
  }

  Future<Map<String, dynamic>> finish(String output) {
    frame({'type': 'complete', 'inputText': 'Hello', 'outputText': output});
    return reply;
  }

  Future<void> close() async {
    if (!opened) return;
    await stream.close();
    await socket.close();
    await server.close(force: true);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late Directory directory;
  late AiVocabulary vocabulary;
  late _VoicePeer peer;
  setUp(() async {
    directory = await Directory.systemTemp.createTemp('voice-latency-');
    vocabulary = AiVocabulary(
      'latency-owner',
      storagePath: () async => directory.path,
      isActive: () => true,
      language: () => 'en-NZ',
      timeZone: () async => 'UTC',
    );
    peer = _VoicePeer(vocabulary);
  });
  tearDown(() async {
    await peer.close();
    await directory.delete(recursive: true);
  });

  Future<void> seed() => vocabulary.execute({
    'action': 'add',
    'word': 'antidote',
    'meaning': 'A medicine that stops a poison from working',
    'example': 'The doctor gave her an antidote.',
  });

  test(
    'V4 ordinary PCM and captions play before completion, once only',
    () async {
      await peer.open(4);
      peer.audio(1);
      peer.text('Hello ');
      await peer.flush();
      expect(peer.completeReceived, false);
      expect(peer.played, [1, 0, 1, 0]);
      expect(peer.captions, ['Hello ']);
      peer.audio(2);
      peer.text('there.');
      await peer.flush();
      expect(peer.played, [1, 0, 1, 0, 2, 0, 2, 0]);
      await peer.finish('Hello there.');
      expect(peer.played, [1, 0, 1, 0, 2, 0, 2, 0]);
      expect(peer.captions.join(), 'Hello there.');
    },
  );

  test('V3 retains legacy buffering until ordinary completion', () async {
    await peer.open(3);
    peer.audio(1);
    peer.text('Hello.');
    await peer.flush();
    expect(peer.played, isEmpty);
    expect(peer.captions, isEmpty);
    await peer.finish('Hello.');
    expect(peer.played, [1, 0, 1, 0]);
    expect(peer.captions, ['Hello.']);
  });

  test('V4 actual review still withholds invalid audio and delivery', () async {
    await seed();
    await peer.open(4);
    final result = await peer.tool({
      'action': 'review_start',
      'scope': 'all',
      'style': 'explain_meaning',
    });
    expect(result['ok'], true);
    peer.audio(1);
    peer.text('Your review is complete.');
    await peer.flush();
    expect(peer.played, isEmpty);
    final reply = await peer.finish('Your review is complete.');
    expect(peer.played, isEmpty);
    expect(reply['audio'], isNull);
    expect(reply['outputText'], result['delivery']['text']);
    expect((await vocabulary.words()).single.reviews, 0);
  });

  test(
    'V4 valid review releases once and acknowledges only delivered content',
    () async {
      await seed();
      await peer.open(4);
      final result = await peer.tool({
        'action': 'review_start',
        'scope': 'all',
        'style': 'explain_meaning',
      });
      final expected = result['delivery']['text'] as String;
      peer.audio(1);
      peer.text(expected);
      await peer.flush();
      expect(peer.played, isEmpty);
      expect(peer.captions, isEmpty);
      expect((await vocabulary.reviewState())!['current']['phase'], 'selected');
      final reply = await peer.finish(expected);
      expect(peer.played, [1, 0, 1, 0]);
      expect(peer.captions, [expected]);
      expect(reply['audio'], isNotNull);
      expect(reply['outputText'], expected);
      // The controller acknowledges delivery after successful transport completion.
      // Merely receiving the model response must not mark a word reviewed.
      expect((await vocabulary.reviewState())!['current']['phase'], 'selected');
      await peer.review.delivered();
      final delivered = (await vocabulary.reviewState())!;
      expect(delivered['current']['phase'], 'delivered');
      expect(delivered['pending'], isNull);
      expect(delivered['completed'], isEmpty);
      expect((await vocabulary.words()).single.reviews, 0);
      await peer.review.delivered();
      expect(
        (await vocabulary.reviewState())!['current'],
        delivered['current'],
      );
      expect(peer.played, [
        1,
        0,
        1,
        0,
      ], reason: 'Acknowledgment never replays audio');
    },
  );

  test('V4 retry reset restores immediate ordinary playback', () async {
    await seed();
    await peer.open(4);
    await peer.tool({
      'action': 'review_start',
      'scope': 'all',
      'style': 'explain_meaning',
    });
    peer.audio(1);
    peer.text('Wrong provisional answer.');
    await peer.flush();
    expect(peer.played, isEmpty);
    peer.frame({'type': 'reset'});
    peer.audio(2);
    peer.text('Hello again.');
    await peer.flush();
    expect(peer.resets, 1);
    expect(peer.played, [2, 0, 2, 0]);
    expect(peer.captions, ['Hello again.']);
    await peer.finish('Hello again.');
    expect(peer.played, [2, 0, 2, 0]);
  });

  test(
    'V4 late review cannot mutate state or replay an ordinary preamble',
    () async {
      await seed();
      await peer.open(4);
      peer.audio(1);
      peer.text('Hello. ');
      await peer.flush();
      expect(peer.played, [1, 0, 1, 0]);
      final result = await peer.tool({
        'action': 'review_start',
        'scope': 'all',
        'style': 'explain_meaning',
      });
      expect(result['ok'], false);
      expect(result['error'], 'review_requires_new_turn');
      expect(await vocabulary.reviewState(), isNull);
      peer.audio(2);
      peer.text('We can review next.');
      await peer.finish('Hello. We can review next.');
      expect(peer.played, [1, 0, 1, 0, 2, 0, 2, 0]);
      expect(peer.captions.join(), 'Hello. We can review next.');
      expect((await vocabulary.words()).single.reviews, 0);
    },
  );

  for (final version in [3, 4]) {
    test(
      'V$version live call playback mode survives turn and interruption',
      () async {
        final messenger =
            TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
        var fed = 0;
        messenger.setMockMethodCallHandler(
          const MethodChannel('com.llfbandit.record/messages'),
          (_) async => null,
        );
        messenger.setMockMethodCallHandler(AiChatController.audio, (
          call,
        ) async {
          if (call.method == 'storagePath') return directory.path;
          if (call.method == 'playedFrames') return 0;
          if (call.method == 'feed') {
            fed += (call.arguments as Uint8List).length;
          }
          return null;
        });
        final store = AiHistoryStore('test');
        await store.load();
        final chat = AiChatController.forTesting(store, vocabulary: vocabulary)
          ..loaded = true;
        Future<void> event(Map<String, dynamic> frame) =>
            chat.receiveCallEventForTesting(jsonEncode(frame));
        try {
          await event({'type': 'ready', 'vocabularyVersion': version});
          await chat.receiveCallEventForTesting(Uint8List(2400));
          await event({
            'type': 'transcript',
            'role': 'model',
            'text': 'Hello.',
          });
          expect(
            fed,
            version == 4 ? 2400 : 0,
            reason: 'Inspect before turnComplete, not only eventual playback',
          );
          if (version == 4) {
            await seed();
            await event({
              'type': 'toolCall',
              'calls': [
                {
                  'id': 'late-review',
                  'name': 'manage_vocabulary',
                  'args': {
                    'action': 'review_start',
                    'scope': 'all',
                    'style': 'explain_meaning',
                  },
                },
              ],
            });
            expect(
              await vocabulary.reviewState(),
              isNull,
              reason:
                  'Live calls reject a review starting after ordinary speech',
            );
          }
          await event({'type': 'turnComplete'});
          expect(fed, 2400);
          await chat.receiveCallEventForTesting(Uint8List(2400));
          await event({
            'type': 'transcript',
            'role': 'model',
            'text': 'Next turn.',
          });
          expect(
            fed,
            version == 4 ? 4800 : 2400,
            reason: 'New turns preserve the negotiated protocol',
          );
          await event({'type': 'interrupted'});
          final before = fed;
          await chat.receiveCallEventForTesting(Uint8List(2400));
          await event({
            'type': 'transcript',
            'role': 'model',
            'text': 'After interruption.',
          });
          expect(fed, before + (version == 4 ? 2400 : 0));
          await event({'type': 'turnComplete'});
          expect(
            fed,
            before + 2400,
            reason: 'Completion must not double-play already streamed audio',
          );
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
