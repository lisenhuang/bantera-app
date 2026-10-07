import 'package:flutter_test/flutter_test.dart';
import 'package:app/infrastructure/ai/ai_history_store.dart';
import 'package:app/presentation/chats/ai/ai_voice_reply_state.dart';

void main() {
  test('first audio creates an immediate bubble with growing duration', () {
    final state = AiVoiceReplyState();
    expect(state.received, false);
    state.addAudio(24000, 'en-NZ');
    final id = state.message!.id;
    expect(state.received, true);
    expect(state.message!.durationMs, 500);
    state.addTranscript('Hello ', 'en-NZ');
    state.addAudio(24000, 'en-NZ');
    state.addTranscript('there', 'en-NZ');
    expect(state.message!.durationMs, 1000);
    expect(state.message!.text, 'Hello there');
    final saved = state.complete('Hello there.', 'reply.wav', 'en-NZ');
    expect(saved.id, id);
    expect(saved.text, 'Hello there.');
    expect(saved.audio, 'reply.wav');
    expect(state.message, isNull);
    expect(state.received, true); // Native playback may still be draining.
    state.clear();
    expect(state.received, false);
  });
  test(
    'interrupted reply keeps its identity and is excluded from model context',
    () {
      final state = AiVoiceReplyState();
      state.addAudio(48000, 'en-NZ');
      state.addTranscript('A partial response', 'en-NZ');
      final id = state.message!.id;
      final saved = state.interrupted('partial.wav')!;
      state.clear();
      final restored = AiMessage.fromJson(saved.toJson());
      expect(restored.id, id);
      expect(restored.failed, true);
      expect(restored.audio, 'partial.wav');
      expect(restored.durationMs, 1000);
      expect(restored.text, 'A partial response');
      expect(AiHistoryStore.contextFor([restored]), isEmpty);
    },
  );
  test('retry replaces partial text and audio without duplicate bubbles', () {
    final state = AiVoiceReplyState();
    state.addTranscript('Discard this partial reply', 'en-NZ');
    final id = state.message!.id;
    state.addAudio(48000, 'en-NZ');
    state.resetAttempt();
    expect(state.message!.text, isEmpty);
    expect(state.message!.durationMs, 0);
    state.addTranscript('Fresh reply', 'en-NZ');
    state.addAudio(24000, 'en-NZ');
    expect(state.message!.id, id);
    expect(state.message!.durationMs, 500);
    state
        .clear(); // Cancelling a recording does not save its provisional response.
    expect(state.message, isNull);
  });
}
