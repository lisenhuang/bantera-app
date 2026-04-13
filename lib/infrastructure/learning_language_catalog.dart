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
    identifier: 'yue-CN',
    displayName: 'Cantonese (China mainland)',
    isInstalled: false,
    flagEmoji: '🇨🇳',
  ),
  TranscriptionLocaleOption(
    identifier: 'zh-CN',
    displayName: 'Chinese (China mainland)',
    isInstalled: false,
    flagEmoji: '🇨🇳',
  ),
  TranscriptionLocaleOption(
    identifier: 'zh-HK',
    displayName: 'Chinese (Hong Kong)',
    isInstalled: false,
    flagEmoji: '🇭🇰',
  ),
  TranscriptionLocaleOption(
    identifier: 'zh-TW',
    displayName: 'Chinese (Taiwan)',
    isInstalled: false,
    flagEmoji: '🇹🇼',
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
    identifier: 'en-IN',
    displayName: 'English (India)',
    isInstalled: false,
    flagEmoji: '🇮🇳',
  ),
  TranscriptionLocaleOption(
    identifier: 'en-IE',
    displayName: 'English (Ireland)',
    isInstalled: false,
    flagEmoji: '🇮🇪',
  ),
  TranscriptionLocaleOption(
    identifier: 'en-NZ',
    displayName: 'English (New Zealand)',
    isInstalled: false,
    flagEmoji: '🇳🇿',
  ),
  TranscriptionLocaleOption(
    identifier: 'en-SG',
    displayName: 'English (Singapore)',
    isInstalled: false,
    flagEmoji: '🇸🇬',
  ),
  TranscriptionLocaleOption(
    identifier: 'en-ZA',
    displayName: 'English (South Africa)',
    isInstalled: false,
    flagEmoji: '🇿🇦',
  ),
  TranscriptionLocaleOption(
    identifier: 'en-GB',
    displayName: 'English (United Kingdom)',
    isInstalled: false,
    flagEmoji: '🇬🇧',
  ),
  TranscriptionLocaleOption(
    identifier: 'en-US',
    displayName: 'English (United States)',
    isInstalled: false,
    flagEmoji: '🇺🇸',
  ),
  TranscriptionLocaleOption(
    identifier: 'fr-BE',
    displayName: 'French (Belgium)',
    isInstalled: false,
    flagEmoji: '🇧🇪',
  ),
  TranscriptionLocaleOption(
    identifier: 'fr-CA',
    displayName: 'French (Canada)',
    isInstalled: false,
    flagEmoji: '🇨🇦',
  ),
  TranscriptionLocaleOption(
    identifier: 'fr-FR',
    displayName: 'French (France)',
    isInstalled: false,
    flagEmoji: '🇫🇷',
  ),
  TranscriptionLocaleOption(
    identifier: 'fr-CH',
    displayName: 'French (Switzerland)',
    isInstalled: false,
    flagEmoji: '🇨🇭',
  ),
  TranscriptionLocaleOption(
    identifier: 'de-AT',
    displayName: 'German (Austria)',
    isInstalled: false,
    flagEmoji: '🇦🇹',
  ),
  TranscriptionLocaleOption(
    identifier: 'de-DE',
    displayName: 'German (Germany)',
    isInstalled: false,
    flagEmoji: '🇩🇪',
  ),
  TranscriptionLocaleOption(
    identifier: 'de-CH',
    displayName: 'German (Switzerland)',
    isInstalled: false,
    flagEmoji: '🇨🇭',
  ),
  TranscriptionLocaleOption(
    identifier: 'it-IT',
    displayName: 'Italian (Italy)',
    isInstalled: false,
    flagEmoji: '🇮🇹',
  ),
  TranscriptionLocaleOption(
    identifier: 'it-CH',
    displayName: 'Italian (Switzerland)',
    isInstalled: false,
    flagEmoji: '🇨🇭',
  ),
  TranscriptionLocaleOption(
    identifier: 'ja-JP',
    displayName: 'Japanese (Japan)',
    isInstalled: false,
    flagEmoji: '🇯🇵',
  ),
  TranscriptionLocaleOption(
    identifier: 'ko-KR',
    displayName: 'Korean (South Korea)',
    isInstalled: false,
    flagEmoji: '🇰🇷',
  ),
  TranscriptionLocaleOption(
    identifier: 'pt-BR',
    displayName: 'Portuguese (Brazil)',
    isInstalled: false,
    flagEmoji: '🇧🇷',
  ),
  TranscriptionLocaleOption(
    identifier: 'pt-PT',
    displayName: 'Portuguese (Portugal)',
    isInstalled: false,
    flagEmoji: '🇵🇹',
  ),
  TranscriptionLocaleOption(
    identifier: 'es-CL',
    displayName: 'Spanish (Chile)',
    isInstalled: false,
    flagEmoji: '🇨🇱',
  ),
  TranscriptionLocaleOption(
    identifier: 'es-MX',
    displayName: 'Spanish (Mexico)',
    isInstalled: false,
    flagEmoji: '🇲🇽',
  ),
  TranscriptionLocaleOption(
    identifier: 'es-ES',
    displayName: 'Spanish (Spain)',
    isInstalled: false,
    flagEmoji: '🇪🇸',
  ),
  TranscriptionLocaleOption(
    identifier: 'es-US',
    displayName: 'Spanish (United States)',
    isInstalled: false,
    flagEmoji: '🇺🇸',
  ),
];
