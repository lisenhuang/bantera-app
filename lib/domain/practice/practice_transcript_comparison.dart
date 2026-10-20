import 'package:characters/characters.dart';
import 'practice_answer_matcher.dart';

class TranscriptRange {
  const TranscriptRange(this.start, this.end);
  final int start, end;
}

class _Unit {
  const _Unit(this.key, this.range);
  final String key;
  final TranscriptRange range;
}

/// Display-only differences. Never changes grading or rewrites recognized text.
class PracticeTranscriptComparison {
  const PracticeTranscriptComparison(this.choice, this.heard, this.reference);
  final int? choice;
  final List<TranscriptRange> heard, reference;

  static PracticeTranscriptComparison compare(
    String transcript,
    List<String> choices,
    String locale, {
    int? matchedChoice,
    List<String> uncertainWords = const [],
  }) {
    final actual = _units(transcript, locale);
    final options = choices.map((s) => _units(s, locale)).toList();
    int? choice =
        matchedChoice != null &&
            matchedChoice >= 0 &&
            matchedChoice < choices.length
        ? matchedChoice
        : null;
    if (choice == null && actual.isNotEmpty && options.length == 2) {
      final scores = options.map((target) {
        final pairs = _align(actual, target);
        return target.isEmpty
            ? 0.0
            : 2 * pairs.length / (actual.length + target.length);
      }).toList();
      final best = scores[0] > scores[1] ? 0 : 1;
      if (scores[best] >= .55 && scores[best] - scores[1 - best] >= .2) {
        choice = best;
      }
    }
    final heard = <TranscriptRange>[], reference = <TranscriptRange>[];
    if (choice != null &&
        PracticeAnswerMatcher.normalise(transcript, locale) !=
            PracticeAnswerMatcher.normalise(choices[choice], locale)) {
      final expected = options[choice];
      final pairs = _align(actual, expected);
      final matchedActual = pairs.map((p) => p.$1).toSet();
      final matchedExpected = pairs.map((p) => p.$2).toSet();
      heard.addAll([
        for (var i = 0; i < actual.length; i++)
          if (!matchedActual.contains(i)) actual[i].range,
      ]);
      reference.addAll([
        for (var i = 0; i < expected.length; i++)
          if (!matchedExpected.contains(i)) expected[i].range,
      ]);
    }
    final uncertain = uncertainWords
        .expand((s) => _units(s, locale))
        .map((u) => u.key)
        .toSet();
    heard.addAll(
      actual.where((u) => uncertain.contains(u.key)).map((u) => u.range),
    );
    return PracticeTranscriptComparison(choice, heard, reference);
  }

  static List<_Unit> _units(String text, String locale) {
    final units = <_Unit>[];
    final compact = const [
      'zh',
      'yue',
      'ja',
      'ko',
      'th',
    ].contains(locale.split('-').first);
    void add(String raw, int start, int end) {
      for (final key in PracticeAnswerMatcher.normalise(
        raw,
        locale,
      ).split(' ')) {
        if (key.isNotEmpty) units.add(_Unit(key, TranscriptRange(start, end)));
      }
    }

    if (compact) {
      var offset = 0;
      for (final grapheme in text.characters) {
        add(grapheme, offset, offset + grapheme.length);
        offset += grapheme.length;
      }
    } else {
      for (final match in RegExp(
        r"[\p{L}\p{M}\p{N}]+(?:['’][\p{L}\p{M}\p{N}]+)*",
        unicode: true,
      ).allMatches(text)) {
        add(match.group(0)!, match.start, match.end);
      }
    }
    // Limit diagnostic work for unexpectedly long recognition output.
    return units.take(400).toList();
  }

  static List<(int, int)> _align(List<_Unit> a, List<_Unit> b) {
    final lengths = List.generate(
      a.length + 1,
      (_) => List.filled(b.length + 1, 0),
    );
    for (var i = a.length - 1; i >= 0; i--) {
      for (var j = b.length - 1; j >= 0; j--) {
        lengths[i][j] = a[i].key == b[j].key
            ? 1 + lengths[i + 1][j + 1]
            : (lengths[i + 1][j] > lengths[i][j + 1]
                  ? lengths[i + 1][j]
                  : lengths[i][j + 1]);
      }
    }
    final result = <(int, int)>[];
    var i = 0, j = 0;
    while (i < a.length && j < b.length) {
      if (a[i].key == b[j].key) {
        result.add((i++, j++));
      } else if (lengths[i + 1][j] >= lengths[i][j + 1]) {
        i++;
      } else {
        j++;
      }
    }
    return result;
  }
}
