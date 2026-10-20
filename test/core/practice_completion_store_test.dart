import 'dart:io';
import 'package:app/core/practice_completion_store.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late Directory directory;
  late DateTime now;
  PracticeCompletionStore create() => PracticeCompletionStore(
    file: () async => File('${directory.path}/counts.json'),
    now: () => now,
  );
  setUp(() {
    directory = Directory.systemTemp.createTempSync('practice-counts');
    now = DateTime(2026, 10, 20, 23, 59);
  });
  tearDown(() => directory.deleteSync(recursive: true));

  test(
    'today count survives restart and repeated correct answers count once',
    () async {
      var store = create();
      expect(await store.today(owner: 'a', language: 'en-NZ'), 0);
      expect(
        await store.today(
          owner: 'a',
          language: 'en-NZ',
          completedExercise: 'one',
        ),
        1,
      );
      store = create();
      expect(await store.today(owner: 'a', language: 'en-NZ'), 1);
      expect(
        await store.today(
          owner: 'a',
          language: 'en-NZ',
          completedExercise: 'one',
        ),
        1,
      );
      expect(
        await store.today(
          owner: 'a',
          language: 'en-NZ',
          completedExercise: 'two',
        ),
        2,
      );
      expect(
        await store.today(
          owner: 'a',
          language: 'en-NZ',
          completedExercise: 'one',
        ),
        2,
      );
    },
  );
  test(
    'accounts and languages are isolated while accents share the count',
    () async {
      final store = create();
      await store.today(
        owner: 'a',
        language: 'en-NZ',
        completedExercise: 'one',
      );
      expect(await store.today(owner: 'a', language: 'en-US'), 1);
      expect(await store.today(owner: 'b', language: 'en-NZ'), 0);
      expect(await store.today(owner: 'a', language: 'es-ES'), 0);
      await store.today(
        owner: 'a',
        language: 'zh-HK',
        completedExercise: 'two',
      );
      expect(await store.today(owner: 'a', language: 'yue-HK'), 1);
      expect(await store.today(owner: 'a', language: 'zh-CN'), 0);
    },
  );
  test(
    'local midnight resets count without recounting the still-open exercise',
    () async {
      final store = create();
      await store.today(owner: 'a', language: 'en', completedExercise: 'one');
      now = now.add(const Duration(minutes: 2));
      expect(await store.today(owner: 'a', language: 'en'), 0);
      expect(
        await store.today(owner: 'a', language: 'en', completedExercise: 'one'),
        0,
      );
      expect(
        await store.today(owner: 'a', language: 'en', completedExercise: 'two'),
        1,
      );
      expect(await create().today(owner: 'a', language: 'en'), 1);
    },
  );
  test('concurrent requests serialize without lost completions', () async {
    final store = create();
    await Future.wait(
      List.generate(
        10,
        (i) => store.today(owner: 'a', language: 'en', completedExercise: '$i'),
      ),
    );
    expect(await create().today(owner: 'a', language: 'en'), 10);
  });
}
