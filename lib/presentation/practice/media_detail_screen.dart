import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/auth_session_notifier.dart';
import '../../core/profile_stats_notifier.dart';
import '../../core/theme.dart';
import '../../domain/models/models.dart';
import '../../infrastructure/auth_api_client.dart';
import '../shared/locale_flag.dart';
import 'practice_player_screen.dart';

class MediaDetailScreen extends StatefulWidget {
  final MediaItem mediaItem;

  const MediaDetailScreen({super.key, required this.mediaItem});

  @override
  State<MediaDetailScreen> createState() => _MediaDetailScreenState();
}

class _MediaDetailScreenState extends State<MediaDetailScreen> {
  bool _transcriptExpanded = false;
  bool? _isSaved;
  bool _savePending = false;

  @override
  void initState() {
    super.initState();
    unawaited(_checkSaved());
  }

  Future<void> _checkSaved() async {
    final token = AuthSessionNotifier.instance.session?.accessToken;
    if (token == null) return;
    final saved = await AuthApiClient.instance.checkVideoSaved(
      accessToken: token,
      videoId: widget.mediaItem.id,
    );
    if (mounted) setState(() => _isSaved = saved);
  }

  Future<void> _toggleSave() async {
    final token = AuthSessionNotifier.instance.session?.accessToken;
    if (token == null) return;
    if (_savePending) return;

    setState(() => _savePending = true);
    try {
      if (_isSaved == true) {
        await AuthApiClient.instance.unsaveVideo(
          accessToken: token,
          videoId: widget.mediaItem.id,
        );
        if (mounted) setState(() => _isSaved = false);
        unawaited(ProfileStatsNotifier.instance.refresh());
      } else {
        await AuthApiClient.instance.saveVideo(
          accessToken: token,
          videoId: widget.mediaItem.id,
        );
        if (mounted) setState(() => _isSaved = true);
        unawaited(ProfileStatsNotifier.instance.refresh());
      }
    } catch (_) {
      // ignore network errors silently
    } finally {
      if (mounted) setState(() => _savePending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasCover = widget.mediaItem.coverUrl.trim().isNotEmpty;
    final langCode = widget.mediaItem.accent.trim();
    final flag = langCode.isNotEmpty ? flagEmojiForLocale(langCode) : '';

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text('Lesson Details'),
        actions: [
          if (_savePending)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 12),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          else
            IconButton(
              icon: Icon(
                _isSaved == true ? Icons.bookmark : Icons.bookmark_border,
                color: _isSaved == true ? BanteraTheme.primaryColor : null,
              ),
              tooltip: _isSaved == true ? 'Unsave' : 'Save',
              onPressed: AuthSessionNotifier.instance.session != null
                  ? _toggleSave
                  : null,
            ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cover image or placeholder
            SizedBox(
              height: 250,
              width: double.infinity,
              child: hasCover
                  ? Image.network(
                      widget.mediaItem.coverUrl,
                      height: 250,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _CoverPlaceholder(
                        isAudio: widget.mediaItem.isAudioOnly,
                      ),
                    )
                  : _CoverPlaceholder(isAudio: widget.mediaItem.isAudioOnly),
            ),

            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Audio / Video + language row
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: BanteraTheme.primaryColor.withValues(
                            alpha: 0.12,
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              widget.mediaItem.isAudioOnly
                                  ? Icons.audiotrack
                                  : Icons.videocam_outlined,
                              size: 14,
                              color: BanteraTheme.primaryColor,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              widget.mediaItem.isAudioOnly ? 'Audio' : 'Video',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: BanteraTheme.primaryColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (flag.isNotEmpty || widget.mediaItem.spokenLanguage.isNotEmpty) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey.withValues(alpha: 0.10),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            flag.isNotEmpty
                                ? '$flag  ${widget.mediaItem.spokenLanguage}'
                                : widget.mediaItem.spokenLanguage,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    widget.mediaItem.title,
                    style: Theme.of(
                      context,
                    ).textTheme.displayLarge?.copyWith(fontSize: 28),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _CreatorAvatar(
                        avatarUrl: widget.mediaItem.creator.avatarUrl,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        widget.mediaItem.creator.displayName,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => PracticePlayerScreen(
                              mediaItem: widget.mediaItem,
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.play_arrow_rounded, size: 28),
                      label: const Text(
                        'Start Practice',
                        style: TextStyle(fontSize: 18),
                      ),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  const Divider(),
                  const SizedBox(height: 16),
                  _buildTranscriptSection(context),
                  const SizedBox(height: 48),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTranscriptSection(BuildContext context) {
    final cues = widget.mediaItem.cues;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: () =>
              setState(() => _transcriptExpanded = !_transcriptExpanded),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                Text(
                  'Transcript',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(width: 6),
                if (cues.isNotEmpty)
                  Text(
                    '(${cues.length} lines)',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                const Spacer(),
                Icon(
                  _transcriptExpanded
                      ? Icons.keyboard_arrow_up_rounded
                      : Icons.keyboard_arrow_down_rounded,
                  color: BanteraTheme.primaryColor,
                ),
                const SizedBox(width: 2),
                Text(
                  _transcriptExpanded ? 'Hide' : 'Show',
                  style: const TextStyle(
                    color: BanteraTheme.primaryColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
        if (_transcriptExpanded) ...[
          const SizedBox(height: 16),
          if (cues.isEmpty)
            Text(
              'No transcript available.',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.grey),
            )
          else
            ...cues.map(
              (cue) => Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: Text(
                  cue.originalText,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyLarge?.copyWith(fontSize: 18),
                ),
              ),
            ),
        ],
      ],
    );
  }
}

class _CoverPlaceholder extends StatelessWidget {
  const _CoverPlaceholder({required this.isAudio});

  final bool isAudio;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey.shade200,
      child: Center(
        child: Icon(
          isAudio ? Icons.audiotrack : Icons.videocam_outlined,
          size: 72,
          color: Colors.grey.shade400,
        ),
      ),
    );
  }
}

class _CreatorAvatar extends StatelessWidget {
  const _CreatorAvatar({required this.avatarUrl});

  final String avatarUrl;

  @override
  Widget build(BuildContext context) {
    final hasAvatar = avatarUrl.trim().isNotEmpty;
    return CircleAvatar(
      radius: 16,
      foregroundImage: hasAvatar ? NetworkImage(avatarUrl) : null,
      child: hasAvatar ? null : const Icon(Icons.person, size: 16),
    );
  }
}
