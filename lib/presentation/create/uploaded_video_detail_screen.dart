import 'package:flutter/material.dart';

import '../../core/auth_session_notifier.dart';
import '../../core/user_profile_notifier.dart';
import '../../domain/models/models.dart';
import '../practice/practice_player_screen.dart';
import '../shared/profile_avatar.dart';

class UploadedVideoDetailScreen extends StatelessWidget {
  const UploadedVideoDetailScreen({super.key, required this.video});

  final UploadedVideo video;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return ListenableBuilder(
      listenable: UserProfileNotifier.instance,
      builder: (context, _) {
        final profile = UserProfileNotifier.instance;

        return Scaffold(
          appBar: AppBar(
            title: Text(
              video.videoWidth == null && video.videoHeight == null
                  ? 'Your Audio'
                  : 'Your Video',
            ),
          ),
          body: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  color: colorScheme.surface,
                  border: Border.all(
                    color: colorScheme.outline.withValues(alpha: 0.12),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            colorScheme.primary.withValues(alpha: 0.16),
                            colorScheme.tertiary.withValues(alpha: 0.14),
                          ],
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.ondemand_video_rounded,
                            size: 42,
                            color: colorScheme.primary,
                          ),
                          const SizedBox(height: 18),
                          Text(
                            _displayTitle(video.originalFileName),
                            style: theme.textTheme.headlineSmall,
                          ),
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              _MetaChip(
                                label: video.isPublic ? 'Public' : 'Private',
                                icon: video.isPublic
                                    ? Icons.public
                                    : Icons.lock_outline,
                              ),
                              if (video.isAiGenerated)
                                _MetaChip(
                                  label: 'AI Generated',
                                  icon: Icons.auto_awesome,
                                  color: Colors.purple,
                                ),
                              _MetaChip(
                                label: video.transcriptLanguage,
                                icon: Icons.translate_outlined,
                              ),
                              _MetaChip(
                                label: '${video.transcriptCues.length} cues',
                                icon: Icons.subtitles_outlined,
                              ),
                              _MetaChip(
                                label: _formatDuration(video.durationMs),
                                icon: Icons.schedule_outlined,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        ProfileAvatar(
                          radius: 18,
                          imageUrl: profile.avatarUrl,
                          imagePath: profile.avatarImagePath,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            profile.displayName,
                            style: theme.textTheme.titleMedium,
                          ),
                        ),
                        Text(
                          _formatDate(video.createdAt),
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    _InfoRow(
                      label: 'File size',
                      value: _formatBytes(video.fileSizeBytes),
                    ),
                    if (video.videoWidth != null && video.videoHeight != null)
                      _InfoRow(
                        label: 'Resolution',
                        value: _formatResolution(
                          video.videoWidth,
                          video.videoHeight,
                        ),
                      ),
                    _InfoRow(
                      label: 'Transcript',
                      value: video.transcriptLanguageCode.isEmpty
                          ? video.transcriptLanguage
                          : '${video.transcriptLanguage} · ${video.transcriptLanguageCode.toUpperCase()}',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: video.transcriptCues.isEmpty
                      ? null
                      : () {
                          Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) => PracticePlayerScreen(
                                mediaItem: _toMediaItem(profile),
                              ),
                            ),
                          );
                        },
                  icon: const Icon(Icons.headphones_rounded),
                  label: const Text('Start Practice'),
                ),
              ),
              const SizedBox(height: 18),
              Text('Transcript Preview', style: theme.textTheme.titleLarge),
              const SizedBox(height: 12),
              if (video.transcriptCues.isEmpty)
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    color: colorScheme.surface,
                    border: Border.all(
                      color: colorScheme.outline.withValues(alpha: 0.12),
                    ),
                  ),
                  child: const Text('No transcript cues are available yet.'),
                )
              else
                ...video.transcriptCues.map((cue) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18),
                      color: colorScheme.surface,
                      border: Border.all(
                        color: colorScheme.outline.withValues(alpha: 0.1),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${cue.index + 1}. ${_formatCueRange(cue)}',
                          style: theme.textTheme.labelLarge?.copyWith(
                            color: colorScheme.primary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(cue.text, style: theme.textTheme.bodyLarge),
                      ],
                    ),
                  );
                }),
            ],
          ),
        );
      },
    );
  }

  MediaItem _toMediaItem(UserProfileNotifier profile) {
    final accessToken = AuthSessionNotifier.instance.session?.accessToken;

    return MediaItem(
      id: video.id,
      title: _displayTitle(video.originalFileName),
      description:
          'Your uploaded practice clip with ${video.transcriptCues.length} transcript cues.',
      creator: User(
        id: video.userId,
        displayName: profile.displayName,
        avatarUrl: profile.avatarUrl ?? '',
        firstLanguage: '',
        learningLanguage: '',
        level: '',
      ),
      coverUrl: '',
      videoUrl: video.videoUrl,
      mediaHeaders: accessToken == null || accessToken.isEmpty
          ? const {}
          : <String, String>{'Authorization': 'Bearer $accessToken'},
      spokenLanguage: video.transcriptLanguageCode.isEmpty
          ? video.transcriptLanguage
          : video.transcriptLanguageCode.toUpperCase(),
      accent: video.transcriptLanguageCode.isNotEmpty
          ? video.transcriptLanguageCode
          : video.transcriptLanguage,
      durationMs: video.durationMs,
      cues: video.transcriptCues.map((cue) {
        return Cue(
          id: '${video.id}-${cue.index}',
          startTimeMs: cue.startMs,
          endTimeMs: cue.endMs,
          originalText: cue.text,
          translatedText: '',
        );
      }).toList(),
      transcriptionSource: 'Your Upload',
      isAudioOnly: video.videoWidth == null && video.videoHeight == null,
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

  static String _formatBytes(int bytes) {
    if (bytes >= 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    if (bytes >= 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    }
    return '$bytes B';
  }

  static String _formatResolution(int? width, int? height) {
    if (width == null || height == null) {
      return 'Unknown';
    }
    return '$width×$height';
  }

  static String _formatCueRange(VideoTranscriptCue cue) {
    return '${_formatTimestamp(cue.startMs)} - ${_formatTimestamp(cue.endMs)}';
  }

  static String _formatTimestamp(int milliseconds) {
    final totalSeconds = milliseconds ~/ 1000;
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  static String _formatDate(DateTime value) {
    final local = value.toLocal();
    final month = _monthLabel(local.month);
    return '$month ${local.day}, ${local.year}';
  }

  static String _monthLabel(int month) {
    const months = <String>[
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    return months[(month - 1).clamp(0, 11)];
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({required this.label, required this.icon, this.color});

  final String label;
  final IconData icon;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final effectiveColor = color ?? colorScheme.primary;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: color != null
            ? color!.withValues(alpha: 0.12)
            : colorScheme.surface.withValues(alpha: 0.8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: effectiveColor),
          const SizedBox(width: 8),
          Text(
            label,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: color != null ? effectiveColor : null,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          SizedBox(
            width: 104,
            child: Text(
              label,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
