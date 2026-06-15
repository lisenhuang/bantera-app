import 'package:app/presentation/practice/attempt_comparison.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('buildAttemptComparison — diff', () {
    test('identical text matches every word', () {
      final result = buildAttemptComparison(
        expectedText: 'the quick brown fox',
        actualText: 'the quick brown fox',
      );

      expect(result.matchedCount, 4);
      expect(result.unexpectedCount, 0);
      expect(result.missingCount, 0);
      expect(result.uncertainCount, 0);
      expect(result.segments.every((s) => s.isMatch), isTrue);
    });

    test('substituted word is unexpected + missing', () {
      final result = buildAttemptComparison(
        expectedText: 'i like coffee',
        actualText: 'i like tea',
      );

      expect(result.matchedCount, 2); // "i", "like"
      expect(result.unexpectedCount, 1); // "tea"
      expect(result.missingCount, 1); // "coffee"
      final tea = result.segments.firstWhere((s) => s.text == 'tea');
      expect(tea.isMatch, isFalse);
    });

    test('dropped word counts as missing only', () {
      final result = buildAttemptComparison(
        expectedText: 'he goes to school',
        actualText: 'he go to school',
      );

      // "go" != "goes" -> one missing (goes), one unexpected (go)
      expect(result.missingCount, 1);
      expect(result.unexpectedCount, 1);
      expect(result.matchedCount, 3); // he, to, school
    });

    test('normalization ignores case and trailing punctuation', () {
      final result = buildAttemptComparison(
        expectedText: 'Hello, world!',
        actualText: 'hello world',
      );

      expect(result.matchedCount, 2);
      expect(result.unexpectedCount, 0);
      expect(result.missingCount, 0);
    });

    test('CJK uses character-level tokenization', () {
      final result = buildAttemptComparison(
        expectedText: '我喜欢咖啡',
        actualText: '我喜欢茶',
      );

      expect(result.joinSegmentsWithSpace, isFalse);
      expect(result.matchedCount, 3); // 我 喜 欢
      expect(result.unexpectedCount, 1); // 茶
      expect(result.missingCount, 2); // 咖 啡
    });
  });

  group('buildAttemptComparison — quote delimiters', () {
    test('quoted phrase in the cue matches the unquoted recognized words', () {
      final result = buildAttemptComparison(
        expectedText: "we should always say 'excuse me.' Can you try saying that?",
        actualText: 'we should always say excuse me can you try saying that',
      );

      // Every content word should match — no different/missing from the quotes.
      expect(result.unexpectedCount, 0);
      expect(result.missingCount, 0);
      final excuse = result.segments.firstWhere((s) => s.text == 'excuse');
      final me = result.segments.firstWhere((s) => s.text == 'me');
      expect(excuse.isMatch, isTrue);
      expect(me.isMatch, isTrue);
    });

    test('curly-quoted phrase also matches', () {
      final result = buildAttemptComparison(
        expectedText: 'say ‘excuse me.’ now',
        actualText: 'say excuse me now',
      );

      expect(result.unexpectedCount, 0);
      expect(result.missingCount, 0);
    });

    test('internal apostrophes (contractions) are preserved and still match', () {
      final result = buildAttemptComparison(
        expectedText: "don't say it's wrong",
        actualText: "don't say it's wrong",
      );

      expect(result.matchedCount, 4);
      expect(result.unexpectedCount, 0);
      expect(result.missingCount, 0);
    });

    test('contraction does not match its non-contracted form', () {
      final result = buildAttemptComparison(
        expectedText: "don't",
        actualText: 'do not',
      );

      // "don't" != "do" and != "not" -> nothing matches.
      expect(result.matchedCount, 0);
    });
  });

  group('buildAttemptComparison — uncertainty', () {
    test('low-confidence matched word is flagged uncertain', () {
      final result = buildAttemptComparison(
        expectedText: 'i like coffee',
        actualText: 'i like coffee',
        actualWordConfidences: const [
          AttemptWordConfidence(text: 'i', confidence: 0.9),
          AttemptWordConfidence(text: 'like', confidence: 0.9),
          AttemptWordConfidence(text: 'coffee', confidence: 0.2),
        ],
      );

      expect(result.uncertainCount, 1);
      final coffee = result.segments.firstWhere((s) => s.text == 'coffee');
      expect(coffee.isMatch, isTrue);
      expect(coffee.isUncertain, isTrue);
      expect(coffee.confidence, 0.2);
    });

    test('confidence of 0 is treated as no-signal and never flags', () {
      final result = buildAttemptComparison(
        expectedText: 'i like coffee',
        actualText: 'i like coffee',
        actualWordConfidences: const [
          AttemptWordConfidence(text: 'i', confidence: 0),
          AttemptWordConfidence(text: 'like', confidence: 0),
          AttemptWordConfidence(text: 'coffee', confidence: 0),
        ],
      );

      expect(result.uncertainCount, 0);
      expect(result.segments.every((s) => s.isUncertain == false), isTrue);
    });

    test('confidence above threshold is not flagged', () {
      final result = buildAttemptComparison(
        expectedText: 'hello world',
        actualText: 'hello world',
        actualWordConfidences: const [
          AttemptWordConfidence(text: 'hello', confidence: 0.95),
          AttemptWordConfidence(text: 'world', confidence: 0.8),
        ],
      );

      expect(result.uncertainCount, 0);
    });

    test('a non-matching word is never marked uncertain', () {
      final result = buildAttemptComparison(
        expectedText: 'i like coffee',
        actualText: 'i like tea',
        actualWordConfidences: const [
          AttemptWordConfidence(text: 'i', confidence: 0.9),
          AttemptWordConfidence(text: 'like', confidence: 0.9),
          AttemptWordConfidence(text: 'tea', confidence: 0.1),
        ],
      );

      final tea = result.segments.firstWhere((s) => s.text == 'tea');
      expect(tea.isMatch, isFalse);
      expect(tea.isUncertain, isFalse);
      expect(result.uncertainCount, 0);
    });

    test('misaligned confidence list is ignored (no flags, safe fallback)', () {
      final result = buildAttemptComparison(
        expectedText: 'one two three',
        actualText: 'one two three',
        // Only two confidences for three tokens -> counts mismatch -> ignored.
        actualWordConfidences: const [
          AttemptWordConfidence(text: 'one', confidence: 0.1),
          AttemptWordConfidence(text: 'two', confidence: 0.1),
        ],
      );

      expect(result.uncertainCount, 0);
      expect(result.segments.every((s) => s.confidence == null), isTrue);
    });

    test('respects a custom uncertainty threshold', () {
      final result = buildAttemptComparison(
        expectedText: 'hello world',
        actualText: 'hello world',
        uncertaintyThreshold: 0.85,
        actualWordConfidences: const [
          AttemptWordConfidence(text: 'hello', confidence: 0.95),
          AttemptWordConfidence(text: 'world', confidence: 0.8),
        ],
      );

      expect(result.uncertainCount, 1); // world (0.8 < 0.85)
    });
  });
}
