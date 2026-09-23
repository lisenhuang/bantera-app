import 'package:app/core/app_locale.dart';
import 'package:app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('existing stored values keep working', () {
    expect(AppLocalePreference.fromStorage('en'), AppLocalePreference.en);
    expect(AppLocalePreference.fromStorage('zh_CN'), AppLocalePreference.zhCn);
    expect(AppLocalePreference.fromStorage('ko'), AppLocalePreference.ko);
    expect(AppLocalePreference.fromStorage('ja'), AppLocalePreference.ja);
    expect(AppLocalePreference.fromStorage(null), AppLocalePreference.system);
    expect(AppLocalePreference.fromStorage('xx'), AppLocalePreference.system);
  });

  test('every preference round-trips through storage', () {
    for (final p in AppLocalePreference.values) {
      expect(AppLocalePreference.fromStorage(p.storageValue), p);
    }
  });

  test('Traditional Chinese uses the Hong Kong flag', () {
    expect(AppLocalePreference.zhHant.label, '🇭🇰  中文（繁體）');
  });

  test('device Chinese maps to Simplified or Traditional', () {
    Locale resolve(String lang, {String? script, String? country}) =>
        resolvePlatformLocale(
          Locale.fromSubtags(
            languageCode: lang,
            scriptCode: script,
            countryCode: country,
          ),
        );
    final hant = AppLocalePreference.zhHant.explicitLocale;
    expect(resolve('zh', script: 'Hant', country: 'HK'), hant);
    expect(resolve('zh', script: 'Hant'), hant);
    expect(resolve('zh', country: 'TW'), hant);
    expect(resolve('zh', country: 'MO'), hant);
    expect(resolve('zh', script: 'Hans', country: 'CN'), const Locale('zh'));
    expect(resolve('zh', country: 'SG'), const Locale('zh'));
  });

  test('device languages map to supported UI languages, else English', () {
    expect(resolvePlatformLocale(const Locale('pt', 'PT')), const Locale('pt'));
    expect(resolvePlatformLocale(const Locale('es', 'ES')), const Locale('es'));
    expect(resolvePlatformLocale(const Locale('uk', 'UA')), const Locale('uk'));
    expect(resolvePlatformLocale(const Locale('in', 'ID')), const Locale('id'));
    expect(resolvePlatformLocale(const Locale('nl', 'NL')), const Locale('en'));
  });

  test('every picker language has app and Material translations', () async {
    for (final p in AppLocalePreference.values) {
      final locale = p.explicitLocale;
      if (locale == null) continue;
      expect(
        AppLocalizations.delegate.isSupported(locale),
        isTrue,
        reason: '$p',
      );
      expect(
        GlobalMaterialLocalizations.delegate.isSupported(locale),
        isTrue,
        reason: '$p',
      );
      final l10n = await AppLocalizations.delegate.load(locale);
      expect(l10n.appName, 'Bantera');
    }
    final hant = await AppLocalizations.delegate.load(
      AppLocalePreference.zhHant.explicitLocale!,
    );
    final hans = await AppLocalizations.delegate.load(const Locale('zh'));
    expect(hant.sectionAccount, isNot(hans.sectionAccount));
  });
}
