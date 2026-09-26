import '../../domain/models/chat_models.dart';
import '../../infrastructure/learning_language_catalog.dart';
import '../../l10n/app_localizations.dart';
import '../shared/locale_flag.dart';

String groupChatTitle(ChatThreadSummary thread, AppLocalizations l10n) {
  return '${thread.title} ${l10n.chatGroupLabel}';
}

String groupChatEmoji(ChatThreadSummary thread) {
  // Group summaries currently provide a display title, but no language code.
  // Match that title to the app's language catalog until the API supplies one.
  final title = thread.title.trim();
  // These group titles use learning-catalog names absent from the smaller
  // embedded fallback list. Keep their regions distinct.
  const chineseGroupLocales = <String, String>{
    'chinese, mandarin (china mainland)': 'zh-CN',
    'chinese, mandarin (taiwan)': 'zh-TW',
    'cantonese (hong kong)': 'zh-HK',
    'cantonese (china mainland)': 'yue-CN',
  };
  final chineseLocale = chineseGroupLocales[title.toLowerCase()];
  if (chineseLocale != null) {
    return flagEmojiForLocale(chineseLocale);
  }
  for (final language in [
    ...kFallbackTranslationLanguages,
    ...kFallbackLearningLanguages,
  ]) {
    if (language.displayName.toLowerCase() == title.toLowerCase()) {
      return language.effectiveFlagEmoji;
    }
  }
  return '🌐';
}
