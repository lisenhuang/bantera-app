import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

/// Exercise snapshots survive moving to the next practice and app restarts.
/// Account keys are captured by the caller before any asynchronous operation.
class SavedPracticeStore {
  SavedPracticeStore({required this.file});

  static final instance = SavedPracticeStore(
    file: () async => File(
      '${(await getApplicationSupportDirectory()).path}/saved_practice.json',
    ),
  );

  final Future<File> Function() file;
  Future<void> _queue = Future.value();

  Future<T> _serial<T>(Future<T> Function() action) {
    final result = _queue.then((_) => action());
    _queue = result.then<void>((_) {}, onError: (Object _, StackTrace _) {});
    return result;
  }

  Future<Map<String, dynamic>> _read(File target) async => await target.exists()
      ? Map<String, dynamic>.from(
          jsonDecode(await target.readAsString()) as Map,
        )
      : <String, dynamic>{};

  Future<List<Map<String, dynamic>>> load(String owner) => _serial(() async {
    if (owner.trim().isEmpty) return [];
    final data = await _read(await file());
    return (data[owner] as List? ?? [])
        .map((entry) => Map<String, dynamic>.from(entry as Map))
        .toList();
  });

  Future<void> clear(String owner) => _serial(() async {
    if (owner.trim().isEmpty) {
      throw ArgumentError('A saved practice requires an owner');
    }
    final target = await file();
    final data = await _read(target);
    data.remove(owner);
    await target.parent.create(recursive: true);
    final temporary = File('${target.path}.tmp');
    await temporary.writeAsString(jsonEncode(data), flush: true);
    await temporary.rename(target.path);
  });

  Future<void> setSaved({
    required String owner,
    required Map<String, dynamic> exercise,
    required bool saved,
  }) {
    // Take a snapshot now, before waiting for other writes.
    final snapshot = jsonDecode(jsonEncode(exercise)) as Map<String, dynamic>;
    return _serial(() async {
      if (owner.trim().isEmpty || snapshot['id'] is! String) {
        throw ArgumentError('A saved practice requires an owner and id');
      }
      final target = await file();
      final data = await _read(target);
      final entries = List<dynamic>.from(data[owner] as List? ?? []);
      entries.removeWhere((entry) => entry['id'] == snapshot['id']);
      if (saved) {
        entries.insert(0, {
          'id': snapshot['id'],
          'locale': snapshot['locale'],
          'level': snapshot['level'],
          'cue': snapshot['cue'],
          'cueAudioUrl': snapshot['cueAudioUrl'],
          'choices': snapshot['choices'],
          'savedAt': DateTime.now().toUtc().toIso8601String(),
        });
      }
      data[owner] = entries;
      await target.parent.create(recursive: true);
      final temporary = File('${target.path}.tmp');
      await temporary.writeAsString(jsonEncode(data), flush: true);
      await temporary.rename(target.path);
    });
  }
}
