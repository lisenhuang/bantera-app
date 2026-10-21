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

/// Goal header label: distinguish accents only when the language has several.
/// Share cards keep their simpler language-only presentation.
String goalLearningLanguageLabel(String? identifier) {
  final language = learningLanguageLabel(identifier);
  if (language.name.isEmpty) return '';
  final normalized = normalizeLocaleIdentifierForLookup(
    normalizeLegacyLearningLanguageIdentifier(identifier!),
  );
  final accents = kFallbackLearningLanguages
      .where(
        (option) =>
            _spokenLanguageGroup(option.identifier) ==
            _spokenLanguageGroup(normalized),
      )
      .map((option) => normalizeLocaleIdentifierForLookup(option.identifier))
      .toSet();
  // A country flag consists of two regional indicator symbols. Catalog globes
  // (for example Latin America) and other placeholders do not belong here.
  final runes = language.flag.runes.toList();
  final countryFlag =
      runes.length == 2 &&
          runes.every((rune) => rune >= 0x1F1E6 && rune <= 0x1F1FF)
      ? language.flag
      : '';
  final flagSuffix = countryFlag.isEmpty ? '' : ' $countryFlag';
  return accents.length > 1
      ? '${language.name}($normalized$flagSuffix)'
      : '${language.name}$flagSuffix';
}

String _spokenLanguageGroup(String identifier) =>
    switch (audioLanguageGroupCode(identifier)) {
      'zh-cn' || 'zh-tw' => 'zh',
      final group => group,
    };
