import 'package:flutter_test/flutter_test.dart';
import 'package:app/domain/practice/practice_transcript_comparison.dart';

void main() {
  List<String> parts(String text, List<TranscriptRange> ranges) =>
      ranges.map((r) => text.substring(r.start, r.end)).toSet().toList();
  test('highlights a different word while retaining original offsets', () {
    const text = '  It’s next to the bark!  ';
    final result = PracticeTranscriptComparison.compare(text, [
      'It’s next to the bank.',
      'It opens at nine.',
    ], 'en-NZ');
    expect(result.choice, 0);
    expect(parts(text, result.heard), ['bark']);
    expect(parts('It’s next to the bank.', result.reference), ['bank']);
  });
  test('missing negation appears only in the reference', () {
    final result = PracticeTranscriptComparison.compare('I do want tea.', [
      'I do not want tea.',
      'It costs five dollars.',
    ], 'en-NZ');
    expect(result.heard, isEmpty);
    expect(parts('I do not want tea.', result.reference), ['not']);
  });
  test('equivalent contractions are not highlighted', () {
    final result = PracticeTranscriptComparison.compare(
      'It is next to the bank.',
      ['It’s next to the bank.', 'It opens at nine.'],
      'en-NZ',
      matchedChoice: 0,
    );
    expect(result.heard, isEmpty);
    expect(result.reference, isEmpty);
  });
  test('uncertain words remain visible even with exact text', () {
    final result = PracticeTranscriptComparison.compare(
      'I am Sam.',
      ['I am Sam.', 'I am from Wellington.'],
      'en-NZ',
      uncertainWords: ['Sam'],
    );
    expect(parts('I am Sam.', result.heard), ['Sam']);
  });
  test('does not invent a reference for ties or unrelated speech', () {
    expect(
      PracticeTranscriptComparison.compare('At the', [
        'At the station.',
        'At the market.',
      ], 'en-NZ').choice,
      isNull,
    );
    expect(
      PracticeTranscriptComparison.compare('Bananas', [
        'At the station.',
        'Tomorrow.',
      ], 'en-NZ').choice,
      isNull,
    );
  });
  test(
    'compares the spoken wrong choice rather than accusing pronunciation',
    () {
      final result = PracticeTranscriptComparison.compare(
        'Tomorrow.',
        ['At the station.', 'Tomorrow.'],
        'en-NZ',
        matchedChoice: 1,
      );
      expect(result.heard, isEmpty);
      expect(result.reference, isEmpty);
    },
  );
  test('Chinese missing character and Arabic word use intact source text', () {
    final chinese = PracticeTranscriptComparison.compare('我想喝茶', [
      '我不想喝茶',
      '明天见',
    ], 'zh-CN');
    expect(parts('我不想喝茶', chinese.reference), ['不']);
    final arabic = PracticeTranscriptComparison.compare(
      'اسمي علي',
      ['اسمي سام', 'أنا من مصر'],
      'ar-SA',
      matchedChoice: 0,
    );
    expect(parts('اسمي علي', arabic.heard), ['علي']);
  });
  test('empty transcript has no fabricated comparison', () {
    final result = PracticeTranscriptComparison.compare('', [
      'Yes.',
      'No.',
    ], 'en');
    expect(result.choice, isNull);
    expect(result.heard, isEmpty);
  });
}
