import 'package:app/domain/models/models.dart';
import 'package:app/infrastructure/short_cue_builder.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ShortCueBuilder', () {
    test('matches hyphenated token against split wordTiming parts', () {
      const line = 'So you would change the whole strategy mid-way?';
      final cues = ShortCueBuilder.build(
        mediaItemId: 'media',
        dialogueLines: const [line],
        wordTiming: const [
          WordTiming(word: 'So', startMs: 16440, endMs: 16710),
          WordTiming(word: 'you', startMs: 16710, endMs: 16860),
          WordTiming(word: 'would', startMs: 16860, endMs: 17010),
          WordTiming(word: 'change', startMs: 17010, endMs: 17430),
          WordTiming(word: 'the', startMs: 17430, endMs: 17520),
          WordTiming(word: 'whole', startMs: 17520, endMs: 17790),
          WordTiming(word: 'strategy', startMs: 17790, endMs: 18300),
          WordTiming(word: 'mid', startMs: 18300, endMs: 18480),
          WordTiming(word: 'way', startMs: 18480, endMs: 18810),
        ],
        parentCues: [
          Cue(
            id: 'media-4',
            startTimeMs: 16440,
            endTimeMs: 18810,
            originalText: line,
            translatedText: '',
          ),
        ],
      );

      expect(cues, hasLength(1));
      expect(cues.first.originalText, line);
      expect(cues.first.startTimeMs, 16440);
      expect(cues.first.endTimeMs, 18810);
    });

    test('uses next word boundary when a token is missing in wordTiming', () {
      const line =
          "Yes, Ma'am. It's better to pivot than stick to a plan that fails.";
      final cues = ShortCueBuilder.build(
        mediaItemId: 'media',
        dialogueLines: const [line],
        wordTiming: const [
          WordTiming(word: 'Yes', startMs: 19320, endMs: 19650),
          WordTiming(word: "It's", startMs: 20160, endMs: 20400),
          WordTiming(word: 'better', startMs: 20400, endMs: 20670),
          WordTiming(word: 'to', startMs: 20670, endMs: 20760),
          WordTiming(word: 'pivot', startMs: 20760, endMs: 21030),
          WordTiming(word: 'than', startMs: 21030, endMs: 21210),
          WordTiming(word: 'stick', startMs: 21210, endMs: 21540),
          WordTiming(word: 'to', startMs: 21540, endMs: 21600),
          WordTiming(word: 'a', startMs: 21600, endMs: 21660),
          WordTiming(word: 'plan', startMs: 21660, endMs: 21900),
          WordTiming(word: 'that', startMs: 21900, endMs: 22080),
          WordTiming(word: 'fails', startMs: 22080, endMs: 22950),
        ],
        parentCues: [
          Cue(
            id: 'media-5',
            startTimeMs: 19320,
            endTimeMs: 22950,
            originalText: line,
            translatedText: '',
          ),
        ],
      );

      expect(cues, hasLength(2));
      expect(cues[0].originalText, "Yes, Ma'am.");
      expect(cues[0].startTimeMs, 19320);
      expect(cues[0].endTimeMs, 20160);
      expect(
        cues[1].originalText,
        "It's better to pivot than stick to a plan that fails.",
      );
      expect(cues[1].startTimeMs, 20160);
      expect(cues[1].endTimeMs, 22950);
    });

    test('keeps baseline behavior for non-hyphen tokens', () {
      const line = 'Thank you.';
      final cues = ShortCueBuilder.build(
        mediaItemId: 'media',
        dialogueLines: const [line],
        wordTiming: const [
          WordTiming(word: 'Thank', startMs: 5250, endMs: 5550),
          WordTiming(word: 'you', startMs: 5550, endMs: 5910),
        ],
        parentCues: [
          Cue(
            id: 'media-1',
            startTimeMs: 5250,
            endTimeMs: 5910,
            originalText: line,
            translatedText: '',
          ),
        ],
      );

      expect(cues, hasLength(1));
      expect(cues.first.startTimeMs, 5250);
      expect(cues.first.endTimeMs, 5910);
      expect(cues.first.originalText, line);
    });

    test('does not split Node.js when there is no whitespace after dot', () {
      const line = 'Node.js powers APIs.';
      final cues = ShortCueBuilder.build(
        mediaItemId: 'media',
        dialogueLines: const [line],
        wordTiming: const [
          WordTiming(word: 'Node.js', startMs: 0, endMs: 120),
          WordTiming(word: 'powers', startMs: 120, endMs: 260),
          WordTiming(word: 'APIs', startMs: 260, endMs: 420),
        ],
        parentCues: [
          Cue(
            id: 'media-2',
            startTimeMs: 0,
            endTimeMs: 420,
            originalText: line,
            translatedText: '',
          ),
        ],
      );

      expect(cues, hasLength(1));
      expect(cues.first.originalText, line);
    });

    test(
      'does not split punctuation run when there is no boundary spacing',
      () {
        const line = 'What?!No way.';
        final cues = ShortCueBuilder.build(
          mediaItemId: 'media',
          dialogueLines: const [line],
          wordTiming: const [
            WordTiming(word: 'WhatNo', startMs: 0, endMs: 220),
            WordTiming(word: 'way', startMs: 220, endMs: 320),
          ],
          parentCues: [
            Cue(
              id: 'media-3',
              startTimeMs: 0,
              endTimeMs: 320,
              originalText: line,
              translatedText: '',
            ),
          ],
        );

        expect(cues, hasLength(1));
        expect(cues.first.originalText, line);
      },
    );

    test('splits punctuation run when followed by whitespace', () {
      const line = 'What?! Yes.';
      final cues = ShortCueBuilder.build(
        mediaItemId: 'media',
        dialogueLines: const [line],
        wordTiming: const [
          WordTiming(word: 'What', startMs: 0, endMs: 120),
          WordTiming(word: 'Yes', startMs: 200, endMs: 320),
        ],
        parentCues: [
          Cue(
            id: 'media-4',
            startTimeMs: 0,
            endTimeMs: 320,
            originalText: line,
            translatedText: '',
          ),
        ],
      );

      expect(cues, hasLength(2));
      expect(cues[0].originalText, 'What?!');
      expect(cues[1].originalText, 'Yes.');
    });

    test('keeps cjk sentence splitting without whitespace', () {
      const line = '你好。谢谢';
      final cues = ShortCueBuilder.build(
        mediaItemId: 'media',
        dialogueLines: const [line],
        wordTiming: const [
          WordTiming(word: '你好', startMs: 0, endMs: 120),
          WordTiming(word: '谢谢', startMs: 140, endMs: 260),
        ],
        parentCues: [
          Cue(
            id: 'media-5',
            startTimeMs: 0,
            endTimeMs: 260,
            originalText: line,
            translatedText: '',
          ),
        ],
      );

      expect(cues, hasLength(2));
      expect(cues[0].originalText, '你好。');
      expect(cues[1].originalText, '谢谢');
    });
  });
}
