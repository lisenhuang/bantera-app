import 'package:app/presentation/chats/ai/ai_listening_progress.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'only rendered frames count, and interruptions discard unplayed words',
    () {
      final progress = AiListeningProgress();
      progress.add(0, 24000, 10, 'en-NZ');
      expect(progress.advance(0), isEmpty);
      expect(progress.advance(12000), {'en-NZ': 5});
      expect(progress.advance(12000), isEmpty);
      progress.clear();
      progress.add(12000, 36000, 8, 'en-NZ');
      expect(progress.advance(24000), {'en-NZ': 4});
      expect(progress.advance(36000), {'en-NZ': 4});
      expect(progress.advance(48000), isEmpty);
    },
  );
}
