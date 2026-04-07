/// Converts a BCP-47 locale identifier to a country flag emoji.
/// Extracts the region subtag (e.g. "US" from "en-US") and maps it to the
/// corresponding Unicode regional indicator pair. Falls back to a
/// language-to-flag map for identifiers without a region subtag.
String flagEmojiForLocale(String identifier) {
  final parts = identifier.split(RegExp(r'[-_]'));

  // Try each part from the end for a 2-letter alpha region code.
  for (final part in parts.reversed) {
    if (part.length == 2 &&
        part.codeUnits.every(
          (c) => (c >= 65 && c <= 90) || (c >= 97 && c <= 122),
        )) {
      final upper = part.toUpperCase();
      // Skip pure language subtags that equal the first part (e.g. "en" in "en").
      if (parts.length > 1 || parts[0].toUpperCase() != upper) {
        return _countryCodeToFlag(upper);
      }
    }
  }

  // Fallback: map language code to a representative flag.
  const languageFallback = <String, String>{
    'en': 'US',
    'zh': 'CN',
    'ja': 'JP',
    'ko': 'KR',
    'fr': 'FR',
    'de': 'DE',
    'es': 'ES',
    'pt': 'PT',
    'it': 'IT',
    'ru': 'RU',
    'ar': 'SA',
    'hi': 'IN',
    'th': 'TH',
    'vi': 'VN',
    'id': 'ID',
    'ms': 'MY',
    'tr': 'TR',
    'pl': 'PL',
    'nl': 'NL',
    'sv': 'SE',
    'nb': 'NO',
    'da': 'DK',
    'fi': 'FI',
    'cs': 'CZ',
    'ro': 'RO',
    'hu': 'HU',
    'el': 'GR',
    'he': 'IL',
    'uk': 'UA',
    'sk': 'SK',
    'hr': 'HR',
    'ca': 'ES',
    'bg': 'BG',
  };

  final lang = parts.first.toLowerCase();
  final countryCode = languageFallback[lang];
  if (countryCode != null) {
    return _countryCodeToFlag(countryCode);
  }

  return '🌐';
}

String _countryCodeToFlag(String countryCode) {
  const base = 0x1F1E6;
  const charA = 0x41;
  final upper = countryCode.toUpperCase();
  if (upper.length != 2) return '🌐';
  final first = base + upper.codeUnitAt(0) - charA;
  final second = base + upper.codeUnitAt(1) - charA;
  return String.fromCharCode(first) + String.fromCharCode(second);
}
