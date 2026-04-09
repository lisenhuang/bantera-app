import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

/// Extra silence after each cue during Play all (for shadowing / repeating aloud).
enum PlayAllPauseBetweenCues {
  /// Play the media continuously (no inserted pause; gaps in the file are unchanged).
  none,

  /// Fixed 1 second between cues.
  oneSecond,

  /// Pause as long as the cue that just finished (same duration as that cue).
  oneCueDuration,

  /// Pause twice the duration of the cue that just finished.
  twoCueDurations,
}

/// Persists the last selected pause-between-cues option for Play all.
class PlayAllPauseStore {
  PlayAllPauseStore._();

  static final PlayAllPauseStore instance = PlayAllPauseStore._();

  PlayAllPauseBetweenCues? _cache;

  Future<File> get _file async {
    final dir = await getApplicationSupportDirectory();
    return File('${dir.path}/play_all_pause.json');
  }

  Future<PlayAllPauseBetweenCues> getSelectedPause() async {
    if (_cache != null) {
      return _cache!;
    }
    try {
      final f = await _file;
      if (await f.exists()) {
        final raw = await f.readAsString();
        if (raw.isNotEmpty) {
          final decoded = jsonDecode(raw);
          if (decoded is Map && decoded['mode'] is int) {
            final i = decoded['mode'] as int;
            if (i >= 0 && i < PlayAllPauseBetweenCues.values.length) {
              _cache = PlayAllPauseBetweenCues.values[i];
              return _cache!;
            }
          }
        }
      }
    } catch (_) {}
    _cache = PlayAllPauseBetweenCues.none;
    return _cache!;
  }

  Future<void> setSelectedPause(PlayAllPauseBetweenCues mode) async {
    _cache = mode;
    try {
      final f = await _file;
      await f.writeAsString(jsonEncode({'mode': mode.index}));
    } catch (_) {}
  }
}
