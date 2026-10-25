/// Conservative number, time and currency equivalence for ASR output.
/// Local display fallback for older servers. The authoritative backend also
/// handles locale-aware spellout and returns exact text-equivalence metadata.
String normalizePracticeNumbers(String text, String locale) {
  final language = locale.toLowerCase().split('-').first;
  if (language == 'en') return _englishCurrency(text);
  if (language == 'ja') {
    // ASR can write 二十歳 as 20歳, or 三時 as 3時. Require an
    // explicit numeric counter rather than rewriting kanji in ordinary words.
    return text.replaceAllMapped(
      RegExp(
        r'[〇零一二三四五六七八九十百千万億兆]+(?=歳|才|円|人|個|本|枚|匹|冊|台|回|階|番|丁目|年|か月|ヶ月|月|日|週間|週|時間|時|分|秒|パーセント)',
      ),
      (m) => normalizePracticeNumbers(m[0]!, 'zh'),
    );
  }
  if (language != 'zh' && language != 'yue') return text;
  const digits = '零一二三四五六七八九';
  text = text.replaceAll('〇', '零').replaceAll('兩', '二').replaceAll('两', '二');
  text = text.replaceAllMapped(
    RegExp(r'[零一二三四五六七八九十百千萬万億亿]+(?:[點点][零一二三四五六七八九]+)?'),
    (match) {
      final original = match[0]!;
      final parts = original.split(RegExp('[點点]'));
      final whole = parts[0];
      // Larger units and colloquial shorthand remain literal rather than guessed.
      if (RegExp('[萬万億亿]').hasMatch(whole)) return original;
      var value = 0, pending = 0, lastUnit = 10000;
      var hasUnit = false, zeroAfterUnit = false, hasPending = false;
      if (!RegExp('[十百千]').hasMatch(whole)) {
        value = int.tryParse(whole.split('').map(digits.indexOf).join()) ?? -1;
      } else {
        for (final char in whole.split('')) {
          final digit = digits.indexOf(char);
          if (digit >= 0) {
            if (digit == 0) {
              zeroAfterUnit = true;
              continue;
            }
            if (hasPending) return original;
            pending = digit;
            hasPending = true;
          } else {
            final unit = {'十': 10, '百': 100, '千': 1000}[char]!;
            if (unit >= lastUnit || (!hasPending && (hasUnit || unit != 10))) {
              return original;
            }
            value += (hasPending ? pending : 1) * unit;
            pending = 0;
            hasPending = false;
            lastUnit = unit;
            hasUnit = true;
            zeroAfterUnit = false;
          }
        }
        if (hasPending && lastUnit >= 100 && !zeroAfterUnit) return original;
        value += pending;
      }
      if (value < 0) return original;
      final fraction = parts.length == 2
          ? parts[1]
                .split('')
                .map(digits.indexOf)
                .join()
                .replaceFirst(RegExp(r'0+$'), '')
          : '';
      return '$value${fraction.isEmpty ? '' : '点$fraction'}';
    },
  );
  // Keep hour/minute boundaries instead of turning 6:30 into the number 630.
  // Only explicit clock notation and half past are folded; decimals stay numbers.
  text = text.replaceAllMapped(
    RegExp(r'(?<![0-9.:])([01]?[0-9]|2[0-3]):([0-5][0-9])(?![0-9.:])'),
    (m) => '${int.parse(m[1]!)}时${int.parse(m[2]!)}分',
  );
  text = text.replaceAllMapped(
    RegExp(r'(?<![0-9.点點])([01]?[0-9]|2[0-3])[點点]半'),
    (m) => '${int.parse(m[1]!)}时30分',
  );
  text = text.replaceAllMapped(
    RegExp(r'(?<![0-9,])[0-9]{1,3}(?:,[0-9]{3})+(?![0-9,])'),
    (m) => m[0]!.replaceAll(',', ''),
  );
  text = text.replaceAllMapped(RegExp(r'([0-9]+)\.(\d+)'), (m) {
    final fraction = m[2]!.replaceFirst(RegExp(r'0+$'), '');
    return '${m[1]}${fraction.isEmpty ? '' : '点$fraction'}';
  });
  final localDollar =
      language == 'yue' ||
      ['zh-tw', 'zh-hk', 'zh-hant'].contains(locale.toLowerCase());
  const amount = r'([0-9]+(?:点[0-9]+)?)';
  // Explicit currency identities remain distinct, even for the same amount.
  final symbols = <String, String>{
    r'us\$': '美元',
    r'hk\$': '港元',
    r'nt\$': '台币',
    r'\$': localDollar ? '元' : '美元',
    '[¥￥]': '元',
    '€': '欧元',
    '£': '英镑',
  };
  for (final entry in symbols.entries) {
    text = text.replaceAllMapped(
      RegExp('${entry.key}\\s*$amount'),
      (m) => '${m[1]}${entry.value}',
    );
  }
  text = text.replaceAllMapped(
    RegExp('$amount\\s*(?:塊錢|块钱|蚊雞|蚊鸡|塊|块|蚊|圓|圆|元)'),
    (m) => '${m[1]}元',
  );
  // Keep decimals/signs meaningful after the matcher's punctuation removal.
  return text
      .replaceAll('負', '负')
      .replaceAllMapped(RegExp(r'-\s*(?=[0-9])'), (_) => '负');
}

String _englishCurrency(String text) {
  // Whole-hour ASR formatting must retain the spoken o'clock unit.
  text = text.replaceAllMapped(
    RegExp(r'(?<![0-9])([01]?[0-9]|2[0-3]):00(?![0-9])'),
    (m) => '${int.parse(m[1]!)} oclock',
  );
  text = text.replaceAllMapped(RegExp(r'\b([ap])\.m\.'), (m) => '${m[1]}m');
  text = text.replaceAllMapped(
    RegExp(r'(?<![0-9,])[0-9]{1,3}(?:,[0-9]{3})+(?![0-9,])'),
    (m) => m[0]!.replaceAll(',', ''),
  );
  const amount = r'(-?\s*[0-9]+(?:\.[0-9]+)?)';
  for (final entry in <String, String>{
    r'us\$': 'usd',
    r'nz\$': 'nzd',
    r'au\$': 'aud',
    r'ca\$': 'cad',
    r'hk\$': 'hkd',
    r'\$': 'dollars',
    '€': 'euros',
    '£': 'pounds',
  }.entries) {
    text = text.replaceAllMapped(
      RegExp('${entry.key}\\s*$amount'),
      (m) => '${m[1]} ${entry.value}',
    );
  }
  text = text.replaceAllMapped(
    RegExp(r'\b(dollar|euro|pound)\b'),
    (m) => '${m[1]}s',
  );
  for (final entry in <String, String>{
    'us dollars': 'usd',
    'new zealand dollars': 'nzd',
    'australian dollars': 'aud',
    'canadian dollars': 'cad',
    'hong kong dollars': 'hkd',
  }.entries) {
    text = text.replaceAll(RegExp('\\b${entry.key}\\b'), entry.value);
  }
  text = text.replaceAllMapped(RegExp(r'([0-9]+)\.([0-9]+)'), (m) {
    final fraction = m[2]!.replaceFirst(RegExp(r'0+$'), '');
    return '${m[1]}${fraction.isEmpty ? '' : 'decimal$fraction'}';
  });
  return text.replaceAllMapped(RegExp(r'-\s*(?=[0-9])'), (_) => 'negative ');
}
