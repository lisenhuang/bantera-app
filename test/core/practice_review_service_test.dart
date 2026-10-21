import 'dart:async';

import 'package:app/core/practice_review_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  String? owner;
  late int requests;
  late PracticeReviewService service;

  PracticeReviewService create({
    bool enabled = true,
    Future<bool> Function()? available,
    Future<void> Function()? request,
  }) => PracticeReviewService(
    enabled: enabled,
    currentOwner: () => owner,
    dismissalDelay: Duration.zero,
    isAvailable: available ?? () async => true,
    requestReview:
        request ??
        () async {
          requests++;
        },
  );

  Future<void> dismissed({bool safe = true}) => service.requestAfterCelebration(
    dismissed: Future<void>.value(),
    isSafe: () => safe,
  );

  setUp(() {
    owner = 'learner-a';
    requests = 0;
    service = create();
  });

  test('no request occurs until the celebration is dismissed', () async {
    final close = Completer<void>();
    final pending = service.requestAfterCelebration(
      dismissed: close.future,
      isSafe: () => true,
    );
    await Future<void>.delayed(Duration.zero);
    expect(requests, 0);
    close.complete();
    await pending;
    expect(requests, 1);
  });

  test(
    'each new dismissal requests review, without lesson or local cooldown gates',
    () async {
      await dismissed();
      await dismissed();
      service = create();
      await dismissed();
      expect(requests, 3);
    },
  );

  test(
    'unsafe state skips review and does not trigger later on its own',
    () async {
      await dismissed(safe: false);
      await Future<void>.delayed(Duration.zero);
      expect(requests, 0);
      await dismissed();
      expect(requests, 1);
    },
  );

  test('account changes while the celebration is open cancel review', () async {
    final close = Completer<void>();
    final pending = service.requestAfterCelebration(
      dismissed: close.future,
      isSafe: () => true,
    );
    owner = 'learner-b';
    close.complete();
    await pending;
    expect(requests, 0);
  });

  test(
    'rechecks safety and account after native availability returns',
    () async {
      for (final changeAccount in [false, true]) {
        var safe = true;
        final checking = Completer<void>();
        final available = Completer<bool>();
        service = create(
          available: () {
            checking.complete();
            return available.future;
          },
        );
        final pending = service.requestAfterCelebration(
          dismissed: Future<void>.value(),
          isSafe: () => safe,
        );
        await checking.future;
        if (changeAccount) {
          owner = 'another';
        } else {
          safe = false;
        }
        available.complete(true);
        await pending;
        expect(requests, 0);
      }
    },
  );

  test('Android stays disabled and signed-out users are skipped', () async {
    service = create(
      enabled: false,
      available: () => throw StateError('Android'),
    );
    await dismissed();
    expect(requests, 0);
    service = create();
    owner = null;
    await dismissed();
    expect(requests, 0);
  });

  test('concurrent requests do not overlap', () async {
    final checking = Completer<void>();
    final available = Completer<bool>();
    service = create(
      available: () {
        checking.complete();
        return available.future;
      },
    );
    final first = dismissed();
    await checking.future;
    await dismissed();
    available.complete(true);
    await first;
    expect(requests, 1);
  });

  test(
    'unavailable and failing native reviews do not interrupt the app',
    () async {
      service = create(available: () async => false);
      await dismissed();
      expect(requests, 0);
      service = create(
        request: () async => throw StateError('StoreKit unavailable'),
      );
      await expectLater(dismissed(), completes);
      service = create();
      await dismissed();
      expect(requests, 1);
    },
  );
}
