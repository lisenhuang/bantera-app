import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import '../domain/activity/daily_word_goal.dart';
import '../domain/activity/word_activity.dart';

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
    required WordTotals totals,
    required bool Function() isSafe,
    required Future<void> Function() present,
  }) async {
    if (_busy || owner == null || !reached(goal, totals) || !isSafe())
      return false;
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
      if (data[owner] == day || !isSafe()) return false;
      data[owner] = day;
      final temp = File('${target.path}.tmp');
      await temp.writeAsString(jsonEncode(data), flush: true);
      await temp.rename(target.path);
      if (!isSafe()) {
        data.remove(owner);
        await target.writeAsString(jsonEncode(data), flush: true);
        return false;
      }
      await present();
      return true;
    } catch (_) {
      return false;
    } finally {
      _busy = false;
    }
  }
}
