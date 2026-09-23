import 'package:flutter/material.dart';

/// User-chosen UI language (persisted). [system] follows the device locale
/// with [resolvePlatformLocale] when computing the effective [Locale].
///
/// Declaration order is the order shown in the language picker.
enum AppLocalePreference {
  system('system', null, 'System default', null),
  en('en', Locale('en'), 'English', '🇺🇸'),
  zhCn('zh_CN', Locale('zh'), '中文（简体）', '🇨🇳'),
  zhHant(
    'zh_Hant',
    Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hant'),
    '中文（繁體）',
    '🇭🇰',
  ),
  ja('ja', Locale('ja'), '日本語', '🇯🇵'),
  ko('ko', Locale('ko'), '한국어', '🇰🇷'),
  es('es', Locale('es'), 'Español', '🇲🇽'),
  ptBr('pt_BR', Locale('pt'), 'Português (Brasil)', '🇧🇷'),
  de('de', Locale('de'), 'Deutsch', '🇩🇪'),
  fr('fr', Locale('fr'), 'Français', '🇫🇷'),
  vi('vi', Locale('vi'), 'Tiếng Việt', '🇻🇳'),
  id('id', Locale('id'), 'Bahasa Indonesia', '🇮🇩'),
  tr('tr', Locale('tr'), 'Türkçe', '🇹🇷'),
  th('th', Locale('th'), 'ไทย', '🇹🇭'),
  it('it', Locale('it'), 'Italiano', '🇮🇹'),
  pl('pl', Locale('pl'), 'Polski', '🇵🇱'),
  ru('ru', Locale('ru'), 'Русский', '🇷🇺'),
  uk('uk', Locale('uk'), 'Українська', '🇺🇦');

  const AppLocalePreference(
    this.storageValue,
    this.explicitLocale,
    this.autonym,
    this.flagEmoji,
  );

  /// Persisted value. Existing values (`en`, `zh_CN`, `ko`, `ja`) must not change.
  final String storageValue;

  /// Fixed locale when not following system; null means use platform resolution.
  final Locale? explicitLocale;

  /// Name in the language's own script; never translated. [system] stays in English.
  final String autonym;

  final String? flagEmoji;

  /// Picker label, e.g. "🇭🇰  中文（繁體）".
  String get label => flagEmoji == null ? autonym : '$flagEmoji  $autonym';

  static AppLocalePreference fromStorage(String? raw) {
    final value = raw?.trim();
    for (final preference in values) {
      if (preference.storageValue == value) return preference;
    }
    return AppLocalePreference.system;
  }
}

const _kTraditionalChineseRegions = {'TW', 'HK', 'MO'};

/// Maps the device locale to a supported UI language, else English.
/// Chinese uses Traditional for the Hant script or TW / HK / MO, else Simplified.
Locale resolvePlatformLocale(Locale platform) {
  final lang = platform.languageCode;
  if (lang == 'zh') {
    final traditional =
        platform.scriptCode == 'Hant' ||
        (platform.scriptCode == null &&
            _kTraditionalChineseRegions.contains(platform.countryCode));
    return traditional
        ? AppLocalePreference.zhHant.explicitLocale!
        : AppLocalePreference.zhCn.explicitLocale!;
  }
  // Older Android versions report Indonesian as "in".
  final code = lang == 'in' ? 'id' : lang;
  for (final preference in AppLocalePreference.values) {
    final locale = preference.explicitLocale;
    if (locale != null &&
        locale.scriptCode == null &&
        locale.languageCode == code) {
      return locale;
    }
  }
  return const Locale('en');
}

/// Effective app [Locale] for [MaterialApp.locale] (always a supported one).
Locale resolveAppLocale({
  required AppLocalePreference preference,
  required Locale platformLocale,
}) {
  final fixed = preference.explicitLocale;
  if (fixed != null) {
    return fixed;
  }
  return resolvePlatformLocale(platformLocale);
}
