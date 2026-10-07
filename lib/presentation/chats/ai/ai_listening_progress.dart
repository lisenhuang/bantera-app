/// Maps rendered PCM frames to transcript-derived word estimates. Queued audio
/// earns nothing, and discarded output never earns later credit after interruption.
class AiListeningProgress {
  final _segments = <_Segment>[];
  void add(int start, int end, int words, String language) {
    if (end > start && words > 0) {
      _segments.add(_Segment(start, end, words, language));
    }
  }

  Map<String, int> advance(int rendered) {
    final result = <String, int>{};
    for (final s in _segments) {
      final count =
          (s.words *
                  (rendered - s.start).clamp(0, s.end - s.start) /
                  (s.end - s.start))
              .floor();
      final delta = count - s.credited;
      if (delta > 0) {
        result.update(s.language, (n) => n + delta, ifAbsent: () => delta);
        s.credited = count;
      }
    }
    _segments.removeWhere((s) => s.credited == s.words);
    return result;
  }

  void clear() => _segments.clear();
}

class _Segment {
  _Segment(this.start, this.end, this.words, this.language);
  final int start, end, words;
  final String language;
  int credited = 0;
}
