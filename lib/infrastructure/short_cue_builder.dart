import '../domain/models/models.dart';

// Placeholder (U+FFFE, guaranteed non-text) swapped in for abbreviation dots
// before splitting so they are never treated as sentence boundaries.
const _kAbbrDot = '\uFFFE';

// Titles and honorifics for en / fr / de / it / es whose trailing period
// should not be treated as a sentence boundary.
final RegExp _kAbbrRe = RegExp(
  r'\b(Mr|Mrs|Ms|Miss|Dr|Prof|Sr|Jr|Rev|Gen|Capt|Lt|Col|Sgt|Cpl|Maj|'
  r'Adm|Gov|Pres|St|Ste|'
  r'M|Mme|Mlle|MM|Me|Mgr|Gal|'
  r'Hr|Fr|Nr|'
  r'Sig|Dott|Avv|Ing|'
  r'Sra|Srta|Dra|Lic|Gral'
  r')\.',
  caseSensitive: false,
);

final RegExp _kHyphenSplitRe = RegExp(
  r'[-\u2010\u2011\u2012\u2013\u2014\u2212]+',
);

/// Builds shorter practice [Cue]s from [dialogueLines] + [wordTiming] (v2 transcripts).
class ShortCueBuilder {
  ShortCueBuilder._();

  static String _normToken(String w) {
    return w.toLowerCase().replaceAll(RegExp(r'[^a-z0-9\u4e00-\u9fff]'), '');
  }

  static String _normTimingWord(WordTiming w) => _normToken(w.word);

  static List<String> _fragmentsFromLine(String line) {
    final trimmed = line.trim();
    if (trimmed.isEmpty) return const [];

    // Replace abbreviation dots with placeholder so the splitter ignores them.
    final protected = trimmed.replaceAllMapped(
      _kAbbrRe,
      (m) => '${m.group(1)!}$_kAbbrDot',
    );

    final re = RegExp(r'[.?!;。？！…；]+');
    if (!re.hasMatch(protected)) {
      return [trimmed];
    }

    final out = <String>[];
    var start = 0;
    for (final m in re.allMatches(protected)) {
      final piece = protected.substring(start, m.end).trim();
      if (piece.isNotEmpty) {
        out.add(piece.replaceAll(_kAbbrDot, '.'));
      }
      start = m.end;
    }
    if (start < protected.length) {
      final tail = protected.substring(start).trim();
      if (tail.isNotEmpty) {
        out.add(tail.replaceAll(_kAbbrDot, '.'));
      }
    }
    return out;
  }

  static List<({String raw, String normalized})> _tokensFromFragment(
    String fragment,
  ) {
    return fragment
        .split(RegExp(r'\s+'))
        .map((raw) => (raw: raw, normalized: _normToken(raw)))
        .where((token) => token.normalized.isNotEmpty)
        .toList();
  }

  static int _findWordTimingIndex(
    List<WordTiming> wordTiming,
    int from,
    String token,
  ) {
    for (var i = from; i < wordTiming.length; i++) {
      if (_normTimingWord(wordTiming[i]) == token) {
        return i;
      }
    }
    return -1;
  }

  static List<String> _splitHyphenTokenParts(String rawToken) {
    return rawToken
        .split(_kHyphenSplitRe)
        .map(_normToken)
        .where((part) => part.isNotEmpty)
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

        for (final token in tokens) {
          final merged = token.normalized;
          var foundAt = _findWordTimingIndex(wordTiming, wPos, merged);
          if (foundAt >= 0) {
            matched++;
            startMs ??= wordTiming[foundAt].startMs;
            endMs = wordTiming[foundAt].endMs;
            wPos = foundAt + 1;
            continue;
          }

          final splitParts = _splitHyphenTokenParts(token.raw);
          if (splitParts.length > 1) {
            var stagedWPos = wPos;
            var stagedStartMs = startMs;
            var stagedEndMs = endMs;
            var allPartsMatched = true;

            for (final part in splitParts) {
              foundAt = _findWordTimingIndex(wordTiming, stagedWPos, part);
              if (foundAt < 0) {
                allPartsMatched = false;
                break;
              }
              stagedStartMs ??= wordTiming[foundAt].startMs;
              stagedEndMs = wordTiming[foundAt].endMs;
              stagedWPos = foundAt + 1;
            }

            if (allPartsMatched) {
              matched++;
              startMs = stagedStartMs;
              endMs = stagedEndMs;
              wPos = stagedWPos;
              continue;
            }
          }

          break;
        }

        if (startMs == null) {
          continue;
        }
        if (matched < tokens.length) {
          // A token in this fragment is missing from wordTiming (for example
          // TTS drops short words). Cap endMs at the next unconsumed word so
          // this cue does not bleed into the following fragment's audio.
          endMs = wPos < wordTiming.length
              ? wordTiming[wPos].startMs
              : parent.endTimeMs;
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
