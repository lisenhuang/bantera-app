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
  TranscriptionLocaleOption(
    identifier: 'ar-AE',
    displayName: 'Arabic (United Arab Emirates)',
    isInstalled: false,
    flagEmoji: '🇦🇪',
  ),
  TranscriptionLocaleOption(
    identifier: 'zh',
    displayName: 'Mandarin',
    isInstalled: false,
    flagEmoji: '🇨🇳',
  ),
  TranscriptionLocaleOption(
    identifier: 'zh-HK',
    displayName: 'Cantonese (Hong Kong)',
    isInstalled: false,
    flagEmoji: '🇭🇰',
  ),
  TranscriptionLocaleOption(
    identifier: 'zh-TW',
    displayName: 'Mandarin (Taiwan)',
    isInstalled: false,
    flagEmoji: '🇹🇼',
  ),
  TranscriptionLocaleOption(
    identifier: 'da',
    displayName: 'Danish',
    isInstalled: false,
    flagEmoji: '🇩🇰',
  ),
  TranscriptionLocaleOption(
    identifier: 'nl',
    displayName: 'Dutch',
    isInstalled: false,
    flagEmoji: '🇳🇱',
  ),
  TranscriptionLocaleOption(
    identifier: 'en',
    displayName: 'English',
    isInstalled: false,
    flagEmoji: '🇬🇧',
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
    identifier: 'fr',
    displayName: 'French',
    isInstalled: false,
    flagEmoji: '🇫🇷',
  ),
  TranscriptionLocaleOption(
    identifier: 'fr-CA',
    displayName: 'French (Canada)',
    isInstalled: false,
    flagEmoji: '🇨🇦',
  ),
  TranscriptionLocaleOption(
    identifier: 'de',
    displayName: 'German',
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
    identifier: 'hi',
    displayName: 'Hindi',
    isInstalled: false,
    flagEmoji: '🇮🇳',
  ),
  TranscriptionLocaleOption(
    identifier: 'id',
    displayName: 'Indonesian',
    isInstalled: false,
    flagEmoji: '🇮🇩',
  ),
  TranscriptionLocaleOption(
    identifier: 'it',
    displayName: 'Italian',
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
    identifier: 'nb',
    displayName: 'Norwegian Bokmål',
    isInstalled: false,
    flagEmoji: '🇳🇴',
  ),
  TranscriptionLocaleOption(
    identifier: 'pl',
    displayName: 'Polish',
    isInstalled: false,
    flagEmoji: '🇵🇱',
  ),
  TranscriptionLocaleOption(
    identifier: 'pt',
    displayName: 'Portuguese',
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
    identifier: 'ru',
    displayName: 'Russian',
    isInstalled: false,
    flagEmoji: '🇷🇺',
  ),
  TranscriptionLocaleOption(
    identifier: 'es',
    displayName: 'Spanish',
    isInstalled: false,
    flagEmoji: '🇪🇸',
  ),
  TranscriptionLocaleOption(
    identifier: 'es-MX',
    displayName: 'Spanish (Mexico)',
    isInstalled: false,
    flagEmoji: '🇲🇽',
  ),
  TranscriptionLocaleOption(
    identifier: 'es-US',
    displayName: 'Spanish (United States)',
    isInstalled: false,
    flagEmoji: '🇺🇸',
  ),
  TranscriptionLocaleOption(
    identifier: 'sv',
    displayName: 'Swedish',
    isInstalled: false,
    flagEmoji: '🇸🇪',
  ),
  TranscriptionLocaleOption(
    identifier: 'th',
    displayName: 'Thai',
    isInstalled: false,
    flagEmoji: '🇹🇭',
  ),
  TranscriptionLocaleOption(
    identifier: 'tr',
    displayName: 'Turkish',
    isInstalled: false,
    flagEmoji: '🇹🇷',
  ),
  TranscriptionLocaleOption(
    identifier: 'uk',
    displayName: 'Ukrainian',
    isInstalled: false,
    flagEmoji: '🇺🇦',
  ),
  TranscriptionLocaleOption(
    identifier: 'vi',
    displayName: 'Vietnamese',
    isInstalled: false,
    flagEmoji: '🇻🇳',
  ),
];

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
    identifier: 'en-NZ',
    displayName: 'English (New Zealand)',
    isInstalled: false,
    flagEmoji: '🇳🇿',
  ),
  TranscriptionLocaleOption(
    identifier: 'en-IE',
    displayName: 'English (Ireland)',
    isInstalled: false,
    flagEmoji: '🇮🇪',
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
    identifier: 'en-PH',
    displayName: 'English (Philippines)',
    isInstalled: false,
    flagEmoji: '🇵🇭',
  ),
  TranscriptionLocaleOption(
    identifier: 'en-AE',
    displayName: 'English (United Arab Emirates)',
    isInstalled: false,
    flagEmoji: '🇦🇪',
  ),
  TranscriptionLocaleOption(
    identifier: 'en-ID',
    displayName: 'English (Indonesia)',
    isInstalled: false,
    flagEmoji: '🇮🇩',
  ),
  TranscriptionLocaleOption(
    identifier: 'en-SA',
    displayName: 'English (Saudi Arabia)',
    isInstalled: false,
    flagEmoji: '🇸🇦',
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
    identifier: 'es-419',
    displayName: 'Spanish (Latin America)',
    isInstalled: false,
    flagEmoji: '🌎',
  ),
  TranscriptionLocaleOption(
    identifier: 'es-US',
    displayName: 'Spanish (United States)',
    isInstalled: false,
    flagEmoji: '🇺🇸',
  ),
  TranscriptionLocaleOption(
    identifier: 'es-CO',
    displayName: 'Spanish (Colombia)',
    isInstalled: false,
    flagEmoji: '🇨🇴',
  ),
  TranscriptionLocaleOption(
    identifier: 'es-CL',
    displayName: 'Spanish (Chile)',
    isInstalled: false,
    flagEmoji: '🇨🇱',
  ),
  TranscriptionLocaleOption(
    identifier: 'fr-FR',
    displayName: 'French (France)',
    isInstalled: false,
    flagEmoji: '🇫🇷',
  ),
  TranscriptionLocaleOption(
    identifier: 'fr-CA',
    displayName: 'French (Canada)',
    isInstalled: false,
    flagEmoji: '🇨🇦',
  ),
  TranscriptionLocaleOption(
    identifier: 'fr-BE',
    displayName: 'French (Belgium)',
    isInstalled: false,
    flagEmoji: '🇧🇪',
  ),
  TranscriptionLocaleOption(
    identifier: 'fr-CH',
    displayName: 'French (Switzerland)',
    isInstalled: false,
    flagEmoji: '🇨🇭',
  ),
  TranscriptionLocaleOption(
    identifier: 'de-DE',
    displayName: 'German (Germany)',
    isInstalled: false,
    flagEmoji: '🇩🇪',
  ),
  TranscriptionLocaleOption(
    identifier: 'de-AT',
    displayName: 'German (Austria)',
    isInstalled: false,
    flagEmoji: '🇦🇹',
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
    identifier: 'zh-CN',
    displayName: 'Mandarin (Mainland China)',
    isInstalled: false,
    flagEmoji: '🇨🇳',
  ),
  TranscriptionLocaleOption(
    identifier: 'zh-TW',
    displayName: 'Mandarin (Taiwan)',
    isInstalled: false,
    flagEmoji: '🇹🇼',
  ),
  TranscriptionLocaleOption(
    identifier: 'zh-HK',
    displayName: 'Cantonese (Hong Kong)',
    isInstalled: false,
    flagEmoji: '🇭🇰',
  ),
  TranscriptionLocaleOption(
    identifier: 'yue-CN',
    displayName: 'Cantonese (China mainland)',
    isInstalled: false,
    flagEmoji: '🇨🇳',
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
    identifier: 'ar-SA',
    displayName: 'Arabic (Saudi Arabia)',
    isInstalled: false,
    flagEmoji: '🇸🇦',
  ),
  TranscriptionLocaleOption(
    identifier: 'ar-AE',
    displayName: 'Arabic (United Arab Emirates)',
    isInstalled: false,
    flagEmoji: '🇦🇪',
  ),
  TranscriptionLocaleOption(
    identifier: 'ru-RU',
    displayName: 'Russian (Russia)',
    isInstalled: false,
    flagEmoji: '🇷🇺',
  ),
  TranscriptionLocaleOption(
    identifier: 'hi-IN',
    displayName: 'Hindi (India)',
    isInstalled: false,
    flagEmoji: '🇮🇳',
  ),
  TranscriptionLocaleOption(
    identifier: 'id-ID',
    displayName: 'Indonesian (Indonesia)',
    isInstalled: false,
    flagEmoji: '🇮🇩',
  ),
  TranscriptionLocaleOption(
    identifier: 'vi-VN',
    displayName: 'Vietnamese (Vietnam)',
    isInstalled: false,
    flagEmoji: '🇻🇳',
  ),
  TranscriptionLocaleOption(
    identifier: 'th-TH',
    displayName: 'Thai (Thailand)',
    isInstalled: false,
    flagEmoji: '🇹🇭',
  ),
  TranscriptionLocaleOption(
    identifier: 'tr-TR',
    displayName: 'Turkish (Türkiye)',
    isInstalled: false,
    flagEmoji: '🇹🇷',
  ),
  TranscriptionLocaleOption(
    identifier: 'nl-NL',
    displayName: 'Dutch (Netherlands)',
    isInstalled: false,
    flagEmoji: '🇳🇱',
  ),
  TranscriptionLocaleOption(
    identifier: 'nl-BE',
    displayName: 'Dutch (Belgium)',
    isInstalled: false,
    flagEmoji: '🇧🇪',
  ),
  TranscriptionLocaleOption(
    identifier: 'pl-PL',
    displayName: 'Polish (Poland)',
    isInstalled: false,
    flagEmoji: '🇵🇱',
  ),
  TranscriptionLocaleOption(
    identifier: 'sv-SE',
    displayName: 'Swedish (Sweden)',
    isInstalled: false,
    flagEmoji: '🇸🇪',
  ),
  TranscriptionLocaleOption(
    identifier: 'da-DK',
    displayName: 'Danish (Denmark)',
    isInstalled: false,
    flagEmoji: '🇩🇰',
  ),
  TranscriptionLocaleOption(
    identifier: 'nb-NO',
    displayName: 'Norwegian Bokmål (Norway)',
    isInstalled: false,
    flagEmoji: '🇳🇴',
  ),
  TranscriptionLocaleOption(
    identifier: 'fi-FI',
    displayName: 'Finnish (Finland)',
    isInstalled: false,
    flagEmoji: '🇫🇮',
  ),
  TranscriptionLocaleOption(
    identifier: 'uk-UA',
    displayName: 'Ukrainian (Ukraine)',
    isInstalled: false,
    flagEmoji: '🇺🇦',
  ),
  TranscriptionLocaleOption(
    identifier: 'el-GR',
    displayName: 'Greek (Greece)',
    isInstalled: false,
    flagEmoji: '🇬🇷',
  ),
  TranscriptionLocaleOption(
    identifier: 'cs-CZ',
    displayName: 'Czech (Czechia)',
    isInstalled: false,
    flagEmoji: '🇨🇿',
  ),
  TranscriptionLocaleOption(
    identifier: 'sk-SK',
    displayName: 'Slovak (Slovakia)',
    isInstalled: false,
    flagEmoji: '🇸🇰',
  ),
  TranscriptionLocaleOption(
    identifier: 'hu-HU',
    displayName: 'Hungarian (Hungary)',
    isInstalled: false,
    flagEmoji: '🇭🇺',
  ),
  TranscriptionLocaleOption(
    identifier: 'ro-RO',
    displayName: 'Romanian (Romania)',
    isInstalled: false,
    flagEmoji: '🇷🇴',
  ),
  TranscriptionLocaleOption(
    identifier: 'hr-HR',
    displayName: 'Croatian (Croatia)',
    isInstalled: false,
    flagEmoji: '🇭🇷',
  ),
  TranscriptionLocaleOption(
    identifier: 'he-IL',
    displayName: 'Hebrew (Israel)',
    isInstalled: false,
    flagEmoji: '🇮🇱',
  ),
  TranscriptionLocaleOption(
    identifier: 'ms-MY',
    displayName: 'Malay (Malaysia)',
    isInstalled: false,
    flagEmoji: '🇲🇾',
  ),
  TranscriptionLocaleOption(
    identifier: 'ca-ES',
    displayName: 'Catalan (Spain)',
    isInstalled: false,
    flagEmoji: '🇪🇸',
  ),
];

/// Keep picker exclusions consistent across device, API and cached source lists.
List<TranscriptionLocaleOption> availableProfileLanguages(
  Iterable<TranscriptionLocaleOption> options, {
  bool nativeLanguage = false,
}) => options
    .where(
      (option) =>
          supportsAudioDialogueLanguage(option.identifier) &&
          (!nativeLanguage ||
              normalizeLocaleIdentifierForLookup(option.identifier) !=
                  'yue-cn'),
    )
    .toList();

/// Full audio dialogues require supported transcription/timing as well as TTS.
bool supportsAudioDialogueLanguage(String identifier) =>
    primaryLanguageCodeForLocaleIdentifier(identifier) != 'mi';

/// Māori stays a learning-only choice. Testing-only availability is marked for
/// admins; public rollout removes the badge for everyone, including admins.
/// Reapply role and rollout state when opening cached pickers.
List<TranscriptionLocaleOption> profileLanguageOptionsForRole(
  Iterable<TranscriptionLocaleOption> options, {
  required bool isAdmin,
  bool maoriPublicEnabled = false,
  bool nativeLanguage = false,
  bool preferNewZealand = false,
}) {
  final visible = availableProfileLanguages(
    options,
    nativeLanguage: nativeLanguage,
  );
  if (nativeLanguage) return visible;
  // Restore the curated catalog order, including lists cached while in NZ.
  final ranks = {
    for (var i = 0; i < kFallbackLearningLanguages.length; i++)
      normalizeLocaleIdentifierForLookup(
        kFallbackLearningLanguages[i].identifier,
      ): i,
  };
  final indexed = visible.indexed.toList();
  indexed.sort((a, b) {
    final rankA =
        ranks[normalizeLocaleIdentifierForLookup(a.$2.identifier)] ??
        ranks.length;
    final rankB =
        ranks[normalizeLocaleIdentifierForLookup(b.$2.identifier)] ??
        ranks.length;
    final order = rankA.compareTo(rankB);
    return order != 0 ? order : a.$1.compareTo(b.$1);
  });
  visible
    ..clear()
    ..addAll(indexed.map((entry) => entry.$2));
  if (isAdmin || maoriPublicEnabled) {
    visible.add(
      TranscriptionLocaleOption(
        identifier: 'mi-NZ',
        displayName: 'Māori (New Zealand)',
        isInstalled: false,
        isAdminOnly: !maoriPublicEnabled,
        flagEmoji: '🇳🇿',
      ),
    );
  }
  if (preferNewZealand) {
    for (final code in ['en-nz', 'mi-nz']) {
      final index = visible.indexWhere(
        (option) =>
            normalizeLocaleIdentifierForLookup(option.identifier) == code,
      );
      if (index > 0) visible.insert(0, visible.removeAt(index));
    }
  }
  return visible;
}

bool supportsQuickPracticeLanguage(
  String identifier, {
  required bool isAdmin,
  bool maoriPublicEnabled = false,
}) =>
    supportsAudioDialogueLanguage(identifier) ||
    ((isAdmin || maoriPublicEnabled) &&
        normalizeLocaleIdentifierForLookup(identifier) == 'mi-nz');
