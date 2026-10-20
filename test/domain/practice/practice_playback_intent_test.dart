import 'package:app/domain/practice/practice_playback_intent.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('opening and retrying initial preparation remain silent', () {
    final intent = PracticePlaybackIntent();
    expect(intent.take('first'), isFalse);
    expect(intent.take('first'), isFalse);
  });
  test('explicit Next survives preparation polls and plays only once', () {
    final intent = PracticePlaybackIntent()..next('next');
    expect(intent.take('obsolete'), isFalse);
    expect(intent.take('next'), isTrue);
    expect(intent.take('next'), isFalse);
  });
  test('leaving, backgrounding or a call cancels pending autoplay', () {
    for (final reason in ['tab exit', 'background', 'call', 'profile change']) {
      final intent = PracticePlaybackIntent()..next('next');
      intent.cancel();
      expect(intent.take('next'), isFalse, reason: reason);
      intent.next('later');
      expect(intent.take('later'), isTrue);
    }
  });
}
