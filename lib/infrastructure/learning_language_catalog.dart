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

/// Last-resort list for translation languages when iOS and API are both unavailable.
/// Mirrors [TranslationLanguageCatalog] on the server.
const kFallbackTranslationLanguages = <TranscriptionLocaleOption>[
  TranscriptionLocaleOption(identifier: 'ar-AE', displayName: 'Arabic (United Arab Emirates)', isInstalled: false, flagEmoji: '🇦🇪'),
  TranscriptionLocaleOption(identifier: 'zh',    displayName: 'Chinese',                       isInstalled: false, flagEmoji: '🇨🇳'),
  TranscriptionLocaleOption(identifier: 'zh-HK', displayName: 'Chinese (Hong Kong)',           isInstalled: false, flagEmoji: '🇭🇰'),
  TranscriptionLocaleOption(identifier: 'zh-TW', displayName: 'Chinese (Taiwan)',              isInstalled: false, flagEmoji: '🇹🇼'),
  TranscriptionLocaleOption(identifier: 'da',    displayName: 'Danish',                        isInstalled: false, flagEmoji: '🇩🇰'),
  TranscriptionLocaleOption(identifier: 'nl',    displayName: 'Dutch',                         isInstalled: false, flagEmoji: '🇳🇱'),
  TranscriptionLocaleOption(identifier: 'en',    displayName: 'English',                       isInstalled: false, flagEmoji: '🇬🇧'),
  TranscriptionLocaleOption(identifier: 'en-AU', displayName: 'English (Australia)',           isInstalled: false, flagEmoji: '🇦🇺'),
  TranscriptionLocaleOption(identifier: 'en-CA', displayName: 'English (Canada)',              isInstalled: false, flagEmoji: '🇨🇦'),
  TranscriptionLocaleOption(identifier: 'en-IN', displayName: 'English (India)',               isInstalled: false, flagEmoji: '🇮🇳'),
  TranscriptionLocaleOption(identifier: 'en-IE', displayName: 'English (Ireland)',             isInstalled: false, flagEmoji: '🇮🇪'),
  TranscriptionLocaleOption(identifier: 'en-NZ', displayName: 'English (New Zealand)',         isInstalled: false, flagEmoji: '🇳🇿'),
  TranscriptionLocaleOption(identifier: 'en-SG', displayName: 'English (Singapore)',           isInstalled: false, flagEmoji: '🇸🇬'),
  TranscriptionLocaleOption(identifier: 'en-ZA', displayName: 'English (South Africa)',        isInstalled: false, flagEmoji: '🇿🇦'),
  TranscriptionLocaleOption(identifier: 'en-GB', displayName: 'English (United Kingdom)',      isInstalled: false, flagEmoji: '🇬🇧'),
  TranscriptionLocaleOption(identifier: 'fr',    displayName: 'French',                        isInstalled: false, flagEmoji: '🇫🇷'),
  TranscriptionLocaleOption(identifier: 'fr-CA', displayName: 'French (Canada)',               isInstalled: false, flagEmoji: '🇨🇦'),
  TranscriptionLocaleOption(identifier: 'de',    displayName: 'German',                        isInstalled: false, flagEmoji: '🇩🇪'),
  TranscriptionLocaleOption(identifier: 'de-CH', displayName: 'German (Switzerland)',          isInstalled: false, flagEmoji: '🇨🇭'),
  TranscriptionLocaleOption(identifier: 'hi',    displayName: 'Hindi',                         isInstalled: false, flagEmoji: '🇮🇳'),
  TranscriptionLocaleOption(identifier: 'id',    displayName: 'Indonesian',                    isInstalled: false, flagEmoji: '🇮🇩'),
  TranscriptionLocaleOption(identifier: 'it',    displayName: 'Italian',                       isInstalled: false, flagEmoji: '🇮🇹'),
  TranscriptionLocaleOption(identifier: 'it-CH', displayName: 'Italian (Switzerland)',         isInstalled: false, flagEmoji: '🇨🇭'),
  TranscriptionLocaleOption(identifier: 'ja',    displayName: 'Japanese',                      isInstalled: false, flagEmoji: '🇯🇵'),
  TranscriptionLocaleOption(identifier: 'ko',    displayName: 'Korean',                        isInstalled: false, flagEmoji: '🇰🇷'),
  TranscriptionLocaleOption(identifier: 'nb',    displayName: 'Norwegian Bokmål',              isInstalled: false, flagEmoji: '🇳🇴'),
  TranscriptionLocaleOption(identifier: 'pl',    displayName: 'Polish',                        isInstalled: false, flagEmoji: '🇵🇱'),
  TranscriptionLocaleOption(identifier: 'pt',    displayName: 'Portuguese',                    isInstalled: false, flagEmoji: '🇧🇷'),
  TranscriptionLocaleOption(identifier: 'pt-PT', displayName: 'Portuguese (Portugal)',         isInstalled: false, flagEmoji: '🇵🇹'),
  TranscriptionLocaleOption(identifier: 'ru',    displayName: 'Russian',                       isInstalled: false, flagEmoji: '🇷🇺'),
  TranscriptionLocaleOption(identifier: 'es',    displayName: 'Spanish',                       isInstalled: false, flagEmoji: '🇪🇸'),
  TranscriptionLocaleOption(identifier: 'es-MX', displayName: 'Spanish (Mexico)',              isInstalled: false, flagEmoji: '🇲🇽'),
  TranscriptionLocaleOption(identifier: 'es-US', displayName: 'Spanish (United States)',       isInstalled: false, flagEmoji: '🇺🇸'),
  TranscriptionLocaleOption(identifier: 'sv',    displayName: 'Swedish',                       isInstalled: false, flagEmoji: '🇸🇪'),
  TranscriptionLocaleOption(identifier: 'th',    displayName: 'Thai',                          isInstalled: false, flagEmoji: '🇹🇭'),
  TranscriptionLocaleOption(identifier: 'tr',    displayName: 'Turkish',                       isInstalled: false, flagEmoji: '🇹🇷'),
  TranscriptionLocaleOption(identifier: 'uk',    displayName: 'Ukrainian',                     isInstalled: false, flagEmoji: '🇺🇦'),
  TranscriptionLocaleOption(identifier: 'vi',    displayName: 'Vietnamese',                    isInstalled: false, flagEmoji: '🇻🇳'),
];

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
