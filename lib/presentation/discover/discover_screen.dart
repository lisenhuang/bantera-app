import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../domain/models/models.dart';
import '../../infrastructure/mock_data.dart';
import '../practice/media_detail_screen.dart';

class DiscoverScreen extends StatelessWidget {
  const DiscoverScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final recommended = MockData.recommendedMedia;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Discover'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60.0),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search topics, lessons, or creators...',
                prefixIcon: const Icon(Icons.search, color: BanteraTheme.textSecondaryLight),
                filled: true,
                fillColor: BanteraTheme.backgroundLight,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Trending Languages', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildLanguageChip('English', 'EN', true),
                  _buildLanguageChip('Spanish', 'ES', false),
                  _buildLanguageChip('Chinese', 'ZH', false),
                  _buildLanguageChip('Japanese', 'JA', false),
                ],
              ),
            ),
            const SizedBox(height: 32),
            Text('Popular Content', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            ListView.separated(
              itemCount: recommended.length,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              separatorBuilder: (context, index) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final item = recommended[index];
                return _buildMediaListTile(context, item);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageChip(String name, String code, bool isSelected) {
    return Container(
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected ? BanteraTheme.primaryColor : BanteraTheme.surfaceColorLight,
        borderRadius: BorderRadius.circular(24),
        border: isSelected ? null : Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 12,
            backgroundColor: isSelected ? Colors.white.withOpacity(0.2) : Colors.grey[200],
            child: Text(code, style: TextStyle(fontSize: 10, color: isSelected ? Colors.white : BanteraTheme.textSecondaryLight)),
          ),
          const SizedBox(width: 8),
          Text(
            name,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: isSelected ? Colors.white : BanteraTheme.textPrimaryLight,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMediaListTile(BuildContext context, MediaItem item) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MediaDetailScreen(mediaItem: item),
          ),
        );
      },
      child: Card(
        elevation: 0,
        color: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                item.coverUrl,
                width: 100,
                height: 100,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(fontSize: 16),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${item.spokenLanguage} · ${item.accent}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.headset, size: 16, color: BanteraTheme.textSecondaryLight),
                      const SizedBox(width: 4),
                      Text('${item.plays}', style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 12)),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '0:${(item.durationMs / 1000).round()}',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey[800]),
                        ),
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
