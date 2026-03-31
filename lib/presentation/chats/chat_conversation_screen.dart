import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../../core/theme.dart';
import '../../domain/models/models.dart';

class ChatConversationScreen extends StatefulWidget {
  final ChatThread thread;
  final User partner;

  const ChatConversationScreen({super.key, required this.thread, required this.partner});

  @override
  State<ChatConversationScreen> createState() => _ChatConversationScreenState();
}

class _ChatConversationScreenState extends State<ChatConversationScreen> {
  bool _showTranslation = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BanteraTheme.backgroundLight,
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(radius: 16, backgroundImage: NetworkImage(widget.partner.avatarUrl)),
            const SizedBox(width: 8),
            Text(widget.partner.displayName),
          ],
        ),
        actions: [
          IconButton(icon: const Icon(Icons.info_outline), onPressed: () {}),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildMessageBubble(context, widget.thread.lastMessage),
              ],
            ),
          ),
          SafeArea(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: BanteraTheme.surfaceColorLight,
              child: Row(
                children: [
                   IconButton(icon: const Icon(Icons.add_circle, color: BanteraTheme.textSecondaryLight, size: 28), onPressed: () {}),
                   Expanded(
                     child: Container(
                       height: 44,
                       decoration: BoxDecoration(
                         color: BanteraTheme.backgroundLight,
                         borderRadius: BorderRadius.circular(22),
                       ),
                       alignment: Alignment.center,
                       child: const Text('Hold to Record', style: TextStyle(color: BanteraTheme.textSecondaryLight)),
                     ),
                   ),
                   IconButton(icon: const Icon(CupertinoIcons.mic_solid, color: BanteraTheme.primaryColor, size: 28), onPressed: () {}),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(BuildContext context, ChatMessage message) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 24),
        width: MediaQuery.of(context).size.width * 0.75,
        decoration: BoxDecoration(
          color: BanteraTheme.surfaceColorLight,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
            bottomRight: Radius.circular(20),
            bottomLeft: Radius.circular(4),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  CircleAvatar(
                     radius: 20,
                     backgroundColor: BanteraTheme.primaryColor,
                     child: const Icon(Icons.play_arrow, color: Colors.white),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      height: 24,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Stack(
                         alignment: Alignment.centerLeft,
                         children: [
                           Container(width: 40, color: BanteraTheme.primaryColor.withOpacity(0.3)),
                         ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text('0:12', style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   Text(
                     message.transcriptPreview,
                     style: Theme.of(context).textTheme.bodyLarge,
                   ),
                   if (_showTranslation) ...[
                     const SizedBox(height: 8),
                     Text(
                       message.translatedPreview,
                       style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: BanteraTheme.primaryColor),
                     ),
                   ],
                   const SizedBox(height: 12),
                   Row(
                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                     children: [
                        Text('10:45 AM', style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 12)),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _showTranslation = !_showTranslation;
                            });
                          },
                          child: Icon(Icons.g_translate, color: _showTranslation ? BanteraTheme.primaryColor : Colors.grey[400], size: 18),
                        ),
                     ],
                   ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
