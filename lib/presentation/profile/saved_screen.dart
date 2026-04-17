import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../core/api_config_notifier.dart';
import '../../core/auth_api_error_localizations.dart';
import '../../l10n/app_localizations.dart';
import '../../core/auth_session_notifier.dart';
import '../../domain/models/models.dart';
import '../../infrastructure/auth_api_client.dart';
import '../practice/media_detail_screen.dart';

class SavedScreen extends StatefulWidget {
  const SavedScreen({super.key});

  @override
  State<SavedScreen> createState() => _SavedScreenState();
}

class _SavedScreenState extends State<SavedScreen> {
  List<UploadedVideo> _videos = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final token = AuthSessionNotifier.instance.session?.accessToken;
    if (token == null) {
      if (mounted)
        setState(() {
          _isLoading = false;
          _error = 'Sign in to view saved content.';
        });
      return;
    }
    if (mounted)
      setState(() {
        _isLoading = true;
        _error = null;
      });
    try {
      final videos = await AuthApiClient.instance.fetchSavedVideos(
        accessToken: token,
      );
      if (mounted)
        setState(() {
          _videos = videos;
          _isLoading = false;
        });
    } on AuthApiException catch (e) {
      if (!mounted) return;
      final l10n = AppLocalizations.of(context)!;
      setState(() {
        _isLoading = false;
        _error = localizeAuthApiError(l10n, e);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.savedTitle)),
      body: RefreshIndicator(
        onRefresh: _load,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(_error!),
                ),
              )
            : _videos.isEmpty
            ? _buildEmpty(context)
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _videos.length,
                itemBuilder: (context, index) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _buildTile(context, _videos[index]),
                ),
              ),
      ),
    );
  }

  Widget _buildEmpty(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.5,
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.bookmark_border,
                  size: 48,
                  color: Colors.grey.shade400,
                ),
                const SizedBox(height: 16),
                Text(
                  'No saved lessons yet',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: Colors.grey),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTile(BuildContext context, UploadedVideo video) {
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
                    ? CachedNetworkImage(
                        imageUrl: video.coverImageUrl!,
                        fit: BoxFit.cover,
                        errorWidget: (_, __, ___) => _placeholder(isAudio),
                      )
                    : _placeholder(isAudio),
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

  Widget _placeholder(bool isAudio) {
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
      transcriptionVersion: video.transcriptionVersion,
      dialogueLines: video.dialogueLines,
      wordTiming: video.wordTiming,
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
