import '../models/models.dart';

/// Counts each original cue once, using actual playback rather than cue selection.
/// Original cue boundaries also work when the player displays shorter sentences.
class LessonCompletionTracker {
  LessonCompletionTracker(List<Cue> cues)
    : _cues = cues.where((cue) => cue.endTimeMs > cue.startTimeMs).toList();

  final List<Cue> _cues;
  final List<({int start, int end})> _heard = [];
  final Set<String> _completed = {};
  int? _position;
  DateTime? _tickAt;

  static String _key(Cue cue) =>
      '${cue.id}:${cue.startTimeMs}:${cue.endTimeMs}';
  Set<String> get requiredCueKeys => _cues.map(_key).toSet();

  void seek(int positionMs, {DateTime? at}) {
    _position = positionMs;
    _tickAt = at ?? DateTime.now();
  }

  Set<String> advance(
    int positionMs, {
    required bool playing,
    double speed = 1,
    DateTime? at,
  }) {
    final now = at ?? DateTime.now();
    final previous = _position;
    final previousAt = _tickAt;
    seek(positionMs, at: now);
    if (!playing ||
        previous == null ||
        previousAt == null ||
        positionMs <= previous ||
        positionMs - previous >
            now.difference(previousAt).inMilliseconds * speed + 600) {
      return {};
    }

    var start = previous;
    var end = positionMs;
    _heard.removeWhere((range) {
      if (range.end < start || range.start > end) return false;
      if (range.start < start) start = range.start;
      if (range.end > end) end = range.end;
      return true;
    });
    _heard.add((start: start, end: end));
    _heard.sort((a, b) => a.start.compareTo(b.start));

    final newlyCompleted = <String>{};
    for (final cue in _cues) {
      final key = _key(cue);
      if (_completed.contains(key)) continue;
      var heardMs = 0;
      var reachedEnd = false;
      for (final range in _heard) {
        final from = range.start.clamp(cue.startTimeMs, cue.endTimeMs);
        final to = range.end.clamp(cue.startTimeMs, cue.endTimeMs);
        heardMs += to - from;
        if (range.start < cue.endTimeMs && range.end >= cue.endTimeMs) {
          reachedEnd = true;
        }
      }
      // Allow small player/short-cue boundary differences, but never a seek to EOF.
      if (reachedEnd && heardMs >= (cue.endTimeMs - cue.startTimeMs) * .95) {
        _completed.add(key);
        newlyCompleted.add(key);
      }
    }
    return newlyCompleted;
  }
}
