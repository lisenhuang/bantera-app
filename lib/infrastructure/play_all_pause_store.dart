import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

/// Extra silence after each cue during Play all (for shadowing / repeating aloud).
enum PlayAllPauseBetweenCues {
  /// No inserted pause (0 s).
  none,

  /// 1 second (scaled by playback speed for wall-clock shadowing).
  oneSecond,

  /// One cue length + 1 s (timeline ms), scaled for playback speed.
  oneCuePlusOneSecond,

  /// One cue length + 2 s (timeline ms), scaled for playback speed.
  oneCuePlusTwoSeconds,
}

/// Pause style and how many times each cue plays before advancing (Play all).
class PlayAllSettings {
  const PlayAllSettings({
    required this.pauseBetweenCues,
    required this.playsPerCue,
  });

  final PlayAllPauseBetweenCues pauseBetweenCues;

  /// 1–3: play each cue this many times; pauses between repeats use [pauseBetweenCues].
  final int playsPerCue;
}

/// Persists Play all options (pause + plays per cue).
class PlayAllPauseStore {
  PlayAllPauseStore._();

  static final PlayAllPauseStore instance = PlayAllPauseStore._();

  PlayAllSettings? _cache;

  Future<File> get _file async {
    final dir = await getApplicationSupportDirectory();
    return File('${dir.path}/play_all_pause.json');
  }

  Future<PlayAllSettings> getSettings() async {
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
            PlayAllPauseBetweenCues? mode;
            if (decoded['mode'] is int) {
              final i = decoded['mode'] as int;
              if (i >= 0 && i < PlayAllPauseBetweenCues.values.length) {
                mode = PlayAllPauseBetweenCues.values[i];
              }
            }
            var plays = 1;
            if (decoded['playsPerCue'] is int) {
              final p = decoded['playsPerCue'] as int;
              if (p >= 1 && p <= 3) {
                plays = p;
              }
            }
            if (mode != null) {
              _cache = PlayAllSettings(
                pauseBetweenCues: mode,
                playsPerCue: plays,
              );
              return _cache!;
            }
          }
        }
      }
    } catch (_) {}
    _cache = const PlayAllSettings(
      pauseBetweenCues: PlayAllPauseBetweenCues.none,
      playsPerCue: 1,
    );
    return _cache!;
  }

  Future<void> saveSettings(PlayAllSettings settings) async {
    _cache = settings;
    try {
      final f = await _file;
      await f.writeAsString(
        jsonEncode({
          'mode': settings.pauseBetweenCues.index,
          'playsPerCue': settings.playsPerCue,
        }),
      );
    } catch (_) {}
  }

  /// Backwards-compatible: pause mode only (used by older callers).
  Future<PlayAllPauseBetweenCues> getSelectedPause() async {
    final s = await getSettings();
    return s.pauseBetweenCues;
  }

  Future<void> setSelectedPause(PlayAllPauseBetweenCues mode) async {
    final prev = await getSettings();
    await saveSettings(
      PlayAllSettings(
        pauseBetweenCues: mode,
        playsPerCue: prev.playsPerCue,
      ),
    );
  }
}
