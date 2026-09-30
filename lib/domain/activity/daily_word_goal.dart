class DailyWordGoal {
  const DailyWordGoal({
    required this.listened,
    required this.spoken,
    this.notificationsEnabled = true,
    this.notificationHour = 19,
    this.notificationMinute = 0,
    this.notificationWeekdays = everyDay,
    this.notificationOnceAt,
  });

  // Planning estimates, deliberately slower than conversational speech.
  static const listeningWordsPerMinute = 120;
  static const speakingWordsPerMinute = 60;
  static const maxWords = 100000;
  static const everyDay = [1, 2, 3, 4, 5, 6, 7];
  static const weekdays = [1, 2, 3, 4, 5];
  final int listened;
  final int spoken;
  final bool notificationsEnabled;
  final int notificationHour;
  final int notificationMinute;
  final List<int> notificationWeekdays;
  final DateTime? notificationOnceAt;

  bool get isValid =>
      listened >= 0 &&
      listened <= maxWords &&
      spoken >= 0 &&
      spoken <= maxWords &&
      notificationHour >= 0 &&
      notificationHour < 24 &&
      notificationMinute >= 0 &&
      notificationMinute < 60 &&
      notificationWeekdays.every((day) => day >= 1 && day <= 7) &&
      notificationWeekdays.toSet().length == notificationWeekdays.length;
  double get listeningMinutes => listened / listeningWordsPerMinute;
  double get speakingMinutes => spoken / speakingWordsPerMinute;
  double get totalMinutes => listeningMinutes + speakingMinutes;

  factory DailyWordGoal.forMinutes(int minutes) => DailyWordGoal(
    notificationWeekdays: weekdays,
    listened: minutes * listeningWordsPerMinute ~/ 2,
    spoken: minutes * speakingWordsPerMinute ~/ 2,
  );

  Map<String, dynamic> toJson() => {
    'listened': listened,
    'spoken': spoken,
    'notificationsEnabled': notificationsEnabled,
    'notificationHour': notificationHour,
    'notificationMinute': notificationMinute,
    'notificationWeekdays': notificationWeekdays,
    'notificationOnceAt': notificationOnceAt?.toIso8601String(),
  };

  static DailyWordGoal? fromJson(Object? json) {
    if (json is! Map) return null;
    final listened = json['listened'];
    final spoken = json['spoken'];
    if (listened is! int || spoken is! int) return null;
    final rawDays = json['notificationWeekdays'];
    if (rawDays != null &&
        (rawDays is! List || rawDays.any((day) => day is! int)))
      return null;
    final goal = DailyWordGoal(
      notificationOnceAt: DateTime.tryParse(
        json['notificationOnceAt']?.toString() ?? '',
      ),
      notificationWeekdays: rawDays is List
          ? List<int>.unmodifiable(rawDays.cast<int>())
          : everyDay,
      listened: listened,
      spoken: spoken,
      notificationHour: json['notificationHour'] is int
          ? json['notificationHour'] as int
          : 19,
      notificationMinute: json['notificationMinute'] is int
          ? json['notificationMinute'] as int
          : 0,
      notificationsEnabled: json['notificationsEnabled'] is bool
          ? json['notificationsEnabled'] as bool
          : true,
    );
    return goal.isValid ? goal : null;
  }
}
