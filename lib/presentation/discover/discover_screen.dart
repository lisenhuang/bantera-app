import 'dart:async';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/settings_notifier.dart';
import '../../domain/audio_level.dart';
import '../shared/audio_level_selector.dart';
import '../../core/apple_system_version.dart';
import '../../core/api_config_notifier.dart';
import '../../l10n/app_localizations.dart';
import '../../core/auth_session_notifier.dart';
import '../../core/user_profile_notifier.dart';
import '../../domain/models/models.dart';
import '../../infrastructure/auth_api_client.dart';
import '../../infrastructure/transcription_locale_option.dart';
import 'discover_filters.dart';
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
  String? _lastLanguage;
  bool _showAllAccents = false;

  Timer? _debounce;
  AudioLevel? _lastLevel;
  int _loadVersion = 0;

  bool get _canShowGenerateWithAiButton =>
      !(Platform.isIOS && isLegacyAppleOsPre26);

  @override
  void initState() {
    super.initState();
    UserProfileNotifier.instance.addListener(_onProfileChanged);
    _lastLevel = SettingsNotifier.instance.audioLevel;
    SettingsNotifier.instance.addListener(_onSettingsChanged);
    _scrollController.addListener(_onScroll);
    _load(reset: true);
  }

  @override
  void dispose() {
    SettingsNotifier.instance.removeListener(_onSettingsChanged);
    _debounce?.cancel();
    _searchController.dispose();
    _scrollController.dispose();
    UserProfileNotifier.instance.removeListener(_onProfileChanged);
    super.dispose();
  }

  void _onSettingsChanged() {
    final level = SettingsNotifier.instance.audioLevel;
    if (level == _lastLevel) return;
    _lastLevel = level;
    _debounce?.cancel();
    _load(reset: true);
  }

  void _onProfileChanged() {
    final lang = UserProfileNotifier.instance.learningLanguage;
    if (lang != _lastLanguage) {
      _showAllAccents = false;
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
    final loadVersion = reset ? ++_loadVersion : _loadVersion;
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
          _isLoadingMore = false;
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
    final effectiveLanguageCode = _effectiveLanguageCode(lang);
    _lastLanguage = lang;
    final accessToken = AuthSessionNotifier.instance.session?.accessToken;

    try {
      final results = await AuthApiClient.instance.fetchPublicVideos(
        accessToken: accessToken,
        languageCode: effectiveLanguageCode,
        limit: _kPageSize,
        offset: reset ? 0 : _currentOffset,
        search: search.isNotEmpty ? search : null,
        mediaType: 'audio',
        level: SettingsNotifier.instance.audioLevel,
      );

      if (!mounted || loadVersion != _loadVersion) return;
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
      if (mounted && loadVersion == _loadVersion) {
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
        final displayLanguageLabel = _displayLanguageLabel(learningLang);
        final colorScheme = Theme.of(context).colorScheme;
        final l10n = AppLocalizations.of(context)!;

        return Scaffold(
          appBar: AppBar(
            title: Text(AppLocalizations.of(context)!.navDiscover),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(60.0),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                child: TextField(
                  controller: _searchController,
                  onChanged: _onSearchChanged,
                  style: TextStyle(color: colorScheme.onSurface),
                  decoration: InputDecoration(
                    hintText: l10n.discoverSearchHint,
                    hintStyle: TextStyle(color: colorScheme.onSurfaceVariant),
                    prefixIcon: Icon(
                      Icons.search,
                      color: colorScheme.onSurfaceVariant,
                    ),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: Icon(
                              Icons.clear,
                              size: 18,
                              color: colorScheme.onSurfaceVariant,
                            ),
                            onPressed: () {
                              _searchController.clear();
                              _load(reset: true);
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: colorScheme.surfaceContainerHighest,
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
          body: GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(),
            behavior: HitTestBehavior.translucent,
            child: RefreshIndicator(
              onRefresh: () => _load(reset: true),
              child: CustomScrollView(
                controller: _scrollController,
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                      child: learningLang == null || learningLang.trim().isEmpty
                          ? Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildSetLanguagePrompt(context),
                                const SizedBox(height: 8),
                                const AudioLevelSelector(
                                  allowAll: true,
                                  showLeadingIcon: false,
                                ),
                              ],
                            )
                          : DiscoverFilters(
                              learningLanguage: learningLang,
                              allAccents: _showAllAccents,
                              onAccentChanged: (allAccents) {
                                setState(() => _showAllAccents = allAccents);
                                _debounce?.cancel();
                                _load(reset: true);
                              },
                            ),
                    ),
                  ),

                  if (_isLoading)
                    const SliverFillRemaining(
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else if (_videos.isEmpty)
                    SliverFillRemaining(
                      child: _buildEmptyState(context, displayLanguageLabel),
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
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      l10n.discoverNoMoreResults,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(color: Colors.grey),
                                    ),
                                    if (_canShowGenerateWithAiButton) ...[
                                      const SizedBox(height: 14),
                                      ElevatedButton.icon(
                                        onPressed: () => Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) =>
                                                const GenerateAiAudioScreen(),
                                          ),
                                        ),
                                        icon: const Icon(
                                          Icons.auto_awesome,
                                          size: 18,
                                        ),
                                        label: Text(l10n.generateWithAiTitle),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSetLanguagePrompt(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
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
          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.05),
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
                l10n.discoverSetLearningLanguagePrompt,
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

  Widget _buildEmptyState(BuildContext context, String? learningLang) {
    final l10n = AppLocalizations.of(context)!;
    final hasLang = learningLang != null && learningLang.isNotEmpty;
    final level = SettingsNotifier.instance.audioLevel;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.inbox_outlined, size: 48, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              switch (learningLang) {
                final l when l != null && l.isNotEmpty =>
                  level == null
                      ? l10n.discoverNoPublicContentInLanguage(l)
                      : l10n.discoverNoPublicContentInLanguageAtLevel(
                          l,
                          audioLevelLabel(l10n, level),
                        ),
                _ => l10n.discoverSetLanguageToDiscover,
              },
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.grey),
            ),
            if (hasLang && _canShowGenerateWithAiButton) ...[
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const GenerateAiAudioScreen(),
                  ),
                ),
                icon: const Icon(Icons.auto_awesome, size: 18),
                label: Text(l10n.generateWithAiTitle),
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
    final languageName = localeDisplayName(
      video.transcriptLanguageCode,
      video.transcriptLanguage,
    );
    final transcriptLanguageLabel = _showAllAccents
        ? '${flagEmojiForLocale(video.transcriptLanguageCode)} $languageName'
        : languageName;
    final dateLabel = _formatDateLabel(context, video.createdAt);

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
                    ? CachedNetworkImage(
                        imageUrl: video.coverImageUrl!,
                        fit: BoxFit.cover,
                        errorWidget: (_, _, _) => _coverPlaceholder(isAudio),
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
                      style: Theme.of(
                        context,
                      ).textTheme.titleMedium?.copyWith(fontSize: 15),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Text(
                          _formatDuration(video.durationMs),
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        if (video.level != null) ...[
                          const SizedBox(width: 12),
                          AudioLevelIcon(level: video.level!, size: 16),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              audioLevelLabel(
                                AppLocalizations.of(context)!,
                                video.level!,
                              ),
                              style: Theme.of(context).textTheme.bodySmall,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$transcriptLanguageLabel · $dateLabel',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
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
      level: video.level,
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
      shortCues: video.transcriptShortCues
          .map(
            (c) => Cue(
              id: '${video.id}-s${c.index}',
              startTimeMs: c.startMs,
              endTimeMs: c.endMs,
              originalText: c.text,
              translatedText: '',
            ),
          )
          .toList(),
      hasBackendShortCues: video.transcriptShortCues.isNotEmpty,
      transcriptionSource: video.isAiGenerated ? 'AI Generated' : 'User Upload',
      isAudioOnly: video.videoWidth == null && video.videoHeight == null,
      createdAt: video.createdAt,
      transcriptionVersion: video.transcriptionVersion,
      dialogueLines: video.dialogueLines,
      wordTiming: video.wordTiming,
    );
  }

  String _formatDateLabel(BuildContext context, DateTime value) {
    return DateFormat.yMMMd(
      AppLocalizations.of(context)!.localeName,
    ).format(value.toLocal());
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

  String _effectiveLanguageCode(String? learningLang) =>
      discoverAccentLanguageCode(learningLang ?? '', _showAllAccents);

  String? _displayLanguageLabel(String? learningLang) => learningLang == null
      ? null
      : discoverAccentLabel(learningLang, _showAllAccents);
}
