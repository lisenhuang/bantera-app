import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:app/core/practice_review_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late Directory directory;
  late File file;
  late DateTime now;
  String? owner;
  late int requests;
  late PracticeReviewService service;

  PracticeReviewService create({
    bool enabled = true,
    Future<bool> Function()? available,
  }) => PracticeReviewService(
    enabled: enabled,
    currentOwner: () => owner,
    file: () async => file,
    now: () => now,
    isAvailable: available ?? () async => true,
    requestReview: () async {
      requests++;
    },
  );

  Future<void> complete(String lesson, {Set<String> cues = const {'a', 'b'}}) =>
      service.recordCompletedCues(
        owner: owner,
        lessonId: lesson,
        completedCueKeys: cues,
        requiredCueKeys: {'a', 'b'},
      );

  Future<void> eligible() async {
    await complete('one');
    await complete('two');
    now = now.add(const Duration(days: 1));
    await complete('three');
  }

  setUp(() {
    directory = Directory.systemTemp.createTempSync('bantera-review-test-');
    file = File('${directory.path}/review.json');
    now = DateTime(2026, 10, 1, 23, 59);
    owner = 'learner-a';
    requests = 0;
    service = create();
  });
  tearDown(() => directory.deleteSync(recursive: true));

  test(
    'Three distinct lessons across local calendar days request once',
    () async {
      await complete('one');
      await complete('one');
      await complete('two');
      await service.requestIfEligible(isSafe: () => true);
      expect(requests, 0);
      now = now.add(const Duration(minutes: 2));
      await complete('three');
      expect(requests, 0); // Finishing audio alone never opens a prompt.
      await service.requestIfEligible(isSafe: () => true);
      await service.requestIfEligible(isSafe: () => true);
      expect(requests, 1);
    },
  );

  test(
    'Three lessons in one day do not qualify, a later lesson does',
    () async {
      for (final id in ['one', 'two', 'three']) {
        await complete(id);
      }
      await service.requestIfEligible(isSafe: () => true);
      expect(requests, 0);
      now = now.add(const Duration(days: 1));
      await complete('four');
      await service.requestIfEligible(isSafe: () => true);
      expect(requests, 1);
    },
  );

  test(
    'Partial cues persist across restarts but do not count until completed',
    () async {
      await complete('one');
      await complete('two');
      await complete('three', cues: {'b'});
      service = create();
      now = now.add(const Duration(days: 1));
      await service.requestIfEligible(isSafe: () => true);
      expect(requests, 0);
      await complete('three', cues: {'a'});
      await service.requestIfEligible(isSafe: () => true);
      expect(requests, 1);
    },
  );

  test(
    'Cooldown survives restarts and requires another completed lesson',
    () async {
      await eligible();
      await service.requestIfEligible(isSafe: () => true);
      service = create();
      now = now.add(const Duration(days: 89));
      await complete('four');
      await service.requestIfEligible(isSafe: () => true);
      expect(requests, 1);
      service = create();
      now = now.add(const Duration(days: 1));
      await complete(
        'three',
        cues: {'a'},
      ); // Replaying one old cue is insufficient.
      await service.requestIfEligible(isSafe: () => true);
      expect(requests, 1);
      await complete('five');
      await service.requestIfEligible(isSafe: () => true);
      expect(requests, 2);
    },
  );

  test(
    'Account histories and pending prompts do not leak between users',
    () async {
      await eligible();
      owner = 'learner-b';
      await service.requestIfEligible(isSafe: () => true);
      await complete('b-one');
      await service.requestIfEligible(isSafe: () => true);
      expect(requests, 0);
    },
  );

  test(
    'Busy route, recording, call or background state can defer the prompt',
    () async {
      await eligible();
      await service.requestIfEligible(isSafe: () => false);
      expect(requests, 0);
      await service.requestIfEligible(isSafe: () => true);
      expect(requests, 1);
    },
  );

  test(
    'Rechecks safety and account after native availability returns',
    () async {
      final available = Completer<bool>();
      final checking = Completer<void>();
      service = create(
        available: () {
          checking.complete();
          return available.future;
        },
      );
      await eligible();
      var safe = true;
      final requesting = service.requestIfEligible(isSafe: () => safe);
      await checking.future;
      safe = false;
      owner = 'learner-b';
      available.complete(true);
      await requesting;
      expect(requests, 0);
      expect(
        (jsonDecode(await file.readAsString()) as Map)['lastRequestAt'],
        isNull,
      );
    },
  );

  test('Android does not record activity or call the review plugin', () async {
    service = create(
      enabled: false,
      available: () => throw StateError('Android'),
    );
    await eligible();
    await service.requestIfEligible(isSafe: () => true);
    expect(requests, 0);
    expect(file.existsSync(), isFalse);
  });

  test(
    'Leaving the safe screen during persistence does not consume cooldown',
    () async {
      await eligible();
      var checks = 0;
      await service.requestIfEligible(isSafe: () => ++checks < 3);
      expect(requests, 0);
      await service.requestIfEligible(isSafe: () => true);
      expect(requests, 1);
    },
  );

  test(
    'Unavailable native review and duplicate requests do not cause prompts',
    () async {
      service = create(available: () async => false);
      await eligible();
      await Future.wait([
        service.requestIfEligible(isSafe: () => true),
        service.requestIfEligible(isSafe: () => true),
      ]);
      expect(requests, 0);
    },
  );
}
