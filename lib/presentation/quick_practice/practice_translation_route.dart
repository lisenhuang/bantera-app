import '../../infrastructure/translation_service.dart';

String practiceTranslationLocale(String value) {
  final code = value.trim().replaceAll('_', '-');
  if (code.toLowerCase() == 'zh-hk' || code.toLowerCase() == 'zh-hant-hk') {
    return 'yue-HK'; // Cantonese must never silently become Mandarin.
  }
  return code;
}

String practiceTranslationLanguageKey(String value) {
  final parts = practiceTranslationLocale(value).toLowerCase().split('-');
  if (parts.first == 'zh') {
    return parts.contains('hant') ||
            parts.contains('tw') ||
            parts.contains('mo')
        ? 'zh-hant'
        : 'zh-hans';
  }
  return parts.first;
}

/// A verified path using at most two native translation sessions. This catalog
/// is exclusive to Practice; profile and other translation pickers stay unchanged.
class PracticeTranslationRoute extends TranslationLocaleOption {
  PracticeTranslationRoute(TranslationLocaleOption target, {this.viaEnglish})
    : super(
        identifier: target.identifier,
        displayName: target.displayName,
        isInstalled: target.isInstalled && (viaEnglish?.isInstalled ?? true),
      );

  final TranslationLocaleOption? viaEnglish;

  static Future<List<TranslationLocaleOption>> options({
    required String source,
    required bool Function() canContinue,
  }) async {
    final service = TranslationService.instance;
    final direct = await service.fetchSupportedLocales(
      sourceLocaleIdentifier: source,
    );
    final routes = <TranslationLocaleOption>[...direct];
    if (!canContinue() || practiceTranslationLanguageKey(source) == 'en') {
      return routes;
    }
    final english = direct
        .where((o) => practiceTranslationLanguageKey(o.identifier) == 'en')
        .firstOrNull;
    if (english == null) return routes;
    try {
      final onward = await service.fetchSupportedLocales(
        sourceLocaleIdentifier: english.identifier,
      );
      if (!canContinue()) return routes;
      final seen = direct
          .map((o) => practiceTranslationLanguageKey(o.identifier))
          .toSet();
      seen.add(practiceTranslationLanguageKey(source));
      for (final target in onward) {
        if (seen.add(practiceTranslationLanguageKey(target.identifier))) {
          routes.add(PracticeTranslationRoute(target, viaEnglish: english));
        }
      }
    } on TranslationException {
      // Discovery of extra destinations must not hide working direct pairs.
    }
    return routes;
  }
}
