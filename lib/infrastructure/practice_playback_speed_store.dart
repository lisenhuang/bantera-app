import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

/// Allowed practice playback speeds (keep in sync with practice player UI).
const kPracticePlaybackSpeedOptions = <double>[
  0.5,
  0.75,
  1.0,
  1.25,
  1.5,
  2.0,
];

double nearestPracticePlaybackSpeed(double value) {
  var best = kPracticePlaybackSpeedOptions.first;
  var bestDiff = (value - best).abs();
  for (final s in kPracticePlaybackSpeedOptions) {
    final d = (value - s).abs();
    if (d < bestDiff) {
      bestDiff = d;
      best = s;
    }
  }
  return best;
}

/// Persists the last practice playback speed (global, all sessions).
class PracticePlaybackSpeedStore {
  PracticePlaybackSpeedStore._();

  static final PracticePlaybackSpeedStore instance =
      PracticePlaybackSpeedStore._();

  double? _cache;

  Future<File> get _file async {
    final dir = await getApplicationSupportDirectory();
    return File('${dir.path}/practice_playback_speed.json');
  }

  Future<double> getSpeed() async {
    if (_cache != null) {
      return _cache!;
    }
    try {
      final f = await _file;
      if (await f.exists()) {
        final raw = await f.readAsString();
        if (raw.isNotEmpty) {
          final decoded = jsonDecode(raw);
          if (decoded is Map && decoded['speed'] is num) {
            _cache = nearestPracticePlaybackSpeed(
              (decoded['speed'] as num).toDouble(),
            );
            return _cache!;
          }
        }
      }
    } catch (_) {}
    _cache = 1.0;
    return _cache!;
  }

  Future<void> setSpeed(double speed) async {
    final v = nearestPracticePlaybackSpeed(speed);
    _cache = v;
    try {
      final file = await _file;
      await file.writeAsString(jsonEncode({'speed': v}));
    } catch (_) {}
  }

  /// Clears persisted speed (e.g. account deletion).
  Future<void> clear() async {
    _cache = null;
    try {
      final file = await _file;
      if (await file.exists()) {
        await file.delete();
      }
    } catch (_) {}
  }
}
