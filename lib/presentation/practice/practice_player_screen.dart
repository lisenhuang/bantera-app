import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../../domain/models/models.dart';
import 'record_compare_sheet.dart';

enum SubtitleState { hidden, original, translated }

class PracticePlayerScreen extends StatefulWidget {
  const PracticePlayerScreen({super.key, required this.mediaItem});

  final MediaItem mediaItem;

  @override
  State<PracticePlayerScreen> createState() => _PracticePlayerScreenState();
}

class _PracticePlayerScreenState extends State<PracticePlayerScreen> {
  int _currentCueIndex = 0;
  SubtitleState _subtitleState = SubtitleState.hidden;
  bool _isPlaying = false;
  bool _isInitializingMedia = false;
  String? _mediaError;
  VideoPlayerController? _videoController;
  VoidCallback? _videoListener;

  bool get _hasPlayableMedia =>
      (widget.mediaItem.localVideoPath?.trim().isNotEmpty ?? false) ||
      (widget.mediaItem.videoUrl?.trim().isNotEmpty ?? false);

  @override
  void initState() {
    super.initState();
    _initializeMedia();
  }

  @override
  void dispose() {
    final controller = _videoController;
    final listener = _videoListener;
    if (controller != null && listener != null) {
      controller.removeListener(listener);
    }
    controller?.dispose();

    if (widget.mediaItem.deleteLocalMediaOnDispose) {
      final localPath = widget.mediaItem.localVideoPath?.trim();
      if (localPath != null && localPath.isNotEmpty) {
        unawaited(_deleteLocalMedia(localPath));
      }
    }

    super.dispose();
  }

  void _nextCue() {
    if (_currentCueIndex < widget.mediaItem.cues.length - 1) {
      unawaited(_selectCue(_currentCueIndex + 1));
    }
  }

  void _prevCue() {
    if (_currentCueIndex > 0) {
      unawaited(_selectCue(_currentCueIndex - 1));
    }
  }

  void _togglePlay() {
    unawaited(_togglePlayback());
  }

  void _cycleSubtitleState() {
    setState(() {
      if (_subtitleState == SubtitleState.hidden) {
        _subtitleState = SubtitleState.original;
      } else if (_subtitleState == SubtitleState.original) {
        _subtitleState = SubtitleState.translated;
      } else {
        _subtitleState = SubtitleState.hidden;
      }
    });
  }

  void _openCompareSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) =>
          RecordCompareSheet(cue: widget.mediaItem.cues[_currentCueIndex]),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.mediaItem.cues.isEmpty) {
      return const Scaffold(body: Center(child: Text('No cues')));
    }

    final cue = widget.mediaItem.cues[_currentCueIndex];
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text(
          '${_currentCueIndex + 1} / ${widget.mediaItem.cues.length}',
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(CupertinoIcons.settings),
            onPressed: () {},
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 12,
                    foregroundImage:
                        widget.mediaItem.creator.avatarUrl.trim().isEmpty
                        ? null
                        : NetworkImage(widget.mediaItem.creator.avatarUrl),
                    child: widget.mediaItem.creator.avatarUrl.trim().isEmpty
                        ? const Icon(CupertinoIcons.person, size: 14)
                        : null,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      widget.mediaItem.title,
                      style: Theme.of(
                        context,
                      ).textTheme.titleMedium?.copyWith(fontSize: 14),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: GestureDetector(
                onTap: _togglePlay,
                child: Container(
                  width: double.infinity,
                  margin: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    borderRadius: BorderRadius.circular(32),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Center(
                          child: _buildMainPracticeArea(cue, colorScheme),
                        ),
                      ),
                      const SizedBox(height: 18),
                      _buildCueTimeline(cue, colorScheme),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                    onPressed: _cycleSubtitleState,
                    icon: Icon(
                      _subtitleState == SubtitleState.hidden
                          ? CupertinoIcons.eye
                          : CupertinoIcons.textformat,
                    ),
                    label: Text(
                      _subtitleState == SubtitleState.hidden
                          ? 'Show Transcript'
                          : 'Translate',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.only(
                top: 16,
                bottom: 24,
                left: 32,
                right: 32,
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        iconSize: 36,
                        icon: const Icon(CupertinoIcons.backward_fill),
                        color: _currentCueIndex > 0
                            ? colorScheme.onSurface
                            : colorScheme.onSurface.withValues(alpha: 0.2),
                        onPressed: _prevCue,
                      ),
                      const SizedBox(width: 24),
                      IconButton(
                        iconSize: 72,
                        icon: Icon(
                          _isPlaying
                              ? CupertinoIcons.pause_circle_fill
                              : CupertinoIcons.play_circle_fill,
                        ),
                        color: colorScheme.primary,
                        onPressed: _togglePlay,
                      ),
                      const SizedBox(width: 24),
                      IconButton(
                        iconSize: 36,
                        icon: const Icon(CupertinoIcons.forward_fill),
                        color:
                            _currentCueIndex < widget.mediaItem.cues.length - 1
                            ? colorScheme.onSurface
                            : colorScheme.onSurface.withValues(alpha: 0.2),
                        onPressed: _nextCue,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildActionBtn(
                        CupertinoIcons.bookmark,
                        'Note',
                        () {},
                        colorScheme,
                      ),
                      _buildActionBtn(
                        CupertinoIcons.mic_solid,
                        'Compare',
                        _openCompareSheet,
                        colorScheme,
                        isHighlight: true,
                      ),
                      _buildActionBtn(
                        CupertinoIcons.reply,
                        'Replay',
                        _togglePlay,
                        colorScheme,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainPracticeArea(Cue cue, ColorScheme colorScheme) {
    if (_isInitializingMedia) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_mediaError != null) {
      return Center(
        child: Text(
          _mediaError!,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      );
    }

    final controller = _videoController;
    if (controller == null || !controller.value.isInitialized) {
      return _buildSubtitleContent(cue, colorScheme, hasPlayableMedia: false);
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Container(color: Colors.black),
          FittedBox(
            fit: BoxFit.contain,
            child: SizedBox(
              width: controller.value.size.width,
              height: controller.value.size.height,
              child: VideoPlayer(controller),
            ),
          ),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.14),
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.6),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(18),
            child: _buildSubtitleContent(
              cue,
              colorScheme,
              hasPlayableMedia: true,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubtitleContent(
    Cue cue,
    ColorScheme colorScheme, {
    required bool hasPlayableMedia,
  }) {
    if (_subtitleState == SubtitleState.hidden) {
      if (hasPlayableMedia) {
        return Align(
          alignment: Alignment.topRight,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.52),
              borderRadius: BorderRadius.circular(999),
            ),
            child: const Text(
              'Transcript hidden',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        );
      }

      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            CupertinoIcons.ear,
            size: 64,
            color: colorScheme.primary.withValues(alpha: 0.4),
          ),
          const SizedBox(height: 16),
          Text(
            'Listen carefully...',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: colorScheme.primary.withValues(alpha: 0.6),
            ),
          ),
        ],
      );
    }

    final originalText = Text(
      cue.originalText,
      textAlign: TextAlign.center,
      style: Theme.of(context).textTheme.displayLarge?.copyWith(
        fontSize: hasPlayableMedia ? 28 : 32,
        height: 1.3,
        color: hasPlayableMedia ? Colors.white : null,
      ),
    );

    if (_subtitleState == SubtitleState.original) {
      if (!hasPlayableMedia) {
        return originalText;
      }

      return Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.58),
            borderRadius: BorderRadius.circular(18),
          ),
          child: originalText,
        ),
      );
    }

    final translatedText = cue.translatedText.trim().isEmpty
        ? 'Translation will be available during listening practice later.'
        : cue.translatedText;

    final translatedContent = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        originalText,
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: hasPlayableMedia
                ? Colors.white.withValues(alpha: 0.12)
                : colorScheme.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            translatedText,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: hasPlayableMedia ? Colors.white : colorScheme.primary,
            ),
          ),
        ),
      ],
    );

    if (!hasPlayableMedia) {
      return translatedContent;
    }

    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.58),
          borderRadius: BorderRadius.circular(18),
        ),
        child: translatedContent,
      ),
    );
  }

  Widget _buildCueTimeline(Cue cue, ColorScheme colorScheme) {
    return Container(
      height: 48,
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              '${_formatTimestamp(cue.startTimeMs)} - ${_formatTimestamp(cue.endTimeMs)}',
              style: Theme.of(context).textTheme.titleSmall,
            ),
          ),
          Container(
            width: 92,
            height: 8,
            decoration: BoxDecoration(
              color: colorScheme.onSurface.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(999),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor:
                  ((_currentCueIndex + 1) / widget.mediaItem.cues.length).clamp(
                    0.0,
                    1.0,
                  ),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: colorScheme.primary,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionBtn(
    IconData icon,
    String label,
    VoidCallback onTap,
    ColorScheme colorScheme, {
    bool isHighlight = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: isHighlight
                ? colorScheme.primary
                : colorScheme.surface,
            foregroundColor: isHighlight
                ? colorScheme.onPrimary
                : colorScheme.primary,
            child: Icon(icon, size: 28),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: isHighlight ? FontWeight.bold : FontWeight.w600,
              color: isHighlight
                  ? colorScheme.primary
                  : colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _initializeMedia() async {
    if (!_hasPlayableMedia) {
      return;
    }

    setState(() {
      _isInitializingMedia = true;
      _mediaError = null;
    });

    try {
      final localPath = widget.mediaItem.localVideoPath?.trim();
      final remoteUrl = widget.mediaItem.videoUrl?.trim();
      final controller = localPath != null && localPath.isNotEmpty
          ? VideoPlayerController.file(File(localPath))
          : VideoPlayerController.networkUrl(
              Uri.parse(remoteUrl!),
              httpHeaders: widget.mediaItem.mediaHeaders,
            );

      _videoController = controller;
      _videoListener = () {
        if (!mounted ||
            _videoController != controller ||
            !controller.value.isInitialized) {
          return;
        }

        final cue = widget.mediaItem.cues[_currentCueIndex];
        final cueEnd = Duration(milliseconds: cue.endTimeMs);
        if (_isPlaying && controller.value.position >= cueEnd) {
          controller.pause();
          if (mounted) {
            setState(() {
              _isPlaying = false;
            });
          }
        }
      };
      controller.addListener(_videoListener!);

      await controller.initialize();
      await controller.pause();
      await controller.seekTo(
        Duration(
          milliseconds: widget.mediaItem.cues[_currentCueIndex].startTimeMs,
        ),
      );
    } catch (_) {
      _mediaError = 'The selected video could not be opened for practice.';
    } finally {
      if (mounted) {
        setState(() {
          _isInitializingMedia = false;
        });
      }
    }
  }

  Future<void> _togglePlayback() async {
    final controller = _videoController;
    if (controller == null || !controller.value.isInitialized) {
      setState(() {
        _isPlaying = !_isPlaying;
      });
      return;
    }

    if (_isPlaying) {
      await controller.pause();
      if (mounted) {
        setState(() {
          _isPlaying = false;
        });
      }
      return;
    }

    final cue = widget.mediaItem.cues[_currentCueIndex];
    await controller.seekTo(Duration(milliseconds: cue.startTimeMs));
    await controller.play();
    if (mounted) {
      setState(() {
        _isPlaying = true;
      });
    }
  }

  Future<void> _selectCue(int nextIndex) async {
    if (nextIndex < 0 || nextIndex >= widget.mediaItem.cues.length) {
      return;
    }

    final controller = _videoController;
    if (controller != null && controller.value.isInitialized) {
      await controller.pause();
      await controller.seekTo(
        Duration(milliseconds: widget.mediaItem.cues[nextIndex].startTimeMs),
      );
    }

    if (!mounted) {
      return;
    }

    setState(() {
      _currentCueIndex = nextIndex;
      _subtitleState = SubtitleState.hidden;
      _isPlaying = false;
    });
  }

  static Future<void> _deleteLocalMedia(String path) async {
    final file = File(path);
    if (await file.exists()) {
      await file.delete();
    }
  }

  static String _formatTimestamp(int milliseconds) {
    final totalSeconds = milliseconds ~/ 1000;
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }
}
