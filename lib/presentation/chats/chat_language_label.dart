import '../shared/locale_flag.dart';

/// Compact language badges preserve the region/accent, without long names.
String? chatLanguageLabel(String? identifier) {
  final value = identifier?.trim().replaceAll('_', '-');
  if (value == null || value.isEmpty) return null;
  final parts = value.split('-');
  final code = [
    parts.first.toLowerCase(),
    for (final part in parts.skip(1))
      if (part.length == 2)
        part.toUpperCase()
      else if (part.length == 4)
        '${part[0].toUpperCase()}${part.substring(1).toLowerCase()}'
      else
        part,
  ].join('-');
  return '$code ${flagEmojiForLocale(code)}';
}
