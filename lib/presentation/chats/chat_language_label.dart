import '../shared/language_code_label.dart';
import '../shared/locale_flag.dart';

/// Compact language badges preserve the region/accent, without long names.
String? chatLanguageLabel(String? identifier) {
  if (identifier == null || identifier.trim().isEmpty) return null;
  final code = languageCodeLabel(identifier);
  return '$code ${flagEmojiForLocale(code)}';
}
