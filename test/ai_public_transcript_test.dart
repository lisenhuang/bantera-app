import 'package:flutter_test/flutter_test.dart';
import 'package:app/infrastructure/ai/ai_history_store.dart';
import 'package:app/presentation/chats/ai/ai_voice_reply_state.dart';

void main() {
  test('escaped punctuation is repaired in streamed and restored AI text', () {
    const raw =
        r'Right, that is what you\u0027re after. \u201CLight soup\u201D.';
    const readable = "Right, that is what you're after. “Light soup”.";
    for (var split = 0; split <= raw.length; split++) {
      final reply = AiVoiceReplyState();
      reply.addTranscript(raw.substring(0, split), 'en-NZ');
      reply.addTranscript(raw.substring(split), 'en-NZ');
      expect(reply.message!.text, readable);
      final restored = AiMessage.fromJson(reply.message!.toJson());
      expect(restored.text, readable);
    }
    expect(AiMessage(role: 'user', text: raw).text, raw);
  });
  test('punctuation repair preserves code samples and other escapes', () {
    const code = r'Use `\u0027`, keep C:\new\test and \u0000 unchanged.';
    expect(AiMessage(role: 'model', text: code).text, code);
    const fenced = '```json\n{"text": r"\\u0027"}\n```';
    expect(AiMessage(role: 'model', text: fenced).text, fenced);
    const incomplete = '```json\n{"text": r"\\u0027"}';
    expect(AiMessage(role: 'model', text: incomplete).text, incomplete);
  });
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
