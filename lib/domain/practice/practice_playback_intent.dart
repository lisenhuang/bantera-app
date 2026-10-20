/// Autoplay belongs only to an explicit Next action. Polling may retain it, but
/// leaving Practice, backgrounding or a call cancels it permanently.
class PracticePlaybackIntent {
  String? _nextRequest;
  void next(String requestId) => _nextRequest = requestId;
  void cancel() => _nextRequest = null;
  bool take(String requestId) {
    final play = _nextRequest == requestId;
    if (play) _nextRequest = null;
    return play;
  }
}
