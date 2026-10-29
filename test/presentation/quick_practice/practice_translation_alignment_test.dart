import 'package:app/presentation/practice/subtitle_word_tokens.dart';
import 'package:app/presentation/quick_practice/practice_translation_alignment.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Map<String, Object> link(
  String source,
  String sourcePart,
  String target,
  String targetPart, {
  bool last = false,
}) {
  final sourceStart = last
      ? source.lastIndexOf(sourcePart)
      : source.indexOf(sourcePart);
  final targetStart = last
      ? target.lastIndexOf(targetPart)
      : target.indexOf(targetPart);
  return {
    'sourceStart': sourceStart,
    'sourceEnd': sourceStart + sourcePart.length,
    'sourceText': sourcePart,
    'targetStart': targetStart,
    'targetEnd': targetStart + targetPart.length,
    'targetText': targetPart,
  };
}

void main() {
  const source = 'Kei hea te teihana?';
  const target = 'Where is the station?';
  test(
    'a selected Māori word highlights its English phrase without changing text',
    () {
      final mappings = [
        link(source, 'Kei hea', target, 'Where is'),
        link(source, 'te teihana', target, 'the station'),
      ];
      final ranges = practiceTranslationHighlights(
        source: source,
        target: target,
        alignments: mappings,
        selected: const SubtitleWordToken(4, 7, 'hea'),
      );
      expect(ranges, [const TextRange(start: 0, end: 8)]);
      final spans = practiceTranslationSpans(target, ranges);
      expect(TextSpan(children: spans).toPlainText(), target);
      expect(spans.first.text, 'Where is');
      expect(spans.first.style!.fontWeight, FontWeight.w700);
      expect(spans.first.style!.decoration, TextDecoration.underline);
      expect(spans.first.style!.backgroundColor, isNull);
      expect(spans.first.style!.background, isNull);
    },
  );
  test('repeated words use exact occurrences, including reordered targets', () {
    const original = 'He waka, he waka.';
    const english = 'A canoe, a canoe.';
    final mappings = [
      link(original, 'waka', english, 'canoe'),
      link(original, 'waka', english, 'canoe', last: true),
    ];
    final ranges = practiceTranslationHighlights(
      source: original,
      target: english,
      alignments: mappings,
      selected: const SubtitleWordToken(12, 16, 'waka'),
    );
    expect(ranges, [const TextRange(start: 11, end: 16)]);
  });
  test(
    'stale text, partial words, malformed ranges and unknown tokens do not guess',
    () {
      final valid = link(source, 'teihana', target, 'station');
      for (final bad in [
        {...valid, 'sourceText': 'another'},
        {...valid, 'targetText': 'stations'},
        {...valid, 'targetStart': -1},
        {...valid, 'targetEnd': 1000},
        {...valid, 'sourceStart': 12, 'sourceText': 'eihana'},
        {...valid, 'targetStart': 14, 'targetText': 'tation'},
        {...valid, 'sourceStart': 11.0},
        null,
        'bad',
      ]) {
        expect(
          practiceTranslationHighlights(
            source: source,
            target: target,
            alignments: [bad],
            selected: const SubtitleWordToken(11, 18, 'teihana'),
          ),
          isEmpty,
        );
      }
      expect(
        practiceTranslationHighlights(
          source: source,
          target: target,
          alignments: [valid],
          selected: const SubtitleWordToken(11, 18, 'wrong'),
        ),
        isEmpty,
      );
      expect(
        practiceTranslationHighlights(
          source: source,
          target: target,
          alignments: null,
          selected: const SubtitleWordToken(11, 18, 'teihana'),
        ),
        isEmpty,
      );
    },
  );
  test('UTF-16 emoji prefixes and macrons preserve exact ranges', () {
    const original = '🌿 Tēnā koe.';
    const english = '🌿 Hello to you.';
    final mapping = link(original, 'Tēnā', english, 'Hello');
    final start = original.indexOf('Tēnā');
    expect(
      practiceTranslationHighlights(
        source: original,
        target: english,
        alignments: [mapping],
        selected: SubtitleWordToken(start, start + 4, 'Tēnā'),
      ),
      [const TextRange(start: 3, end: 8)],
    );
  });
  test('multiple English spans are merged without duplication', () {
    final mapping = link(source, 'Kei hea', target, 'Where is');
    expect(
      practiceTranslationHighlights(
        source: source,
        target: target,
        alignments: [
          mapping,
          mapping,
          link(source, 'Kei hea', target, 'Where'),
        ],
        selected: const SubtitleWordToken(0, 3, 'Kei'),
      ),
      [const TextRange(start: 0, end: 8)],
    );
  });
}
