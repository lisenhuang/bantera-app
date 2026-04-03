import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

import '../../core/auth_session_notifier.dart';
import '../../domain/models/models.dart';
import '../../infrastructure/auth_api_client.dart';
import 'local_video_practice_screen.dart';
import 'uploaded_video_detail_screen.dart';
import 'video_upload_screen.dart';

class CreateHubScreen extends StatefulWidget {
  const CreateHubScreen({super.key});

  @override
  State<CreateHubScreen> createState() => _CreateHubScreenState();
}

class _CreateHubScreenState extends State<CreateHubScreen> {
  final AuthApiClient _apiClient = AuthApiClient.instance;

  List<UploadedVideo> _myVideos = const [];
  bool _isLoadingVideos = true;
  String? _loadError;

  @override
  void initState() {
    super.initState();
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
                    CupertinoIcons.video_camera,
                    'Upload Video',
                    colorScheme,
                    isSecondary: true,
                    onTap: () async {
                      final uploaded = await Navigator.of(context)
                          .push<UploadedVideo>(
                            MaterialPageRoute<UploadedVideo>(
                              builder: (_) => const VideoUploadScreen(),
                            ),
                          );

                      if (!mounted) {
                        return;
                      }

                      if (uploaded != null) {
                        setState(() {
                          _myVideos = [
                            uploaded,
                            ..._myVideos.where(
                              (video) => video.id != uploaded.id,
                            ),
                          ];
                        });
                      } else {
                        await _loadMyVideos(showLoadingState: false);
                      }
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
                  'Your Videos',
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

  Widget _buildUploadedVideoItem(
    BuildContext context,
    UploadedVideo video,
    ColorScheme colorScheme,
  ) {
    final theme = Theme.of(context);

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () {
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
            Container(
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
                const SizedBox(height: 14),
                Icon(
                  CupertinoIcons.chevron_right,
                  color: colorScheme.onSurface.withValues(alpha: 0.45),
                  size: 18,
                ),
              ],
            ),
          ],
        ),
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
}
