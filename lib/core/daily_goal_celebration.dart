import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import '../domain/activity/daily_word_goal.dart';
import '../domain/activity/word_activity.dart';
import '../infrastructure/transcription_locale_option.dart';

/// Recording/assessment can finish before presenting a global achievement.
final practiceInteractionBusy = ValueNotifier(false);

class DailyGoalCelebration {
  DailyGoalCelebration({required this.file, DateTime Function()? now})
    : now = now ?? DateTime.now;
  static final instance = DailyGoalCelebration(
    file: () async => File(
      '${(await getApplicationSupportDirectory()).path}/daily_goal_celebrations.json',
    ),
  );
  final Future<File> Function() file;
  final DateTime Function() now;
  bool _busy = false;
  static bool reached(DailyWordGoal? goal, WordTotals totals) =>
      goal != null &&
      goal.isValid &&
      goal.listened + goal.spoken > 0 &&
      totals.listened >= goal.listened &&
      totals.spoken >= goal.spoken;

  Future<bool> presentIfEligible({
    required String? owner,
    required DailyWordGoal? goal,
    String? language,
    bool Function()? isCurrent,
    required WordTotals totals,
    required bool Function() isSafe,
    required Future<void> Function() present,
  }) async {
    final complete = reached(goal, totals);
    if (_busy ||
        owner == null ||
        goal == null ||
        !goal.isValid ||
        goal.listened + goal.spoken == 0 ||
        !(isCurrent?.call() ?? true) ||
        (complete && !isSafe())) {
      return false;
    }
    _busy = true;
    try {
      final date = now();
      final day = '${date.year}-${date.month}-${date.day}';
      final target = await file();
      Map<String, dynamic> data = {};
      try {
        data = Map<String, dynamic>.from(
          jsonDecode(await target.readAsString()) as Map,
        );
      } catch (_) {}
      if (!(isCurrent?.call() ?? true)) return false;
      final previous = data[owner];
      final record = previous is Map && previous['day'] == day
          ? Map<String, dynamic>.from(previous)
          : <String, dynamic>{
              'day': day,
              // Preserve today's existing celebration when upgrading from the
              // old once-per-day record, until progress goes below the goal.
              if (previous == day) 'legacyCompleted': true,
            };
      final completions = record['languages'] is Map
          ? Map<String, dynamic>.from(record['languages'] as Map)
          : <String, dynamic>{};
      final scope = normalizeLocaleIdentifierForLookup(
        normalizeLegacyLearningLanguageIdentifier(language ?? ''),
      );
      final alreadyComplete =
          completions[scope] == true ||
          (!completions.containsKey(scope) &&
              record['legacyCompleted'] == true);
      if (complete == alreadyComplete) return false;
      if (complete && !isSafe()) return false;
      // Record the below-goal state even while a call/recording prevents UI.
      // Raising the target therefore arms the next celebration immediately.
      completions[scope] = complete;
      record['languages'] = completions;
      data[owner] = record;
      final temp = File('${target.path}.tmp');
      await temp.writeAsString(jsonEncode(data), flush: true);
      await temp.rename(target.path);
      if (!(isCurrent?.call() ?? true) || (complete && !isSafe())) {
        if (previous == null) {
          data.remove(owner);
        } else {
          data[owner] = previous;
        }
        await target.writeAsString(jsonEncode(data), flush: true);
        return false;
      }
      if (!complete) return false;
      await present();
      return true;
    } catch (_) {
      return false;
    } finally {
      _busy = false;
    }
  }
}
