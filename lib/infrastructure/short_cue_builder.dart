import '../domain/models/models.dart';

/// Builds shorter practice [Cue]s from [dialogueLines] + [wordTiming] (v2 transcripts).
class ShortCueBuilder {
  ShortCueBuilder._();

  static String _normToken(String w) {
    return w.toLowerCase().replaceAll(RegExp(r'[^a-z0-9\u4e00-\u9fff]'), '');
  }

  static String _normTimingWord(WordTiming w) => _normToken(w.word);

  static List<String> _fragmentsFromLine(String line) {
    final trimmed = line.trim();
    if (trimmed.isEmpty) {
      return const [];
    }
    final re = RegExp(r'[.?!;。？！…；]+');
    if (!re.hasMatch(trimmed)) {
      return [trimmed];
    }
    final out = <String>[];
    var start = 0;
    for (final m in re.allMatches(line)) {
      final piece = line.substring(start, m.end).trim();
      if (piece.isNotEmpty) {
        out.add(piece);
      }
      start = m.end;
    }
    if (start < line.length) {
      final tail = line.substring(start).trim();
      if (tail.isNotEmpty) {
        out.add(tail);
      }
    }
    return out;
  }

  static List<String> _tokensFromFragment(String fragment) {
    return fragment
        .split(RegExp(r'\s+'))
        .map(_normToken)
        .where((t) => t.isNotEmpty)
        .toList();
  }

  static List<Cue> build({
    required String mediaItemId,
    required List<String> dialogueLines,
    required List<WordTiming> wordTiming,
    required List<Cue> parentCues,
  }) {
    var wPos = 0;
    final out = <Cue>[];
    var syntheticIndex = 0;

    for (var lineIdx = 0; lineIdx < dialogueLines.length; lineIdx++) {
      final line = dialogueLines[lineIdx];
      final parent = lineIdx < parentCues.length
          ? parentCues[lineIdx]
          : (parentCues.isNotEmpty ? parentCues.last : null);
      if (parent == null) {
        continue;
      }

      for (final frag in _fragmentsFromLine(line)) {
        final tokens = _tokensFromFragment(frag);
        if (tokens.isEmpty) {
          continue;
        }

        int? startMs;
        int? endMs;
        var matched = 0;

        for (final tok in tokens) {
          var foundAt = -1;
          for (var j = wPos; j < wordTiming.length; j++) {
            if (_normTimingWord(wordTiming[j]) == tok) {
              foundAt = j;
              break;
            }
          }
          if (foundAt < 0) {
            break;
          }
          matched++;
          startMs ??= wordTiming[foundAt].startMs;
          endMs = wordTiming[foundAt].endMs;
          wPos = foundAt + 1;
        }

        if (startMs == null) {
          continue;
        }
        if (matched < tokens.length) {
          endMs = parent.endTimeMs;
        }
        final end = endMs ?? startMs;
        final safeEnd = end < startMs ? startMs : end;

        out.add(
          Cue(
            id: '$mediaItemId-s$syntheticIndex',
            startTimeMs: startMs,
            endTimeMs: safeEnd,
            originalText: frag,
            translatedText: '',
          ),
        );
        syntheticIndex++;
      }
    }

    return out;
  }
}
