import 'daily_word_goal.dart';

class WordTotals {
  const WordTotals({this.listened = 0, this.spoken = 0});
  final int listened;
  final int spoken;

  WordTotals operator +(WordTotals other) => WordTotals(
    listened: listened + other.listened,
    spoken: spoken + other.spoken,
  );

  Map<String, dynamic> toJson() => {
    'listenedWords': listened,
    'spokenWords': spoken,
  };

  factory WordTotals.fromJson(Map<String, dynamic> json) => WordTotals(
    listened: (json['listenedWords'] as num?)?.toInt() ?? 0,
    spoken: (json['spokenWords'] as num?)?.toInt() ?? 0,
  );
}

String wordActivityDateKey(DateTime date) =>
    '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

/// Accents share a language bucket. Mandarin variants share zh; Cantonese
/// stays distinct. An empty bucket preserves historical unlabelled activity.
String wordActivityLanguageKey(String? language) {
  final code = (language ?? '').trim().replaceAll('_', '-').toLowerCase();
  if (code == 'zh-hk' ||
      code == 'zh-hant-hk' ||
      code == 'yue' ||
      code.startsWith('yue-')) {
    return 'yue';
  }
  final primary = code.split('-').first;
  return switch (primary) {
    'iw' => 'he',
    'in' => 'id',
    'ji' => 'yi',
    _ => primary,
  };
}

String wordActivityBucketKey(String date, String? language) {
  final key = wordActivityLanguageKey(language);
  return key.isEmpty ? date : '$date|$key';
}

String wordActivityBucketDate(String key) => key.split('|').first;
String wordActivityBucketLanguage(String key) =>
    key.contains('|') ? key.split('|').last : '';

/// Remote daily totals plus the portion of this device's cumulative counts
/// that the server has not yet acknowledged. Repeated syncs do not add twice.
class WordActivityLedger {
  WordActivityLedger({required this.deviceId});
  final String deviceId;
  DailyWordGoal? dailyGoal;
  Map<String, WordTotals> local = {};
  Map<String, WordTotals> acknowledged = {};
  Map<String, WordTotals> remote = {};

  void record(DateTime date, WordTotals words, {String? language}) {
    final day = wordActivityBucketKey(wordActivityDateKey(date), language);
    local[day] = (local[day] ?? const WordTotals()) + words;
  }

  Map<String, WordTotals> get pendingSnapshots => {
    for (final entry in local.entries)
      if (entry.value.listened != (acknowledged[entry.key]?.listened ?? 0) ||
          entry.value.spoken != (acknowledged[entry.key]?.spoken ?? 0))
        entry.key: entry.value,
  };

  Map<String, WordTotals> get combinedDays {
    final days = Map<String, WordTotals>.of(remote);
    for (final entry in local.entries) {
      final ack = acknowledged[entry.key] ?? const WordTotals();
      days[entry.key] =
          (days[entry.key] ?? const WordTotals()) +
          WordTotals(
            listened: (entry.value.listened - ack.listened).clamp(0, 10000000),
            spoken: (entry.value.spoken - ack.spoken).clamp(0, 10000000),
          );
    }
    return days;
  }

  ({WordTotals today, WordTotals week, WordTotals total}) summary(
    DateTime now, {
    String? language,
  }) {
    final todayKey = wordActivityDateKey(now);
    // Calendar arithmetic remains correct across daylight saving changes.
    final monday = DateTime(now.year, now.month, now.day - now.weekday + 1);
    final mondayKey = wordActivityDateKey(monday);
    var today = const WordTotals();
    var week = const WordTotals();
    var total = const WordTotals();
    for (final entry in combinedDays.entries) {
      if (language != null &&
          wordActivityBucketLanguage(entry.key) !=
              wordActivityLanguageKey(language)) {
        continue;
      }
      final date = wordActivityBucketDate(entry.key);
      total = total + entry.value;
      if (date == todayKey) today = today + entry.value;
      if (date.compareTo(mondayKey) >= 0 && date.compareTo(todayKey) <= 0) {
        week = week + entry.value;
      }
    }
    return (today: today, week: week, total: total);
  }

  void accept(
    Map<String, WordTotals> snapshots,
    Map<String, WordTotals> serverDays,
  ) {
    acknowledged.addAll(snapshots);
    remote = serverDays;
  }

  Map<String, dynamic> toJson() => {
    'deviceId': deviceId,
    'dailyGoal': dailyGoal?.toJson(),
    'local': local.map((key, value) => MapEntry(key, value.toJson())),
    'acknowledged': acknowledged.map(
      (key, value) => MapEntry(key, value.toJson()),
    ),
    'remote': remote.map((key, value) => MapEntry(key, value.toJson())),
  };

  factory WordActivityLedger.fromJson(Map<String, dynamic> json) {
    Map<String, WordTotals> read(String key) => (json[key] as Map? ?? {}).map(
      (key, value) => MapEntry(
        key.toString(),
        WordTotals.fromJson(Map<String, dynamic>.from(value as Map)),
      ),
    );
    return WordActivityLedger(deviceId: json['deviceId'] as String)
      ..dailyGoal = DailyWordGoal.fromJson(json['dailyGoal'])
      ..local = read('local')
      ..acknowledged = read('acknowledged')
      ..remote = read('remote');
  }
}
