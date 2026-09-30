import 'package:app/domain/activity/lesson_completion_tracker.dart';
import 'package:app/domain/models/models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final cues = [
    for (var i = 0; i < 3; i++)
      Cue(
        id: '$i',
        startTimeMs: i * 2000,
        endTimeMs: (i + 1) * 2000,
        originalText: 'A practice cue',
        translatedText: '',
      ),
  ];
  final start = DateTime(2026, 10, 1, 12);

  test('Continuous playback completes every original cue exactly once', () {
    final tracker = LessonCompletionTracker(cues)..seek(0, at: start);
    final completed = <String>{};
    for (var ms = 500; ms <= 6000; ms += 500) {
      completed.addAll(
        tracker.advance(
          ms,
          playing: true,
          at: start.add(Duration(milliseconds: ms)),
        ),
      );
    }
    expect(completed, tracker.requiredCueKeys);
    tracker.seek(0, at: start.add(const Duration(seconds: 10)));
    expect(
      tracker.advance(
        6000,
        playing: true,
        at: start.add(const Duration(seconds: 16)),
      ),
      isEmpty,
    );
  });

  test(
    'Seeking to the last cue or an unexpected jump does not finish a lesson',
    () {
      final tracker = LessonCompletionTracker(cues)..seek(0, at: start);
      expect(
        tracker.advance(
          6000,
          playing: true,
          at: start.add(const Duration(milliseconds: 200)),
        ),
        isEmpty,
      );
      tracker.seek(4000, at: start);
      final completed = tracker.advance(
        6000,
        playing: true,
        at: start.add(const Duration(seconds: 2)),
      );
      expect(completed, {'2:4000:6000'});
      expect(completed.containsAll(tracker.requiredCueKeys), isFalse);
    },
  );

  test(
    'Pauses and repeated portions preserve coverage without double counting',
    () {
      final tracker = LessonCompletionTracker([cues.first])..seek(0, at: start);
      expect(
        tracker.advance(
          1000,
          playing: true,
          at: start.add(const Duration(seconds: 1)),
        ),
        isEmpty,
      );
      tracker.seek(0, at: start.add(const Duration(seconds: 2)));
      expect(
        tracker.advance(
          1000,
          playing: true,
          at: start.add(const Duration(seconds: 3)),
        ),
        isEmpty,
      );
      expect(
        tracker.advance(
          1000,
          playing: false,
          at: start.add(const Duration(seconds: 8)),
        ),
        isEmpty,
      );
      tracker.seek(1000, at: start.add(const Duration(seconds: 9)));
      expect(
        tracker.advance(
          2000,
          playing: true,
          at: start.add(const Duration(seconds: 10)),
        ),
        tracker.requiredCueKeys,
      );
    },
  );

  test(
    'Short sentence boundaries and faster playback can finish an original cue',
    () {
      final tracker = LessonCompletionTracker([cues.first])..seek(0, at: start);
      expect(
        tracker.advance(
          980,
          playing: true,
          speed: 2,
          at: start.add(const Duration(milliseconds: 490)),
        ),
        isEmpty,
      );
      tracker.seek(1000, at: start.add(const Duration(seconds: 1)));
      expect(
        tracker.advance(
          2000,
          playing: true,
          speed: 2,
          at: start.add(const Duration(milliseconds: 1500)),
        ),
        tracker.requiredCueKeys,
      );
    },
  );
}
