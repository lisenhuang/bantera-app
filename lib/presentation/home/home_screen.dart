import 'package:flutter/material.dart';

import '../../core/api_config_notifier.dart';
import '../../core/auth_session_notifier.dart';
import '../../core/theme.dart';
import '../../core/user_profile_notifier.dart';
import '../../domain/models/models.dart';
import '../../infrastructure/auth_api_client.dart';
import '../practice/media_detail_screen.dart';
import '../profile/edit_profile_screen.dart';
import '../shared/profile_avatar.dart';

// Number of recommended items to request from the server.
const _kRecommendedLimit = 5;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<UploadedVideo>? _videos;
  bool _isLoading = false;
  String? _lastLoadedLanguage;

  @override
  void initState() {
    super.initState();
    UserProfileNotifier.instance.addListener(_onProfileChanged);
    _loadVideos();
  }

  @override
  void dispose() {
    UserProfileNotifier.instance.removeListener(_onProfileChanged);
    super.dispose();
  }

  void _onProfileChanged() {
    final current = UserProfileNotifier.instance.learningLanguage;
    if (current != _lastLoadedLanguage) {
      _loadVideos();
    }
  }

  Future<void> _loadVideos() async {
    final lang = UserProfileNotifier.instance.learningLanguage;
    if (lang == null || lang.isEmpty) {
      if (mounted) setState(() { _videos = []; _isLoading = false; });
      _lastLoadedLanguage = lang;
      return;
    }

    if (mounted) setState(() => _isLoading = true);

    // Send the full locale (e.g. "en-US") so the backend can distinguish
    // between different regional variants of the same language.
    final langCode = lang.trim();
    final accessToken = AuthSessionNotifier.instance.session?.accessToken;

    try {
      final results = await AuthApiClient.instance.fetchPublicVideos(
        accessToken: accessToken,
        languageCode: langCode,
        limit: _kRecommendedLimit,
      );
      _lastLoadedLanguage = lang;
      if (mounted) setState(() { _videos = results; _isLoading = false; });
    } catch (_) {
      if (mounted) setState(() { _videos = []; _isLoading = false; });
    }
  }

  List<UploadedVideo> _recommended() => _videos ?? [];

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: UserProfileNotifier.instance,
      builder: (context, _) {
        final profile = UserProfileNotifier.instance;

        return Scaffold(
          body: SafeArea(
            child: RefreshIndicator(
              onRefresh: _loadVideos,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20.0,
                  vertical: 16.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Good evening,',
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(
                                    color: BanteraTheme.textSecondaryLight,
                                  ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              profile.displayName,
                              style: Theme.of(context).textTheme.displayLarge,
                            ),
                          ],
                        ),
                        ProfileAvatar(
                          radius: 28,
                          imageUrl: profile.avatarUrl,
                          imagePath: profile.avatarImagePath,
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Daily Goal',
                                  style: Theme.of(
                                    context,
                                  ).textTheme.titleMedium,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  '15 / 20 mins listened',
                                  style: Theme.of(
                                    context,
                                  ).textTheme.bodyMedium,
                                ),
                              ],
                            ),
                            const Stack(
                              alignment: Alignment.center,
                              children: [
                                SizedBox(
                                  width: 50,
                                  height: 50,
                                  child: CircularProgressIndicator(
                                    value: 15 / 20,
                                    strokeWidth: 6,
                                    backgroundColor: Color(0xFFE4E4E7),
                                    color: BanteraTheme.primaryColor,
                                  ),
                                ),
                                Icon(
                                  Icons.local_fire_department,
                                  color: BanteraTheme.secondaryColor,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    Text(
                      'Recommended for you',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    _buildRecommendedSection(context, profile),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildRecommendedSection(
    BuildContext context,
    UserProfileNotifier profile,
  ) {
    final learningLang = profile.learningLanguage;

    if (learningLang == null || learningLang.isEmpty) {
      return _buildSetLanguagePrompt(context);
    }

    if (_isLoading) {
      return const SizedBox(
        height: 200,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    final recommended = _recommended();
    if (recommended.isEmpty) {
      return _buildEmptyState(context, learningLang);
    }

    return SizedBox(
      height: 240,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: recommended.length,
        itemBuilder: (context, index) =>
            _buildVideoCard(context, recommended[index]),
      ),
    );
  }

  Widget _buildSetLanguagePrompt(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const EditProfileScreen()),
      ),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Theme.of(
              context,
            ).colorScheme.primary.withValues(alpha: 0.35),
          ),
          color: Theme.of(
            context,
          ).colorScheme.primary.withValues(alpha: 0.05),
        ),
        child: Row(
          children: [
            Icon(
              Icons.school_outlined,
              size: 32,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Set your learning language',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "We'll show content that matches what you're learning.",
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              Icons.chevron_right,
              color: Theme.of(context).colorScheme.primary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, String learningLang) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.inbox_outlined, size: 32, color: Colors.grey),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              'No uploaded content in $learningLang yet.\nUpload or generate audio to see it here.',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVideoCard(BuildContext context, UploadedVideo video) {
    final isAudio = video.videoContentType.startsWith('audio/');
    return GestureDetector(
      onTap: () => _openPractice(context, video),
      child: Container(
        width: 200,
        margin: const EdgeInsets.only(right: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: SizedBox(
                height: 140,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    if (video.coverImageUrl != null)
                      Image.network(
                        video.coverImageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                            _buildCoverPlaceholder(isAudio),
                      )
                    else
                      _buildCoverPlaceholder(isAudio),
                    // Play overlay
                    Center(
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.45),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          isAudio
                              ? Icons.play_arrow_rounded
                              : Icons.play_circle_outline_rounded,
                          color: Colors.white,
                          size: 32,
                        ),
                      ),
                    ),
                    // Audio / Video type badge – top-left
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.65),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              isAudio
                                  ? Icons.audiotrack
                                  : Icons.videocam,
                              color: Colors.white,
                              size: 11,
                            ),
                            const SizedBox(width: 3),
                            Text(
                              isAudio ? 'Audio' : 'Video',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Duration badge – bottom-right
                    Positioned(
                      bottom: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.7),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _formatDuration(video.durationMs),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              _titleFromFileName(video.originalFileName),
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontSize: 16),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              video.transcriptLanguage,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }

  void _openPractice(BuildContext context, UploadedVideo video) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MediaDetailScreen(mediaItem: _toMediaItem(video)),
      ),
    );
  }

  /// Converts a public [UploadedVideo] from the backend into the [MediaItem]
  /// that [PracticePlayerScreen] consumes. Public videos are streamed without
  /// an auth header.
  static MediaItem _toMediaItem(UploadedVideo video) {
    return MediaItem(
      id: video.id,
      title: _titleFromFileName(video.originalFileName),
      description: video.transcriptText.length > 160
          ? '${video.transcriptText.substring(0, 160)}…'
          : video.transcriptText,
      creator: User(
        id: video.userId,
        displayName: 'Bantera',
        avatarUrl:
            '${ApiConfigNotifier.instance.baseUrl}/api/users/${video.userId}/avatar',
        firstLanguage: '',
        learningLanguage: '',
        level: '',
      ),
      coverUrl: video.coverImageUrl ?? '',
      videoUrl: video.videoUrl,
      // Public videos are accessible without auth headers.
      mediaHeaders: const {},
      spokenLanguage: video.transcriptLanguage,
      accent: video.transcriptLanguageCode,
      durationMs: video.durationMs,
      cues: video.transcriptCues
          .map(
            (c) => Cue(
              id: '${video.id}-${c.index}',
              startTimeMs: c.startMs,
              endTimeMs: c.endMs,
              originalText: c.text,
              translatedText: '',
            ),
          )
          .toList(),
      transcriptionSource:
          video.isAiGenerated ? 'AI Generated' : 'User Upload',
      isAudioOnly:
          video.videoWidth == null && video.videoHeight == null,
    );
  }

  Widget _buildCoverPlaceholder(bool isAudio) {
    return Container(
      color: Colors.grey.shade200,
      child: Center(
        child: Icon(
          isAudio ? Icons.audiotrack : Icons.videocam_outlined,
          size: 40,
          color: Colors.grey.shade400,
        ),
      ),
    );
  }

  static String _titleFromFileName(String fileName) {
    final dot = fileName.lastIndexOf('.');
    return dot > 0 ? fileName.substring(0, dot) : fileName;
  }

  static String _formatDuration(int ms) {
    final total = ms ~/ 1000;
    final mins = total ~/ 60;
    final secs = total % 60;
    return '$mins:${secs.toString().padLeft(2, '0')}';
  }
}
