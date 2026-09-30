import 'dart:io';
import 'package:flutter/material.dart';
import '../../core/chat_session_notifier.dart';
import '../../domain/models/chat_models.dart';
import '../../l10n/app_localizations.dart';

class ChatImageMessage extends StatefulWidget {
  const ChatImageMessage({super.key, required this.message});
  final ChatMessageItem message;
  @override
  State<ChatImageMessage> createState() => _ChatImageMessageState();
}

class _ChatImageMessageState extends State<ChatImageMessage> {
  late Future<File> _file;
  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    _file = ChatSessionNotifier.instance.ensureLocalAudio(widget.message);
  }

  @override
  void didUpdateWidget(ChatImageMessage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.message.messageId != widget.message.messageId) _load();
  }

  @override
  Widget build(BuildContext context) => FutureBuilder<File>(
    future: _file,
    builder: (context, snapshot) {
      if (snapshot.hasError) {
        return TextButton.icon(
          onPressed: () => setState(_load),
          icon: const Icon(Icons.refresh),
          label: Text(AppLocalizations.of(context)!.wordActivityShareFailed),
        );
      }
      if (!snapshot.hasData) {
        return const SizedBox(
          height: 120,
          child: Center(child: CircularProgressIndicator()),
        );
      }
      final file = snapshot.data!;
      return InkWell(
        onTap: () => showDialog<void>(
          context: context,
          builder: (_) => Dialog(
            child: Stack(
              children: [
                InteractiveViewer(child: Image.file(file, fit: BoxFit.contain)),
                Positioned(
                  top: 0,
                  right: 0,
                  child: IconButton.filledTonal(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                  ),
                ),
              ],
            ),
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Image.file(file, width: 240, fit: BoxFit.contain),
        ),
      );
    },
  );
}
