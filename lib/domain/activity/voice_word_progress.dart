/// Voice messages have a transcript but no word timestamps. Estimate the
/// portion heard from audio progress, retaining progress while recognition runs.
class VoiceWordProgress {
  VoiceWordProgress({required this.durationMs, required this.onWords});
  final int durationMs;
  final void Function(int words, DateTime at) onWords;
  final List<({int from, int to, DateTime at})> _pending = [];
  int _position = 0;
  int? _wordCount;

  void setWordCount(int count) {
    if (_wordCount != null) return;
    _wordCount = count;
    for (final span in _pending) {
      _count(span.from, span.to, span.at);
    }
    _pending.clear();
  }

  void advance(int positionMs, {required bool playing, DateTime? at}) {
    if (!playing || durationMs <= 0) return;
    final next = positionMs.clamp(0, durationMs);
    if (next <= _position) return;
    final now = at ?? DateTime.now();
    if (_wordCount == null) {
      _pending.add((from: _position, to: next, at: now));
    } else {
      _count(_position, next, now);
    }
    _position = next;
  }

  void _count(int from, int to, DateTime at) {
    final count = _wordCount!;
    final words = (count * to ~/ durationMs) - (count * from ~/ durationMs);
    if (words > 0) onWords(words, at);
  }
}
