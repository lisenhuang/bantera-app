import 'package:characters/characters.dart';

/// Mirrors backend alignment contract v2. Never derives readings by splitting
/// generated romanization; an invalid mapping is displayed as original text.
class PracticePronunciationAlignment {
  static const version = 2;
  static final _spoken = RegExp(r'[\p{L}\p{N}]', unicode: true);
  static final _letter = RegExp(r'[\p{L}\p{M}]', unicode: true);
  static final _word = RegExp(
    r"^[\p{L}\p{M}\u200c\u200d]+(?:['’\-][\p{L}\p{M}]+)*$",
    unicode: true,
  );
  static final _number = RegExp(r'^\p{N}+(?:[:.,/\-]\p{N}+)*$', unicode: true);
  static bool _han(int r) =>
      r >= 0x3400 && r <= 0x9fff ||
      r >= 0xf900 && r <= 0xfaff ||
      r >= 0x20000 && r <= 0x323af;
  static bool _hangul(int r) =>
      r >= 0xac00 && r <= 0xd7af || r >= 0x1100 && r <= 0x11ff;
  static bool _latin(int r) =>
      !RegExp(r'\p{L}', unicode: true).hasMatch(String.fromCharCode(r)) ||
      r <= 0x024f ||
      r >= 0x1e00 && r <= 0x1eff;

  static bool valid(List<dynamic> parts, String text, String locale) {
    final code = locale.replaceAll('_', '-').toLowerCase();
    final language = code.split('-').first;
    if (parts.isEmpty ||
        parts.length > 640 ||
        parts.any(
          (p) => p is! Map || p['text'] is! String || p['reading'] is! String,
        ) ||
        parts.map((p) => p['text']).join() != text) {
      return false;
    }
    final boundaries = <int>{0};
    var offset = 0;
    for (final c in text.characters) {
      offset += c.length;
      boundaries.add(offset);
    }
    offset = 0;
    for (final p in parts) {
      final source = p['text'] as String, reading = p['reading'] as String;
      offset += source.length;
      if (source.isEmpty ||
          source.length > 80 ||
          reading.length > 160 ||
          !boundaries.contains(offset) ||
          reading.trim() != reading ||
          RegExp(r'[\x00-\x1f\x7f-\x9f]').hasMatch(reading)) {
        return false;
      }
      if (!_spoken.hasMatch(source)) {
        if (reading.isNotEmpty) return false;
        continue;
      }
      if (reading.isEmpty ||
          !reading.runes.every(_latin) ||
          !RegExp(r'\p{L}', unicode: true).hasMatch(reading)) {
        return false;
      }
      if (_number.hasMatch(source)) {
        final rest = text.substring(offset);
        if (RegExp(r'^\p{N}|^[:.,/\-]\p{N}', unicode: true).hasMatch(rest)) {
          return false;
        }
        continue;
      }
      if (!_word.hasMatch(source)) return false;
      final runes = source.runes.toList();
      final count = source.characters.length;
      if ({'zh', 'yue'}.contains(language) && runes.any(_han)) {
        if (count != 1 || runes.where(_han).length != 1) return false;
        if (code == 'zh-hk' || language == 'yue') {
          if (!RegExp(r'^[a-z]+[1-6]$').hasMatch(reading)) return false;
        } else if (!RegExp(
          r'^[a-zA-ZüÜêÊāáǎàēéěèīíǐìōóǒòūúǔùǖǘǚǜńňǹḿ\p{M}]{1,12}$',
          unicode: true,
        ).hasMatch(reading)) {
          return false;
        }
      } else if (language == 'ko' && runes.any(_hangul)) {
        if (count != 1 ||
            !runes
                .where(
                  (r) => RegExp(
                    r'\p{L}',
                    unicode: true,
                  ).hasMatch(String.fromCharCode(r)),
                )
                .every(_hangul) ||
            !RegExp(r'^[a-zA-Z\p{M}]{1,12}$', unicode: true).hasMatch(reading)) {
          return false;
        }
      } else if ({'zh', 'yue', 'ko'}.contains(language)) {
        if (!runes.every(_latin)) return false;
      } else if (language == 'ja' && !runes.every(_latin)) {
        if (count > 12 || RegExp(r'\s').hasMatch(reading)) return false;
        var sawHan = false;
        var sawKanaAfterHan = false;
        for (final r in runes) {
          if (_han(r)) {
            if (sawKanaAfterHan) return false;
            sawHan = true;
          } else if (sawHan && r >= 0x3040 && r <= 0x30ff) {
            sawKanaAfterHan = true;
          }
        }
      } else if (language == 'th' &&
          runes.any((r) => r >= 0x0e00 && r <= 0x0e7f)) {
        // Ignore tone/length marks before counting vowel nuclei. This also
        // handles decomposed marks between the vowels of one nucleus.
        var plain = reading.replaceAll(RegExp(r'[\u0300-\u036f]'), '');
        const vowels = {
          'a': 'āáǎàâäãă',
          'e': 'ēéěèêë',
          'i': 'īíǐìîï',
          'o': 'ōóǒòôö',
          'u': 'ūúǔùûü',
        };
        for (final entry in vowels.entries) {
          plain = plain.replaceAll(
            RegExp('[${entry.value}]', caseSensitive: false),
            entry.key,
          );
        }
        if (count > 12 ||
            !RegExp(r'^[a-zA-Z]+$').hasMatch(plain) ||
            RegExp(r'[aeiouAEIOU]+').allMatches(plain).length != 1) {
          return false;
        }
      }
      if ({'ar', 'he', 'ru', 'uk', 'el'}.contains(language) ||
          runes.every(_latin)) {
        if (offset < text.length &&
            _letter.hasMatch(String.fromCharCode(runes.last)) &&
            ((_letter.hasMatch(text.substring(offset).characters.first) &&
                    ({'ar', 'he', 'ru', 'uk', 'el'}.contains(language) ||
                        _latin(text.substring(offset).runes.first))) ||
                "'’-".contains(text[offset]))) {
          return false;
        }
      }
    }
    return true;
  }

  static bool validPayload(
    Map<String, dynamic> value,
    String locale,
    List<String>? source,
  ) {
    if (source != null && source.length != 3) return false;
    final cue = value['cue'], choices = value['choices'];
    if (cue is! List ||
        choices is! List ||
        choices.length != 2 ||
        choices.any((p) => p is! List)) {
      return false;
    }
    final lists = [cue, ...choices.cast<List>()];
    for (var i = 0; i < lists.length; i++) {
      final list = lists[i];
      if (list.any((p) => p is! Map || p['text'] is! String)) return false;
      if (!valid(
        list,
        source == null ? list.map((p) => p['text']).join() : source[i],
        locale,
      )) {
        return false;
      }
    }
    return true;
  }
}
