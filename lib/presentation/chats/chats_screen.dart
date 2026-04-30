import 'package:flutter/material.dart';

import '../../core/chat_session_notifier.dart';
import '../../domain/models/chat_models.dart';
import '../../l10n/app_localizations.dart';
import '../shared/locale_flag.dart';
import '../shared/profile_avatar.dart';
import 'chat_conversation_screen.dart';

class ChatsScreen extends StatefulWidget {
  const ChatsScreen({super.key});

  @override
  State<ChatsScreen> createState() => _ChatsScreenState();
}

class _ChatsScreenState extends State<ChatsScreen> {
  final ChatSessionNotifier _chat = ChatSessionNotifier.instance;

  @override
  void initState() {
    super.initState();
    Future<void>.microtask(
      () => _chat.refreshBootstrap(showLoadingState: false),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.chatsTitle)),
      body: RefreshIndicator(
        onRefresh: () => _chat.refreshBootstrap(),
        child: ListenableBuilder(
          listenable: _chat,
          builder: (context, _) {
            return StreamBuilder<List<ChatThreadSummary>>(
              stream: _chat.watchGroups(),
              builder: (context, groupsSnapshot) {
                return StreamBuilder<List<ChatUserSummary>>(
                  stream: _chat.watchOnlineUsers(),
                  builder: (context, usersSnapshot) {
                    return StreamBuilder<List<ChatThreadSummary>>(
                      stream: _chat.watchDirectMessages(),
                      builder: (context, dmsSnapshot) {
                        final items = _buildHomeItems(
                          l10n,
                          groupsSnapshot.data ?? const <ChatThreadSummary>[],
                          usersSnapshot.data ?? const <ChatUserSummary>[],
                          dmsSnapshot.data ?? const <ChatThreadSummary>[],
                        );
                        if (items.isEmpty && _chat.isLoading) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }

                        if (items.isEmpty) {
                          return ListView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            children: [
                              const SizedBox(height: 160),
                              Center(child: Text(l10n.chatNoChatsYet)),
                            ],
                          );
                        }

                        return ListView.builder(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                          itemCount: items.length,
                          itemBuilder: (context, index) {
                            final item = items[index];
                            return switch (item) {
                              _ChatSectionHeaderItem() => Padding(
                                padding: const EdgeInsets.only(
                                  top: 16,
                                  bottom: 8,
                                ),
                                child: Text(
                                  item.title,
                                  style: Theme.of(context).textTheme.titleMedium
                                      ?.copyWith(
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.primary,
                                      ),
                                ),
                              ),
                              _ChatThreadItem() => _ThreadCard(
                                thread: item.thread,
                                onTap: () => Navigator.of(context).push(
                                  MaterialPageRoute<void>(
                                    builder: (_) =>
                                        ChatConversationScreen.thread(
                                          thread: item.thread,
                                        ),
                                  ),
                                ),
                              ),
                              _ChatUserItem() => _UserCard(
                                user: item.user,
                                onTap: () => Navigator.of(context).push(
                                  MaterialPageRoute<void>(
                                    builder: (_) =>
                                        ChatConversationScreen.directUser(
                                          partner: item.user,
                                        ),
                                  ),
                                ),
                              ),
                            };
                          },
                        );
                      },
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }

  List<_ChatHomeItem> _buildHomeItems(
    AppLocalizations l10n,
    List<ChatThreadSummary> groups,
    List<ChatUserSummary> onlineUsers,
    List<ChatThreadSummary> dms,
  ) {
    return <_ChatHomeItem>[
      _ChatSectionHeaderItem(l10n.chatOnlineSection),
      ...groups.map((thread) => _ChatThreadItem(thread)),
      ...onlineUsers.map((user) => _ChatUserItem(user)),
      _ChatSectionHeaderItem(l10n.chatDirectMessagesSection),
      ...dms.map((thread) => _ChatThreadItem(thread)),
    ];
  }
}

sealed class _ChatHomeItem {
  const _ChatHomeItem();
}

class _ChatSectionHeaderItem extends _ChatHomeItem {
  const _ChatSectionHeaderItem(this.title);

  final String title;
}

class _ChatThreadItem extends _ChatHomeItem {
  const _ChatThreadItem(this.thread);

  final ChatThreadSummary thread;
}

class _ChatUserItem extends _ChatHomeItem {
  const _ChatUserItem(this.user);

  final ChatUserSummary user;
}

class _ThreadCard extends StatelessWidget {
  const _ThreadCard({required this.thread, required this.onTap});

  final ChatThreadSummary thread;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final subtitle = [
      if (thread.isGroup) ...thread.roleBadges,
      if (thread.learningLanguageDisplay != null)
        thread.learningLanguageDisplay,
      if (thread.nativeLanguageDisplay != null && !thread.isGroup)
        thread.nativeLanguageDisplay,
    ].whereType<String>().where((value) => value.isNotEmpty).join(' • ');

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 10,
        ),
        leading: thread.isGroup
            ? CircleAvatar(
                backgroundColor: theme.colorScheme.primary.withValues(
                  alpha: 0.12,
                ),
                child: const Icon(Icons.groups_rounded),
              )
            : ProfileAvatar(radius: 22, imageUrl: thread.avatarUrl),
        title: Row(
          children: [
            Expanded(
              child: Text(
                thread.title,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleMedium,
              ),
            ),
            if (thread.isMuted)
              Icon(
                Icons.notifications_off_outlined,
                size: 18,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            if (thread.unreadCount > 0) ...[
              const SizedBox(width: 8),
              CircleAvatar(
                radius: 11,
                backgroundColor: theme.colorScheme.primary,
                child: Text(
                  '${thread.unreadCount}',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onPrimary,
                  ),
                ),
              ),
            ],
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (subtitle.isNotEmpty)
                Text(subtitle, maxLines: 2, overflow: TextOverflow.ellipsis),
              if (thread.lastMessageDurationMs != null)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    l10n.chatAudioDuration(
                      _formatDuration(thread.lastMessageDurationMs!),
                    ),
                    style: theme.textTheme.bodySmall,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _UserCard extends StatelessWidget {
  const _UserCard({required this.user, required this.onTap});

  final ChatUserSummary user;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final languages = [
      _languageLabel(user.learningLanguage, user.learningLanguageDisplay),
      _languageLabel(user.nativeLanguage, user.nativeLanguageDisplay),
    ].whereType<String>().join(' • ');

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 10,
        ),
        leading: Stack(
          children: [
            ProfileAvatar(radius: 22, imageUrl: user.avatarUrl),
            Positioned(
              right: 0,
              bottom: 0,
              child: CircleAvatar(
                radius: 6,
                backgroundColor: user.isOnline ? Colors.green : Colors.grey,
              ),
            ),
          ],
        ),
        title: Text(user.name),
        subtitle: Text(languages, maxLines: 2, overflow: TextOverflow.ellipsis),
      ),
    );
  }

  String? _languageLabel(String? identifier, String? displayName) {
    final value = displayName ?? identifier;
    if (value == null || value.trim().isEmpty) {
      return null;
    }
    final flag = identifier == null || identifier.trim().isEmpty
        ? '🌐'
        : flagEmojiForLocale(identifier);
    return '$flag $value';
  }
}

String _formatDuration(int durationMs) {
  final totalSeconds = (durationMs / 1000).round();
  final minutes = totalSeconds ~/ 60;
  final seconds = totalSeconds % 60;
  return '$minutes:${seconds.toString().padLeft(2, '0')}';
}
