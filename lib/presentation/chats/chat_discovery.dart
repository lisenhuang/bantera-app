import '../../domain/models/chat_models.dart';

// Keep these families aligned with the backend ChatLanguageResolver.
String? chatLanguageMatchKey(String? language) {
  final code = language?.trim().replaceAll('_', '-').toLowerCase();
  if (code == null || code.isEmpty) return null;
  if (code == 'zh-cn' || code == 'zh-sg' || code.startsWith('zh-hans')) {
    return 'zh';
  }
  if (code.startsWith('zh-')) return code;
  return code.split('-').first;
}

bool sameChatLanguage(String? first, String? second) {
  final key = chatLanguageMatchKey(first);
  return key != null && key == chatLanguageMatchKey(second);
}

List<ChatUserSummary> discoverableOnlineUsers({
  required Iterable<ChatUserSummary> users,
  required Set<String> existingDmUserIds,
  required String? learningLanguage,
  required String? nativeLanguage,
}) => users.where((other) {
  if (existingDmUserIds.contains(other.id)) return false;
  if (sameChatLanguage(nativeLanguage, other.nativeLanguage)) {
    return false;
  }
  return sameChatLanguage(learningLanguage, other.learningLanguage) ||
      sameChatLanguage(learningLanguage, other.nativeLanguage) ||
      sameChatLanguage(nativeLanguage, other.learningLanguage);
}).toList();
