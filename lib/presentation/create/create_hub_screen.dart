import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

import 'video_upload_screen.dart';

class CreateHubScreen extends StatelessWidget {
  const CreateHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.background,
      appBar: AppBar(
        title: const Text('Create'),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(CupertinoIcons.question_circle),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'What would you like to share today?',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 24),

            // Large Action Buttons
            Row(
              children: [
                Expanded(
                  child: _buildPrimaryAction(
                    context,
                    CupertinoIcons.mic,
                    'Record Audio',
                    colorScheme,
                    onTap: () {},
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildPrimaryAction(
                    context,
                    CupertinoIcons.video_camera,
                    'Upload Video',
                    colorScheme,
                    isSecondary: true,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => const VideoUploadScreen(),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildPrimaryAction(
                    context,
                    CupertinoIcons.doc_text,
                    'Import Transcript',
                    colorScheme,
                    isSecondary: true,
                    onTap: () {},
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildPrimaryAction(
                    context,
                    CupertinoIcons.link,
                    'Paste Link',
                    colorScheme,
                    isSecondary: true,
                    onTap: () {},
                  ),
                ),
              ],
            ),

            const SizedBox(height: 48),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Recent Drafts',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                TextButton(
                  onPressed: () {},
                  child: Text(
                    'See All',
                    style: TextStyle(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Mock Draft Items
            _buildDraftItem(
              context,
              'Ordering Coffee - Review',
              'Updated 2 hrs ago',
              '0:45',
              colorScheme,
            ),
            const SizedBox(height: 12),
            _buildDraftItem(
              context,
              'Airport Security Vocab',
              'Updated yesterday',
              '1:20',
              colorScheme,
            ),

            const SizedBox(height: 48),
            Text(
              'Uploading Tips',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: colorScheme.onSurface.withOpacity(0.05),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    CupertinoIcons.lightbulb_fill,
                    color: Colors.amber[600],
                    size: 32,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      'Keep your audio under 3 minutes for the best engagement. Clear subtitles are generated automatically!',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPrimaryAction(
    BuildContext context,
    IconData icon,
    String label,
    ColorScheme colorScheme, {
    required VoidCallback onTap,
    bool isSecondary = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 120,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSecondary ? colorScheme.surface : colorScheme.primary,
          borderRadius: BorderRadius.circular(20),
          boxShadow: isSecondary
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [
                  BoxShadow(
                    color: colorScheme.primary.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(
              icon,
              size: 32,
              color: isSecondary ? colorScheme.primary : colorScheme.onPrimary,
            ),
            Text(
              label,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: isSecondary
                    ? colorScheme.onSurface
                    : colorScheme.onPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDraftItem(
    BuildContext context,
    String title,
    String subtitle,
    String duration,
    ColorScheme colorScheme,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: colorScheme.background,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              CupertinoIcons.mic,
              color: colorScheme.onSurface.withOpacity(0.5),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(
                    context,
                  ).textTheme.titleMedium?.copyWith(fontSize: 16),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(fontSize: 12),
                ),
              ],
            ),
          ),
          Text(duration, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
