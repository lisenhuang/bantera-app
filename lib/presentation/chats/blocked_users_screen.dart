import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/chat_session_notifier.dart';
import '../../domain/models/chat_models.dart';
import '../../l10n/app_localizations.dart';
import '../shared/profile_avatar.dart';

class BlockedUsersScreen extends StatefulWidget {
  const BlockedUsersScreen({super.key});

  @override
  State<BlockedUsersScreen> createState() => _BlockedUsersScreenState();
}

class _BlockedUsersScreenState extends State<BlockedUsersScreen> {
  final ChatSessionNotifier _chat = ChatSessionNotifier.instance;

  @override
  void initState() {
    super.initState();
    Future<void>.microtask(_chat.refreshBlockedUsers);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.chatBlockedUsersTitle)),
      body: RefreshIndicator(
        onRefresh: _chat.refreshBlockedUsers,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          children: const [BlockedUsersList()],
        ),
      ),
    );
  }
}

class BlockedUsersList extends StatefulWidget {
  const BlockedUsersList({super.key});

  @override
  State<BlockedUsersList> createState() => _BlockedUsersListState();
}

class _BlockedUsersListState extends State<BlockedUsersList> {
  final ChatSessionNotifier _chat = ChatSessionNotifier.instance;
  final Set<String> _unblockingIds = <String>{};

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return StreamBuilder<List<ChatUserSummary>>(
      stream: _chat.watchBlockedUsers(),
      builder: (context, snapshot) {
        final users = snapshot.data ?? const <ChatUserSummary>[];
        if (users.isEmpty) {
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(l10n.chatNoBlockedUsers),
            ),
          );
        }

        return Column(
          children: users
              .map(
                (user) => Card(
                  child: ListTile(
                    leading: ProfileAvatar(
                      radius: 22,
                      imageUrl: user.avatarUrl,
                    ),
                    title: Text(user.name),
                    subtitle: Text(_languageSubtitle(user)),
                    trailing: TextButton(
                      onPressed: _unblockingIds.contains(user.id)
                          ? null
                          : () => _confirmAndUnblock(user),
                      child: Text(l10n.chatUnblock),
                    ),
                  ),
                ),
              )
              .toList(),
        );
      },
    );
  }

  String _languageSubtitle(ChatUserSummary user) {
    return [
      user.learningLanguageDisplay,
      user.nativeLanguageDisplay,
    ].whereType<String>().where((value) => value.isNotEmpty).join(' • ');
  }

  Future<void> _confirmAndUnblock(ChatUserSummary user) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.chatUnblockUserTitle(user.name)),
        content: Text(l10n.chatUnblockUserBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.confirmLabel),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) {
      return;
    }

    setState(() => _unblockingIds.add(user.id));
    try {
      await _chat.unblockUser(user.id);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.chatUnblockFailed)));
      }
    } finally {
      if (mounted) {
        setState(() => _unblockingIds.remove(user.id));
      }
    }
  }
}
