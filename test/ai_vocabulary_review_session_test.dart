import 'dart:convert';
import 'dart:io';
import 'package:app/infrastructure/ai/ai_vocabulary.dart';
import 'package:app/infrastructure/ai/ai_review_turn.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late Directory root;
  late DateTime now;
  late bool active;
  late AiVocabulary store;
  AiVocabulary create([String owner = 'one']) => AiVocabulary(
    owner,
    storagePath: () async => root.path,
    isActive: () => active,
    now: () => now,
    timeZone: () async => 'Pacific/Auckland',
    language: () => 'en-NZ',
  );
  setUp(() async {
    root = await Directory.systemTemp.createTemp('review-session');
    now = DateTime.utc(2026, 11, 1);
    active = true;
    store = create();
  });
  tearDown(() async => root.delete(recursive: true));
  Future<Map<String, dynamic>> add([
    String word = 'give it a go',
    String language = 'en-NZ',
  ]) async => (await store.execute({
    'action': 'add',
    'word': word,
    'meaning': 'Try something',
    'language': language,
  }))['word'];
  Future<Map<String, dynamic>> start({
    String scope = 'due',
    String style = 'guess_expression',
    String turn = 'q',
  }) => store.reviewTool(
    {'action': 'review_start', 'scope': scope, 'style': style},
    turnId: turn,
    input: 'Review my words',
  );
  Future<void> deliver(Map result) async => expect(
    await store.reviewDelivered(
      result['delivery']['turn'],
      result['delivery']['token'],
    ),
    isTrue,
  );

  test('ordinary chat pauses old review without losing its progress', () async {
    final ordinary = AiReviewTurn(store, 'chat')..enabled = true;
    await ordinary.allowOrdinaryReply();
    expect(ordinary.normalConversation, true);
    final word = await add();
    final session = await start(scope: 'all');
    final blocked = AiReviewTurn(store, 'unrelated')..enabled = true;
    await blocked.allowOrdinaryReply();
    expect(blocked.holdOutput, false);
    await blocked.authorizeOrdinaryTool('search_web');
    expect(blocked.normalConversation, true);
    final paused = (await store.reviewState())!;
    expect(paused['paused'], true);
    expect(paused['id'], session['sessionId']);
    expect(paused['current']['id'], word['id']);
    expect(paused['completed'], isEmpty);
    expect((await store.words()).single.reviews, 0);
    final resumed = await store.reviewTool(
      {'action': 'review_next'},
      turnId: 'resume',
      input: 'Continue',
    );
    expect(resumed['currentId'], word['id']);
    expect(resumed['sessionId'], session['sessionId']);
  });

  test(
    'failed review attempt cannot escape validation through ordinary fallback',
    () async {
      final gate = AiReviewTurn(store, 'invalid')..enabled = true;
      await gate.tool({
        'action': 'review_feedback',
        'id': 'invented',
        'questionId': 'missing',
      });
      await gate.allowOrdinaryReply();
      expect(gate.holdOutput, true);
      expect(await gate.delivered(), isNull);
    },
  );

  test(
    'empty, none due, storage failure and language no-match are distinct',
    () async {
      expect((await start())['state'], 'empty_notebook');
      await store.reviewTool(
        {'action': 'review_cancel'},
        turnId: 'x',
        input: 'stop',
      );
      await add();
      expect((await start())['state'], 'none_due');
      final file = root.listSync().whereType<File>().first;
      await file.writeAsString('broken json');
      final gate = AiReviewTurn(store, 'bad')..enabled = true;
      expect(
        (await gate.tool({'action': 'review_status'}))['state'],
        'storage_error',
      );
      await gate.allowOrdinaryReply();
      expect(gate.normalConversation, true);
      final review = AiReviewTurn(store, 'bad-review')..enabled = true;
      await review.tool({'action': 'review_next'});
      expect(await review.finalText(), AiReviewTurn.unavailable);
    },
  );

  for (final sessionKind in [
    'none',
    'active',
    'paused',
    'completed',
    'cancelled',
    'none_due',
    'empty',
  ]) {
    for (final statusFirst in [true, false]) {
      test(
        'status and add are ordinary: $sessionKind, statusFirst=$statusFirst',
        () async {
          if (sessionKind != 'none') {
            if (sessionKind != 'empty') await add();
            final started = await start(
              scope: sessionKind == 'none_due' ? 'due' : 'all',
            );
            if (sessionKind == 'paused') {
              await store.reviewTool(
                {'action': 'review_pause', 'explicitChange': true},
                turnId: 'pause',
                input: 'pause',
              );
            } else if (sessionKind == 'cancelled') {
              await store.reviewTool(
                {'action': 'review_cancel'},
                turnId: 'cancel',
                input: 'cancel',
              );
            } else if (sessionKind == 'completed') {
              await deliver(started);
              await store.reviewInput('answer', 'Try something');
              final feedback = await store.reviewTool(
                {
                  'action': 'review_feedback',
                  'id': started['currentId'],
                  'questionId': started['questionId'],
                  'verdict': 'accepted',
                },
                turnId: 'answer',
                input: 'Try something',
              );
              await deliver(feedback);
            }
          }
          final before = await store.reviewState();
          final gate = AiReviewTurn(store, 'add-antidote')..enabled = true;
          Future<void> status() async {
            final beforeRead = await store.reviewState();
            final file = root.listSync().whereType<File>().firstOrNull;
            final bytes = await file?.readAsBytes();
            final result = await gate.tool({'action': 'review_status'});
            expect(result.containsKey('delivery'), false);
            expect(result['ok'], true);
            if (sessionKind == 'none') expect(result['state'], 'inactive');
            expect(await store.reviewState(), beforeRead);
            if (file != null) expect(await file.readAsBytes(), bytes);
            if (sessionKind == 'cancelled')
              expect(result['state'], 'cancelled');
          }

          if (statusFirst) await status();
          final added = await gate.tool({
            'action': 'add',
            'word': 'antidote',
            'meaning': 'A medicine that stops a poison from hurting you',
            'example': 'The doctor gave her an antidote.',
          });
          expect(added['ok'], true);
          expect(gate.normalConversation, true);
          if (!statusFirst) await status();
          await gate.allowOrdinaryReply();
          expect(gate.holdOutput, false);
          expect(
            (await store.words()).where((w) => w.word == 'antidote'),
            hasLength(1),
          );
          final after = await store.reviewState();
          if (before != null) {
            for (final field in [
              'id',
              'scope',
              'style',
              'pool',
              'current',
              'completed',
              'skipped',
              'removed',
            ]) {
              expect(after![field], before[field], reason: field);
            }
            if (sessionKind == 'active' || sessionKind == 'paused')
              expect(after!['paused'], true);
          } else {
            expect(after, isNull);
          }
          // A fresh message for a translation/meaning remains ordinary too.
          final followUp = AiReviewTurn(create(), 'translation')
            ..enabled = true;
          await followUp.tool({'action': 'review_status'});
          await followUp.allowOrdinaryReply();
          expect(followUp.holdOutput, false);
        },
      );
    }
  }

  for (final action in [
    'stats',
    'latest',
    'list',
    'review_suggestions',
    'add',
    'update',
    'remove',
  ]) {
    test(
      'notebook $action pauses earlier review but never grades it',
      () async {
        final word = await add();
        final started = await start(scope: 'all');
        await deliver(started);
        final gate = AiReviewTurn(store, 'notebook')..enabled = true;
        final result = await gate.tool({
          'action': action,
          'id': word['id'],
          'word': 'antidote',
          'meaning': 'Medicine for poison',
        });
        expect(result['ok'], true);
        expect(gate.holdOutput, false);
        final saved = (await store.reviewState())!;
        expect(saved['paused'], true);
        expect(saved['completed'], isEmpty);
        expect(saved['current']['phase'], 'delivered');
      },
    );
  }

  test(
    'status is observational even for paused, stale and deleted items',
    () async {
      final word = await add();
      final started = await start(scope: 'all');
      await store.reviewTool(
        {'action': 'review_pause', 'explicitChange': true},
        turnId: 'p',
        input: 'pause',
      );
      await store.execute({'action': 'remove', 'id': word['id']});
      final file = root.listSync().whereType<File>().single;
      final original = await file.readAsString();
      final result = await store.reviewTool(
        {'action': 'review_status'},
        turnId: 's',
        input: 'inspect',
      );
      expect(result['paused'], true);
      expect(result['currentId'], isNull);
      expect(result['state'], 'empty_notebook');
      expect(result['removed'], 1);
      expect(result.containsKey('delivery'), false);
      expect(await file.readAsString(), original);
      expect(jsonDecode(original)['reviewSession']['id'], started['sessionId']);
    },
  );

  test(
    'observations and notebook tools cannot release same-turn valid review output',
    () async {
      await add();
      final gate = AiReviewTurn(store, 'q')..enabled = true;
      final result = await gate.tool({
        'action': 'review_start',
        'scope': 'all',
        'style': 'explain_meaning',
      });
      final expected = await gate.finalText();
      await gate.tool({'action': 'review_status'});
      await gate.tool({'action': 'stats'});
      await gate.tool({
        'action': 'add',
        'word': 'antidote',
        'meaning': 'Medicine for poison',
      });
      expect((await gate.tool({'action': 'review_conversation'}))['ok'], false);
      await gate.authorizeOrdinaryTool('search_web');
      await gate.allowOrdinaryReply();
      expect(gate.holdOutput, true);
      expect(await gate.finalText(), expected);
      expect(
        await store.reviewDeliveryValid('q', result['delivery']['token']),
        true,
      );
      await gate.delivered();
      expect((await store.reviewState())!['current']['phase'], 'delivered');
    },
  );

  test(
    'invalid review attempts stay guarded after observations and ordinary tools',
    () async {
      await add();
      final gate = AiReviewTurn(store, 'invalid')..enabled = true;
      await gate.tool({
        'action': 'review_feedback',
        'id': 'invented',
        'questionId': 'invented',
        'verdict': 'accepted',
      });
      await gate.tool({'action': 'review_status'});
      await gate.tool({'action': 'list'});
      await gate.tool({'action': 'review_conversation'});
      await gate.authorizeOrdinaryTool('search_web');
      await gate.allowOrdinaryReply();
      expect(gate.holdOutput, true);
      expect(await gate.finalText(), AiReviewTurn.notReady);
      expect(await gate.delivered(), isNull);
      expect((await store.words()).single.reviews, 0);
    },
  );

  for (final name in ['search_web', 'display_formatted_text', 'send_emojis']) {
    test(
      '$name authorizes ordinary output but cannot override a review attempt',
      () async {
        await add();
        await start(scope: 'all');
        final ordinary = AiReviewTurn(store, 'ordinary')..enabled = true;
        await ordinary.tool({'action': 'review_status'});
        await ordinary.authorizeOrdinaryTool(name);
        expect(ordinary.holdOutput, false);
        expect((await store.reviewState())!['paused'], true);
        final guarded = AiReviewTurn(store, 'guarded')..enabled = true;
        await guarded.tool({'action': 'review_next'});
        final expected = await guarded.finalText();
        await guarded.authorizeOrdinaryTool(name);
        expect(guarded.holdOutput, true);
        expect(await guarded.finalText(), expected);
      },
    );
  }

  test(
    'ordinary overlapping turn does not invalidate an issued review delivery',
    () async {
      await add();
      final question = AiReviewTurn(store, 'question')..enabled = true;
      final selected = await question.tool({
        'action': 'review_start',
        'scope': 'all',
        'style': 'explain_meaning',
      });
      final questionText = await question.finalText();
      final unrelated = AiReviewTurn(create(), 'ordinary')..enabled = true;
      await unrelated.tool({'action': 'review_status'});
      await unrelated.allowOrdinaryReply();
      expect(unrelated.holdOutput, false);
      expect((await store.reviewState())!['paused'], true);
      expect(await question.finalText(), questionText);
      expect(
        await store.reviewDeliveryValid(
          'question',
          selected['delivery']['token'],
        ),
        true,
      );
      await question.delivered();
      expect((await store.reviewState())!['current']['phase'], 'delivered');
      expect((await store.words()).single.reviews, 0);

      final answer = AiReviewTurn(create(), 'answer')..enabled = true;
      answer.addInput('Try something');
      final state = await answer.tool({'action': 'review_answer'});
      final feedback = await answer.tool({
        'action': 'review_feedback',
        'id': state['currentId'],
        'questionId': state['questionId'],
        'verdict': 'accepted',
      });
      final feedbackText = await answer.finalText();
      final addTurn = AiReviewTurn(create(), 'add')..enabled = true;
      await addTurn.tool({
        'action': 'add',
        'word': 'antidote',
        'meaning': 'Medicine for poison',
      });
      await addTurn.tool({'action': 'review_status'});
      expect(await answer.finalText(), feedbackText);
      expect(
        await store.reviewDeliveryValid(
          'answer',
          feedback['delivery']['token'],
        ),
        true,
      );
      await answer.delivered();
      expect(
        (await store.words())
            .firstWhere((w) => w.word == 'give it a go')
            .reviews,
        1,
      );
      expect((await store.reviewState())!['paused'], true);
      expect(await answer.delivered(), isNull);
    },
  );

  for (final action in ['review_pause', 'review_cancel', 'review_next']) {
    test(
      'explicit $action still invalidates previous pending delivery',
      () async {
        await add();
        final pending = AiReviewTurn(store, 'old')..enabled = true;
        final old = await pending.tool({
          'action': 'review_start',
          'scope': 'all',
          'style': 'explain_meaning',
        });
        final ordinary = AiReviewTurn(create(), 'ordinary')..enabled = true;
        await ordinary.allowOrdinaryReply();
        expect(
          await store.reviewDeliveryValid('old', old['delivery']['token']),
          true,
        );
        final explicit = AiReviewTurn(create(), 'new')..enabled = true;
        await explicit.tool({'action': action, 'explicitChange': true});
        expect(
          await store.reviewDeliveryValid('old', old['delivery']['token']),
          false,
        );
        expect(await pending.finalText(), AiReviewTurn.notReady);
        expect(await pending.delivered(), isNull);
        expect((await store.words()).single.reviews, 0);
      },
    );
  }

  test(
    'ordinary storage failure is not a failed review and never prevents normal replies',
    () async {
      await add();
      await root.listSync().whereType<File>().single.writeAsString('broken');
      final gate = AiReviewTurn(store, 'ordinary')..enabled = true;
      expect((await gate.tool({'action': 'list'}))['state'], 'storage_error');
      await gate.tool({'action': 'review_status'});
      await gate.allowOrdinaryReply();
      expect(gate.normalConversation, true);
      expect(gate.holdOutput, false);
    },
  );

  for (final style in ['guess_expression', 'explain_meaning']) {
    test(
      '$style phrase identity survives selection, interruption and restart',
      () async {
        final word = await add();
        now = now.add(const Duration(days: 2));
        final chosen = await start(style: style);
        expect(chosen['currentId'], word['id']);
        expect(chosen.containsKey('answerReference'), false);
        expect(
          chosen['delivery']['text'].contains(word['word']),
          style == 'explain_meaning',
        );
        expect((await store.words()).single.reviews, 0);
        store = create();
        final again = await store.reviewTool(
          {'action': 'review_next'},
          turnId: 'q2',
          input: 'continue',
        );
        expect(again['questionId'], chosen['questionId']);
        expect(again['scope'], 'due');
        expect(again['style'], style);
        await deliver(again);
        await store.reviewInput('a', 'have a try');
        final status = await store.reviewTool(
          {'action': 'review_status'},
          turnId: 'a',
          input: 'have a try',
        );
        expect(status['phase'], 'attempted');
        expect(status['answerReference']['id'], word['id']);
        final feedback = await store.reviewTool(
          {
            'action': 'review_feedback',
            'id': word['id'],
            'questionId': status['questionId'],
            'verdict': 'accepted',
          },
          turnId: 'a',
          input: 'have a try',
        );
        expect((await store.words()).single.reviews, 0);
        await deliver(feedback);
        expect((await store.words()).single.reviews, 1);
        expect(
          await store.reviewDelivered('a', feedback['delivery']['token']),
          false,
        );
        expect((await store.words()).single.reviews, 1);
        expect((await store.reviewState())!['state'], 'completed');
        expect(
          (await store.reviewTool(
            {'action': 'review_next'},
            turnId: 'later',
            input: 'next',
          ))['state'],
          'completed',
        );
      },
    );
  }

  test(
    'due scope and cutoff do not reset to recent, include new arrivals or silently change',
    () async {
      await add('older');
      now = now.add(const Duration(days: 2));
      await add('newer');
      final s = await start();
      final cutoff = s['dueCutoff'];
      now = now.add(const Duration(days: 3));
      final again = await start(scope: 'all', style: 'explain_meaning');
      expect(again['scope'], 'due');
      expect(again['style'], 'guess_expression');
      expect(again['dueCutoff'], cutoff);
      expect((await store.reviewState())!['pool'].length, 1);
      final changed = await store.reviewTool(
        {
          'action': 'review_start',
          'explicitChange': true,
          'sessionId': s['sessionId'],
          'scope': 'all',
          'style': 'explain_meaning',
        },
        turnId: 'new',
        input: 'change',
      );
      expect(changed['scope'], 'all');
      expect(changed['sessionId'], isNot(s['sessionId']));
      expect((await store.reviewState())!['pool'].length, 2);
    },
  );

  test(
    'unsaved ids, selection alone and same-turn input cannot be reviewed',
    () async {
      final word = await add();
      final s = await start(scope: 'all');
      final args = {
        'action': 'review_feedback',
        'id': word['id'],
        'questionId': s['questionId'],
        'verdict': 'accepted',
      };
      expect(
        (await store.reviewTool(args, turnId: 'q', input: 'answer'))['ok'],
        false,
      );
      await deliver(s);
      await store.reviewInput('q', 'initial request');
      expect(
        (await store.reviewTool(args, turnId: 'q', input: 'answer'))['ok'],
        false,
      );
      await store.reviewInput('a', 'answer');
      expect(
        (await store.reviewTool(
          {...args, 'id': 'invented'},
          turnId: 'a',
          input: 'answer',
        ))['error'],
        'not_current_item',
      );
      expect((await store.words()).single.reviews, 0);
    },
  );

  test(
    'skip is unfinished, explicit repeat is allowed, cancellation releases conversation',
    () async {
      final word = await add();
      final s = await start(scope: 'all');
      final skipped = await store.reviewTool(
        {'action': 'review_skip', 'id': word['id']},
        turnId: 'skip',
        input: 'skip',
      );
      expect(skipped['state'], 'unfinished');
      expect(skipped['skipped'], 1);
      expect((await store.words()).single.reviews, 0);
      final repeated = await store.reviewTool(
        {'action': 'review_repeat', 'id': word['id'], 'explicitChange': true},
        turnId: 'repeat',
        input: 'repeat',
      );
      expect(repeated['currentId'], word['id']);
      expect(repeated['questionId'], isNot(s['questionId']));
      expect(
        (await store.reviewTool(
          {'action': 'review_conversation'},
          turnId: 'r',
          input: 'hi',
        ))['normalConversation'],
        true,
      );
      expect((await store.reviewState())!['paused'], true);
      await store.reviewTool(
        {'action': 'review_cancel'},
        turnId: 'cancel',
        input: 'stop',
      );
      expect(
        (await store.reviewTool(
          {'action': 'review_conversation'},
          turnId: 'r',
          input: 'hi',
        ))['normalConversation'],
        true,
      );
    },
  );

  test(
    'deletion, editing, clearing and racing deliveries cannot consume stale entries',
    () async {
      final word = await add();
      final s = await start(scope: 'all');
      await store.execute({
        'action': 'update',
        'id': word['id'],
        'meaning': 'An edited meaning',
      });
      expect(await store.reviewDelivered('q', s['delivery']['token']), false);
      final again = await store.reviewTool(
        {'action': 'review_next'},
        turnId: 'q2',
        input: 'next',
      );
      expect(again['questionId'], isNot(s['questionId']));
      final concurrent = await Future.wait([
        store.reviewTool(
          {'action': 'review_next'},
          turnId: 'c1',
          input: 'next',
        ),
        create().reviewTool(
          {'action': 'review_next'},
          turnId: 'c2',
          input: 'next',
        ),
      ]);
      expect(concurrent[0]['currentId'], concurrent[1]['currentId']);
      expect(
        await store.reviewDelivered('c1', concurrent[0]['delivery']['token']),
        false,
      );
      await store.execute({'action': 'remove', 'id': word['id']});
      expect(
        await store.reviewDelivered('c2', concurrent[1]['delivery']['token']),
        false,
      );
      expect(
        (await store.reviewTool(
          {'action': 'review_status'},
          turnId: 's',
          input: 'status',
        ))['state'],
        'empty_notebook',
      );
      await store.clear();
      expect(await store.reviewState(), null);
    },
  );

  test(
    'next and status are not attempts; pause retains due scope; reconnect can finish actual feedback',
    () async {
      final w = await add();
      now = now.add(const Duration(days: 2));
      final s = await start();
      await deliver(s);
      final next = AiReviewTurn(store, 'next')..enabled = true;
      next.addInput('next');
      await next.tool({'action': 'review_status'});
      expect((await store.reviewState())!['current']['phase'], 'delivered');
      await next.tool({'action': 'review_pause', 'explicitChange': true});
      expect(next.normalConversation, true);
      expect((await store.reviewState())!['scope'], 'due');
      final answer = AiReviewTurn(create(), 'answer')..enabled = true;
      answer.addInput('to try');
      await answer.tool({'action': 'review_answer'});
      // A model disconnect loses no actual answer. Feedback is retried on another transport.
      final reconnect = AiReviewTurn(create(), 'reconnected')..enabled = true;
      final status = await reconnect.tool({'action': 'review_status'});
      expect(status['phase'], 'attempted');
      expect(status['scope'], 'due');
      await reconnect.tool({
        'action': 'review_feedback',
        'id': w['id'],
        'questionId': status['questionId'],
        'verdict': 'accepted',
      });
      expect((await store.words()).single.reviews, 0);
      expect(
        await reconnect.delivered(),
        'Your due review is finished for this session.',
      );
      expect(await reconnect.delivered(), null);
    },
  );

  test(
    'language filter is retained and explicit no-match is not an empty notebook',
    () async {
      await add('hello', 'en-NZ');
      await add('bonjour', 'fr-FR');
      var result = await store.reviewTool(
        {
          'action': 'review_start',
          'scope': 'all',
          'style': 'explain_meaning',
          'language': 'ja-JP',
        },
        turnId: 'q',
        input: 'Japanese',
      );
      expect(result['state'], 'no_matches');
      result = await store.reviewTool(
        {
          'action': 'review_start',
          'scope': 'all',
          'style': 'explain_meaning',
          'language': 'fr-FR',
          'explicitChange': true,
          'sessionId': result['sessionId'],
        },
        turnId: 'q2',
        input: 'French',
      );
      expect(result['delivery']['text'], contains('bonjour'));
      final resumed = await create().reviewTool(
        {'action': 'review_next'},
        turnId: 'q3',
        input: 'continue',
      );
      expect(resumed['language'], 'fr-fr');
      expect(resumed['currentId'], result['currentId']);
    },
  );

  test(
    'account isolation, failures and restart do not depend on chat history',
    () async {
      await add();
      final s = await start(scope: 'all');
      expect((await create().reviewState())!['id'], s['sessionId']);
      expect(await create('two').reviewState(), null);
      expect(await create('two').words(), isEmpty);
      active = false;
      expect(() => store.reviewState(), throwsStateError);
    },
  );

  test(
    'output gate rejects unsolicited/unsaved output, allows only device-authored review text',
    () async {
      await add();
      final gate = AiReviewTurn(store, 'q')..enabled = true;
      expect(gate.holdOutput, true);
      expect(await gate.finalText(), AiReviewTurn.notReady);
      await gate.tool({
        'action': 'review_start',
        'scope': 'all',
        'style': 'guess_expression',
      });
      expect(gate.holdOutput, true);
      final expected = await gate.finalText();
      expect(gate.matchesSpeech('What is banana?', expected), false);
      expect(expected.contains('give it a go'), false);
      expect(gate.matchesSpeech(expected.toUpperCase(), expected), true);
      expect(
        (await gate.tool({'action': 'review', 'id': 'fake'}))['ok'],
        false,
      );
      await gate.delivered();
      expect((await store.words()).single.reviews, 0);
      final next = AiReviewTurn(create(), 'answer')..enabled = true;
      next.addInput('to try');
      final status = await next.tool({'action': 'review_answer'});
      expect(status['scope'], 'all');
      expect(status['phase'], 'attempted');
      expect(status['learnerAnswer'], 'to try');
    },
  );
}
