import 'package:flutter/material.dart';

/// User-chosen UI language (persisted). [system] follows the device locale
/// with [resolvePlatformLocale] when computing the effective [Locale].
enum AppLocalePreference {
  system,
  en,
  zhCn,
  ko,
  ja;

  static AppLocalePreference fromStorage(String? raw) {
    switch (raw?.trim()) {
      case 'en':
        return AppLocalePreference.en;
      case 'zh_CN':
        return AppLocalePreference.zhCn;
      case 'ko':
        return AppLocalePreference.ko;
      case 'ja':
        return AppLocalePreference.ja;
      case 'system':
      case '':
      case null:
        return AppLocalePreference.system;
      default:
        return AppLocalePreference.system;
    }
  }

  String get storageValue => switch (this) {
        AppLocalePreference.system => 'system',
        AppLocalePreference.en => 'en',
        AppLocalePreference.zhCn => 'zh_CN',
        AppLocalePreference.ko => 'ko',
        AppLocalePreference.ja => 'ja',
      };

  /// Fixed locale when not following system; null means use platform resolution.
  Locale? get explicitLocale => switch (this) {
        AppLocalePreference.system => null,
        AppLocalePreference.en => const Locale('en'),
        AppLocalePreference.zhCn => const Locale('zh'),
        AppLocalePreference.ko => const Locale('ko'),
        AppLocalePreference.ja => const Locale('ja'),
      };
}

/// Fixed display names for the language picker (each language in its own script).
class AppLocaleAutonyms {
  AppLocaleAutonyms._();

  /// Always shown in English (not translated with app locale).
  static const String systemDefault = 'System default';

  static const String english = 'English';
  static const String chineseSimplified = '中文（简体）';
  static const String korean = '한국어';
  static const String japanese = '日本語';
}

/// Maps device locale to one of: en, zh_CN, ko, ja. Any `zh_*` → zh_CN.
Locale resolvePlatformLocale(Locale platform) {
  final lang = platform.languageCode;
  if (lang == 'zh') {
    return const Locale('zh');
  }
  if (lang == 'ko') {
    return const Locale('ko');
  }
  if (lang == 'ja') {
    return const Locale('ja');
  }
  if (lang == 'en') {
    return const Locale('en');
  }
  return const Locale('en');
}

/// Effective app [Locale] for [MaterialApp.locale] (always one of the four).
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
