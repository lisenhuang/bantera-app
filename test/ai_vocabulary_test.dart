import 'dart:io';
import 'dart:convert';
import 'dart:math';
import 'package:flutter_test/flutter_test.dart';
import 'package:app/infrastructure/ai/ai_vocabulary.dart';

void main() {
  late Directory root;
  late DateTime now;
  late bool active;
  late AiVocabulary store;
  AiVocabulary create(String owner) => AiVocabulary(
    owner,
    storagePath: () async => root.path,
    isActive: () => active,
    now: () => now,
    timeZone: () async => 'Pacific/Auckland',
    language: () => 'en-NZ',
    random: Random(17),
  );
  setUp(() async {
    root = await Directory.systemTemp.createTemp('vocabulary-test');
    now = DateTime.utc(2026, 10, 12);
    active = true;
    store = create('one');
  });
  tearDown(() async => root.delete(recursive: true));
  Future<Map<String, dynamic>> add(String word) => store.execute({
    'action': 'add',
    'word': word,
    'meaning': 'A short meaning',
  });
  test(
    'persists, counts and lists latest across repository instances; edits preserve learned date',
    () async {
      final first = await add('broth');
      final id = first['word']['id'];
      now = now.add(const Duration(hours: 2));
      await add('skewer');
      now = now.add(const Duration(days: 1));
      await create(
        'one',
      ).execute({'action': 'update', 'id': id, 'meaning': 'A thin soup'});
      final result = await store.execute({'action': 'list'});
      expect(result['total'], 2);
      expect(result['latest']['word'], 'skewer');
      final edited = (await store.words()).firstWhere((w) => w.id == id);
      expect(edited.learnedAt, DateTime.utc(2026, 10, 12));
      expect(edited.updatedAt, now);
      expect(edited.timeZone, 'Pacific/Auckland');
      expect(edited.meaning, 'A thin soup');
      expect((await create('two').words()), isEmpty);
    },
  );
  test(
    'concurrent writes do not lose words and duplicate retry preserves original meaning/date',
    () async {
      await Future.wait(
        List.generate(
          24,
          (i) => create(
            'one',
          ).execute({'action': 'add', 'word': 'word$i', 'meaning': 'meaning'}),
        ),
      );
      final repeat = await add('  WORD0  ');
      expect(repeat['alreadySaved'], true);
      expect(repeat['word']['meaning'], 'meaning');
      expect((await store.words()).length, 24);
      final page = await store.execute({'action': 'list', 'offset': 20});
      expect(page['items'].length, 4);
      expect(page['total'], 24);
    },
  );
  test(
    'only exact ids allow edits/removal and cross-language words remain distinct',
    () async {
      final original = await add('chat');
      await store.execute({
        'action': 'add',
        'word': 'chat',
        'meaning': 'cat',
        'language': 'fr-FR',
      });
      expect((await store.words()).length, 2);
      expect(
        (await store.execute({'action': 'remove', 'id': 'chat'}))['ok'],
        false,
      );
      expect(
        (await store.execute({
          'action': 'remove',
          'id': original['word']['id'],
        }))['ok'],
        true,
      );
      expect((await store.words()).single.language, 'fr-FR');
    },
  );
  test(
    'due review suggestions throttled for 24h and reviewing moves due date',
    () async {
      final word = (await add('broth'))['word'];
      expect(
        (await store.execute({
          'action': 'review_suggestions',
        }))['suggestReview'],
        false,
      );
      now = now.add(const Duration(days: 2));
      expect(
        (await store.execute({
          'action': 'review_suggestions',
        }))['suggestReview'],
        true,
      );
      expect(
        (await create(
          'one',
        ).execute({'action': 'review_suggestions'}))['suggestReview'],
        false,
      );
      await store.execute({'action': 'review', 'id': word['id']});
      await store.execute({'action': 'review', 'id': word['id']});
      final reviewed = (await store.words()).single;
      expect(reviewed.reviews, 1);
      expect(reviewed.dueAt, now.add(const Duration(days: 3)));
      expect(
        (await store.execute({'action': 'list', 'dueOnly': true}))['items'],
        isEmpty,
      );
    },
  );
  test(
    'account change blocks reads/writes and corrupt data is not overwritten',
    () async {
      await add('broth');
      active = false;
      await expectLater(store.words(), throwsStateError);
      await expectLater(add('skewer'), throwsStateError);
      active = true;
      expect((await store.words()).length, 1);
      final key = base64Url.encode(utf8.encode('one')).replaceAll('=', '');
      final file = File('${root.path}/$key.vocabulary-v1.json');
      await file.writeAsString('{broken');
      await expectLater(add('skewer'), throwsFormatException);
      expect(await file.readAsString(), '{broken');
    },
  );
  test(
    'stats and latest use all saved words, respect filters and do not disclose the notebook',
    () async {
      expect((await store.execute({'action': 'stats'}))['total'], 0);
      expect((await store.execute({'action': 'latest'}))['word'], isNull);
      for (var i = 0; i < 25; i++) {
        await add('word$i');
        now = now.add(const Duration(minutes: 1));
      }
      await store.execute({
        'action': 'add',
        'word': 'bonjour',
        'meaning': 'hello',
        'language': 'fr-FR',
      });
      final stats = await store.execute({'action': 'stats'});
      expect(stats['total'], 26);
      expect(stats['unreviewed'], 26);
      expect(stats['byLanguage'], {'en-NZ': 25, 'fr-FR': 1});
      expect(stats.containsKey('items'), isFalse);
      expect(stats.containsKey('word'), isFalse);
      expect(
        (await store.execute({
          'action': 'stats',
          'language': 'fr-FR',
        }))['matched'],
        1,
      );
      expect(
        (await store.execute({
          'action': 'latest',
          'language': 'en-NZ',
        }))['word']['word'],
        'word24',
      );
      expect(
        (await store.execute({'action': 'latest'}))['word']['word'],
        'bonjour',
      );
    },
  );

  test(
    'quiz samples the whole selected pool, skips exclusions and never marks review',
    () async {
      for (var i = 0; i < 30; i++) {
        await add('word$i');
        now = now.add(const Duration(minutes: 1));
      }
      final before = (await store.words()).map((w) => w.toJson()).toList();
      final selected = <String>{};
      for (var i = 0; i < 100; i++) {
        final result = await store.execute({
          'action': 'quiz',
          'selection': 'all',
        });
        expect(result['eligible'], 30);
        selected.add(result['word']['word'] as String);
      }
      expect(selected.any((w) => int.parse(w.substring(4)) < 10), isTrue);
      final recent = await store.execute({'action': 'quiz'});
      expect(recent['eligible'], 20);
      expect(
        int.parse((recent['word']['word'] as String).substring(4)),
        greaterThanOrEqualTo(10),
      );
      final excluded = (await store.words()).take(20).map((w) => w.id).toList();
      final empty = await store.execute({
        'action': 'quiz',
        'excludeIds': excluded,
      });
      expect(empty['word'], isNull);
      expect(empty['eligible'], 0);
      expect((await store.words()).map((w) => w.toJson()).toList(), before);
    },
  );

  test(
    'new and due quizzes filter correctly and empty pools stay empty',
    () async {
      expect((await store.execute({'action': 'quiz'}))['word'], isNull);
      final old = (await add('broth'))['word'];
      now = now.add(const Duration(days: 2));
      final fresh = (await add('skewer'))['word'];
      expect(
        (await store.execute({
          'action': 'quiz',
          'selection': 'due',
        }))['word']['id'],
        old['id'],
      );
      await store.execute({'action': 'review', 'id': old['id']});
      final quiz = await store.execute({'action': 'quiz', 'selection': 'new'});
      expect(quiz['word']['id'], fresh['id']);
      expect(quiz['word']['reviews'], 0);
      expect(
        (await store.execute({'action': 'quiz', 'query': 'missing'}))['word'],
        isNull,
      );
      expect(
        (await store.execute({'action': 'quiz', 'selection': 'due'}))['word'],
        isNull,
      );
      await expectLater(
        store.execute({'action': 'quiz', 'excludeIds': 'bad'}),
        throwsFormatException,
      );
      await expectLater(
        store.execute({'action': 'quiz', 'selection': 'unknown'}),
        throwsFormatException,
      );
    },
  );

  test('invalid input rejected without creating entries', () async {
    await expectLater(
      store.execute({'action': 'add', 'word': '', 'meaning': 'x'}),
      throwsFormatException,
    );
    await expectLater(
      store.execute({'action': 'add', 'word': 'a' * 101, 'meaning': 'x'}),
      throwsFormatException,
    );
    expect(await store.words(), isEmpty);
  });
}
