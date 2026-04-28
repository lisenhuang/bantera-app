import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

import '../../core/apple_system_version.dart';
import '../../core/app_resume_notifier.dart';
import '../../core/auth_api_error_localizations.dart';
import '../../core/auth_session_notifier.dart';
import '../../core/generation_job_notifier.dart';
import '../../l10n/app_localizations.dart';
import '../../core/profile_stats_notifier.dart';
import '../../core/user_profile_notifier.dart';
import '../../domain/models/models.dart';
import '../../infrastructure/auth_api_client.dart';
import '../../infrastructure/local_practice_repository.dart';
import '../practice/practice_player_screen.dart';
import '../shared/locale_flag.dart';
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
  final GenerationJobNotifier _generationJobNotifier =
      GenerationJobNotifier.instance;

  List<UploadedVideo> _myVideos = const [];
  bool _isLoadingVideos = true;
  String? _loadError;
  String? _selectedLanguageCode;
  String? _openingLocalVideoId;
  String? _deletingLocalVideoId;
  String? _deletingUploadedVideoId;

  List<({String code, String name, int count})> get _languageGroups {
    final map = <String, ({String name, int count})>{};
    for (final v in _myVideos) {
      final e = map[v.transcriptLanguageCode];
      map[v.transcriptLanguageCode] = e == null
          ? (name: v.transcriptLanguage, count: 1)
          : (name: e.name, count: e.count + 1);
    }
    return (map.entries
        .map((e) => (code: e.key, name: e.value.name, count: e.value.count))
        .toList()
      ..sort((a, b) => b.count.compareTo(a.count)));
  }

  List<UploadedVideo> get _filteredVideos {
    if (_selectedLanguageCode == null) return _myVideos;
    return _myVideos
        .where((v) => v.transcriptLanguageCode == _selectedLanguageCode)
        .toList();
  }

  @override
  void initState() {
    super.initState();
    AppResumeNotifier.instance.addListener(_handleAppResumed);
    unawaited(_localPracticeRepository.refreshForCurrentUser());
    _loadMyVideos();
  }

  @override
  void dispose() {
    AppResumeNotifier.instance.removeListener(_handleAppResumed);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
    final showOnDevicePracticeVideo = supportsOnDevicePracticeVideo;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.navCreate),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.createWhatToday,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 24),

            // Large Action Buttons
            if (showOnDevicePracticeVideo)
              Row(
                children: [
                  Expanded(
                    child: _buildPrimaryAction(
                      context,
                      Icons.auto_awesome,
                      l10n.generateWithAiTitle,
                      colorScheme,
                      isSecondary: true,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => GenerateAiAudioScreen(
                              onGenerationStarted: (jobId) {
                                _generationJobNotifier.start(jobId);
                              },
                              onYourMediaChanged: () {
                                if (!mounted) return;
                                unawaited(
                                  _loadMyVideos(showLoadingState: false),
                                );
                              },
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildPrimaryAction(
                      context,
                      CupertinoIcons.play_rectangle_fill,
                      l10n.createPracticeVideo,
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
                ],
              )
            else
              _buildPrimaryAction(
                context,
                Icons.auto_awesome,
                l10n.generateWithAiTitle,
                colorScheme,
                isSecondary: true,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => GenerateAiAudioScreen(
                        onGenerationStarted: (jobId) {
                          _generationJobNotifier.start(jobId);
                        },
                        onYourMediaChanged: () {
                          if (!mounted) return;
                          unawaited(_loadMyVideos(showLoadingState: false));
                        },
                      ),
                    ),
                  );
                },
              ),

            if (showOnDevicePracticeVideo) ...[
              const SizedBox(height: 48),
              _buildLocalPracticeSection(context, colorScheme, l10n),
            ],
            const SizedBox(height: 48),
            ListenableBuilder(
              listenable: _generationJobNotifier,
              builder: (context, _) {
                if (!_generationJobNotifier.hasProcessingJob) {
                  return const SizedBox.shrink();
                }
                return Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: colorScheme.primary.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Text(
                    'Generating audio in background...',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                );
              },
            ),
            Row(
              children: [
                Text(
                  l10n.createYourMedia,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(width: 8),
                if (!_isLoadingVideos && _myVideos.isNotEmpty)
                  Expanded(child: _buildLanguageDropdown(colorScheme))
                else
                  const Spacer(),
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
                      child: Text(l10n.createTryAgain),
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
                  l10n.createUploadedVideosEmptyHint,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              )
            else if (_filteredVideos.isEmpty)
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
                  'No media for this language.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              )
            else
              ..._filteredVideos.map((video) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _buildUploadedVideoItem(
                    context,
                    video,
                    colorScheme,
                    l10n,
                  ),
                );
              }),
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
        _loadError = AppLocalizations.of(context)!.createSignInToLoadVideos;
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
      final pendingJobs = await _apiClient.fetchPendingJobs(
        accessToken: session.accessToken,
      );
      if (!mounted) {
        return;
      }

      final completedJob = _resolveGenerationJobState(pendingJobs: pendingJobs);

      setState(() {
        _myVideos = videos;
        _isLoadingVideos = false;
        if (_selectedLanguageCode != null &&
            !videos.any(
              (v) => v.transcriptLanguageCode == _selectedLanguageCode,
            )) {
          _selectedLanguageCode = null;
        }
      });

      if (completedJob) {
        unawaited(_loadMyVideos(showLoadingState: false));
      }
    } on AuthApiException catch (error) {
      if (!mounted) {
        return;
      }
      final l10n = AppLocalizations.of(context)!;
      setState(() {
        _isLoadingVideos = false;
        _loadError = localizeAuthApiError(l10n, error);
      });
    }
  }

  void _handleAppResumed() {
    unawaited(_loadMyVideos(showLoadingState: false));
  }

  bool _resolveGenerationJobState({
    required List<PendingAudioJob> pendingJobs,
  }) {
    final activeJobId = _generationJobNotifier.jobId;
    if (activeJobId != null && activeJobId.isNotEmpty) {
      final matching = pendingJobs.where((j) => j.id == activeJobId).toList();
      if (matching.isNotEmpty) {
        final status = matching.first.status;
        _generationJobNotifier.updateStatus(status);
        if (status == 'processing') {
          return false;
        }
        _generationJobNotifier.clear();
        if (mounted) {
          final messenger = ScaffoldMessenger.of(context);
          final message = status == 'done'
              ? 'Your audio is ready!'
              : 'Audio generation failed.';
          messenger.showSnackBar(SnackBar(content: Text(message)));
        }
        return status == 'done';
      }
      _generationJobNotifier.clear();
      return false;
    }

    final processingJob = pendingJobs
        .where((j) => j.status == 'processing')
        .firstOrNull;
    if (processingJob != null) {
      _generationJobNotifier.start(processingJob.id);
    }
    return false;
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
          color: isSecondary
              ? colorScheme.surfaceContainerHigh
              : colorScheme.primary,
          borderRadius: BorderRadius.circular(20),
          boxShadow: isSecondary
              ? [
                  BoxShadow(
                    color: colorScheme.shadow.withValues(alpha: 0.1),
                    blurRadius: 14,
                    offset: const Offset(0, 3),
                    spreadRadius: -1,
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
    AppLocalizations l10n,
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
                  l10n.createOnThisIphone,
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
                      onPressed: () =>
                          _localPracticeRepository.refreshForCurrentUser(),
                      child: Text(l10n.createTryAgain),
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
                  l10n.createLocalVideosEmptyHint,
                  style: theme.textTheme.bodyMedium,
                ),
              )
            else
              ...localVideos.map((video) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _buildLocalPracticeItem(
                    context,
                    video,
                    colorScheme,
                    l10n,
                  ),
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
    AppLocalizations l10n,
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
            _VideoThumbnailIcon(
              videoPath: video.localVideoPath,
              colorScheme: colorScheme,
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
                    '${video.accent} · ${_formatDuration(video.durationMs)} · ${l10n.createVideoMetaCues(video.cueCount)} · ${_formatDateLabel(context, video.createdAt)}',
                    style: theme.textTheme.bodySmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
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
                    l10n.createOnDeviceBadge,
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
                    itemBuilder: (context) => [
                      PopupMenuItem<String>(
                        value: 'delete',
                        child: Text(l10n.deleteLabel),
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

  Widget _buildLanguageDropdown(ColorScheme colorScheme) {
    final groups = _languageGroups;
    return DropdownButtonHideUnderline(
      child: DropdownButton<String?>(
        value: _selectedLanguageCode,
        isExpanded: true,
        borderRadius: BorderRadius.circular(12),
        style: Theme.of(context).textTheme.bodySmall,
        items: [
          DropdownMenuItem<String?>(
            value: null,
            child: Text('All (${_myVideos.length})'),
          ),
          ...groups.map(
            (g) => DropdownMenuItem<String?>(
              value: g.code,
              child: Text(
                '${flagEmojiForLocale(g.code)} ${g.name} (${g.count})',
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ],
        onChanged: (value) => setState(() => _selectedLanguageCode = value),
      ),
    );
  }

  Widget _buildUploadedVideoItem(
    BuildContext context,
    UploadedVideo video,
    ColorScheme colorScheme,
    AppLocalizations l10n,
  ) {
    final theme = Theme.of(context);
    final isDeleting = _deletingUploadedVideoId == video.id;
    final usesRemoveFromList = _usesRemoveFromList(video);

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: isDeleting
          ? null
          : () async {
              final changed = await Navigator.of(context).push<bool>(
                MaterialPageRoute<bool>(
                  builder: (_) => UploadedVideoDetailScreen(video: video),
                ),
              );

              if (changed == true && mounted) {
                unawaited(_loadMyVideos(showLoadingState: false));
              }
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
                  ? CachedNetworkImage(
                      imageUrl: video.coverImageUrl!,
                      width: 52,
                      height: 52,
                      fit: BoxFit.cover,
                      errorWidget: (context, url, error) =>
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
                    '${flagEmojiForLocale(video.transcriptLanguageCode)} ${video.transcriptLanguage} · ${_formatDuration(video.durationMs)} · ${l10n.createVideoMetaCues(video.transcriptCues.length)} · ${_formatDateLabel(context, video.createdAt)}',
                    style: theme.textTheme.bodySmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
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
                    video.isPublic
                        ? l10n.createPublicBadge
                        : l10n.createPrivateBadge,
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
                          l10n.createAiBadge,
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
                    itemBuilder: (context) => [
                      PopupMenuItem<String>(
                        value: 'delete',
                        child: Text(
                          usesRemoveFromList
                              ? l10n.removeFromListLabel
                              : l10n.deleteLabel,
                        ),
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
      child: Icon(
        CupertinoIcons.video_camera_solid,
        color: colorScheme.primary,
      ),
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

  String _formatDateLabel(BuildContext context, DateTime value) {
    return DateFormat.yMMMd(
      AppLocalizations.of(context)!.localeName,
    ).format(value.toLocal());
  }

  static bool _usesRemoveFromList(UploadedVideo video) {
    final contentType = video.videoContentType.trim().toLowerCase();
    return video.isAiGenerated && contentType.startsWith('audio/');
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
          builder: (dialogContext) {
            final l10n = AppLocalizations.of(dialogContext)!;
            return AlertDialog(
              title: Text(l10n.createDeleteSavedVideoTitle),
              content: Text(l10n.createDeleteSavedVideoBody(video.title)),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(false),
                  child: Text(l10n.cancel),
                ),
                FilledButton(
                  onPressed: () => Navigator.of(dialogContext).pop(true),
                  child: Text(l10n.deleteLabel),
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
    final removeFromList = _usesRemoveFromList(video);
    final confirmed =
        await showDialog<bool>(
          context: context,
          builder: (ctx) {
            final l10n = AppLocalizations.of(ctx)!;
            return AlertDialog(
              title: Text(
                removeFromList
                    ? l10n.removeFromListTitle
                    : l10n.createDeleteMediaTitle,
              ),
              content: Text(
                removeFromList
                    ? l10n.removeFromListBody
                    : l10n.createDeleteMediaBody(
                        _displayTitle(video.originalFileName),
                      ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(false),
                  child: Text(l10n.cancel),
                ),
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(true),
                  style: TextButton.styleFrom(
                    foregroundColor: Theme.of(ctx).colorScheme.error,
                  ),
                  child: Text(
                    removeFromList
                        ? l10n.removeFromListLabel
                        : l10n.deleteLabel,
                  ),
                ),
              ],
            );
          },
        ) ??
        false;

    if (!confirmed || !mounted) return;

    final session = AuthSessionNotifier.instance.session;
    if (session == null) return;

    setState(() => _deletingUploadedVideoId = video.id);

    try {
      if (removeFromList) {
        await _apiClient.removeVideoFromList(
          accessToken: session.accessToken,
          videoId: video.id,
        );
      } else {
        await _apiClient.deleteVideo(
          accessToken: session.accessToken,
          videoId: video.id,
        );
      }
      if (mounted) {
        setState(() {
          _myVideos = _myVideos.where((v) => v.id != video.id).toList();
        });
      }
      if (removeFromList) {
        unawaited(_loadMyVideos(showLoadingState: false));
      }
      unawaited(ProfileStatsNotifier.instance.refresh());
    } on AuthApiException catch (e) {
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(localizeAuthApiError(l10n, e))));
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

class _VideoThumbnailIcon extends StatefulWidget {
  const _VideoThumbnailIcon({
    required this.videoPath,
    required this.colorScheme,
  });

  final String videoPath;
  final ColorScheme colorScheme;

  @override
  State<_VideoThumbnailIcon> createState() => _VideoThumbnailIconState();
}

class _VideoThumbnailIconState extends State<_VideoThumbnailIcon> {
  Uint8List? _thumbnail;

  @override
  void initState() {
    super.initState();
    _loadThumbnail();
  }

  @override
  void didUpdateWidget(_VideoThumbnailIcon old) {
    super.didUpdateWidget(old);
    if (old.videoPath != widget.videoPath) {
      setState(() {
        _thumbnail = null;
      });
      _loadThumbnail();
    }
  }

  // Try these offsets in order; use the first frame whose brightness
  // is above the threshold (15/255). Falls back to the last attempt.
  static const _candidateMs = [0, 1000, 3000, 7000];
  static const _brightnessThreshold = 15.0;

  Future<void> _loadThumbnail() async {
    try {
      Uint8List? best;
      for (final ms in _candidateMs) {
        final bytes = await VideoThumbnail.thumbnailData(
          video: widget.videoPath,
          imageFormat: ImageFormat.JPEG,
          maxWidth: 104,
          quality: 75,
          timeMs: ms,
        );
        if (bytes == null) continue;
        best = bytes;
        if (await _averageBrightness(bytes) >= _brightnessThreshold) break;
      }
      if (mounted) {
        setState(() {
          _thumbnail = best;
        });
      }
    } catch (_) {}
  }

  /// Decodes the JPEG and returns the average luminance (0–255).
  static Future<double> _averageBrightness(Uint8List jpeg) async {
    try {
      final codec = await ui.instantiateImageCodec(jpeg);
      final frame = await codec.getNextFrame();
      final byteData = await frame.image.toByteData(
        format: ui.ImageByteFormat.rawRgba,
      );
      frame.image.dispose();
      if (byteData == null) return 0;
      final pixels = byteData.buffer.asUint8List();
      double sum = 0;
      int count = 0;
      // Sample every 50th pixel (4 bytes per pixel: R, G, B, A).
      for (int i = 0; i < pixels.length - 3; i += 200) {
        sum +=
            0.299 * pixels[i] + 0.587 * pixels[i + 1] + 0.114 * pixels[i + 2];
        count++;
      }
      return count > 0 ? sum / count : 0;
    } catch (_) {
      return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = widget.colorScheme;
    final thumb = _thumbnail;

    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: SizedBox(
        width: 52,
        height: 52,
        child: thumb != null
            ? Image.memory(thumb, fit: BoxFit.cover)
            : Container(
                decoration: BoxDecoration(
                  color: colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  CupertinoIcons.video_camera,
                  color: colorScheme.primary,
                ),
              ),
      ),
    );
  }
}
