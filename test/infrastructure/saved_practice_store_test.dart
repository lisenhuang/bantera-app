import 'dart:io';
import 'package:app/infrastructure/saved_practice_store.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late Directory directory;
  late File file;
  late SavedPracticeStore store;
  Map<String, dynamic> exercise(String id, [String locale = 'en-US']) => {
    'id': id,
    'locale': locale,
    'level': 'A0',
    'cue': 'Hello',
    'cueAudioUrl': 'https://example.com/hello.wav',
    'choices': [
      {'text': 'Hi', 'audioUrl': 'https://example.com/hi.wav'},
    ],
  };
  setUp(() async {
    directory = await Directory.systemTemp.createTemp('saved-practice-test-');
    file = File('${directory.path}/saved.json');
    store = SavedPracticeStore(file: () async => file);
  });
  tearDown(() async => directory.delete(recursive: true));

  test(
    'saved snapshots survive restart, deduplicate and keep languages',
    () async {
      final first = exercise('one');
      await store.setSaved(owner: 'alice', exercise: first, saved: true);
      first['cue'] = 'changed after saving';
      await store.setSaved(
        owner: 'alice',
        exercise: exercise('two', 'ja-JP'),
        saved: true,
      );
      await store.setSaved(
        owner: 'alice',
        exercise: exercise('two', 'ja-JP'),
        saved: true,
      );
      final restarted = SavedPracticeStore(file: () async => file);
      final saved = await restarted.load('alice');
      expect(saved.map((e) => e['id']), ['two', 'one']);
      expect(saved.map((e) => e['locale']), ['ja-JP', 'en-US']);
      expect(saved.last['cue'], 'Hello');
      expect(saved.last['choices'], exercise('one')['choices']);
    },
  );

  test(
    'concurrent saves and removals preserve other accounts and exercises',
    () async {
      await Future.wait([
        store.setSaved(owner: 'alice', exercise: exercise('one'), saved: true),
        store.setSaved(owner: 'bob', exercise: exercise('one'), saved: true),
        store.setSaved(owner: 'alice', exercise: exercise('two'), saved: true),
        store.setSaved(owner: 'alice', exercise: exercise('one'), saved: false),
      ]);
      expect((await store.load('alice')).map((e) => e['id']), ['two']);
      expect((await store.load('bob')).map((e) => e['id']), ['one']);
      expect(await store.load('stranger'), isEmpty);
      expect(await store.load(''), isEmpty);
    },
  );

  test(
    'failed writes do not poison the queue or overwrite unreadable saves',
    () async {
      await file.writeAsString('broken JSON');
      await expectLater(
        store.setSaved(owner: 'alice', exercise: exercise('one'), saved: true),
        throwsFormatException,
      );
      expect(await file.readAsString(), 'broken JSON');
      await file.writeAsString('{}');
      await store.setSaved(
        owner: 'alice',
        exercise: exercise('one'),
        saved: true,
      );
      expect((await store.load('alice')).length, 1);
      await expectLater(
        store.setSaved(owner: '', exercise: exercise('two'), saved: true),
        throwsArgumentError,
      );
      expect((await store.load('alice')).length, 1);
    },
  );
}
