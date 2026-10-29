import 'package:app/presentation/leaderboard/speaking_leaderboard.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:app/l10n/app_localizations_en.dart';

Map<String, dynamic> page({
  int days = 14,
  int offset = 0,
  bool more = false,
  String until = '2026-10-29T12:00:00Z',
  String prefix = 'current',
}) => {
  'periodDays': days,
  'fromDate': '2026-10-15',
  'throughDate': '2026-10-29',
  'fromUtc': DateTime.parse(
    until,
  ).subtract(Duration(days: days)).toIso8601String(),
  'throughUtc': until,
  'offset': offset,
  'hasMore': more,
  'rows': [
    for (var i = offset; i < offset + 2; i++) {'key': '$prefix-$i'},
  ],
  'you': {'rank': 3},
};

void main() {
  test(
    'English configured periods include the actual number and singular form',
    () {
      final l = AppLocalizationsEn();
      expect(l.leaderboardPeriodScope(1), 'Last 1 day');
      expect(l.leaderboardPeriodScope(14), 'Last 14 days');
    },
  );
  test('cached reports keep their actual period with safe legacy default', () {
    expect(SpeakingReport(page()).periodDays, 14);
    for (final value in [null, 0, 366, '14']) {
      expect(SpeakingReport({...page(), 'periodDays': value}).periodDays, 30);
    }
    final first = SpeakingReport(page());
    expect(first.fingerprint, isNot(SpeakingReport(page(days: 7)).fingerprint));
    expect(
      first.fingerprint,
      isNot(SpeakingReport(page(until: '2026-10-29T12:01:00Z')).fingerprint),
    );
  });
  test(
    'pagination holds exact cutoff and resets when period changes',
    () async {
      final calls = <({int offset, String? until})>[];
      final result = await loadSpeakingLeaderboardPages(
        appendTo: SpeakingReport(page(more: true, prefix: 'old')),
        loadPage: ({int offset = 0, String? until}) async {
          calls.add((offset: offset, until: until));
          return page(days: 7, offset: offset);
        },
      );
      expect(calls, [
        (offset: 2, until: '2026-10-29T12:00:00Z'),
        (offset: 0, until: null),
      ]);
      expect(result.periodDays, 7);
      expect(result.rows.map((r) => r['key']), ['current-0', 'current-1']);
      expect(result.nextOffset, 2);
    },
  );
  test(
    'same-day changed boundaries also reset instead of mixing rows',
    () async {
      final offsets = <int>[];
      final result = await loadSpeakingLeaderboardPages(
        appendTo: SpeakingReport(page(more: true, prefix: 'old')),
        loadPage: ({int offset = 0, String? until}) async {
          offsets.add(offset);
          return page(offset: offset, until: '2026-10-29T12:01:00Z');
        },
      );
      expect(offsets, [2, 0]);
      expect(result.rows.map((r) => r['key']), ['current-0', 'current-1']);
    },
  );
  test(
    'refresh discards partial expanded results when setting changes mid-fetch',
    () async {
      final offsets = <int>[];
      final result = await loadSpeakingLeaderboardPages(
        retainRows: 6,
        loadPage: ({int offset = 0, String? until}) async {
          offsets.add(offset);
          return offsets.length == 1
              ? page(more: true, prefix: 'old')
              : page(days: 21, offset: offset);
        },
      );
      expect(offsets, [0, 2, 0]);
      expect(result.periodDays, 21);
      expect(result.rows.map((r) => r['key']), ['current-0', 'current-1']);
    },
  );
  test(
    'same-window pages append without duplicates and advance by consumed offset',
    () async {
      final result = await loadSpeakingLeaderboardPages(
        appendTo: SpeakingReport(page(more: true)),
        loadPage: ({int offset = 0, String? until}) async => {
          ...page(offset: offset),
          'rows': [
            {'key': 'current-1'},
            {'key': 'current-2'},
          ],
        },
      );
      expect(result.rows.map((r) => r['key']), [
        'current-0',
        'current-1',
        'current-2',
      ]);
      expect(result.nextOffset, 4);
    },
  );
}
