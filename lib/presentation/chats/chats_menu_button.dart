import 'dart:async';

import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../l10n/app_localizations.dart';
import '../shared/adaptive_overlays.dart';
import 'chat_menu_item_row.dart';

class ChatsMenuButton extends StatefulWidget {
  const ChatsMenuButton({
    super.key,
    required this.owner,
    required this.notificationsEnabled,
    required this.onNotificationsChanged,
    required this.onBlockedUsers,
  });

  final String? owner;
  final bool notificationsEnabled;
  final Future<void> Function(bool enabled) onNotificationsChanged;
  final VoidCallback onBlockedUsers;

  @override
  State<ChatsMenuButton> createState() => _ChatsMenuButtonState();
}

enum _ChatsMenuAction { notifications, blockedUsers }

class _ChatsMenuButtonState extends State<ChatsMenuButton> {
  bool _updating = false;
  bool _saving = false;

  bool _sameOwner(String owner) => mounted && widget.owner == owner;

  Future<void> _toggleNotifications() async {
    final owner = widget.owner;
    if (owner == null || _updating) return;
    final enabled = !widget.notificationsEnabled;
    final l = AppLocalizations.of(context)!;
    setState(() => _updating = true);
    try {
      if (!enabled) {
        final confirmed = await showBanteraDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            scrollable: true,
            title: Text(l.chatDisableAllNotificationsTitle),
            content: Text(l.chatDisableAllNotificationsBody),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(l.cancel),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text(l.chatMuteNotifications),
              ),
            ],
          ),
        );
        if (confirmed != true || !mounted || !_sameOwner(owner)) return;
      } else {
        // Match Settings: do not enable account alerts if the OS denies them.
        var status = await Permission.notification.status;
        if (!mounted || !_sameOwner(owner)) return;
        if (!status.isGranted) {
          status = await Permission.notification.request();
          if (!mounted || !_sameOwner(owner)) return;
        }
        if (!status.isGranted) {
          final permanentlyDenied =
              status.isPermanentlyDenied || status.isRestricted;
          await showBanteraDialog<void>(
            context: context,
            builder: (context) => AlertDialog(
              scrollable: true,
              title: Text(l.chatNotificationsDisabledTitle),
              content: Text(
                permanentlyDenied
                    ? l.chatNotificationsDisabledSettings
                    : l.chatNotificationsDisabledBody,
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(l.closeLabel),
                ),
                if (permanentlyDenied)
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      unawaited(openAppSettings());
                    },
                    child: Text(l.permissionsOpenSettings),
                  ),
              ],
            ),
          );
          return;
        }
      }
      if (!_sameOwner(owner) || widget.notificationsEnabled == enabled) return;
      // The notifier publishes the new value after the server has saved it.
      setState(() => _saving = true);
      await widget.onNotificationsChanged(enabled);
    } on Exception {
      if (mounted && _sameOwner(owner)) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l.chatNotificationUpdateFailed)));
      }
    } finally {
      if (mounted) {
        setState(() {
          _updating = false;
          _saving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return PopupMenuButton<_ChatsMenuAction>(
      enabled: !_updating,
      icon: _saving
          ? const SizedBox.square(
              dimension: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Icon(Icons.more_vert),
      onSelected: (action) {
        switch (action) {
          case _ChatsMenuAction.notifications:
            unawaited(_toggleNotifications());
          case _ChatsMenuAction.blockedUsers:
            widget.onBlockedUsers();
        }
      },
      itemBuilder: (context) => [
        PopupMenuItem(
          value: _ChatsMenuAction.notifications,
          enabled: widget.owner != null,
          child: ChatMenuItemRow(
            icon: widget.notificationsEnabled
                ? Icons.notifications_off_outlined
                : Icons.notifications_active_outlined,
            label: widget.notificationsEnabled
                ? l.chatMuteNotifications
                : l.chatEnableNotifications,
          ),
        ),
        PopupMenuItem(
          value: _ChatsMenuAction.blockedUsers,
          child: ChatMenuItemRow(
            icon: Icons.person_off_outlined,
            label: l.chatBlockedUsersMenu,
          ),
        ),
      ],
    );
  }
}
