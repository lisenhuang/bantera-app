import 'package:app/infrastructure/ai/ai_emoji_tool.dart';
import 'package:app/infrastructure/ai/ai_history_store.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'flags, joined emojis, skin tones and keycaps survive history and context',
    () {
      final message = AiMessage(role: 'model', text: 'Here are the flags.');
      final values = ['🇮🇪', '🇮🇳', '👩🏽‍💻', '👨‍👩‍👧‍👦', '1️⃣', '❤️'];
      expect(
        AiEmojiTool.deliver({'emojis': values}, message)['delivered'],
        true,
      );
      // A retried tool call must not duplicate the visible emojis.
      AiEmojiTool.deliver({'emojis': values}, message);
      final restored = AiMessage.fromJson(message.toJson());
      expect(restored.emojis, values);
      final context = AiHistoryStore.contextFor([restored]).single;
      expect(context['text'], contains('[Shared emojis: 🇮🇪 🇮🇳'));
      expect(context['resumeText'], 'Here are the flags.');
    },
  );

  test(
    'reject names, URLs, control characters and unbounded payloads atomically',
    () {
      final message = AiMessage(role: 'model');
      for (final values in [
        [],
        ['Ireland'],
        ['https://example.com'],
        ['🙂\n'],
        ['🇮🇪', 'bad'],
        List.filled(13, '🙂'),
        ['🙂' * 40],
      ]) {
        expect(
          AiEmojiTool.deliver({'emojis': values}, message)['delivered'],
          false,
        );
        expect(message.emojis, isEmpty);
      }
      expect(AiEmojiTool.deliver(null, message)['delivered'], false);
    },
  );
}
