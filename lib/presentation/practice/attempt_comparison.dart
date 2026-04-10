import 'package:characters/characters.dart';

/// Result of comparing expected cue text to a transcribed attempt.
class AttemptComparisonResult {
  const AttemptComparisonResult({
    required this.transcriptText,
    required this.segments,
    required this.matchedCount,
    required this.unexpectedCount,
    required this.missingCount,
    this.joinSegmentsWithSpace = true,
  });

  final String transcriptText;
  final List<DiffSegment> segments;
  final int matchedCount;
  final int unexpectedCount;
  final int missingCount;

  /// False for CJK character-level diff — inserting spaces would break Chinese.
  final bool joinSegmentsWithSpace;
}

class DiffSegment {
  const DiffSegment({required this.text, required this.isMatch});

  final String text;
  final bool isMatch;
}

class DiffToken {
  const DiffToken({required this.display, required this.normalized});

  final String display;
  final String normalized;
}

/// Builds token-level / character-level diff for shadowing feedback.
AttemptComparisonResult buildAttemptComparison({
  required String expectedText,
  required String actualText,
}) {
  final expectedClean = _stripInvisibleSeparators(expectedText.trim());
  final actualClean = _stripInvisibleSeparators(actualText.trim());
  final useCharacterTokens =
      _containsCjk(expectedClean) || _containsCjk(actualClean);

  final expectedTokens = _tokenize(
    expectedClean,
    useCharacterTokens: useCharacterTokens,
  );
  final actualTokens = _tokenize(
    actualClean,
    useCharacterTokens: useCharacterTokens,
  );

  final expComp = _comparableTokensForLcs(expectedTokens);
  final actComp = _comparableTokensForLcs(actualTokens);
  final lcs = _longestCommonSubsequence(expComp.norms, actComp.norms);

  final matchedActualOriginalIndexes = <int>{};
  for (final pair in lcs) {
    matchedActualOriginalIndexes.add(actComp.sourceIndexes[pair.$2]);
  }

  final segments = <DiffSegment>[];
  for (var i = 0; i < actualTokens.length; i += 1) {
    final punctOnly = actualTokens[i].normalized.isEmpty;
    segments.add(
      DiffSegment(
        text: actualTokens[i].display,
        isMatch: punctOnly || matchedActualOriginalIndexes.contains(i),
      ),
    );
  }

  final contentMatches = lcs.length;
  final contentUnexpected = actComp.norms.length - contentMatches;
  final contentMissing = expComp.norms.length - contentMatches;

  return AttemptComparisonResult(
    transcriptText: actualText,
    segments: segments,
    matchedCount: contentMatches,
    unexpectedCount: contentUnexpected,
    missingCount: contentMissing,
    joinSegmentsWithSpace: !useCharacterTokens,
  );
}

List<DiffToken> _tokenize(
  String text, {
  required bool useCharacterTokens,
}) {
  if (useCharacterTokens) {
    return Characters(text)
        .map(
          (g) => DiffToken(
            display: g,
            normalized: _normalizeGraphemeForCompare(g),
          ),
        )
        .toList(growable: false);
  }

  return text
      .trim()
      .split(RegExp(r'\s+'))
      .where((token) => token.trim().isNotEmpty)
      .map((token) => DiffToken(display: token, normalized: _normalizeToken(token)))
      .toList(growable: false);
}

String _normalizeToken(String token) {
  var t = _normalizeConfusableQuotesForTokenCompare(token.trim());
  t = t.toLowerCase();
  t = t.replaceAll(
    RegExp(r'^[\.,!?:;"“”‘’()\[\]{}]+|[\.,!?:;"“”‘’()\[\]{}]+$'),
    '',
  );
  return _stripIgnorableForComparison(t);
}

({List<String> norms, List<int> sourceIndexes}) _comparableTokensForLcs(
  List<DiffToken> tokens,
) {
  final norms = <String>[];
  final sourceIndexes = <int>[];
  for (var i = 0; i < tokens.length; i += 1) {
    final n = tokens[i].normalized;
    if (n.isEmpty) {
      continue;
    }
    norms.add(n);
    sourceIndexes.add(i);
  }
  return (norms: norms, sourceIndexes: sourceIndexes);
}

List<(int, int)> _longestCommonSubsequence(
  List<String> expected,
  List<String> actual,
) {
  final rows = expected.length + 1;
  final cols = actual.length + 1;
  final dp = List.generate(rows, (_) => List.filled(cols, 0));

  for (var i = expected.length - 1; i >= 0; i -= 1) {
    for (var j = actual.length - 1; j >= 0; j -= 1) {
      if (expected[i] == actual[j]) {
        dp[i][j] = dp[i + 1][j + 1] + 1;
      } else {
        dp[i][j] = dp[i + 1][j] >= dp[i][j + 1]
            ? dp[i + 1][j]
            : dp[i][j + 1];
      }
    }
  }

  final matches = <(int, int)>[];
  var i = 0;
  var j = 0;
  while (i < expected.length && j < actual.length) {
    if (expected[i] == actual[j]) {
      matches.add((i, j));
      i += 1;
      j += 1;
    } else if (dp[i + 1][j] >= dp[i][j + 1]) {
      i += 1;
    } else {
      j += 1;
    }
  }

  return matches;
}

String _stripInvisibleSeparators(String s) {
  return s.replaceAll(RegExp(r'[\u200B-\u200D\uFEFF\u2060]'), '');
}

bool _containsCjk(String s) {
  for (final r in s.runes) {
    if (_isCjkKanaHangulOrFullwidthPunctRune(r)) {
      return true;
    }
  }
  return false;
}

bool _isCjkKanaHangulOrFullwidthPunctRune(int r) {
  return (r >= 0x2E80 && r <= 0x9FFF) ||
      (r >= 0xA960 && r <= 0xA97F) ||
      (r >= 0xAC00 && r <= 0xD7AF) ||
      (r >= 0xF900 && r <= 0xFAFF) ||
      (r >= 0xFE10 && r <= 0xFE19) ||
      (r >= 0xFE30 && r <= 0xFE4F) ||
      (r >= 0xFF00 && r <= 0xFFEF) ||
      (r >= 0x1B000 && r <= 0x1B122) ||
      (r >= 0x20000 && r <= 0x3134F);
}

String _normalizeGraphemeForCompare(String grapheme) {
  var t = _normalizeConfusableQuotesForTokenCompare(grapheme);
  t = t.toLowerCase();
  final mapped = _fullwidthToHalfwidthForCompare(t);
  return _stripIgnorableForComparison(mapped.trim());
}

String _stripIgnorableForComparison(String t) {
  if (t.isEmpty) {
    return t;
  }
  final b = StringBuffer();
  for (final g in Characters(t)) {
    if (!_isIgnorableForComparisonGrapheme(g)) {
      b.write(g);
    }
  }
  return b.toString();
}

bool _isIgnorableForComparisonGrapheme(String g) {
  if (g.isEmpty) {
    return true;
  }
  if (g == "'" ||
      g == '-' ||
      g == '\u2010' ||
      g == '\u2011' ||
      g == '\u2013') {
    return false;
  }
  for (final r in g.runes) {
    if (_isLetterDigitOrIdeographOrKanaRune(r)) {
      return false;
    }
  }
  return true;
}

bool _isLetterDigitOrIdeographOrKanaRune(int r) {
  if ((r >= 0x30 && r <= 0x39) ||
      (r >= 0x41 && r <= 0x5A) ||
      (r >= 0x61 && r <= 0x7A)) {
    return true;
  }
  if ((r >= 0x00C0 && r <= 0x024F) || (r >= 0x1E00 && r <= 0x1EFF)) {
    return true;
  }
  if ((r >= 0x0370 && r <= 0x052F) || (r >= 0x0400 && r <= 0x052F)) {
    return true;
  }
  if ((r >= 0x0600 && r <= 0x06FF) || (r >= 0x0590 && r <= 0x05FF)) {
    return true;
  }
  if (r >= 0x0900 && r <= 0x0FFF) {
    return true;
  }
  if (r >= 0x0E00 && r <= 0x109F) {
    return true;
  }
  if (r >= 0x1200 && r <= 0x137F) {
    return true;
  }
  if (r >= 0x10A0 && r <= 0x10FF) {
    return true;
  }
  if ((r >= 0x1100 && r <= 0x11FF) ||
      (r >= 0x3130 && r <= 0x318F) ||
      (r >= 0xA960 && r <= 0xA97F) ||
      (r >= 0xAC00 && r <= 0xD7AF)) {
    return true;
  }
  if ((r >= 0x3040 && r <= 0x30FF) || (r >= 0x31F0 && r <= 0x31FF)) {
    return true;
  }
  if ((r >= 0x2E80 && r <= 0x9FFF) ||
      (r >= 0xF900 && r <= 0xFAFF) ||
      (r >= 0x20000 && r <= 0x3134F)) {
    return true;
  }
  if (r >= 0x0300 && r <= 0x036F) {
    return true;
  }
  return false;
}

const _cjkPunctMap = <String, String>{
  '，': ',',
  '。': '.',
  '、': ',',
  '．': '.',
  '？': '?',
  '！': '!',
  '：': ':',
  '；': ';',
  '（': '(',
  '）': ')',
  '【': '[',
  '】': ']',
  '「': '"',
  '」': '"',
  '『': '"',
  '』': '"',
  '《': '<',
  '》': '>',
  '〈': '<',
  '〉': '>',
  '…': '.',
  '—': '-',
  '–': '-',
  '・': '.',
  '·': '.',
};

String _fullwidthToHalfwidthForCompare(String t) {
  if (t.isEmpty) return t;
  final b = StringBuffer();
  for (final ch in Characters(t)) {
    if (ch.length == 1) {
      final c = ch.codeUnitAt(0);
      if (c >= 0xFF01 && c <= 0xFF5E) {
        b.writeCharCode(c - 0xFEE0);
        continue;
      }
      if (c == 0x3000) {
        b.write(' ');
        continue;
      }
    }
    b.write(_cjkPunctMap[ch] ?? ch);
  }
  return b.toString();
}

String _normalizeConfusableQuotesForTokenCompare(String input) {
  var s = input.replaceAll(
    RegExp(r"[\u2018\u2019\u201B\u0060\u00B4\u02BC\u02BB\uFF07\u2032]"),
    "'",
  );
  s = s.replaceAll(
    RegExp(r'[\u201C\u201D\u201E\u00AB\u00BB]'),
    '"',
  );
  return s;
}
