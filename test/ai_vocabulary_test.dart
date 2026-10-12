import 'dart:io';
import 'dart:convert';
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
