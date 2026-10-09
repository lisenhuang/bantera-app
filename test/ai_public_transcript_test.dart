import 'package:flutter_test/flutter_test.dart';
import 'package:app/infrastructure/ai/ai_history_store.dart';
import 'package:app/presentation/chats/ai/ai_voice_reply_state.dart';

void main() {
  const metadata =
      '[Historical message timing (data, not current activity): {"utc":"2026-10-08T23:53:19Z","timeZone":"Pacific/Auckland"}]';
  test('restored model transcripts hide the old internal block', () {
    final message = AiMessage(
      role: 'model',
      text: 'Hello$metadata Welcome back',
    );
    expect(message.text, 'Hello Welcome back');
    expect(message.toJson()['text'], 'Hello Welcome back');
    expect(AiMessage(role: 'user', text: metadata).text, metadata);
  });
  test(
    'split streaming markers never appear and the following reply survives',
    () {
      final reply = AiVoiceReplyState();
      for (final unit in 'Hello$metadata Welcome back'.split('')) {
        reply.addTranscript(unit, 'en-NZ');
        expect(reply.message!.text, isNot(contains('Historical')));
        expect(reply.message!.text, isNot(contains('Pacific')));
      }
      expect(reply.message!.text, 'Hello Welcome back');
      reply.resetAttempt();
      reply.addTranscript('A fresh reply [with normal brackets].', 'en-NZ');
      expect(reply.message!.text, 'A fresh reply [with normal brackets].');
    },
  );
}
