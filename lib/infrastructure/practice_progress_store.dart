import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

import '../core/auth_session_notifier.dart';
import '../domain/models/models.dart';

/// Progress counts original cues actually heard, independent of sentence mode.
class PracticeHistoryEntry {
  const PracticeHistoryEntry({
    required this.mediaItem,
    required this.cueIndex,
    required this.cueStartMs,
    required this.cueMode,
    required this.completedCueKeys,
    required this.lastPracticedAt,
  });

  final MediaItem mediaItem;
  final int cueIndex;
  final int cueStartMs;
  final String cueMode;
  final Set<String> completedCueKeys;
  final DateTime lastPracticedAt;

  Set<String> get requiredCueKeys => {
    for (final cue in mediaItem.cues)
      if (cue.endTimeMs > cue.startTimeMs)
        '${cue.id}:${cue.startTimeMs}:${cue.endTimeMs}',
  };
  int get totalCues => requiredCueKeys.length;
  int get completedCues =>
      completedCueKeys.intersection(requiredCueKeys).length;
  double get progress => totalCues == 0 ? 0 : completedCues / totalCues;

  int resolveCueIndex(List<Cue> cues, String mode) {
    if (cues.isEmpty) return 0;
    if (mode == cueMode &&
        cueIndex >= 0 &&
        cueIndex < cues.length &&
        cues[cueIndex].startTimeMs == cueStartMs) {
      return cueIndex;
    }
    final index = cues.lastIndexWhere((cue) => cue.startTimeMs <= cueStartMs);
    return index < 0 ? 0 : index;
  }

  Map<String, dynamic> toJson() => {
    'media': mediaItem.toJson(),
    'cueIndex': cueIndex,
    'cueStartMs': cueStartMs,
    'cueMode': cueMode,
    'completed': completedCueKeys.toList(),
    'lastPracticedAt': lastPracticedAt.toIso8601String(),
  };

  factory PracticeHistoryEntry.fromJson(Map<String, dynamic> json) =>
      PracticeHistoryEntry(
        mediaItem: MediaItem.fromJson(json['media'] as Map<String, dynamic>),
        cueIndex: (json['cueIndex'] as int).clamp(0, 1 << 30),
        cueStartMs: json['cueStartMs'] as int,
        cueMode: json['cueMode'] as String,
        completedCueKeys: (json['completed'] as List).cast<String>().toSet(),
        lastPracticedAt: DateTime.parse(json['lastPracticedAt'] as String),
      );
}

/// Device-local history and resume positions, isolated by account. All IO is
/// serialised so fast player callbacks cannot overwrite newer progress/removals.
class PracticeProgressStore extends ChangeNotifier {
  PracticeProgressStore({
    required Future<File> Function() file,
    required String Function() owner,
    DateTime Function()? now,
  }) : _file = file,
       _owner = owner,
       _now = now ?? DateTime.now;

  static final PracticeProgressStore instance = PracticeProgressStore(
    file: () async {
      final dir = await getApplicationSupportDirectory();
      return File('${dir.path}/practice_progress.json');
    },
    owner: () =>
        AuthSessionNotifier.instance.session?.cacheKey ?? 'local-device-user',
  );

  final Future<File> Function() _file;
  final String Function() _owner;
  final DateTime Function() _now;
  final Map<String, Map<String, PracticeHistoryEntry>> _history = {};
  final Map<String, Map<String, int>> _positions = {};
  Future<void> _queue = Future.value();
  bool _loaded = false;
  String get currentOwner => _owner();

  List<PracticeHistoryEntry> get entries => List.unmodifiable(
    (_history[_owner()]?.values.toList() ?? [])
      ..sort((a, b) => b.lastPracticedAt.compareTo(a.lastPracticedAt)),
  );

  Future<T> _serial<T>(Future<T> Function() action) {
    final task = _queue.then((_) => action());
    _queue = task.then<void>((_) {}, onError: (Object _, StackTrace _) {});
    return task;
  }

  Future<void> _read(String owner) async {
    if (_loaded) return;
    final file = await _file();
    if (await file.exists()) {
      final content = await file.readAsString();
      final raw = content.isEmpty
          ? <String, dynamic>{}
          : jsonDecode(content) as Map<String, dynamic>;
      if (raw['version'] == 2) {
        final owners = raw['owners'] as Map<String, dynamic>;
        for (final entry in owners.entries) {
          final data = entry.value as Map<String, dynamic>;
          _positions[entry.key] = (data['positions'] as Map<String, dynamic>)
              .map((key, value) => MapEntry(key, value as int));
          final records = <String, PracticeHistoryEntry>{};
          for (final row in data['history'] as List) {
            try {
              final record = PracticeHistoryEntry.fromJson(
                row as Map<String, dynamic>,
              );
              records[record.mediaItem.id] = record;
            } catch (_) {
              // One damaged record must not hide the rest of the library.
            }
          }
          _history[entry.key] = records;
        }
      } else {
        // Old versions only stored indices. Preserve resume, but never invent
        // dates, media metadata, or completed cues for those legacy positions.
        _positions[owner] = {
          for (final entry in raw.entries)
            if (entry.value is int) entry.key: entry.value as int,
        };
        await _write();
      }
    }
    _loaded = true;
  }

  Future<void> _write() async {
    final file = await _file();
    await file.parent.create(recursive: true);
    final temp = File('${file.path}.tmp');
    await temp.writeAsString(
      jsonEncode({
        'version': 2,
        'owners': {
          for (final owner in {..._positions.keys, ..._history.keys})
            owner: {
              'positions': _positions[owner] ?? {},
              'history':
                  _history[owner]?.values.map((e) => e.toJson()).toList() ?? [],
            },
        },
      }),
      flush: true,
    );
    await temp.rename(file.path);
  }

  Future<void> load() {
    final owner = _owner();
    return _serial(() async {
      await _read(owner);
      notifyListeners();
    });
  }

  Future<PracticeHistoryEntry?> getEntry(String id, {String? owner}) {
    final key = owner ?? _owner();
    return _serial(() async {
      await _read(key);
      return _history[key]?[id];
    });
  }

  Future<int> getCueIndex(String id, {String? owner}) {
    final key = owner ?? _owner();
    return _serial(() async {
      await _read(key);
      return _positions[key]?[id] ?? 0;
    });
  }

  Future<void> setCueIndex(String id, int index) {
    final owner = _owner();
    return _serial(() async {
      await _read(owner);
      (_positions[owner] ??= {})[id] = index;
      await _write();
    });
  }

  Future<void> record({
    required MediaItem mediaItem,
    required int cueIndex,
    required int cueStartMs,
    required String cueMode,
    required String owner,
    Set<String> completedCueKeys = const {},
  }) {
    // Temporary imports are deleted on leaving the player and cannot be resumed.
    if (mediaItem.deleteLocalMediaOnDispose || mediaItem.cues.isEmpty) {
      return Future.value();
    }
    final at = _now();
    return _serial(() async {
      await _read(owner);
      final history = _history[owner] ??= {};
      final old = history[mediaItem.id];
      final next = PracticeHistoryEntry(
        mediaItem: mediaItem,
        cueIndex: cueIndex,
        cueStartMs: cueStartMs,
        cueMode: cueMode,
        completedCueKeys: {...?old?.completedCueKeys, ...completedCueKeys},
        lastPracticedAt: at,
      );
      final oldPosition = _positions[owner]?[mediaItem.id];
      history[mediaItem.id] = next;
      (_positions[owner] ??= {})[mediaItem.id] = cueIndex;
      try {
        await _write();
      } catch (_) {
        if (old == null) {
          history.remove(mediaItem.id);
        } else {
          history[mediaItem.id] = old;
        }
        if (oldPosition == null) {
          _positions[owner]!.remove(mediaItem.id);
        } else {
          _positions[owner]![mediaItem.id] = oldPosition;
        }
        rethrow;
      }
      notifyListeners();
    });
  }

  /// Removes only history and its resume point, never saved content or totals.
  Future<void> remove(String id) {
    final owner = _owner();
    return _serial(() async {
      await _read(owner);
      final record = _history[owner]?.remove(id);
      final position = _positions[owner]?.remove(id);
      try {
        await _write();
      } catch (_) {
        if (record != null) (_history[owner] ??= {})[id] = record;
        if (position != null) (_positions[owner] ??= {})[id] = position;
        rethrow;
      }
      notifyListeners();
    });
  }

  Future<void> clearAll() {
    final owner = _owner();
    return _serial(() async {
      await _read(owner);
      final history = _history.remove(owner);
      final positions = _positions.remove(owner);
      try {
        await _write();
      } catch (_) {
        if (history != null) _history[owner] = history;
        if (positions != null) _positions[owner] = positions;
        rethrow;
      }
      notifyListeners();
    });
  }
}
