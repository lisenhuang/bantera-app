/// Splits subtitle text into the units the player highlights and seeks to.
///
/// Words follow the app's word pattern, except that Chinese and Japanese runs
/// (which have no spaces, so the pattern returns a whole clause) are split into
/// single characters. Mirrors `WordTimingAligner.SplitCjk` on the backend, which
/// times each of those characters.
library;

final RegExp kSubtitleWordRe = RegExp(
  r"[\p{L}\p{N}]+(?:['’ʼ][\p{L}\p{N}]+)*",
  unicode: true,
);

final RegExp _kKeyStripRe = RegExp(r'[^\p{L}\p{N}]', unicode: true);

/// Small kana and the long-vowel mark are not spoken alone; they join the
/// character before them (きょう → きょ, う).
const String _kKanaModifiers =
    'ぁぃぅぇぉっゃゅょゎゕゖァィゥェォッャュョヮヵヶㇰㇱㇲㇳㇴㇵㇶㇷㇸㇹㇺㇻㇼㇽㇾㇿーｧｨｩｪｫｯｬｭｮｰﾞﾟ゛゜';

class SubtitleWordToken {
  const SubtitleWordToken(this.start, this.end, this.text);

  /// UTF-16 offsets into the subtitle text.
  final int start;
  final int end;
  final String text;
}

/// Lowercased letters and digits only, so script and timing words compare equal.
String subtitleWordKey(String word) =>
    word.toLowerCase().replaceAll(_kKeyStripRe, '');

bool isCjkRune(int rune) =>
    (rune >= 0x3040 && rune <= 0x30FF) || // hiragana, katakana
    (rune >= 0x31F0 && rune <= 0x31FF) || // katakana phonetic extensions
    (rune >= 0x3400 && rune <= 0x4DBF) || // CJK extension A
    (rune >= 0x4E00 && rune <= 0x9FFF) || // CJK unified ideographs
    (rune >= 0xF900 && rune <= 0xFAFF) || // CJK compatibility ideographs
    (rune >= 0xFF66 && rune <= 0xFF9F) || // half-width katakana
    (rune >= 0x20000 && rune <= 0x3134F); // CJK extensions B–G

List<SubtitleWordToken> subtitleWordTokens(String text) {
  final tokens = <SubtitleWordToken>[];
  for (final match in kSubtitleWordRe.allMatches(text)) {
    var offset = match.start;
    int? otherStart;
    var lastWasCjk = false;
    void flushOther(int end) {
      if (otherStart != null) {
        tokens.add(
          SubtitleWordToken(otherStart!, end, text.substring(otherStart!, end)),
        );
        otherStart = null;
      }
    }

    for (final rune in match.group(0)!.runes) {
      final length = rune > 0xFFFF ? 2 : 1;
      if (!isCjkRune(rune)) {
        otherStart ??= offset;
        lastWasCjk = false;
      } else {
        flushOther(offset);
        final isModifier =
            lastWasCjk && _kKanaModifiers.contains(String.fromCharCode(rune));
        if (isModifier) {
          final previous = tokens.removeLast();
          final end = offset + length;
          tokens.add(
            SubtitleWordToken(
              previous.start,
              end,
              text.substring(previous.start, end),
            ),
          );
        } else {
          tokens.add(
            SubtitleWordToken(
              offset,
              offset + length,
              text.substring(offset, offset + length),
            ),
          );
        }
        lastWasCjk = true;
      }
      offset += length;
    }
    flushOther(match.end);
  }
  return tokens;
}
