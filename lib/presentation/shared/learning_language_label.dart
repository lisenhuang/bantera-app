import '../../infrastructure/learning_language_catalog.dart';
import '../../infrastructure/audio_language_groups.dart';
import '../../infrastructure/transcription_locale_option.dart';
import 'locale_flag.dart';

/// Language name without accent/region, paired with the selected locale's flag.
({String name, String flag}) learningLanguageLabel(String? identifier) {
  final language = identifier?.trim();
  final normalized = language == null
      ? ''
      : normalizeLocaleIdentifierForLookup(
          normalizeLegacyLearningLanguageIdentifier(language),
        );
  final languageOptions = [
    ...kFallbackLearningLanguages,
    ...kFallbackTranslationLanguages,
  ];
  final languageOption = languageOptions
      .where(
        (option) =>
            normalizeLocaleIdentifierForLookup(option.identifier) == normalized,
      )
      .firstOrNull;
  final fallbackLanguage = languageOptions
      .where(
        (option) =>
            primaryLanguageCodeForLocaleIdentifier(option.identifier) ==
            primaryLanguageCodeForLocaleIdentifier(normalized),
      )
      .firstOrNull;
  final displayName =
      languageOption?.displayName ?? fallbackLanguage?.displayName;
  // Share the language itself, without locale codes, regions or accents.
  // An unrecognized identifier stays hidden instead of leaking a raw code.
  final languageName = language == null || language.isEmpty
      ? ''
      : switch (audioLanguageGroupCode(language)) {
          'yue' => 'Cantonese',
          'zh-cn' || 'zh-tw' => 'Mandarin',
          _ => displayName?.split('(').first.trim() ?? '',
        };
  final languageFlag =
      languageOption?.effectiveFlagEmoji ??
      (language == null ? '' : flagEmojiForLocale(language));
  return (name: languageName, flag: languageFlag);
}
