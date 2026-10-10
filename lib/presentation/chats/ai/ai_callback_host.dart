import 'package:flutter/material.dart';
import '../../../core/ai_callback_notifier.dart';
import '../../../l10n/app_localizations.dart';
import 'ai_chat_screen.dart';
import 'ai_avatar.dart';

class AiCallbackHost extends StatelessWidget {
  const AiCallbackHost({super.key, this.callback});
  final AiCallbackNotifier? callback;
  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: callback ?? AiCallbackNotifier.instance,
    builder: (context, _) {
      final callback = this.callback ?? AiCallbackNotifier.instance;
      // CallKit owns incoming audio-call presentation on iOS. Answering never
      // creates a conversation route; the user can open Chats independently.
      if (callback.usesSystemCallInterface) return const SizedBox.shrink();
      if (callback.id == null) return const SizedBox.shrink();
      if (callback.accepted) {
        return Positioned.fill(
          child: Navigator(
            key: ValueKey(callback.id),
            onGenerateRoute: (_) => MaterialPageRoute<void>(
              builder: (_) => AiChatScreen(
                controller: callback.controller,
                onClose: callback.close,
              ),
            ),
          ),
        );
      }
      final l = AppLocalizations.of(context)!;
      return Positioned.fill(
        child: ColoredBox(
          color: Colors.black54,
          child: Center(
            child: Card(
              margin: const EdgeInsets.all(24),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const AiAvatar(radius: 28),
                    const SizedBox(height: 16),
                    const Text(
                      'Bantera AI',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(l.chatAudioIncoming),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextButton(
                          onPressed: callback.close,
                          child: Text(l.chatCallDecline),
                        ),
                        const SizedBox(width: 16),
                        FilledButton.icon(
                          onPressed: callback.accepting
                              ? null
                              : callback.accept,
                          icon: const Icon(Icons.call),
                          label: Text(l.chatCallAccept),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    },
  );
}
