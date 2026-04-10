import 'transcription_locale_option.dart';

/// One row from [GET /api/public/learning-languages] (or embedded fallback).
class LearningLanguageRow {
  const LearningLanguageRow({
    required this.identifier,
    required this.displayName,
    required this.flagEmoji,
  });

  factory LearningLanguageRow.fromJson(Map<String, dynamic> json) {
    return LearningLanguageRow(
      identifier: json['identifier'] as String? ?? '',
      displayName: json['displayName'] as String? ?? '',
      flagEmoji: json['flagEmoji'] as String? ?? '🌐',
    );
  }

  final String identifier;
  final String displayName;
  final String flagEmoji;
}

/// Last-resort list when the API is unreachable; mirrors [LearningLanguageCatalog] on the server.
const kFallbackLearningLanguages = <TranscriptionLocaleOption>[
  TranscriptionLocaleOption(
    identifier: 'en-US',
    displayName: 'English (United States)',
    isInstalled: false,
    flagEmoji: '🇺🇸',
  ),
  TranscriptionLocaleOption(
    identifier: 'en-GB',
    displayName: 'English (United Kingdom)',
    isInstalled: false,
    flagEmoji: '🇬🇧',
  ),
  TranscriptionLocaleOption(
    identifier: 'en-UK',
    displayName: 'English (United Kingdom)',
    isInstalled: false,
    flagEmoji: '🇬🇧',
  ),
  TranscriptionLocaleOption(
    identifier: 'en-NZ',
    displayName: 'English (New Zealand)',
    isInstalled: false,
    flagEmoji: '🇳🇿',
  ),
  TranscriptionLocaleOption(
    identifier: 'en-AU',
    displayName: 'English (Australia)',
    isInstalled: false,
    flagEmoji: '🇦🇺',
  ),
  TranscriptionLocaleOption(
    identifier: 'en-CA',
    displayName: 'English (Canada)',
    isInstalled: false,
    flagEmoji: '🇨🇦',
  ),
  TranscriptionLocaleOption(
    identifier: 'en-IE',
    displayName: 'English (Ireland)',
    isInstalled: false,
    flagEmoji: '🇮🇪',
  ),
  TranscriptionLocaleOption(
    identifier: 'en-IN',
    displayName: 'English (India)',
    isInstalled: false,
    flagEmoji: '🇮🇳',
  ),
  TranscriptionLocaleOption(
    identifier: 'zh',
    displayName: 'Chinese (Mandarin)',
    isInstalled: false,
    flagEmoji: '🇨🇳',
  ),
  TranscriptionLocaleOption(
    identifier: 'ja',
    displayName: 'Japanese',
    isInstalled: false,
    flagEmoji: '🇯🇵',
  ),
  TranscriptionLocaleOption(
    identifier: 'ko',
    displayName: 'Korean',
    isInstalled: false,
    flagEmoji: '🇰🇷',
  ),
  TranscriptionLocaleOption(
    identifier: 'fr',
    displayName: 'French',
    isInstalled: false,
    flagEmoji: '🇫🇷',
  ),
  TranscriptionLocaleOption(
    identifier: 'de',
    displayName: 'German',
    isInstalled: false,
    flagEmoji: '🇩🇪',
  ),
  TranscriptionLocaleOption(
    identifier: 'es',
    displayName: 'Spanish',
    isInstalled: false,
    flagEmoji: '🇪🇸',
  ),
  TranscriptionLocaleOption(
    identifier: 'pt',
    displayName: 'Portuguese',
    isInstalled: false,
    flagEmoji: '🇵🇹',
  ),
  TranscriptionLocaleOption(
    identifier: 'hi',
    displayName: 'Hindi',
    isInstalled: false,
    flagEmoji: '🇮🇳',
  ),
  TranscriptionLocaleOption(
    identifier: 'ar',
    displayName: 'Arabic',
    isInstalled: false,
    flagEmoji: '🌐',
  ),
  TranscriptionLocaleOption(
    identifier: 'it',
    displayName: 'Italian',
    isInstalled: false,
    flagEmoji: '🇮🇹',
  ),
  TranscriptionLocaleOption(
    identifier: 'si',
    displayName: 'Sinhala',
    isInstalled: false,
    flagEmoji: '🇱🇰',
  ),
];
