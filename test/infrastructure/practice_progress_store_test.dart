import 'dart:convert';
import 'dart:io';

import 'package:app/domain/models/models.dart';
import 'package:app/infrastructure/practice_progress_store.dart';
import 'package:flutter_test/flutter_test.dart';

MediaItem historyMedia(String id, {bool temporary = false}) => MediaItem(
  id: id,
  title: 'Ordering coffee',
  description: '',
  creator: User(
    id: 'creator',
    displayName: 'Bantera',
    avatarUrl: '',
    firstLanguage: '',
    learningLanguage: '',
    level: '',
  ),
  coverUrl: '',
  videoUrl: 'https://example.test/$id.mp3',
  spokenLanguage: 'en',
  accent: '',
  durationMs: 4000,
  transcriptionSource: 'AI Generated',
  isAudioOnly: true,
  deleteLocalMediaOnDispose: temporary,
  cues: List.generate(
    2,
    (i) => Cue(
      id: '$i',
      startTimeMs: i * 2000,
      endTimeMs: (i + 1) * 2000,
      originalText: 'Coffee please',
      translatedText: '',
    ),
  ),
);

void main() {
  late Directory dir;
  late File file;
  late String owner;
  late DateTime now;
  late PracticeProgressStore store;
  PracticeProgressStore create() => PracticeProgressStore(
    file: () async => file,
    owner: () => owner,
    now: () => now,
  );
  Future<void> record(
    String id, {
    Set<String> completed = const {},
    int index = 0,
  }) => store.record(
    mediaItem: historyMedia(id),
    cueIndex: index,
    cueStartMs: index * 2000,
    cueMode: 'long',
    owner: owner,
    completedCueKeys: completed,
  );
  setUp(() {
    dir = Directory.systemTemp.createTempSync('practice-history-');
    file = File('${dir.path}/progress.json');
    owner = 'learner-a';
    now = DateTime.utc(2026, 10, 6);
    store = create();
  });
  tearDown(() async {
    store.dispose();
    await dir.delete(recursive: true);
  });

  test(
    'legacy positions survive migration without fabricated history',
    () async {
      await file.writeAsString(jsonEncode({'old-media': 4}));
      await store.load();
      expect(await store.getCueIndex('old-media'), 4);
      expect(store.entries, isEmpty);
      owner = 'learner-b';
      expect(await create().getCueIndex('old-media'), 0);
    },
  );

  test(
    'completed cues accumulate once across sessions and mode changes',
    () async {
      await record('lesson', completed: {'0:0:2000'});
      store.dispose();
      store = create();
      await store.record(
        mediaItem: historyMedia('lesson'),
        cueIndex: 3,
        cueStartMs: 2000,
        cueMode: 'short',
        owner: owner,
        completedCueKeys: {'0:0:2000', '1:2000:4000', 'obsolete'},
      );
      final entry = store.entries.single;
      expect(entry.completedCues, 2);
      expect(entry.progress, 1);
      expect(entry.cueMode, 'short');
      expect(entry.cueStartMs, 2000);
      expect(await store.getCueIndex('lesson'), 3);
    },
  );

  test(
    'resume follows time when sentence mode or transcript boundaries change',
    () async {
      await record('lesson', index: 1);
      final entry = store.entries.single;
      final shortCues = List.generate(
        4,
        (i) => Cue(
          id: 's$i',
          startTimeMs: i * 1000,
          endTimeMs: (i + 1) * 1000,
          originalText: '',
          translatedText: '',
        ),
      );
      expect(entry.resolveCueIndex(shortCues, 'short'), 2);
      expect(entry.resolveCueIndex(shortCues, 'long'), 2);
      expect(entry.resolveCueIndex([], 'long'), 0);
    },
  );

  test(
    'snapshot omits request credentials but resume can supply fresh headers',
    () async {
      final item = MediaItem.fromJson(
        historyMedia('lesson').toJson(),
        mediaHeaders: {'Authorization': 'Bearer test-secret'},
      );
      await store.record(
        mediaItem: item,
        cueIndex: 0,
        cueStartMs: 0,
        cueMode: 'long',
        owner: owner,
      );
      expect(await file.readAsString(), isNot(contains('test-secret')));
      expect(MediaItem.fromJson(item.toJson()).mediaHeaders, isEmpty);
      final resumed = MediaItem.fromJson(
        item.toJson(),
        mediaHeaders: {'Authorization': 'Bearer fresh-token'},
      );
      expect(resumed.mediaHeaders['Authorization'], 'Bearer fresh-token');
    },
  );

  test('jumping to the last cue does not count as listening', () async {
    await record('lesson', index: 1);
    expect(store.entries.single.completedCues, 0);
    expect(store.entries.single.progress, 0);
  });

  test('history is recent first and isolated between accounts', () async {
    await record('first');
    now = now.add(const Duration(minutes: 1));
    await record('second');
    now = now.add(const Duration(minutes: 1));
    await record('first');
    expect(store.entries.map((e) => e.mediaItem.id), ['first', 'second']);
    owner = 'learner-b';
    expect(store.entries, isEmpty);
    await record('other');
    await store.clearAll();
    owner = 'learner-a';
    expect(store.entries.length, 2);
  });

  test(
    'queued updates followed by removal stay removed after restart',
    () async {
      await Future.wait([
        record('lesson'),
        record('lesson', index: 1),
        store.remove('lesson'),
      ]);
      final reopened = create();
      await reopened.load();
      expect(reopened.entries, isEmpty);
      expect(await reopened.getCueIndex('lesson'), 0);
      await record('lesson');
      expect(store.entries.single.completedCues, 0);
    },
  );

  test(
    'temporary media is not offered for resume after its file is deleted',
    () async {
      await store.record(
        mediaItem: historyMedia('temp', temporary: true),
        cueIndex: 0,
        cueStartMs: 0,
        cueMode: 'long',
        owner: owner,
      );
      expect(store.entries, isEmpty);
      expect(await file.exists(), isFalse);
    },
  );

  test(
    'failed removal restores the visible record and resume position',
    () async {
      await record('lesson', index: 1);
      final original = await file.readAsString();
      await file.delete();
      await Directory(file.path).create();
      await expectLater(
        store.remove('lesson'),
        throwsA(isA<FileSystemException>()),
      );
      expect(store.entries.single.mediaItem.id, 'lesson');
      expect(await store.getCueIndex('lesson'), 1);
      await Directory(file.path).delete();
      await file.writeAsString(original);
      await store.remove('lesson');
      expect(store.entries, isEmpty);
    },
  );

  test('bad JSON reports a load error without overwriting the file', () async {
    await file.writeAsString('{broken');
    await expectLater(store.load(), throwsFormatException);
    expect(await file.readAsString(), '{broken');
  });
}
