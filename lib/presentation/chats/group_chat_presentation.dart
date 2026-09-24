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
