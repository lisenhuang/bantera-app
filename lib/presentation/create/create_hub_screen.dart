import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

import '../../core/auth_session_notifier.dart';
import '../../core/profile_stats_notifier.dart';
import '../../core/user_profile_notifier.dart';
import '../../domain/models/models.dart';
import '../../infrastructure/auth_api_client.dart';
import '../../infrastructure/local_practice_repository.dart';
import '../practice/practice_player_screen.dart';
import 'generate_ai_audio_screen.dart';
import 'local_video_practice_screen.dart';
import 'uploaded_video_detail_screen.dart';
class CreateHubScreen extends StatefulWidget {
  const CreateHubScreen({super.key});

  @override
  State<CreateHubScreen> createState() => _CreateHubScreenState();
}

class _CreateHubScreenState extends State<CreateHubScreen> {
  final AuthApiClient _apiClient = AuthApiClient.instance;
  final LocalPracticeRepository _localPracticeRepository =
      LocalPracticeRepository.instance;

  List<UploadedVideo> _myVideos = const [];
  bool _isLoadingVideos = true;
  String? _loadError;
  String? _openingLocalVideoId;
  String? _deletingLocalVideoId;
  String? _deletingUploadedVideoId;

  @override
  void initState() {
    super.initState();
    unawaited(_localPracticeRepository.refreshForCurrentUser());
    _loadMyVideos();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
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
              'What would you like to do today?',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 24),

            // Large Action Buttons
            Row(
              children: [
                Expanded(
                  child: _buildPrimaryAction(
                    context,
                    CupertinoIcons.play_rectangle_fill,
                    'Practice Video',
                    colorScheme,
                    isSecondary: true,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => const LocalVideoPracticeScreen(),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildPrimaryAction(
                    context,
                    Icons.auto_awesome,
                    'Generate with AI',
                    colorScheme,
                    isSecondary: true,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => const GenerateAiAudioScreen(),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 48),
            _buildLocalPracticeSection(context, colorScheme),
            const SizedBox(height: 48),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Your Media',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                IconButton(
                  onPressed: _isLoadingVideos
                      ? null
                      : () => _loadMyVideos(showLoadingState: false),
                  icon: const Icon(CupertinoIcons.refresh),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (_isLoadingVideos)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_loadError != null)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.red.withValues(alpha: 0.18)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _loadError!,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.red.shade700,
                      ),
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton(
                      onPressed: () => _loadMyVideos(),
                      child: const Text('Try Again'),
                    ),
                  ],
                ),
              )
            else if (_myVideos.isEmpty)
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: colorScheme.onSurface.withValues(alpha: 0.05),
                  ),
                ),
                child: Text(
                  'Your uploaded videos will show up here so you can reopen them and practice cue by cue.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              )
            else
              ..._myVideos.map((video) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _buildUploadedVideoItem(context, video, colorScheme),
                );
              }),

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
                  color: colorScheme.onSurface.withValues(alpha: 0.05),
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

  Future<void> _loadMyVideos({bool showLoadingState = true}) async {
    final session = AuthSessionNotifier.instance.session;
    if (session == null) {
      if (!mounted) {
        return;
      }
      setState(() {
        _myVideos = const [];
        _isLoadingVideos = false;
        _loadError = 'Sign in again to load your uploaded videos.';
      });
      return;
    }

    if (showLoadingState) {
      setState(() {
        _isLoadingVideos = true;
        _loadError = null;
      });
    } else {
      setState(() {
        _loadError = null;
      });
    }

    try {
      final videos = await _apiClient.fetchMyVideos(
        accessToken: session.accessToken,
      );
      if (!mounted) {
        return;
      }

      setState(() {
        _myVideos = videos;
        _isLoadingVideos = false;
      });
    } on AuthApiException catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _isLoadingVideos = false;
        _loadError = error.message;
      });
    }
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
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [
                  BoxShadow(
                    color: colorScheme.primary.withValues(alpha: 0.3),
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

  Widget _buildLocalPracticeSection(
    BuildContext context,
    ColorScheme colorScheme,
  ) {
    final theme = Theme.of(context);

    return ListenableBuilder(
      listenable: _localPracticeRepository,
      builder: (context, _) {
        final localVideos = _localPracticeRepository.videos;
        final localError = _localPracticeRepository.errorMessage;
        final isLoadingLocalVideos = _localPracticeRepository.isLoading;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'On This iPhone',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                IconButton(
                  onPressed: isLoadingLocalVideos
                      ? null
                      : () => _localPracticeRepository.refreshForCurrentUser(
                          showLoadingState: false,
                        ),
                  icon: const Icon(CupertinoIcons.refresh),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (isLoadingLocalVideos)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (localError != null)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.red.withValues(alpha: 0.18)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      localError,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.red.shade700,
                      ),
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton(
                      onPressed: () => _localPracticeRepository
                          .refreshForCurrentUser(),
                      child: const Text('Try Again'),
                    ),
                  ],
                ),
              )
            else if (localVideos.isEmpty)
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: colorScheme.onSurface.withValues(alpha: 0.05),
                  ),
                ),
                child: Text(
                  'Videos you practice locally will be saved on this iPhone so you can reopen them later without retranscribing.',
                  style: theme.textTheme.bodyMedium,
                ),
              )
            else
              ...localVideos.map((video) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _buildLocalPracticeItem(context, video, colorScheme),
                );
              }),
          ],
        );
      },
    );
  }

  Widget _buildLocalPracticeItem(
    BuildContext context,
    LocalPracticeVideoSummary video,
    ColorScheme colorScheme,
  ) {
    final theme = Theme.of(context);
    final isOpening = _openingLocalVideoId == video.id;
    final isDeleting = _deletingLocalVideoId == video.id;

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: isOpening || isDeleting
          ? null
          : () {
              unawaited(_openLocalPracticeVideo(video.id));
            },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                CupertinoIcons.device_phone_portrait,
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    video.title,
                    style: theme.textTheme.titleMedium,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${video.accent} · ${_formatDuration(video.durationMs)} · ${video.cueCount} cues',
                    style: theme.textTheme.bodySmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    video.transcriptPreview,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    'On Device',
                    style: theme.textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                if (isOpening || isDeleting)
                  SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: colorScheme.primary,
                    ),
                  )
                else
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'delete') {
                        unawaited(_confirmDeleteLocalVideo(video));
                      }
                    },
                    itemBuilder: (context) => const [
                      PopupMenuItem<String>(
                        value: 'delete',
                        child: Text('Delete'),
                      ),
                    ],
                    icon: Icon(
                      CupertinoIcons.ellipsis_circle,
                      color: colorScheme.onSurface.withValues(alpha: 0.55),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUploadedVideoItem(
    BuildContext context,
    UploadedVideo video,
    ColorScheme colorScheme,
  ) {
    final theme = Theme.of(context);
    final isDeleting = _deletingUploadedVideoId == video.id;

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: isDeleting
          ? null
          : () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => UploadedVideoDetailScreen(video: video),
                ),
              );
            },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: video.coverImageUrl != null
                  ? Image.network(
                      video.coverImageUrl!,
                      width: 52,
                      height: 52,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                          _fallbackMediaIcon(colorScheme),
                    )
                  : _fallbackMediaIcon(colorScheme),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _displayTitle(video.originalFileName),
                    style: theme.textTheme.titleMedium,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${video.transcriptLanguage} · ${_formatDuration(video.durationMs)} · ${video.transcriptCues.length} cues',
                    style: theme.textTheme.bodySmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    video.transcriptText.replaceAll('\n', ' '),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: video.isPublic
                        ? colorScheme.primary.withValues(alpha: 0.12)
                        : colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    video.isPublic ? 'Public' : 'Private',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: video.isPublic ? colorScheme.primary : null,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                if (video.isAiGenerated) ...[
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.purple.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.auto_awesome,
                          size: 11,
                          color: Colors.purple.shade700,
                        ),
                        const SizedBox(width: 3),
                        Text(
                          'AI',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: Colors.purple.shade700,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 10),
                if (isDeleting)
                  SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: colorScheme.primary,
                    ),
                  )
                else
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'delete') {
                        unawaited(_confirmDeleteUploadedVideo(video));
                      }
                    },
                    itemBuilder: (context) => const [
                      PopupMenuItem<String>(
                        value: 'delete',
                        child: Text('Delete'),
                      ),
                    ],
                    icon: Icon(
                      CupertinoIcons.ellipsis_circle,
                      color: colorScheme.onSurface.withValues(alpha: 0.55),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _fallbackMediaIcon(ColorScheme colorScheme) {
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        color: colorScheme.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Icon(CupertinoIcons.video_camera_solid, color: colorScheme.primary),
    );
  }

  static String _displayTitle(String fileName) {
    final dotIndex = fileName.lastIndexOf('.');
    if (dotIndex <= 0) {
      return fileName;
    }
    return fileName.substring(0, dotIndex);
  }

  static String _formatDuration(int durationMs) {
    final totalSeconds = (durationMs / 1000).round();
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  Future<void> _openLocalPracticeVideo(String id) async {
    setState(() {
      _openingLocalVideoId = id;
    });

    try {
      final video = await _localPracticeRepository.openVideo(id);
      if (!mounted) {
        return;
      }

      await Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => PracticePlayerScreen(
            mediaItem: video.toMediaItem(creator: _currentCreator()),
          ),
        ),
      );
    } on LocalPracticeRepositoryException catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.message)));
    } finally {
      if (mounted) {
        setState(() {
          _openingLocalVideoId = null;
        });
      }
    }
  }

  Future<void> _confirmDeleteLocalVideo(LocalPracticeVideoSummary video) async {
    final confirmed =
        await showDialog<bool>(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('Delete Saved Video?'),
              content: Text(
                'Bantera will remove "${video.title}" from this iPhone and delete its saved transcript cues.',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text('Delete'),
                ),
              ],
            );
          },
        ) ??
        false;

    if (!confirmed || !mounted) {
      return;
    }

    setState(() {
      _deletingLocalVideoId = video.id;
    });

    try {
      await _localPracticeRepository.deleteVideo(video.id);
    } finally {
      if (mounted) {
        setState(() {
          _deletingLocalVideoId = null;
        });
      }
    }
  }

  Future<void> _confirmDeleteUploadedVideo(UploadedVideo video) async {
    final confirmed =
        await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Delete media?'),
            content: Text(
              'This will permanently delete "${_displayTitle(video.originalFileName)}" and its transcript. This cannot be undone.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(true),
                style: TextButton.styleFrom(
                  foregroundColor: Theme.of(ctx).colorScheme.error,
                ),
                child: const Text('Delete'),
              ),
            ],
          ),
        ) ??
        false;

    if (!confirmed || !mounted) return;

    final session = AuthSessionNotifier.instance.session;
    if (session == null) return;

    setState(() => _deletingUploadedVideoId = video.id);

    try {
      await _apiClient.deleteVideo(
        accessToken: session.accessToken,
        videoId: video.id,
      );
      if (mounted) {
        setState(() {
          _myVideos = _myVideos.where((v) => v.id != video.id).toList();
        });
      }
      unawaited(ProfileStatsNotifier.instance.refresh());
    } on AuthApiException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.message)));
      }
    } finally {
      if (mounted) setState(() => _deletingUploadedVideoId = null);
    }
  }

  User _currentCreator() {
    final profile = UserProfileNotifier.instance;

    return User(
      id: AuthSessionNotifier.instance.session?.cacheKey ?? 'local-user',
      displayName: profile.displayName,
      avatarUrl: profile.avatarUrl ?? '',
      firstLanguage: '',
      learningLanguage: '',
      level: '',
    );
  }
}
