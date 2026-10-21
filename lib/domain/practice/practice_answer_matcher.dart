import 'package:characters/characters.dart';
import 'practice_number_normalization.dart';

/// Matches speech to a displayed reply without AI or network access.
/// Keep behaviour aligned with the backend and shared JSON regression fixtures.
class PracticeAnswerMatcher {
  static const _contractions = <String, String>{
    "i'm": "i am",
    "you're": "you are",
    "we're": "we are",
    "they're": "they are",
    "it's": "it is",
    "that's": "that is",
    "what's": "what is",
    "where's": "where is",
    "there's": "there is",
    "isn't": "is not",
    "aren't": "are not",
    "wasn't": "was not",
    "weren't": "were not",
    "don't": "do not",
    "doesn't": "does not",
    "didn't": "did not",
    "can't": "can not",
    "cannot": "can not",
    "won't": "will not",
    "wouldn't": "would not",
    "shouldn't": "should not",
    "couldn't": "could not",
    "haven't": "have not",
    "hasn't": "has not",
    "hadn't": "had not",
    "i'll": "i will",
    "you'll": "you will",
    "we'll": "we will",
    "they'll": "they will",
    "i've": "i have",
    "you've": "you have",
    "we've": "we have",
    "they've": "they have",
  };

  static int? match(
    String transcript,
    List<String> choices,
    String locale, {
    Iterable<String> uncertainWords = const [],
  }) {
    if (choices.length != 2 || transcript.length > 1200) return null;
    final heard = normalise(transcript, locale);
    final options = choices.map((x) => normalise(x, locale)).toList();
    if (heard.isEmpty ||
        options.any((x) => x.isEmpty) ||
        options[0] == options[1]) {
      return null;
    }
    final uncertain = uncertainWords
        .map((x) => normalise(x, locale))
        .where((x) => x.isNotEmpty)
        .toList();
    final left = _units(heard, locale);
    final right = options.map((x) => _units(x, locale)).toList();
    if (left.length > 400 || right.any((x) => x.length > 400)) return null;
    final overlaps = right.map((x) => _overlap(left, x)).toList();
    // Reading both replies must not choose whichever happens to be longer.
    if (left.length >= right[0].length + right[1].length &&
        List.generate(
          2,
          (i) => overlaps[i] == right[i].length,
        ).every((x) => x)) {
      return null;
    }
    final scores = List.generate(2, (i) {
      final overlap = 2 * overlaps[i] / (left.length + right[i].length);
      final literal = _score(heard, options[i], locale);
      return overlap > literal ? overlap : literal;
    });
    final best = scores[0] > scores[1] ? 0 : 1;
    if (!_sameProtectedMeaning(heard, options[best], locale)) return null;
    final uncertainShared = uncertain.every(
      (word) => options.every((x) => _containsUnit(x, word, locale)),
    );
    if (uncertainShared &&
        _score(heard, options[best], locale) >= .94 &&
        scores[best] - scores[1 - best] >= .04) {
      return best;
    }

    // Chinese ASR often marks a whole phrase low-confidence despite an exact
    // transcript. Accept a clear full reply, but never close alternatives or a
    // wholly uncertain transcript. Other languages retain existing safeguards.
    if (['zh', 'yue'].contains(locale.toLowerCase().split('-').first) &&
        heard == options[best] &&
        left.length >= 6 &&
        scores[best] - scores[1 - best] >= .20 &&
        2 * _overlap(right[0], right[1]) / (right[0].length + right[1].length) <
            .70 &&
        // Expanded clock labels are formatting, not extra speech confidence.
        _overlap(
              _reliableUnits(heard, [
                ...uncertain,
                ...RegExp(
                  r'[0-9]+时[0-9]+分',
                ).allMatches(heard).map((m) => m[0]!),
              ], locale),
              right[best],
            ) >=
            2) {
      return best;
    }

    // Choice identification tolerates recognition differences. Require substantial
    // ordered evidence for one reply and a clear lead over the other reply.
    final minimum = _compact(locale) ? 6 : 3;
    if (left.length < minimum ||
        right[best].length < minimum + 1 ||
        overlaps[best] < minimum ||
        scores[best] < .60 ||
        scores[best] - scores[1 - best] < .20 ||
        overlaps[best] / right[best].length < .55 ||
        overlaps[best] / left.length < .60) {
      return null;
    }

    // One uncertain word no longer vetoes an otherwise clear long reply. Remove
    // uncertain spans and check that the remaining speech still identifies it.
    final reliable = _reliableUnits(heard, uncertain, locale);
    final trusted = right.map((x) => _overlap(reliable, x)).toList();
    final trustedScores = List.generate(
      2,
      (i) => 2 * trusted[i] / (left.length + right[i].length),
    );
    if (trusted[best] < minimum ||
        trustedScores[best] < .50 ||
        trustedScores[best] - trustedScores[1 - best] < .15) {
      return null;
    }
    for (final word in uncertain) {
      if (!options.every((x) => _containsUnit(x, word, locale)) &&
          _protectedSignature(word, locale).isNotEmpty) {
        return null;
      }
    }
    return best;
  }

  static bool _compact(String locale) => const [
    'zh',
    'yue',
    'ja',
    'ko',
    'th',
  ].contains(locale.toLowerCase().split('-').first);
  static bool _containsUnit(String text, String word, String locale) =>
      _compact(locale) ? text.contains(word) : ' $text '.contains(' $word ');
  static List<String> _units(String text, String locale) =>
      _compact(locale) ? text.characters.toList() : text.split(' ');

  static int _overlap(List<String> heard, List<String> target) {
    var previous = List.filled(target.length + 1, 0);
    for (final word in heard) {
      final current = List.filled(target.length + 1, 0);
      for (var j = 0; j < target.length; j++) {
        current[j + 1] = word == target[j]
            ? previous[j] + 1
            : (previous[j + 1] > current[j] ? previous[j + 1] : current[j]);
      }
      previous = current;
    }
    return previous.last;
  }

  static List<String> _reliableUnits(
    String heard,
    List<String> uncertain,
    String locale,
  ) {
    final units = _units(heard, locale), excluded = <int>{};
    for (final word in uncertain) {
      final span = _units(word, locale);
      for (var i = 0; i + span.length <= units.length; i++) {
        if (List.generate(
          span.length,
          (j) => units[i + j] == span[j],
        ).every((x) => x)) {
          excluded.addAll(List.generate(span.length, (j) => i + j));
        }
      }
    }
    return [
      for (var i = 0; i < units.length; i++)
        if (!excluded.contains(i)) units[i],
    ];
  }

  // Conservative guards for numbers and common negation markers. These are not
  // a semantic or pronunciation model; close alternatives still require a margin.
  static const _negations = <String, String>{
    'en': 'not no never neither nor without',
    'es': 'no nunca jamás sin ni',
    'fr': 'ne pas jamais sans ni non',
    'de': 'nicht kein keine keinen keinem keiner keines nie ohne',
    'it': 'non mai senza né',
    'pt': 'não nunca jamais sem nem',
    'ru': 'не нет никогда без ни',
    'uk': 'не ні ніколи без',
    'pl': 'nie nigdy bez',
    'id': 'tidak bukan jangan belum tanpa',
    'vi': 'không chẳng chưa đừng',
    'tr': 'değil yok hayır',
    'ar': 'لا لم لن ليس دون',
    'he': 'לא אין בלי',
    'fa': 'نه نیست بدون',
    'zh': '不 没 沒 无 無 未 别 別',
    'yue': '唔 冇 未 不 沒',
    'ja': 'ない ません ぬ ず',
    'ko': '안 못 않 없',
    'th': 'ไม่ มิ',
  };
  static List<String> _protectedSignature(String text, String locale) {
    final result = RegExp(
      locale.toLowerCase().startsWith('en')
          ? r'[0-9]+(?:decimal[0-9]+)?'
          : r'\p{N}+',
      unicode: true,
    ).allMatches(text).map((x) => x.group(0)!).toList();
    if (['zh', 'yue'].contains(locale.toLowerCase().split('-').first)) {
      result.addAll(
        // Protect the complete clock too: 6:12 must not equal 12:06.
        RegExp(
          r'[0-9]+时[0-9]+分|美元|港元|台币|欧元|英镑|元|负',
        ).allMatches(text).map((m) => m[0]!),
      );
    }
    if (locale.toLowerCase().startsWith('en')) {
      result.addAll(
        RegExp(
          r'\b(dollars|euros|pounds|usd|nzd|aud|cad|hkd|negative|am|pm)\b',
        ).allMatches(text).map((m) => m[0]!),
      );
    }
    final markers =
        _negations[locale.toLowerCase() == 'zh-hk'
            ? 'yue'
            : locale.toLowerCase().split('-').first];
    for (final marker in markers?.split(' ') ?? <String>[]) {
      final pattern = _compact(locale)
          ? RegExp(RegExp.escape(marker))
          : RegExp(
              r'(?<![\p{L}\p{M}\p{N}])' +
                  RegExp.escape(marker) +
                  r'(?![\p{L}\p{M}\p{N}])',
              unicode: true,
            );
      result.addAll(pattern.allMatches(text).map((_) => marker));
    }
    return result..sort();
  }

  static bool _sameProtectedMeaning(String a, String b, String locale) =>
      _protectedSignature(a, locale).join('|') ==
      _protectedSignature(b, locale).join('|');

  static String normalise(String text, String locale) {
    text = String.fromCharCodes(
      text.runes.map((c) => c >= 0xff01 && c <= 0xff5e ? c - 0xfee0 : c),
    ).toLowerCase().replaceAll('’', "'").replaceAll('‘', "'");
    if (locale.toLowerCase().startsWith('en')) {
      for (final entry in _contractions.entries) {
        text = text.replaceAll(
          RegExp(
            r'(?<![\p{L}\p{N}])' +
                RegExp.escape(entry.key) +
                r'(?![\p{L}\p{N}])',
            unicode: true,
          ),
          entry.value,
        );
      }
      text = text.replaceAll(
        RegExp(
          r'(?<![\p{L}\p{N}])(um|uh|erm|hmm)(?![\p{L}\p{N}])',
          unicode: true,
        ),
        ' ',
      );
    }
    text = normalizePracticeNumbers(text, locale);
    text = text
        .replaceAll("'", '')
        .replaceAll(RegExp(r'[^\p{L}\p{M}\p{N}]+', unicode: true), ' ')
        .trim();
    if (locale.toLowerCase().startsWith('en')) text = _englishNumbers(text);
    if (_compact(locale)) text = text.replaceAll(' ', '');
    // Cantonese ASR uses either character for this affirmative reply particle.
    // Keep the equivalence scoped to the opening 得啊/得呀, not all 啊/呀.
    if (locale.toLowerCase().split('-').first == 'yue' ||
        locale.toLowerCase() == 'zh-hk') {
      text = text.replaceFirst(RegExp(r'^得啊'), '得呀');
    }
    return text;
  }

  static String _englishNumbers(String text) {
    const units = [
      'zero',
      'one',
      'two',
      'three',
      'four',
      'five',
      'six',
      'seven',
      'eight',
      'nine',
      'ten',
      'eleven',
      'twelve',
      'thirteen',
      'fourteen',
      'fifteen',
      'sixteen',
      'seventeen',
      'eighteen',
      'nineteen',
    ];
    const tens = [
      'twenty',
      'thirty',
      'forty',
      'fifty',
      'sixty',
      'seventy',
      'eighty',
      'ninety',
    ];
    final words = text.split(' '), result = <String>[];
    for (var i = 0; i < words.length; i++) {
      final unit = units.indexOf(words[i]), ten = tens.indexOf(words[i]);
      if (ten >= 0) {
        var value = (ten + 2) * 10;
        final next = i + 1 < words.length ? units.indexOf(words[i + 1]) : -1;
        if (next > 0 && next < 10) {
          value += next;
          i++;
        }
        result.add(value.toString());
      } else {
        result.add(unit >= 0 ? unit.toString() : words[i]);
      }
    }
    return result.join(' ');
  }

  static double _score(String heard, String target, String locale) {
    if (heard == target) return 1;
    if (_compact(locale)) return 0;
    final left = heard.split(' '), right = target.split(' ');
    if (left.length < 3 || left.length != right.length || target.length < 14) {
      return 0;
    }
    var differences = 0;
    for (var i = 0; i < left.length; i++) {
      if (left[i] == right[i]) continue;
      if (++differences > 1 ||
          left[i].length < 5 ||
          right[i].length < 5 ||
          RegExp(r'\p{N}', unicode: true).hasMatch(left[i] + right[i]) ||
          left[i][0] != right[i][0] ||
          left[i][left[i].length - 1] != right[i][right[i].length - 1] ||
          !_oneEdit(left[i], right[i])) {
        return 0;
      }
    }
    return .94;
  }

  static bool _oneEdit(String a, String b) {
    if ((a.length - b.length).abs() > 1) return false;
    var i = 0, j = 0, edits = 0;
    while (i < a.length && j < b.length) {
      if (a[i] == b[j]) {
        i++;
        j++;
        continue;
      }
      if (++edits > 1) return false;
      if (a.length >= b.length) i++;
      if (b.length >= a.length) j++;
    }
    return edits + (a.length - i) + (b.length - j) <= 1;
  }
}
