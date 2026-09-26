import 'package:app/domain/models/chat_models.dart';
import 'package:app/presentation/chats/group_chat_presentation.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  ChatThreadSummary group(String title) => ChatThreadSummary(
    threadId: 'thread',
    threadType: 'group',
    title: title,
    avatarUrl: null,
    learningLanguage: null,
    learningLanguageDisplay: null,
    nativeLanguage: null,
    nativeLanguageDisplay: null,
    isMuted: false,
    unreadCount: 0,
    lastMessageAt: null,
    lastMessageDurationMs: null,
    otherUser: null,
    roleBadges: const [],
    section: 'groups',
    sectionOrder: 0,
  );

  test('group chat icons distinguish mainland and Taiwan Mandarin', () {
    expect(groupChatEmoji(group('Chinese')), '🇨🇳');
    expect(groupChatEmoji(group('Chinese, Mandarin (Taiwan)')), '🇹🇼');
    expect(groupChatEmoji(group('Cantonese (Hong Kong)')), '🇭🇰');
    expect(groupChatEmoji(group('Cantonese (China mainland)')), '🇨🇳');
  });
}
