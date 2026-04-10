import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';

import '../../core/auth_session_notifier.dart';
import '../../core/profile_stats_notifier.dart';
import '../../core/user_profile_notifier.dart';
import '../../domain/models/models.dart';
import '../../infrastructure/auth_api_client.dart';
import '../../infrastructure/video_processing_service.dart';
import '../../l10n/app_localizations.dart';
import '../practice/practice_player_screen.dart';
import '../shared/profile_avatar.dart';

class UploadedVideoDetailScreen extends StatefulWidget {
  const UploadedVideoDetailScreen({super.key, required this.video});

  final UploadedVideo video;

  @override
  State<UploadedVideoDetailScreen> createState() =>
      _UploadedVideoDetailScreenState();
}

class _UploadedVideoDetailScreenState extends State<UploadedVideoDetailScreen> {
  late UploadedVideo _video;
  bool _isTranscribing = false;
  String? _transcriptionError;
  bool _transcriptExpanded = false;

  @override
  void initState() {
    super.initState();
    _video = widget.video;
    if (_video.isAiGenerated && _video.isTranscriptionEstimated) {
      unawaited(_runPhoneTranscription());
    }
  }

  bool get _isAudioOnlyUpload =>
      _video.videoWidth == null && _video.videoHeight == null;

  Future<void> _confirmDelete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        final l10n = AppLocalizations.of(ctx)!;
        final isAudio = _isAudioOnlyUpload;
        return AlertDialog(
          title: Text(
            isAudio
                ? l10n.uploadedDetailDeleteAudioTitle
                : l10n.uploadedDetailDeleteVideoTitle,
          ),
          content: Text(
            isAudio
                ? l10n.uploadedDetailDeleteAudioBody
                : l10n.uploadedDetailDeleteVideoBody,
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
              child: Text(l10n.deleteLabel),
            ),
          ],
        );
      },
    );
    if (confirmed != true || !mounted) return;

    final accessToken = AuthSessionNotifier.instance.session?.accessToken;
    if (accessToken == null) return;

    try {
      await AuthApiClient.instance.deleteVideo(
        accessToken: accessToken,
        videoId: _video.id,
      );
      unawaited(ProfileStatsNotifier.instance.refresh());
      if (mounted) Navigator.of(context).pop();
    } on AuthApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message)),
      );
    }
  }

  Future<void> _runPhoneTranscription() async {
    final accessToken = AuthSessionNotifier.instance.session?.accessToken;
    if (accessToken == null || accessToken.isEmpty) return;

    final videoUrl = _video.videoUrl?.trim();
    if (videoUrl == null || videoUrl.isEmpty) return;

    final localeIdentifier = _video.transcriptLanguageCode.isNotEmpty
        ? _video.transcriptLanguageCode
        : _video.transcriptLanguage;

    if (!mounted) return;
    setState(() {
      _isTranscribing = true;
      _transcriptionError = null;
    });

    File? tempFile;
    try {
      // Download WAV to a temp file (HttpClient bypasses iOS ATS for HTTP)
      final uri = Uri.parse(videoUrl);
      final request = await HttpClient().getUrl(uri);
      request.headers.set('Authorization', 'Bearer $accessToken');
      final response = await request.close();
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw Exception('Server returned ${response.statusCode}');
      }
      final tempDir = await getTemporaryDirectory();
      tempFile = File('${tempDir.path}/bantera_transcribe_${_video.id}.wav');
      final sink = tempFile.openWrite();
      await response.pipe(sink);

      // Transcribe with SFSpeechRecognizer
      final result = await VideoProcessingService.instance.transcribeAudioForUpload(
        inputFile: tempFile,
        localeIdentifier: localeIdentifier,
      );

      if (result.transcriptCues.isEmpty) {
        throw const VideoProcessingException(
          code: 'no_cues',
          message: 'The transcription returned no cues.',
        );
      }

      // Send real cues to server
      final updated = await AuthApiClient.instance.updateVideoTranscript(
        accessToken: accessToken,
        videoId: _video.id,
        transcriptText: result.transcriptText,
        transcriptCues: result.transcriptCues,
      );

      if (!mounted) return;
      setState(() {
        _video = updated;
        _isTranscribing = false;
      });
    } on VideoProcessingException catch (e) {
      if (!mounted) return;
      final l10n = AppLocalizations.of(context)!;
      final message = e.code == 'no_cues'
          ? l10n.uploadedDetailTranscriptionNoCues
          : e.message;
      setState(() {
        _isTranscribing = false;
        _transcriptionError = message;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isTranscribing = false;
        _transcriptionError = AppLocalizations.of(context)!
            .uploadedDetailTranscriptionFailedFallback;
      });
    } finally {
      try {
        await tempFile?.delete();
      } catch (_) {}
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final video = _video;

    return ListenableBuilder(
      listenable: UserProfileNotifier.instance,
      builder: (context, _) {
        final profile = UserProfileNotifier.instance;
        final l10n = AppLocalizations.of(context)!;

        return Scaffold(
          appBar: AppBar(
            title: Text(
              video.videoWidth == null && video.videoHeight == null
                  ? l10n.uploadedDetailYourAudio
                  : l10n.uploadedDetailYourVideo,
            ),
            actions: [
              if (video.isAiGenerated)
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  tooltip: l10n.deleteLabel,
                  onPressed: _isTranscribing ? null : () => _confirmDelete(context),
                ),
            ],
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
                        gradient: video.coverImageUrl == null
                            ? LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  colorScheme.primary.withValues(alpha: 0.16),
                                  colorScheme.tertiary.withValues(alpha: 0.14),
                                ],
                              )
                            : null,
                        image: video.coverImageUrl != null
                            ? DecorationImage(
                                image: NetworkImage(video.coverImageUrl!),
                                fit: BoxFit.cover,
                                colorFilter: ColorFilter.mode(
                                  Colors.black.withValues(alpha: 0.45),
                                  BlendMode.darken,
                                ),
                              )
                            : null,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (video.coverImageUrl == null) ...[
                            Icon(
                              Icons.ondemand_video_rounded,
                              size: 42,
                              color: colorScheme.primary,
                            ),
                            const SizedBox(height: 18),
                          ] else
                            const SizedBox(height: 8),
                          Text(
                            _displayTitle(video.originalFileName),
                            style: theme.textTheme.headlineSmall?.copyWith(
                              color: video.coverImageUrl != null ? Colors.white : null,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              _MetaChip(
                                label: video.isPublic
                                    ? l10n.createPublicBadge
                                    : l10n.createPrivateBadge,
                                icon: video.isPublic
                                    ? Icons.public
                                    : Icons.lock_outline,
                              ),
                              if (video.isAiGenerated)
                                _MetaChip(
                                  label: l10n.uploadedDetailAiGenerated,
                                  icon: Icons.auto_awesome,
                                  color: Colors.purple,
                                ),
                              _MetaChip(
                                label: video.transcriptLanguage,
                                icon: Icons.translate_outlined,
                              ),
                              _MetaChip(
                                label: l10n.createVideoMetaCues(
                                  video.transcriptCues.length,
                                ),
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
                          _formatDateLabel(context, video.createdAt),
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    _InfoRow(
                      label: l10n.uploadedDetailFileSize,
                      value: _formatBytes(video.fileSizeBytes),
                    ),
                    if (video.videoWidth != null && video.videoHeight != null)
                      _InfoRow(
                        label: l10n.uploadedDetailResolution,
                        value: _formatResolutionLabel(
                          context,
                          video.videoWidth,
                          video.videoHeight,
                        ),
                      ),
                    _InfoRow(
                      label: l10n.mediaTranscript,
                      value: video.transcriptLanguageCode.isEmpty
                          ? video.transcriptLanguage
                          : '${video.transcriptLanguage} · ${video.transcriptLanguageCode.toUpperCase()}',
                    ),
                  ],
                ),
              ),

              // Transcription status banner
              if (_isTranscribing) ...[
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    color: colorScheme.primaryContainer.withValues(alpha: 0.5),
                  ),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: colorScheme.primary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          l10n.uploadedDetailTranscribing,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onPrimaryContainer,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ] else if (_transcriptionError != null) ...[
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    color: colorScheme.errorContainer.withValues(alpha: 0.5),
                  ),
                  child: Text(
                    _transcriptionError!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onErrorContainer,
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _isTranscribing || video.transcriptCues.isEmpty
                      ? null
                      : () {
                          Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) => PracticePlayerScreen(
                                mediaItem: _toMediaItem(profile, l10n),
                              ),
                            ),
                          );
                        },
                  icon: const Icon(Icons.headphones_rounded),
                  label: Text(l10n.mediaStartPractice),
                ),
              ),
              const SizedBox(height: 18),
              // Transcript section – collapsed by default
              InkWell(
                borderRadius: BorderRadius.circular(8),
                onTap: () => setState(
                  () => _transcriptExpanded = !_transcriptExpanded,
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Text(
                        l10n.mediaTranscript,
                        style: theme.textTheme.titleLarge,
                      ),
                      const SizedBox(width: 6),
                      if (video.transcriptCues.isNotEmpty)
                        Text(
                          '(${l10n.createVideoMetaCues(video.transcriptCues.length)})',
                          style: theme.textTheme.bodySmall,
                        ),
                      const Spacer(),
                      Icon(
                        _transcriptExpanded
                            ? Icons.keyboard_arrow_up_rounded
                            : Icons.keyboard_arrow_down_rounded,
                        color: colorScheme.primary,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        _transcriptExpanded ? l10n.mediaHide : l10n.mediaShow,
                        style: TextStyle(
                          color: colorScheme.primary,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (_transcriptExpanded) ...[
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
                    child: Text(l10n.uploadedDetailNoTranscriptCuesYet),
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
            ],
          ),
        );
      },
    );
  }

  MediaItem _toMediaItem(UserProfileNotifier profile, AppLocalizations l10n) {
    final accessToken = AuthSessionNotifier.instance.session?.accessToken;

    return MediaItem(
      id: _video.id,
      title: _displayTitle(_video.originalFileName),
      description: l10n.uploadedDetailMediaDescription(
        _video.transcriptCues.length,
      ),
      creator: User(
        id: _video.userId,
        displayName: profile.displayName,
        avatarUrl: profile.avatarUrl ?? '',
        firstLanguage: '',
        learningLanguage: '',
        level: '',
      ),
      coverUrl: _video.coverImageUrl ?? '',
      videoUrl: _video.videoUrl,
      mediaHeaders: accessToken == null || accessToken.isEmpty
          ? const {}
          : <String, String>{'Authorization': 'Bearer $accessToken'},
      spokenLanguage: _video.transcriptLanguageCode.isEmpty
          ? _video.transcriptLanguage
          : _video.transcriptLanguageCode.toUpperCase(),
      accent: _video.transcriptLanguageCode.isNotEmpty
          ? _video.transcriptLanguageCode
          : _video.transcriptLanguage,
      durationMs: _video.durationMs,
      cues: _video.transcriptCues.map((cue) {
        return Cue(
          id: '${_video.id}-${cue.index}',
          startTimeMs: cue.startMs,
          endTimeMs: cue.endMs,
          originalText: cue.text,
          translatedText: '',
        );
      }).toList(),
      transcriptionSource: l10n.uploadedDetailTranscriptionSourceYourUpload,
      isAudioOnly: _video.videoWidth == null && _video.videoHeight == null,
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

  String _formatResolutionLabel(
    BuildContext context,
    int? width,
    int? height,
  ) {
    if (width == null || height == null) {
      return AppLocalizations.of(context)!.uploadedDetailResolutionUnknown;
    }
    return '$width×$height';
  }

  String _formatDateLabel(BuildContext context, DateTime value) {
    return DateFormat.yMMMd(
      Localizations.localeOf(context).toString(),
    ).format(value.toLocal());
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
