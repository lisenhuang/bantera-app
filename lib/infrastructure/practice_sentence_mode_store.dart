import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

enum CueSentenceMode { short, long }

/// Persists short vs long sentence mode for practice (word-timing videos).
class PracticeSentenceModeStore {
  PracticeSentenceModeStore._();

  static final PracticeSentenceModeStore instance = PracticeSentenceModeStore._();

  CueSentenceMode? _cache;

  Future<File> get _file async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/practice_sentence_mode.json');
  }

  Future<CueSentenceMode> load() async {
    if (_cache != null) {
      return _cache!;
    }
    try {
      final f = await _file;
      if (await f.exists()) {
        final raw = await f.readAsString();
        if (raw.isNotEmpty) {
          final decoded = jsonDecode(raw);
          if (decoded is Map) {
            final name = decoded['mode']?.toString();
            if (name == CueSentenceMode.long.name) {
              _cache = CueSentenceMode.long;
              return _cache!;
            }
            if (name == CueSentenceMode.short.name) {
              _cache = CueSentenceMode.short;
              return _cache!;
            }
          }
        }
      }
    } catch (_) {}
    _cache = CueSentenceMode.short;
    return _cache!;
  }

  Future<void> save(CueSentenceMode mode) async {
    _cache = mode;
    try {
      final f = await _file;
      await f.writeAsString(jsonEncode(<String, dynamic>{'mode': mode.name}));
    } catch (_) {}
  }
}
