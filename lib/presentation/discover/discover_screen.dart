import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/api_config_notifier.dart';
import '../../core/auth_session_notifier.dart';
import '../../core/theme.dart';
import '../../core/user_profile_notifier.dart';
import '../../domain/models/models.dart';
import '../../infrastructure/auth_api_client.dart';
import '../create/generate_ai_audio_screen.dart';
import '../practice/media_detail_screen.dart';
import '../profile/edit_profile_screen.dart';
import '../shared/locale_flag.dart';

const _kPageSize = 20;

class DiscoverScreen extends StatefulWidget {
  const DiscoverScreen({super.key});

  @override
  State<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends State<DiscoverScreen> {
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();

  List<UploadedVideo> _videos = [];
  bool _isLoading = false;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  int _currentOffset = 0;
  String _lastSearch = '';
  String? _lastLanguage;

  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    UserProfileNotifier.instance.addListener(_onProfileChanged);
    _scrollController.addListener(_onScroll);
    _load(reset: true);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    _scrollController.dispose();
    UserProfileNotifier.instance.removeListener(_onProfileChanged);
    super.dispose();
  }

  void _onProfileChanged() {
    final lang = UserProfileNotifier.instance.learningLanguage;
    if (lang != _lastLanguage) {
      _load(reset: true);
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200 &&
        !_isLoading &&
        !_isLoadingMore &&
        _hasMore) {
      _load(reset: false);
    }
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 450), () {
      _load(reset: true);
    });
  }

  Future<void> _load({required bool reset}) async {
    final lang = UserProfileNotifier.instance.learningLanguage;

    // No learning language set — show empty without hitting the API.
    if (lang == null || lang.trim().isEmpty) {
      _lastLanguage = lang;
      if (mounted) {
        setState(() {
          _isLoading = false;
          _isLoadingMore = false;
          _videos = [];
          _currentOffset = 0;
          _hasMore = false;
        });
      }
      return;
    }

    if (reset) {
      if (mounted) {
        setState(() {
          _isLoading = true;
          _videos = [];
          _currentOffset = 0;
          _hasMore = true;
        });
      }
    } else {
      if (_isLoadingMore || !_hasMore) return;
      if (mounted) setState(() => _isLoadingMore = true);
    }

    final search = _searchController.text.trim();
    _lastLanguage = lang;
    _lastSearch = search;

    final accessToken = AuthSessionNotifier.instance.session?.accessToken;

    try {
      final results = await AuthApiClient.instance.fetchPublicVideos(
        accessToken: accessToken,
        languageCode: lang.trim(),
        limit: _kPageSize,
        offset: reset ? 0 : _currentOffset,
        search: search.isNotEmpty ? search : null,
        mediaType: 'audio',
      );

      if (!mounted) return;
      setState(() {
        if (reset) {
          _videos = results;
        } else {
          _videos = [..._videos, ...results];
        }
        _currentOffset = _videos.length;
        _hasMore = results.length >= _kPageSize;
        _isLoading = false;
        _isLoadingMore = false;
      });
    } catch (_) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _isLoadingMore = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: UserProfileNotifier.instance,
      builder: (context, _) {
        final profile = UserProfileNotifier.instance;
        final learningLang = profile.learningLanguage;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Discover'),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(60.0),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                child: TextField(
                  controller: _searchController,
                  onChanged: _onSearchChanged,
                  decoration: InputDecoration(
                    hintText: 'Search title or transcript…',
                    prefixIcon: const Icon(
                      Icons.search,
                      color: BanteraTheme.textSecondaryLight,
                    ),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 18),
                            onPressed: () {
                              _searchController.clear();
                              _load(reset: true);
                            },
                          )
                        : null,
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
          body: RefreshIndicator(
            onRefresh: () => _load(reset: true),
            child: CustomScrollView(
              controller: _scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                // Learning language chip
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                    child: _buildLanguageHeader(context, learningLang),
                  ),
                ),

                if (_isLoading)
                  const SliverFillRemaining(
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (_videos.isEmpty)
                  SliverFillRemaining(
                    child: _buildEmptyState(context, learningLang),
                  )
                else ...[
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _buildVideoTile(context, _videos[index]),
                        ),
                        childCount: _videos.length,
                      ),
                    ),
                  ),
                  // Footer: spinner or end indicator
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      child: _isLoadingMore
                          ? const Center(child: CircularProgressIndicator())
                          : _hasMore
                              ? const SizedBox.shrink()
                              : Center(
                                  child: Text(
                                    'No more results',
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodySmall?.copyWith(
                                      color: Colors.grey,
                                    ),
                                  ),
                                ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLanguageHeader(BuildContext context, String? learningLang) {
    if (learningLang == null || learningLang.isEmpty) {
      return GestureDetector(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const EditProfileScreen()),
        ),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
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
                size: 20,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Set your learning language to see content here',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: Theme.of(context).colorScheme.primary,
              ),
            ],
          ),
        ),
      );
    }

    final flag = flagEmojiForLocale(learningLang);
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: Theme.of(
              context,
            ).colorScheme.primary.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(flag, style: const TextStyle(fontSize: 18)),
              const SizedBox(width: 8),
              Text(
                learningLang,
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Text(
          'content',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context, String? learningLang) {
    final hasLang = learningLang != null && learningLang.isNotEmpty;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.inbox_outlined, size: 48, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              hasLang
                  ? 'No public content in $learningLang yet'
                  : 'Set a learning language to discover content',
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.grey),
            ),
            if (hasLang) ...[
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const GenerateAiAudioScreen(),
                  ),
                ),
                icon: const Icon(Icons.auto_awesome, size: 18),
                label: const Text('Generate with AI'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildVideoTile(BuildContext context, UploadedVideo video) {
    final isAudio = video.videoContentType.startsWith('audio/');
    final title = _titleFromFileName(video.originalFileName);

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => MediaDetailScreen(mediaItem: _toMediaItem(video)),
        ),
      ),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.horizontal(
                left: Radius.circular(14),
              ),
              child: SizedBox(
                width: 96,
                height: 96,
                child: video.coverImageUrl != null
                    ? Image.network(
                        video.coverImageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                            _coverPlaceholder(isAudio),
                      )
                    : _coverPlaceholder(isAudio),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontSize: 15,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(
                          isAudio ? Icons.audiotrack : Icons.videocam_outlined,
                          size: 13,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          isAudio ? 'Audio' : 'Video',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          '· ${_formatDuration(video.durationMs)}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      video.transcriptLanguage,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
          ],
        ),
      ),
    );
  }

  Widget _coverPlaceholder(bool isAudio) {
    return Container(
      color: Colors.grey.shade200,
      child: Center(
        child: Icon(
          isAudio ? Icons.audiotrack : Icons.videocam_outlined,
          size: 32,
          color: Colors.grey.shade400,
        ),
      ),
    );
  }

  MediaItem _toMediaItem(UploadedVideo video) {
    return MediaItem(
      id: video.id,
      title: _titleFromFileName(video.originalFileName),
      description: '',
      creator: User(
        id: video.userId,
        displayName: video.creatorDisplayName ?? 'Bantera',
        avatarUrl:
            '${ApiConfigNotifier.instance.baseUrl}/api/users/${video.userId}/avatar',
        firstLanguage: '',
        learningLanguage: '',
        level: '',
      ),
      coverUrl: video.coverImageUrl ?? '',
      videoUrl: video.videoUrl,
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
      transcriptionSource: video.isAiGenerated ? 'AI Generated' : 'User Upload',
      isAudioOnly: video.videoWidth == null && video.videoHeight == null,
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
