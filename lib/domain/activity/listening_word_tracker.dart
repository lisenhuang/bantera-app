import '../models/models.dart';
import '../../presentation/practice/subtitle_word_tokens.dart';

/// Transcript-derived units, matching the subtitle tokenizer. Counts are
/// estimates for languages without spaces and cues without word timestamps.
int activityWordCount(String text) => subtitleWordTokens(text).length;

class ListeningWordUnit {
  const ListeningWordUnit(this.endMs, this.count);
  final int endMs;
  final int count;
}

class ListeningWordTracker {
  ListeningWordTracker(List<ListeningWordUnit> units)
    : _units = [...units]..sort((a, b) => a.endMs.compareTo(b.endMs));

  factory ListeningWordTracker.forMedia(MediaItem media) {
    final timing = media.wordTiming;
    if (timing != null && timing.isNotEmpty) {
      return ListeningWordTracker([
        for (final word in timing)
          if (word.endMs > word.startMs)
            ListeningWordUnit(word.endMs, activityWordCount(word.word)),
      ]);
    }
    return ListeningWordTracker([
      for (final cue in media.cues)
        ...estimatedUnits(cue.originalText, cue.startTimeMs, cue.endTimeMs),
    ]);
  }

  static List<ListeningWordUnit> estimatedUnits(
    String text,
    int startMs,
    int endMs,
  ) {
    final count = activityWordCount(text);
    if (count == 0 || endMs <= startMs) return [];
    return [
      for (var i = 1; i <= count; i++)
        ListeningWordUnit(startMs + ((endMs - startMs) * i / count).round(), 1),
    ];
  }

  final List<ListeningWordUnit> _units;
  int? _positionMs;
  DateTime? _tickAt;

  void seek(int positionMs, {DateTime? at}) {
    _positionMs = positionMs;
    _tickAt = at ?? DateTime.now();
  }

  int advance(
    int positionMs, {
    required bool playing,
    double speed = 1,
    DateTime? at,
  }) {
    final now = at ?? DateTime.now();
    final previous = _positionMs;
    final previousAt = _tickAt;
    _positionMs = positionMs;
    _tickAt = now;
    if (!playing ||
        previous == null ||
        previousAt == null ||
        positionMs <= previous) {
      return 0;
    }
    // Ignore unexpected forward jumps too, even if a platform seek callback
    // arrives outside the explicit seek path. Allow normal coarse player ticks.
    final maxAdvance = (now.difference(previousAt).inMilliseconds * speed + 600)
        .ceil();
    if (positionMs - previous > maxAdvance) {
      return 0;
    }
    // Binary search the crossed word ends, so long lessons stay inexpensive.
    int upperBound(int target) {
      var lo = 0;
      var hi = _units.length;
      while (lo < hi) {
        final mid = (lo + hi) ~/ 2;
        if (_units[mid].endMs <= target) {
          lo = mid + 1;
        } else {
          hi = mid;
        }
      }
      return lo;
    }

    var count = 0;
    final end = upperBound(positionMs);
    for (var i = upperBound(previous); i < end; i++) {
      count += _units[i].count;
    }
    return count;
  }
}
