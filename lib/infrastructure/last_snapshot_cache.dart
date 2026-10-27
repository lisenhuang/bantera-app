import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

/// A bounded, single-slot snapshot. A new scope replaces, never accumulates,
/// old content. Scope checks prevent account/language crossover.
class LastSnapshotCache {
  LastSnapshotCache({
    required this.file,
    required this.maxAge,
    required this.valid,
    DateTime Function()? now,
  }) : now = now ?? DateTime.now;

  final Future<File> Function() file;
  final Duration maxAge;
  final bool Function(Map<String, dynamic>) valid;
  final DateTime Function() now;
  static const maxBytes = 512 * 1024;
  String? _scope;
  Map<String, dynamic>? _data;
  DateTime? _savedAt;
  int _generation = 0;
  Future<void> _queue = Future.value();

  static File _path(Directory directory, String name) =>
      File('${directory.path}/$name-v1.json');
  static final leaderboard = LastSnapshotCache(
    file: () async => _path(
      await getApplicationSupportDirectory(),
      'speaking-leaderboard-cache',
    ),
    maxAge: const Duration(days: 1),
    valid: (data) =>
        data['offset'] == 0 &&
        data['rows'] is List &&
        (data['rows'] as List).length <= 100 &&
        data['you'] is Map &&
        DateTime.tryParse(data['fromDate']?.toString() ?? '') != null &&
        DateTime.tryParse(data['throughDate']?.toString() ?? '') != null,
  );
  static final practice = LastSnapshotCache(
    file: () async =>
        _path(await getApplicationSupportDirectory(), 'last-practice-cache'),
    maxAge: const Duration(days: 7),
    valid: (data) =>
        data['status'] == 'ready' &&
        data['id'] is String &&
        data['cue'] is String &&
        data['cueAudioUrl'] is String &&
        data['level'] is String &&
        data['choices'] is List &&
        (data['choices'] as List).length == 2 &&
        (data['choices'] as List).every(
          (row) =>
              row is Map && row['text'] is String && row['audioUrl'] is String,
        ),
  );

  Map<String, dynamic> _copy(Map<String, dynamic> data) =>
      jsonDecode(jsonEncode(data)) as Map<String, dynamic>;
  bool _fresh(DateTime date) {
    final age = now().difference(date);
    return !age.isNegative && age <= maxAge;
  }

  Map<String, dynamic>? peek(String scope) =>
      scope == _scope && _data != null && _savedAt != null && _fresh(_savedAt!)
      ? _copy(_data!)
      : null;

  Future<T> _serial<T>(Future<T> Function() work) {
    final task = _queue.then((_) => work());
    _queue = task.then<void>((_) {}, onError: (Object _, StackTrace _) {});
    return task;
  }

  Future<Map<String, dynamic>?> read(String scope) async {
    final memory = peek(scope);
    if (memory != null) return memory;
    final generation = _generation;
    return _serial(() async {
      try {
        final target = await file();
        if (!await target.exists() || await target.length() > maxBytes) {
          return null;
        }
        final envelope = jsonDecode(await target.readAsString()) as Map;
        if (generation != _generation) return peek(scope);
        if (envelope['scope'] != scope || envelope['version'] != 1) return null;
        final date = DateTime.tryParse(envelope['savedAt']?.toString() ?? '');
        final data = Map<String, dynamic>.from(envelope['data'] as Map);
        if (date == null || !_fresh(date) || !valid(data)) return null;
        _scope = scope;
        _data = data;
        _savedAt = date;
        return _copy(data);
      } catch (_) {
        return null; // A missing/corrupt cache never prevents a network refresh.
      }
    });
  }

  Future<void> save(String scope, Map<String, dynamic> data) async {
    try {
      if (scope.isEmpty || !valid(data)) return;
      // Card and full-screen requests may finish out of order.
      final existing = peek(scope);
      final before = DateTime.tryParse(existing?['asOf']?.toString() ?? '');
      final after = DateTime.tryParse(data['asOf']?.toString() ?? '');
      if (before != null && after != null && after.isBefore(before)) return;
      final snapshot = _copy(data), date = now();
      final encoded = jsonEncode({
        'version': 1,
        'scope': scope,
        'savedAt': date.toIso8601String(),
        'data': snapshot,
      });
      if (utf8.encode(encoded).length > maxBytes) return;
      final generation = ++_generation;
      _scope = scope;
      _data = snapshot;
      _savedAt = date;
      await _serial(() async {
        if (generation != _generation) return;
        final target = await file();
        await target.parent.create(recursive: true);
        final temp = File('${target.path}.tmp');
        await temp.writeAsString(encoded, flush: true);
        await temp.rename(target.path);
      });
    } catch (_) {
      // Memory caching still works when disk storage is unavailable.
    }
  }

  Future<void> clearAll() async {
    _generation++;
    _scope = null;
    _data = null;
    _savedAt = null;
    await _serial(() async {
      final target = await file();
      for (final path in [target.path, '${target.path}.tmp']) {
        if (await FileSystemEntity.type(path, followLinks: false) ==
            FileSystemEntityType.file) {
          await File(path).delete();
        }
      }
    });
  }

  Future<void> clear(String scope) async {
    if (_scope == null || _scope == scope) _generation++;
    if (_scope == scope) {
      _scope = null;
      _data = null;
      _savedAt = null;
    }
    try {
      await _serial(() async {
        final target = await file();
        if (await target.exists() && await target.length() <= maxBytes) {
          final envelope = jsonDecode(await target.readAsString()) as Map;
          if (envelope['scope'] == scope) await target.delete();
        }
      });
    } catch (_) {
      // Scope validation still prevents another account from reading this file.
    }
  }
}
