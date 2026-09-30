import 'package:app/domain/activity/word_activity.dart';
import 'package:app/domain/activity/listening_word_tracker.dart';
import 'package:app/domain/activity/voice_word_progress.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('languages stay separate, accents merge and switching is immediate', () {
    final day = DateTime(2026, 9, 30);
    final ledger = WordActivityLedger(deviceId: 'device');
    ledger.record(
      day,
      const WordTotals(listened: 40, spoken: 10),
      language: 'en-NZ',
    );
    ledger.record(
      day,
      const WordTotals(listened: 20, spoken: 5),
      language: 'en_US',
    );
    ledger.record(
      day,
      const WordTotals(listened: 12, spoken: 7),
      language: 'ja-JP',
    );
    expect(ledger.summary(day, language: 'en-GB').today.listened, 60);
    expect(ledger.summary(day, language: 'en').today.spoken, 15);
    expect(ledger.summary(day, language: 'ja').today.spoken, 7);
    expect(ledger.summary(day, language: 'fr-FR').total.listened, 0);
    expect(ledger.summary(day, language: 'en-NZ').total.spoken, 15);
    expect(ledger.pendingSnapshots.keys, ['2026-09-30|en', '2026-09-30|ja']);
    expect(wordActivityLanguageKey('zh-TW'), wordActivityLanguageKey('zh-CN'));
    expect(wordActivityLanguageKey('zh-Hant-HK'), 'yue');
    expect(wordActivityLanguageKey('yue-CN'), 'yue');
    expect(wordActivityLanguageKey('iw-IL'), 'he');
  });

  test(
    'legacy data remains unlabelled across migration, offline work and sync',
    () {
      final day = DateTime(2026, 9, 30);
      final ledger = WordActivityLedger.fromJson({
        'deviceId': 'old-device',
        'local': {
          '2026-09-30': {'listenedWords': 50, 'spokenWords': 10},
        },
        'acknowledged': {
          '2026-09-30': {'listenedWords': 40, 'spokenWords': 8},
        },
        'remote': {
          '2026-09-30': {'listenedWords': 60, 'spokenWords': 12},
        },
      });
      ledger.record(day, const WordTotals(spoken: 20), language: 'en-NZ');
      expect(ledger.summary(day, language: '').total.listened, 70);
      expect(ledger.summary(day, language: 'en').total.listened, 0);
      expect(ledger.summary(day, language: 'en-US').total.spoken, 20);
      final snapshot = ledger.pendingSnapshots;
      ledger.record(day, const WordTotals(spoken: 3), language: 'ja-JP');
      ledger.accept(snapshot, {
        '2026-09-30': const WordTotals(listened: 70, spoken: 14),
        '2026-09-30|en': const WordTotals(spoken: 20),
      });
      final restored = WordActivityLedger.fromJson(ledger.toJson());
      expect(restored.summary(day, language: '').total.spoken, 14);
      expect(restored.summary(day, language: 'en').total.spoken, 20);
      expect(restored.summary(day, language: 'ja').total.spoken, 3);
      expect(restored.pendingSnapshots.keys, ['2026-09-30|ja']);
    },
  );

  test(
    'calendar periods use local dates, Monday and exclude future days from week',
    () {
      final ledger = WordActivityLedger(deviceId: 'device');
      ledger.record(
        DateTime(2026, 9, 27, 23, 59),
        const WordTotals(listened: 10),
      );
      ledger.record(DateTime(2026, 9, 28), const WordTotals(listened: 20));
      ledger.record(DateTime(2026, 9, 30, 0, 1), const WordTotals(spoken: 5));
      final stats = ledger.summary(DateTime(2026, 9, 30));
      expect(stats.today.listened, 0);
      expect(stats.today.spoken, 5);
      expect(stats.week.listened, 20);
      expect(stats.total.listened, 30);
      expect(ledger.summary(DateTime(2026, 9, 27)).week.listened, 10);
      expect(ledger.summary(DateTime(2026, 10, 1)).today.spoken, 0);
    },
  );

  test(
    'offline delta, sync retries and recording during sync do not double count',
    () {
      final day = DateTime(2026, 9, 30);
      final ledger = WordActivityLedger(deviceId: 'device');
      ledger.record(day, const WordTotals(listened: 50, spoken: 10));
      final snapshot = ledger.pendingSnapshots;
      // More words arrive while network requests are in flight.
      ledger.record(day, const WordTotals(listened: 20, spoken: 5));
      ledger.accept(snapshot, {
        '2026-09-30': const WordTotals(listened: 80, spoken: 20),
      });
      expect(ledger.summary(day).total.listened, 100); // 80 remote + 20 pending
      expect(ledger.summary(day).total.spoken, 25);
      ledger.accept(snapshot, {
        '2026-09-30': const WordTotals(listened: 80, spoken: 20),
      });
      expect(ledger.summary(day).total.listened, 100);
      ledger.accept(ledger.pendingSnapshots, {
        '2026-09-30': const WordTotals(listened: 100, spoken: 25),
      });
      expect(ledger.pendingSnapshots, isEmpty);
      expect(ledger.summary(day).total.listened, 100);
      final restored = WordActivityLedger.fromJson(ledger.toJson());
      expect(restored.deviceId, 'device');
      expect(restored.pendingSnapshots, isEmpty);
      expect(restored.summary(day).total.spoken, 25);
    },
  );

  test('word estimates ignore punctuation and preserve contractions', () {
    expect(activityWordCount("I can't wait, café 42!"), 5);
    expect(activityWordCount('... 🗣️'), 0);
    expect(activityWordCount('你好世界'), 4);
  });

  test(
    'listening counts crossed words once, pauses, seeks, speed and repeats',
    () {
      final at = DateTime(2026, 9, 30);
      final tracker = ListeningWordTracker([
        const ListeningWordUnit(250, 1),
        const ListeningWordUnit(500, 1),
        const ListeningWordUnit(1000, 1),
        const ListeningWordUnit(5000, 1),
      ]);
      tracker.seek(0, at: at);
      expect(
        tracker.advance(
          500,
          playing: true,
          at: at.add(const Duration(milliseconds: 500)),
        ),
        2,
      );
      expect(
        tracker.advance(
          500,
          playing: true,
          at: at.add(const Duration(milliseconds: 600)),
        ),
        0,
      );
      expect(
        tracker.advance(
          1000,
          playing: false,
          at: at.add(const Duration(seconds: 1)),
        ),
        0,
      );
      tracker.seek(5000, at: at.add(const Duration(seconds: 2)));
      expect(
        tracker.advance(
          5100,
          playing: true,
          at: at.add(const Duration(milliseconds: 2100)),
        ),
        0,
      );
      tracker.seek(0, at: at.add(const Duration(seconds: 3)));
      expect(
        tracker.advance(
          1000,
          playing: true,
          speed: 2,
          at: at.add(const Duration(milliseconds: 3500)),
        ),
        3,
      );
      expect(
        tracker.advance(
          5000,
          playing: true,
          at: at.add(const Duration(milliseconds: 3550)),
        ),
        0,
      );
    },
  );

  test(
    'voice progress survives delayed recognition and stops at heard portion',
    () {
      var listened = 0;
      final progress = VoiceWordProgress(
        durationMs: 1000,
        onWords: (words, _) => listened += words,
      );
      progress.advance(500, playing: true);
      progress.advance(800, playing: false);
      progress.setWordCount(10);
      expect(listened, 5);
      progress.setWordCount(
        20,
      ); // re-transcription must not recount this playback
      progress.advance(800, playing: true);
      expect(listened, 8);
      progress.advance(800, playing: true);
      expect(listened, 8);
      progress.advance(1000, playing: true);
      expect(listened, 10);
      progress.advance(2000, playing: true);
      expect(listened, 10);
    },
  );
}
