import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../infrastructure/ai/ai_history_store.dart';
import '../../../l10n/app_localizations.dart';
import 'ai_chat_controller.dart';

/// Saved bubbles remain references to the original, device-local conversation.
class AiSavedDialoguesScreen extends StatefulWidget {
  const AiSavedDialoguesScreen({super.key, required this.controller});

  final AiChatController controller;

  @override
  State<AiSavedDialoguesScreen> createState() => _AiSavedDialoguesScreenState();
}

class _AiSavedDialoguesScreenState extends State<AiSavedDialoguesScreen> {
  final _unsaving = <String>{};

  Future<void> _unsave(AiMessage message) async {
    if (!_unsaving.add(message.id)) return;
    setState(() {});
    try {
      await widget.controller.toggleSavedMessage(message);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.onboardingLoadFailed),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _unsaving.remove(message.id));
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
      appBar: AppBar(title: Text(l.aiSavedDialogues)),
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
                final unsaving = _unsaving.contains(message.id);
                return Card(
                  key: ValueKey('ai-saved-dialogue-${message.id}'),
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    onTap: () => Navigator.pop<String>(context, message.id),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 8, 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  message.role == 'user'
                                      ? l.aiDialogueYou
                                      : 'Bantera AI',
                                  style: theme.textTheme.labelLarge,
                                ),
                              ),
                              IconButton(
                                tooltip: l.aiUnsaveDialogue,
                                onPressed:
                                    unsaving ||
                                        !widget.controller.canSaveMessage(
                                          message,
                                        )
                                    ? null
                                    : () => _unsave(message),
                                icon: unsaving
                                    ? const SizedBox.square(
                                        dimension: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : Icon(
                                        Icons.bookmark_rounded,
                                        color: theme.colorScheme.primary,
                                      ),
                              ),
                            ],
                          ),
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
                );
              },
            );
          },
        ),
      ),
    );
  }
}
