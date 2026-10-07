import 'package:flutter_test/flutter_test.dart';
import 'package:app/presentation/chats/chat_recording_countdown.dart';

void main() {
  testWidgets(
    '180 seconds counts down, expires once, and cancellation prevents sending',
    (tester) async {
      var elapsed = 0, remaining = -1, sends = 0;
      final timer = ChatRecordingCountdown(
        elapsedMilliseconds: () => elapsed,
        onTick: (value) => remaining = value,
        onExpired: () => sends++,
      );
      timer.start();
      expect(remaining, 180);
      elapsed = 179000;
      await tester.pump(const Duration(milliseconds: 250));
      expect(remaining, 1);
      expect(sends, 0);
      elapsed = 180100; // Timer delayed beyond the deadline still sends once.
      await tester.pump(const Duration(seconds: 2));
      expect(remaining, 0);
      expect(sends, 1);
      await tester.pump(const Duration(seconds: 2));
      expect(sends, 1);
      elapsed = 0;
      timer.start();
      expect(remaining, 180);
      timer.cancel();
      elapsed = 181000;
      await tester.pump(const Duration(seconds: 2));
      expect(sends, 1);
    },
  );
}
