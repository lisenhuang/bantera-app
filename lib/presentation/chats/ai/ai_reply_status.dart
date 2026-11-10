import 'package:flutter/material.dart';
import '../../../infrastructure/ai/ai_reply_activity.dart';
import '../../../l10n/app_localizations.dart';

class AiReplyStatus extends StatelessWidget {
  const AiReplyStatus({super.key, required this.phase});
  final AiReplyPhase phase;
  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final label = switch (phase) {
      AiReplyPhase.sending => l.chatSendingAudio,
      AiReplyPhase.waiting => l.aiWaitingForReply,
      AiReplyPhase.vocabulary => l.aiCheckingVocabulary,
      AiReplyPhase.web => l.aiWebSearching,
      AiReplyPhase.images => l.aiImagesSearching,
      AiReplyPhase.videos => l.aiVideosSearching,
      AiReplyPhase.replying => l.aiReplying,
    };
    return Semantics(
      liveRegion: true,
      child: Row(
        children: [
          const SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(label)),
        ],
      ),
    );
  }
}
