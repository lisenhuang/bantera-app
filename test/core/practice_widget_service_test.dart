import 'dart:async';

import 'package:app/core/practice_widget_service.dart';
import 'package:app/domain/activity/word_activity.dart';
import 'package:app/l10n/app_localizations_en.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final l = AppLocalizationsEn();

  test(
    'details are scoped to the account and current learning language',
    () async {
      final writes = <Map<String, Object>>[];
      final service = PracticeWidgetService.forTesting(
        send: (data) async {
          writes.add(data);
        },
      );
      Future<void> publish(String owner, String language, {DateTime? now}) =>
          service.update(
            signedIn: true,
            owner: owner,
            learningLanguage: language,
            today: const WordTotals(spoken: 12),
            localizations: l,
            now: now,
          );
      await publish('alice', 'ja-JP');
      service.setProgress(owner: 'alice', language: 'ja-JP', level: 'B2');
      service.setLeaderboard(
        owner: 'alice',
        report: {
          'you': {'rank': 7},
          'throughDate': wordActivityDateKey(DateTime.now().toUtc()),
        },
      );
      await publish('alice', 'ja-JP');
      expect(writes.last['level'], 'B2');
      expect(writes.last['rank'], 7);
      expect(writes.last.containsKey('owner'), false);
      service.setProgress(owner: 'alice', language: 'ko-KR', level: 'A1');
      service.setLeaderboard(
        owner: 'bob',
        report: {
          'you': {'rank': 1},
        },
      );
      await publish('alice', 'ja-JP');
      expect(writes.last['level'], 'B2');
      expect(writes.last['rank'], 7);
      await publish('alice', 'ko-KR');
      expect(writes.last.containsKey('level'), false);
      expect(
        writes.last['rank'],
        7,
      ); // Ranking includes every learning language.
      await publish('bob', 'ko-KR');
      expect(writes.last.containsKey('rank'), false);
      expect(writes.last.containsKey('level'), false);
      service.setProgress(owner: 'alice', language: 'ko-KR', level: 'C1');
      service.setProgress(owner: 'bob', language: 'ko-KR', level: 'A2');
      await publish('bob', 'ko-KR');
      expect(writes.last['level'], 'A2');
      await service.update(
        signedIn: false,
        today: const WordTotals(),
        localizations: l,
      );
      for (final key in ['learningLanguage', 'level', 'rank', 'rankingDate']) {
        expect(writes.last.containsKey(key), false);
      }
    },
  );

  test(
    'rank expires at UTC rollover while the current level remains',
    () async {
      final writes = <Map<String, Object>>[];
      final service = PracticeWidgetService.forTesting(
        send: (data) async {
          writes.add(data);
        },
      );
      Future<void> publish(DateTime date) => service.update(
        signedIn: true,
        owner: 'alice',
        learningLanguage: 'ja-JP',
        today: const WordTotals(),
        now: date,
        localizations: l,
      );
      final today = DateTime.now().toUtc();
      await publish(today);
      service.setProgress(owner: 'alice', language: 'ja-JP', level: 'C2');
      service.setLeaderboard(
        owner: 'alice',
        report: {
          'you': {'rank': 3},
          'throughDate': wordActivityDateKey(today),
        },
      );
      await publish(today);
      expect(writes.last['rank'], 3);
      await publish(today.add(const Duration(days: 1)));
      expect(writes.last.containsKey('rank'), false);
      expect(writes.last['level'], 'C2');
      service.setLeaderboard(
        owner: 'alice',
        report: {
          'you': {'rank': null},
          'throughDate': wordActivityDateKey(today),
        },
      );
      await publish(today);
      expect(writes.last.containsKey('rank'), false);
    },
  );

  test('shares only aggregate counts and resets them on sign-out', () async {
    final writes = <Map<String, Object>>[];
    final service = PracticeWidgetService.forTesting(
      send: (value) async {
        writes.add(value);
      },
    );
    await service.update(
      signedIn: true,
      today: const WordTotals(spoken: 128, listened: 640),
      now: DateTime(2026, 10, 8, 23, 59),
      localizations: l,
    );
    expect(writes.single['dateKey'], '2026-10-08');
    expect(writes.single['spoken'], 128);
    expect(writes.single['listened'], 640);
    expect(
      writes.single.keys,
      unorderedEquals([
        'dateKey',
        'signedIn',
        'spoken',
        'listened',
        'locale',
        'labels',
      ]),
    );
    await service.update(
      signedIn: false,
      today: const WordTotals(spoken: 128, listened: 640),
      localizations: l,
    );
    expect(writes.last['signedIn'], false);
    expect(writes.last['spoken'], 0);
    expect(writes.last['listened'], 0);
  });

  test('sign-out wins when the previous account write is in flight', () async {
    final entered = Completer<void>();
    final release = Completer<void>();
    final writes = <Map<String, Object>>[];
    final service = PracticeWidgetService.forTesting(
      send: (value) async {
        if (writes.isEmpty) {
          entered.complete();
          await release.future;
        }
        writes.add(value);
      },
    );
    final first = service.update(
      signedIn: true,
      today: const WordTotals(spoken: 55),
      localizations: l,
    );
    await entered.future;
    final logout = service.update(
      signedIn: false,
      today: const WordTotals(),
      localizations: l,
    );
    release.complete();
    await Future.wait([first, logout]);
    expect(writes.last['signedIn'], false);
    expect(writes.last['spoken'], 0);
  });

  test('deduplicates snapshots but sends again after midnight', () async {
    final writes = <Map<String, Object>>[];
    final service = PracticeWidgetService.forTesting(
      send: (value) async {
        writes.add(value);
      },
    );
    for (final day in [8, 8, 9]) {
      await service.update(
        signedIn: true,
        today: const WordTotals(),
        now: DateTime(2026, 10, day),
        localizations: l,
      );
    }
    expect(writes.length, 2);
    expect(writes.last['dateKey'], '2026-10-09');
  });

  test('a failed native write can retry the same snapshot', () async {
    var calls = 0;
    final service = PracticeWidgetService.forTesting(
      send: (_) async {
        if (++calls == 1) throw PlatformException(code: 'unavailable');
      },
    );
    for (var i = 0; i < 2; i++) {
      await service.update(
        signedIn: true,
        today: const WordTotals(),
        now: DateTime(2026, 10, 8),
        localizations: l,
      );
    }
    expect(calls, 2);
  });

  test(
    'cold and warm widget taps are delivered once without starting a call',
    () async {
      var pending = true;
      final messenger =
          TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
      messenger.setMockMethodCallHandler(PracticeWidgetService.channel, (
        call,
      ) async {
        expect(call.method, 'takePendingOpen');
        final value = pending;
        pending = false;
        return value;
      });
      addTearDown(
        () => messenger.setMockMethodCallHandler(
          PracticeWidgetService.channel,
          null,
        ),
      );
      final service = PracticeWidgetService.forTesting(send: (_) async {});
      await service.initialize();
      expect(service.chatRequested.value, true);
      service.chatRequested.value = false;
      pending = true;
      await messenger.handlePlatformMessage(
        'bantera/practice_widget',
        const StandardMethodCodec().encodeMethodCall(
          const MethodCall('openChat'),
        ),
        (_) {},
      );
      expect(service.chatRequested.value, true);
      service.chatRequested.value = false;
      await messenger.handlePlatformMessage(
        'bantera/practice_widget',
        const StandardMethodCodec().encodeMethodCall(
          const MethodCall('openChat'),
        ),
        (_) {},
      );
      expect(service.chatRequested.value, false);
    },
  );
}
