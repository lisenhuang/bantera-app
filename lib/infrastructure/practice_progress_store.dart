import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

/// Persists the last cue index per media-item so the user can resume
/// practice from where they left off.
class PracticeProgressStore {
  PracticeProgressStore._();

  static final PracticeProgressStore instance = PracticeProgressStore._();

  Map<String, int>? _cache;

  Future<File> get _file async {
    final dir = await getApplicationSupportDirectory();
    return File('${dir.path}/practice_progress.json');
  }

  Future<Map<String, int>> _read() async {
    if (_cache != null) return _cache!;
    try {
      final f = await _file;
      if (await f.exists()) {
        final raw = await f.readAsString();
        if (raw.isNotEmpty) {
          final decoded = jsonDecode(raw);
          if (decoded is Map) {
            _cache = decoded.map(
              (k, v) => MapEntry(k.toString(), v is int ? v : 0),
            );
            return _cache!;
          }
        }
      }
    } catch (_) {}
    _cache = {};
    return _cache!;
  }

  Future<void> _write() async {
    try {
      final f = await _file;
      await f.writeAsString(jsonEncode(_cache ?? {}));
    } catch (_) {}
  }

  Future<int> getCueIndex(String mediaItemId) async {
    final map = await _read();
    return map[mediaItemId] ?? 0;
  }

  Future<void> setCueIndex(String mediaItemId, int cueIndex) async {
    final map = await _read();
    if (map[mediaItemId] == cueIndex) return;
    map[mediaItemId] = cueIndex;
    await _write();
  }

  Future<void> remove(String mediaItemId) async {
    final map = await _read();
    if (map.remove(mediaItemId) != null) {
      await _write();
    }
  }
}
