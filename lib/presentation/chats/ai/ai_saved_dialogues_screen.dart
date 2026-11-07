import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../infrastructure/ai/ai_history_store.dart';
import '../../../l10n/app_localizations.dart';
import '../../shared/swipe_action_reveal.dart';
import 'ai_chat_controller.dart';

/// Saved bubbles remain references to the original, device-local conversation.
class AiSavedDialoguesScreen extends StatefulWidget {
  const AiSavedDialoguesScreen({super.key, required this.controller});

  final AiChatController controller;

  @override
  State<AiSavedDialoguesScreen> createState() => _AiSavedDialoguesScreenState();
}

class _AiSavedDialoguesScreenState extends State<AiSavedDialoguesScreen> {
  bool _removing = false;

  Future<void> _remove(List<AiMessage> messages, {bool all = false}) async {
    if (_removing) return;
    setState(() => _removing = true);
    final l = AppLocalizations.of(context)!;
    try {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          scrollable: true,
          title: Text(all ? l.aiClearSavedDialoguesTitle : l.aiUnsaveDialogue),
          content: Text(
            all ? l.aiClearSavedDialoguesBody : l.aiUnsaveDialogueBody,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(l.cancel),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(all ? l.clearAllLabel : l.aiUnsaveDialogue),
            ),
          ],
        ),
      );
      if (confirmed != true || !mounted) return;
      await widget.controller.removeSavedMessages(messages);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l.onboardingLoadFailed)));
      }
    } finally {
      if (mounted) setState(() => _removing = false);
    }
  }

  String _preview(AiMessage message, AppLocalizations l) {
    // Preserve link labels and normal punctuation while removing Markdown
    // markers from the compact, non-interactive preview.
    final text = message.displayText
        .replaceAllMapped(RegExp(r'!?\[([^\]]*)\]\([^)]*\)'), (m) => m[1]!)
        .replaceAll(RegExp(r'^\s{0,3}(?:#{1,6}\s+|>\s*)', multiLine: true), '')
        .replaceAll(RegExp(r'[*_`~]'), '')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
    if (text.isNotEmpty) return text;
    if (message.images.isNotEmpty) return l.aiImages;
    if (message.videos.isNotEmpty) return l.mediaKindVideo;
    if (message.emojis.isNotEmpty) return message.emojis.join(' ');
    return l.aiReminderMessage;
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final locale = Localizations.localeOf(context).toString();
    return Scaffold(
      appBar: AppBar(
        title: Text(l.aiSavedDialogues),
        actions: [
          ListenableBuilder(
            listenable: widget.controller,
            builder: (context, _) {
              final saved = widget.controller.messages
                  .where((message) => message.savedAt != null)
                  .toList();
              return IconButton(
                tooltip: l.clearAllLabel,
                icon: const Icon(Icons.delete_outline_rounded),
                onPressed:
                    !_removing &&
                        saved.isNotEmpty &&
                        saved.every(widget.controller.canSaveMessage)
                    ? () => _remove(saved, all: true)
                    : null,
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: ListenableBuilder(
          listenable: widget.controller,
          builder: (context, _) {
            final messages =
                widget.controller.messages
                    .where((message) => message.savedAt != null)
                    .toList()
                  ..sort((a, b) => b.savedAt!.compareTo(a.savedAt!));
            if (messages.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.bookmark_border_rounded,
                        size: 48,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        l.aiSavedDialoguesEmpty,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.titleMedium,
                      ),
                    ],
                  ),
                ),
              );
            }
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final message = messages[index];
                final savedAt = message.savedAt!.toLocal();
                final canRemove =
                    !_removing && widget.controller.canSaveMessage(message);
                return Card(
                  key: ValueKey('ai-saved-dialogue-${message.id}'),
                  clipBehavior: Clip.antiAlias,
                  child: SwipeActionReveal(
                    surfaceColor: theme.colorScheme.surfaceContainerLow,
                    actions: [
                      if (canRemove)
                        SwipeRevealAction(
                          label: l.aiUnsaveDialogue,
                          icon: const Icon(Icons.delete_outline_rounded),
                          onPressed: () => _remove([message]),
                          backgroundColor: Colors.transparent,
                          foregroundColor: theme.colorScheme.error,
                        ),
                    ],
                    child: InkWell(
                      onTap: () => Navigator.pop<String>(context, message.id),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              message.role == 'user'
                                  ? l.aiDialogueYou
                                  : 'Bantera AI',
                              style: theme.textTheme.labelLarge,
                            ),
                            const SizedBox(height: 8),
                            Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: Text(
                                _preview(message, l),
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.bodyLarge,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              '${DateFormat.yMMMd(locale).format(savedAt)} · ${TimeOfDay.fromDateTime(savedAt).format(context)}',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
