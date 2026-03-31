import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../infrastructure/mock_data.dart';
import 'chat_conversation_screen.dart';

class ChatsScreen extends StatelessWidget {
  const ChatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final threads = MockData.recentChats;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chats'),
        actions: [
          IconButton(
             icon: const Icon(Icons.person_add_alt_1), 
             onPressed: () {},
          )
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: BanteraTheme.surfaceColorLight,
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                       elevation: 0,
                       backgroundColor: BanteraTheme.primaryColor.withOpacity(0.1),
                       foregroundColor: BanteraTheme.primaryColor,
                    ),
                    child: const Text('DMs'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(
                       foregroundColor: BanteraTheme.textSecondaryLight,
                       side: BorderSide(color: Colors.grey[300]!),
                    ),
                    child: const Text('Groups'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(
                       foregroundColor: BanteraTheme.textSecondaryLight,
                       side: BorderSide(color: Colors.grey[300]!),
                    ),
                    child: const Text('Exchange'),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.separated(
              itemCount: threads.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final thread = threads[index];
                final partner = thread.participants.firstWhere((p) => p.id != MockData.currentUser.id);

                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  leading: CircleAvatar(
                    radius: 28,
                    backgroundImage: NetworkImage(partner.avatarUrl),
                  ),
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(partner.displayName, style: Theme.of(context).textTheme.titleMedium),
                      Text('5m ago', style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 12)),
                    ],
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        const Icon(Icons.mic, size: 16, color: BanteraTheme.primaryColor),
                        const SizedBox(width: 4),
                        Text('0:${(thread.lastMessage.durationMs / 1000).round()}', style: const TextStyle(fontWeight: FontWeight.bold, color: BanteraTheme.primaryColor)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            thread.lastMessage.transcriptPreview,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                      ],
                    ),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChatConversationScreen(thread: thread, partner: partner),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
