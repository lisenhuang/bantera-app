import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../domain/models/models.dart';
import 'practice_player_screen.dart';

class MediaDetailScreen extends StatelessWidget {
  final MediaItem mediaItem;

  const MediaDetailScreen({super.key, required this.mediaItem});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BanteraTheme.surfaceColorLight,
      appBar: AppBar(
        title: const Text('Lesson Details'),
        actions: [
          IconButton(icon: const Icon(Icons.bookmark_border), onPressed: () {}),
          IconButton(icon: const Icon(Icons.more_horiz), onPressed: () {}),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cover Image
            Container(
              height: 250,
              width: double.infinity,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(mediaItem.coverUrl),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    mediaItem.title,
                    style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 28),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 16,
                        backgroundImage: NetworkImage(mediaItem.creator.avatarUrl),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        mediaItem.creator.displayName,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: BanteraTheme.backgroundLight,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${mediaItem.spokenLanguage} · ${mediaItem.accent}',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Text(
                    mediaItem.description,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => PracticePlayerScreen(mediaItem: mediaItem),
                          ),
                        );
                      },
                      icon: const Icon(Icons.play_arrow_rounded, size: 28),
                      label: const Text('Start Practice', style: TextStyle(fontSize: 18)),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  const Divider(),
                  const SizedBox(height: 16),
                  Text('Transcript Preview', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 16),
                  ...mediaItem.cues.take(3).map((cue) => Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: Text(
                          cue.originalText,
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontSize: 18),
                        ),
                      )),
                  if (mediaItem.cues.length > 3)
                    Text(
                      '...and ${mediaItem.cues.length - 3} more cues',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: BanteraTheme.primaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  const SizedBox(height: 48), // Padding equivalent
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
