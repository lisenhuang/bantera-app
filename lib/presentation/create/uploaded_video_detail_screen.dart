import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

import '../../core/auth_api_error_localizations.dart';
import '../../core/auth_session_notifier.dart';
import '../../core/profile_stats_notifier.dart';
import '../../core/user_profile_notifier.dart';
import '../../domain/models/models.dart';
import '../../infrastructure/auth_api_client.dart';
import '../../infrastructure/video_processing_service.dart';
import '../../l10n/app_localizations.dart';
import '../practice/practice_player_screen.dart';
import '../shared/profile_avatar.dart';
import '../shared/lesson_details_body.dart';

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

  bool get _showsBanteraAiBranding => _video.isAiGenerated;

  @override
  void initState() {
    super.initState();
    _video = widget.video;
    if (_video.isAiGenerated && _video.isTranscriptionEstimated) {
      unawaited(_runPhoneTranscription());
    }
  }

  bool get _supportsRemoveFromList {
    final contentType = _video.videoContentType.trim().toLowerCase();
    return _video.isAiGenerated && contentType.startsWith('audio/');
  }

  Future<void> _confirmDelete() async {
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final l10n = AppLocalizations.of(context)!;
    final errorColor = Theme.of(context).colorScheme.error;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text(l10n.removeFromListTitle),
          content: Text(l10n.removeFromListBody),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: Text(l10n.cancel),
            ),
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              style: TextButton.styleFrom(foregroundColor: errorColor),
              child: Text(l10n.removeFromListLabel),
            ),
          ],
        );
      },
    );
    if (confirmed != true || !mounted) return;

    final accessToken = AuthSessionNotifier.instance.session?.accessToken;
    if (accessToken == null) return;

    try {
      await AuthApiClient.instance.removeVideoFromList(
        accessToken: accessToken,
        videoId: _video.id,
      );
      unawaited(ProfileStatsNotifier.instance.refresh());
      if (mounted) navigator.pop(true);
    } on AuthApiException catch (e) {
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(content: Text(localizeAuthApiError(l10n, e))),
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
      final result = await VideoProcessingService.instance
          .transcribeAudioForUpload(
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
        _transcriptionError = AppLocalizations.of(
          context,
        )!.uploadedDetailTranscriptionFailedFallback;
      });
    } finally {
      try {
        await tempFile?.delete();
      } catch (_) {}
    }
  }

  @override
  Widget build(BuildContext context) {
    final video = _video;
    return ListenableBuilder(
      listenable: UserProfileNotifier.instance,
      builder: (context, _) {
        final profile = UserProfileNotifier.instance;
        final l10n = AppLocalizations.of(context)!;
        final media = _toMediaItem(profile, l10n);
        return Scaffold(
          appBar: AppBar(
            title: Text(
              media.isAudioOnly
                  ? l10n.uploadedDetailYourAudio
                  : l10n.uploadedDetailYourVideo,
            ),
            actions: [
              if (_supportsRemoveFromList)
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  tooltip: l10n.removeFromListLabel,
                  onPressed: _isTranscribing ? null : _confirmDelete,
                ),
            ],
          ),
          body: LessonDetailsBody(
            mediaItem: media,
            isPrivate: !video.isPublic,
            resolution: video.videoWidth != null && video.videoHeight != null
                ? '${video.videoWidth}×${video.videoHeight}'
                : null,
            creatorAvatar: _showsBanteraAiBranding
                ? const CircleAvatar(
                    radius: 18,
                    backgroundColor: Colors.transparent,
                    backgroundImage: AssetImage('assets/icon.png'),
                  )
                : ProfileAvatar(
                    radius: 18,
                    imageUrl: profile.avatarUrl,
                    imagePath: profile.avatarImagePath,
                  ),
            isTranscribing: _isTranscribing,
            transcriptionError: _transcriptionError,
            onStartPractice: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => PracticePlayerScreen(mediaItem: media),
              ),
            ),
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
        displayName: _showsBanteraAiBranding
            ? 'Bantera AI'
            : profile.displayName,
        avatarUrl: _showsBanteraAiBranding ? '' : (profile.avatarUrl ?? ''),
        firstLanguage: '',
        learningLanguage: '',
        level: '',
      ),
      coverUrl: _video.coverImageUrl ?? '',
      videoUrl: _video.videoUrl,
      mediaHeaders: accessToken == null || accessToken.isEmpty
          ? const {}
          : <String, String>{'Authorization': 'Bearer $accessToken'},
      spokenLanguage: _video.transcriptLanguage,
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
      shortCues: _video.transcriptShortCues
          .map(
            (cue) => Cue(
              id: '${_video.id}-s${cue.index}',
              startTimeMs: cue.startMs,
              endTimeMs: cue.endMs,
              originalText: cue.text,
              translatedText: '',
            ),
          )
          .toList(),
      hasBackendShortCues: _video.transcriptShortCues.isNotEmpty,
      transcriptionSource: l10n.uploadedDetailTranscriptionSourceYourUpload,
      isAudioOnly: _video.videoWidth == null && _video.videoHeight == null,
      createdAt: _video.createdAt,
      transcriptionVersion: _video.transcriptionVersion,
      dialogueLines: _video.dialogueLines,
      wordTiming: _video.wordTiming,
    );
  }

  static String _displayTitle(String fileName) {
    final dotIndex = fileName.lastIndexOf('.');
    if (dotIndex <= 0) {
      return fileName;
    }

    return fileName.substring(0, dotIndex);
  }
}
