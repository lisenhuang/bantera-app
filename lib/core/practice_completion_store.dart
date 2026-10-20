import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

import '../domain/activity/word_activity.dart';

/// Device-local daily completions, isolated by account and language.
class PracticeCompletionStore {
  PracticeCompletionStore({required this.file, DateTime Function()? now})
    : now = now ?? DateTime.now;

  static final instance = PracticeCompletionStore(
    file: () async => File(
      '${(await getApplicationSupportDirectory()).path}/practice_completions.json',
    ),
  );

  final Future<File> Function() file;
  final DateTime Function() now;
  Future<void> _queue = Future.value();

  Future<int> today({
    required String owner,
    required String language,
    String? completedExercise,
  }) {
    final day = wordActivityDateKey(now());
    final result = _queue.then((_) async {
      final target = await file();
      final data = await target.exists()
          ? Map<String, dynamic>.from(
              jsonDecode(await target.readAsString()) as Map,
            )
          : <String, dynamic>{};
      final key = jsonEncode([owner, wordActivityLanguageKey(language)]);
      final entry = Map<String, dynamic>.from(data[key] as Map? ?? {});
      final ids = entry['day'] == day
          ? Set<String>.from(entry['ids'] as List? ?? [])
          : <String>{};
      if (completedExercise != null &&
          completedExercise != entry['lastCompleted'] &&
          ids.add(completedExercise)) {
        data[key] = {
          'day': day,
          'ids': ids.toList(),
          'lastCompleted': completedExercise,
        };
        await target.parent.create(recursive: true);
        final temp = File('${target.path}.tmp');
        await temp.writeAsString(jsonEncode(data), flush: true);
        await temp.rename(target.path);
      }
      // lastCompleted survives the date boundary, so retrying yesterday's
      // still-open exercise does not count as a new completion today.
      return ids.length;
    });
    _queue = result.then<void>((_) {}, onError: (Object _, StackTrace _) {});
    return result;
  }
}
