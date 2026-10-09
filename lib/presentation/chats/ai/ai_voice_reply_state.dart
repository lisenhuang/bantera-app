import '../../../infrastructure/ai/ai_history_store.dart';

/// A provisional response is saved when the stream completes or the chat closes.
/// Keep its identity through retries and completion so the bubble does not jump.
class AiVoiceReplyState {
  AiMessage? message;
  bool received = false;
  int _bytes = 0;

  AiMessage ensure(String language) {
    received = true;
    return message ??= AiMessage(role: 'model', language: language);
  }

  void addAudio(int bytes, String language) {
    _bytes += bytes;
    ensure(language).durationMs = _bytes * 1000 ~/ 48000;
  }

  void addTranscript(String text, String language) {
    if (text.isNotEmpty) ensure(language).appendTranscript(text);
  }

  void resetAttempt() {
    _bytes = 0;
    message?.text = '';
    message?.durationMs = 0;
  }

  AiMessage complete(String text, String audio, String language) {
    final result = ensure(language);
    result.text = text;
    result.audio = audio;
    // The final WAV duration is filled from the history store's audio cache.
    result.durationMs = null;
    message = null;
    return result;
  }

  AiMessage? interrupted(String? audio, {bool failed = true}) {
    final result = message;
    if (result == null) return null;
    result.audio = audio;
    result.failed = failed;
    message = null;
    return result;
  }

  void clear() {
    message = null;
    received = false;
    _bytes = 0;
  }
}
