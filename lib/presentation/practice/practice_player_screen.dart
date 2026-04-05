import 'dart:async';
import 'dart:io';
import 'dart:math' as math;

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_player/video_player.dart';

import '../../core/user_profile_notifier.dart';
import '../../domain/models/models.dart';
import '../../infrastructure/local_practice_repository.dart';
import '../../infrastructure/translation_service.dart';
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
  AudioPlayer? _audioPlayer;
  StreamSubscription<Duration>? _audioPositionSub;
  bool _audioPlayerReady = false;
  Map<String, String> _translatedCueTexts = const {};
  String? _translatedLanguageIdentifier;
  bool _isTranslating = false;
  bool _isBackgroundTranslating = false;
  String? _translationErrorMessage;
  int _translationGeneration = 0;

  bool get _hasPlayableMedia =>
      (widget.mediaItem.localVideoPath?.trim().isNotEmpty ?? false) ||
      (widget.mediaItem.videoUrl?.trim().isNotEmpty ?? false);
  bool get _isSavedLocalPractice =>
      (widget.mediaItem.localVideoPath?.trim().isNotEmpty ?? false) &&
      !(widget.mediaItem.videoUrl?.trim().isNotEmpty ?? false) &&
      !widget.mediaItem.deleteLocalMediaOnDispose;
  String? get _savedLocalPracticeId =>
      _isSavedLocalPractice ? widget.mediaItem.id : null;

  @override
  void initState() {
    super.initState();
    _seedPreloadedTranslations();
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
    _audioPositionSub?.cancel();
    final ap = _audioPlayer;
    if (ap != null) unawaited(ap.dispose());

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

  Future<void> _handleSubtitleToggle() async {
    if (_isTranslating) {
      return;
    }

    if (_subtitleState == SubtitleState.hidden) {
      setState(() {
        _subtitleState = SubtitleState.original;
        _translationErrorMessage = null;
      });
      return;
    }

    if (_subtitleState == SubtitleState.original) {
      await _showTranslatedSubtitle();
      return;
    }

    setState(() {
      _subtitleState = SubtitleState.hidden;
      _translationErrorMessage = null;
    });
  }

  void _openCompareSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => RecordCompareSheet(
        mediaItemId: widget.mediaItem.id,
        cue: widget.mediaItem.cues[_currentCueIndex],
        sourceLocaleIdentifier: _sourceLocaleIdentifier,
      ),
    );
  }

  void _seedPreloadedTranslations() {
    final targetLanguage = widget.mediaItem.translatedLanguage?.trim();
    if (targetLanguage == null || targetLanguage.isEmpty) {
      return;
    }

    final translated = <String, String>{};
    for (final cue in widget.mediaItem.cues) {
      final text = cue.translatedText.trim();
      if (text.isNotEmpty) {
        translated[cue.id] = text;
      }
    }

    if (translated.isEmpty) {
      return;
    }

    _translatedCueTexts = translated;
    _translatedLanguageIdentifier = targetLanguage;
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
            onPressed: _isTranslating
                ? null
                : () {
                    unawaited(_changeTranslationLanguage());
                  },
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
                    onPressed: () {
                      unawaited(_handleSubtitleToggle());
                    },
                    icon: _isTranslating
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Icon(
                            _subtitleState == SubtitleState.hidden
                                ? CupertinoIcons.eye
                                : _subtitleState == SubtitleState.original
                                ? CupertinoIcons.globe
                                : CupertinoIcons.eye_slash,
                          ),
                    label: Text(
                      _isTranslating
                          ? 'Translating...'
                          : _subtitleState == SubtitleState.hidden
                          ? 'Show Transcript'
                          : _subtitleState == SubtitleState.original
                          ? 'Translate'
                          : 'Hide Text',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
            if (_translationErrorMessage != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.red.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Text(
                    _translationErrorMessage!,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.red.shade700,
                    ),
                  ),
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

    if (widget.mediaItem.isAudioOnly) {
      return _buildSubtitleContent(
        cue,
        colorScheme,
        hasPlayableMedia: _audioPlayerReady,
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

    if (_subtitleState == SubtitleState.original) {
      return _buildOriginalSubtitlePanel(
        cue: cue,
        colorScheme: colorScheme,
        hasPlayableMedia: hasPlayableMedia,
      );
    }

    final translatedText =
        _translatedCueTexts[cue.id]?.trim() ?? cue.translatedText.trim();
    return _buildTranslatedSubtitlePanel(
      cue: cue,
      translatedText: translatedText.isEmpty
          ? 'Translation unavailable for this cue right now.'
          : translatedText,
      colorScheme: colorScheme,
      hasPlayableMedia: hasPlayableMedia,
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

  Widget _buildOriginalSubtitlePanel({
    required Cue cue,
    required ColorScheme colorScheme,
    required bool hasPlayableMedia,
  }) {
    final baseStyle = Theme.of(context).textTheme.displayLarge?.copyWith(
      fontSize: hasPlayableMedia ? 28 : 32,
      height: 1.3,
      color: hasPlayableMedia ? Colors.white : colorScheme.onSurface,
      fontWeight: FontWeight.w700,
    );

    final content = LayoutBuilder(
      builder: (context, constraints) {
        final panelHeight = _subtitlePanelHeight(
          constraints.maxHeight,
          hasPlayableMedia: hasPlayableMedia,
          showsTranslation: false,
        );
        return _buildSubtitlePanel(
          colorScheme: colorScheme,
          hasPlayableMedia: hasPlayableMedia,
          panelHeight: panelHeight,
          child: _AdaptiveSubtitleText(
            text: cue.originalText,
            textAlign: TextAlign.center,
            style: baseStyle,
            minFontSize: hasPlayableMedia ? 16 : 18,
            maxFontSize: hasPlayableMedia ? 30 : 34,
            maxHeight: math.max(56, panelHeight - 32),
          ),
        );
      },
    );

    if (!hasPlayableMedia) {
      return content;
    }

    return Align(alignment: Alignment.bottomCenter, child: content);
  }

  Widget _buildTranslatedSubtitlePanel({
    required Cue cue,
    required String translatedText,
    required ColorScheme colorScheme,
    required bool hasPlayableMedia,
  }) {
    final originalStyle = Theme.of(context).textTheme.displayLarge?.copyWith(
      fontSize: hasPlayableMedia ? 28 : 32,
      height: 1.28,
      color: hasPlayableMedia ? Colors.white : colorScheme.onSurface,
      fontWeight: FontWeight.w700,
    );
    final translatedStyle = Theme.of(context).textTheme.titleLarge?.copyWith(
      fontSize: hasPlayableMedia ? 24 : 28,
      height: 1.28,
      color: hasPlayableMedia ? Colors.white : colorScheme.primary,
      fontWeight: FontWeight.w700,
    );

    final content = LayoutBuilder(
      builder: (context, constraints) {
        final panelHeight = _subtitlePanelHeight(
          constraints.maxHeight,
          hasPlayableMedia: hasPlayableMedia,
          showsTranslation: true,
        );
        final gap = hasPlayableMedia ? 12.0 : 16.0;
        final contentHeight = math.max(120.0, panelHeight - 32);
        final availableHeight = math.max(88.0, contentHeight - gap);
        final innerWidth = math.max(120.0, constraints.maxWidth - 32);
        final layout = _calculateTranslatedSubtitleLayout(
          context: context,
          innerWidth: innerWidth,
          availableHeight: availableHeight,
          originalText: cue.originalText,
          translatedText: translatedText,
          originalStyle: originalStyle,
          translatedStyle: translatedStyle,
        );
        final originalHeight = layout.originalHeight;
        final translatedHeight = layout.translatedHeight;

        return _buildSubtitlePanel(
          colorScheme: colorScheme,
          hasPlayableMedia: hasPlayableMedia,
          panelHeight: panelHeight,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                height: originalHeight,
                child: _AdaptiveSubtitleText(
                  text: cue.originalText,
                  textAlign: TextAlign.center,
                  style: originalStyle,
                  minFontSize: hasPlayableMedia ? 14 : 18,
                  maxFontSize: hasPlayableMedia ? 28 : 34,
                  maxHeight: originalHeight,
                ),
              ),
              SizedBox(height: gap),
              SizedBox(
                height: translatedHeight,
                child: _AdaptiveSubtitleText(
                  text: translatedText,
                  textAlign: TextAlign.center,
                  style: translatedStyle,
                  minFontSize: hasPlayableMedia ? 13 : 16,
                  maxFontSize: hasPlayableMedia ? 24 : 28,
                  maxHeight: translatedHeight,
                ),
              ),
            ],
          ),
        );
      },
    );

    if (!hasPlayableMedia) {
      return content;
    }

    return Align(alignment: Alignment.bottomCenter, child: content);
  }

  Widget _buildSubtitlePanel({
    required ColorScheme colorScheme,
    required bool hasPlayableMedia,
    required double panelHeight,
    required Widget child,
  }) {
    return SizedBox(
      width: double.infinity,
      height: panelHeight,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: hasPlayableMedia
              ? Colors.black.withValues(alpha: 0.58)
              : colorScheme.surfaceContainerHighest.withValues(alpha: 0.42),
          borderRadius: BorderRadius.circular(18),
        ),
        child: child,
      ),
    );
  }

  double _subtitlePanelHeight(
    double maxHeight, {
    required bool hasPlayableMedia,
    required bool showsTranslation,
  }) {
    if (!hasPlayableMedia) {
      return showsTranslation
          ? math.min(maxHeight, 300)
          : math.min(maxHeight, 220);
    }

    final ratio = showsTranslation ? 0.82 : 0.42;
    return (maxHeight * ratio).clamp(156.0, showsTranslation ? 500.0 : 280.0);
  }

  ({double originalHeight, double translatedHeight})
  _calculateTranslatedSubtitleLayout({
    required BuildContext context,
    required double innerWidth,
    required double availableHeight,
    required String originalText,
    required String translatedText,
    required TextStyle? originalStyle,
    required TextStyle? translatedStyle,
  }) {
    final originalNeed = _estimateTextHeight(
      context: context,
      text: originalText,
      style: originalStyle,
      maxWidth: innerWidth,
    );
    final translatedNeed = _estimateTextHeight(
      context: context,
      text: translatedText,
      style: translatedStyle,
      maxWidth: innerWidth,
    );

    final totalNeed = math.max(1.0, originalNeed + translatedNeed);
    final minSectionHeight = math.min(availableHeight * 0.45, 52.0);

    var originalHeight = (availableHeight * (originalNeed / totalNeed)).clamp(
      minSectionHeight,
      availableHeight - minSectionHeight,
    );
    var translatedHeight = availableHeight - originalHeight;

    if (translatedHeight < minSectionHeight) {
      translatedHeight = minSectionHeight;
      originalHeight = availableHeight - translatedHeight;
    }

    return (originalHeight: originalHeight, translatedHeight: translatedHeight);
  }

  double _estimateTextHeight({
    required BuildContext context,
    required String text,
    required TextStyle? style,
    required double maxWidth,
  }) {
    final direction = Directionality.of(context);
    final scaler = MediaQuery.textScalerOf(context);
    final painter = TextPainter(
      text: TextSpan(text: text, style: style),
      textAlign: TextAlign.center,
      textDirection: direction,
      textScaler: scaler,
    )..layout(maxWidth: maxWidth);

    return painter.height;
  }

  Future<void> _showTranslatedSubtitle() async {
    final sourceLocaleIdentifier = _sourceLocaleIdentifier;
    final targetLocale = await _ensureTranslationLanguage(
      sourceLocaleIdentifier: sourceLocaleIdentifier,
    );
    if (!mounted || targetLocale == null) {
      return;
    }

    final cue = widget.mediaItem.cues[_currentCueIndex];
    final generation = _activateTranslationTarget(targetLocale);
    final cachedTranslation = _translatedCueTexts[cue.id]?.trim();

    if (cachedTranslation != null && cachedTranslation.isNotEmpty) {
      if (!mounted) {
        return;
      }
      setState(() {
        _subtitleState = SubtitleState.translated;
        _translationErrorMessage = null;
      });
      unawaited(
        _translateRemainingCuesInBackground(
          sourceLocaleIdentifier: sourceLocaleIdentifier,
          targetLocaleIdentifier: targetLocale,
          generation: generation,
          excludedCueId: cue.id,
        ),
      );
      return;
    }

    setState(() {
      _isTranslating = true;
      _translationErrorMessage = null;
    });

    try {
      final translated = await TranslationService.instance.translateCues(
        sourceLocaleIdentifier: sourceLocaleIdentifier,
        targetLocaleIdentifier: targetLocale,
        cues: [cue],
      );
      if (!_isCurrentTranslationGeneration(generation, targetLocale) ||
          !mounted) {
        return;
      }

      setState(() {
        _translatedCueTexts = {..._translatedCueTexts, ...translated};
        _subtitleState = SubtitleState.translated;
      });
      unawaited(
        _persistLocalTranslations(
          targetLocaleIdentifier: targetLocale,
          translations: translated,
        ),
      );
      unawaited(
        _translateRemainingCuesInBackground(
          sourceLocaleIdentifier: sourceLocaleIdentifier,
          targetLocaleIdentifier: targetLocale,
          generation: generation,
          excludedCueId: cue.id,
        ),
      );
    } on TranslationException catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _translationErrorMessage = error.message;
      });
    } finally {
      if (mounted) {
        setState(() {
          _isTranslating = false;
        });
      }
    }
  }

  Future<void> _translateRemainingCuesInBackground({
    required String sourceLocaleIdentifier,
    required String targetLocaleIdentifier,
    required int generation,
    required String excludedCueId,
  }) async {
    if (_isBackgroundTranslating ||
        !_isCurrentTranslationGeneration(generation, targetLocaleIdentifier)) {
      return;
    }

    final remainingCues = widget.mediaItem.cues.where((cue) {
      if (cue.id == excludedCueId) {
        return false;
      }
      final cached = _translatedCueTexts[cue.id]?.trim();
      return cached == null || cached.isEmpty;
    }).toList();

    if (remainingCues.isEmpty) {
      return;
    }

    _isBackgroundTranslating = true;

    try {
      final translated = await TranslationService.instance.translateCues(
        sourceLocaleIdentifier: sourceLocaleIdentifier,
        targetLocaleIdentifier: targetLocaleIdentifier,
        cues: remainingCues,
      );
      if (!_isCurrentTranslationGeneration(
            generation,
            targetLocaleIdentifier,
          ) ||
          !mounted) {
        return;
      }

      setState(() {
        _translatedCueTexts = {..._translatedCueTexts, ...translated};
      });
      unawaited(
        _persistLocalTranslations(
          targetLocaleIdentifier: targetLocaleIdentifier,
          translations: translated,
        ),
      );
    } on TranslationException {
      // Keep the current cue responsive even if the background batch fails.
    } finally {
      if (_isCurrentTranslationGeneration(generation, targetLocaleIdentifier)) {
        _isBackgroundTranslating = false;
      }
    }
  }

  Future<String?> _ensureTranslationLanguage({
    required String sourceLocaleIdentifier,
  }) async {
    List<TranslationLocaleOption> locales;
    try {
      locales = await TranslationService.instance.fetchSupportedLocales(
        sourceLocaleIdentifier: sourceLocaleIdentifier,
      );
    } on TranslationException catch (error) {
      if (mounted) {
        setState(() {
          _translationErrorMessage = error.message;
        });
      }
      return null;
    }

    if (locales.isEmpty) {
      if (mounted) {
        setState(() {
          _translationErrorMessage =
              'Bantera could not find any translation languages for this transcript.';
        });
      }
      return null;
    }

    final savedIdentifier = UserProfileNotifier.instance.translationLanguage;
    final savedLocale = _findTranslationLocale(locales, savedIdentifier);
    if (savedLocale != null) {
      return savedLocale.identifier;
    }

    final selectedLocale = await _showTranslationLanguageSheet(
      locales: locales,
      selected: _bestMatchingTranslationLocale(locales) ?? locales.first,
      title: 'Choose Translation Language',
      description:
          'Bantera will translate listening practice into this language and save it to your profile for future sessions.',
    );
    if (!mounted || selectedLocale == null) {
      return null;
    }

    final confirmed = await _confirmTranslationLanguageSelection(
      selectedLocale,
    );
    if (!mounted || !confirmed) {
      return null;
    }

    final saved = await UserProfileNotifier.instance.updateTranslationLanguage(
      selectedLocale.identifier,
    );
    if (!mounted) {
      return null;
    }
    if (!saved) {
      setState(() {
        _translationErrorMessage =
            UserProfileNotifier.instance.errorMessage ??
            'Bantera could not save your translation language.';
      });
      return null;
    }

    return selectedLocale.identifier;
  }

  Future<void> _changeTranslationLanguage() async {
    final sourceLocaleIdentifier = _sourceLocaleIdentifier;

    List<TranslationLocaleOption> locales;
    try {
      locales = await TranslationService.instance.fetchSupportedLocales(
        sourceLocaleIdentifier: sourceLocaleIdentifier,
      );
    } on TranslationException catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _translationErrorMessage = error.message;
      });
      return;
    }

    if (!mounted || locales.isEmpty) {
      return;
    }

    final current = _findTranslationLocale(
      locales,
      UserProfileNotifier.instance.translationLanguage,
    );

    final selectedLocale = await _showTranslationLanguageSheet(
      locales: locales,
      selected: current ?? _bestMatchingTranslationLocale(locales),
      title: 'Change Translation Language',
      description:
          'Choose the language Bantera should translate into. The new choice will be saved to your profile.',
    );
    if (!mounted || selectedLocale == null) {
      return;
    }

    final currentIdentifier = current?.identifier.toLowerCase();
    if (currentIdentifier == selectedLocale.identifier.toLowerCase()) {
      return;
    }

    final confirmed = await _confirmTranslationLanguageSelection(
      selectedLocale,
    );
    if (!mounted || !confirmed) {
      return;
    }

    final saved = await UserProfileNotifier.instance.updateTranslationLanguage(
      selectedLocale.identifier,
    );
    if (!mounted) {
      return;
    }
    if (!saved) {
      setState(() {
        _translationErrorMessage =
            UserProfileNotifier.instance.errorMessage ??
            'Bantera could not save your translation language.';
      });
      return;
    }

    unawaited(
      _resetStoredLocalTranslations(
        targetLocaleIdentifier: selectedLocale.identifier,
      ),
    );
    setState(() {
      _translatedCueTexts = const {};
      _translatedLanguageIdentifier = null;
      _translationErrorMessage = null;
      _isBackgroundTranslating = false;
      _translationGeneration += 1;
      if (_subtitleState == SubtitleState.translated) {
        _subtitleState = SubtitleState.original;
      }
    });
  }

  int _activateTranslationTarget(String targetLocaleIdentifier) {
    final normalizedTarget = targetLocaleIdentifier.trim().toLowerCase();
    final currentTarget = _translatedLanguageIdentifier?.trim().toLowerCase();
    if (currentTarget == normalizedTarget) {
      return _translationGeneration;
    }

    setState(() {
      _translatedCueTexts = const {};
      _translatedLanguageIdentifier = targetLocaleIdentifier;
      _isBackgroundTranslating = false;
      _translationGeneration += 1;
    });
    return _translationGeneration;
  }

  bool _isCurrentTranslationGeneration(
    int generation,
    String targetLocaleIdentifier,
  ) {
    final activeTarget = _translatedLanguageIdentifier?.trim().toLowerCase();
    return mounted &&
        generation == _translationGeneration &&
        activeTarget == targetLocaleIdentifier.trim().toLowerCase();
  }

  Future<void> _persistLocalTranslations({
    required String targetLocaleIdentifier,
    required Map<String, String> translations,
  }) async {
    final localPracticeId = _savedLocalPracticeId;
    if (localPracticeId == null || translations.isEmpty) {
      return;
    }

    try {
      await LocalPracticeRepository.instance.storeTranslations(
        id: localPracticeId,
        translatedLanguage: targetLocaleIdentifier,
        translations: translations,
      );
    } catch (_) {
      // Local persistence should not block practice playback.
    }
  }

  Future<void> _resetStoredLocalTranslations({
    required String targetLocaleIdentifier,
  }) async {
    final localPracticeId = _savedLocalPracticeId;
    if (localPracticeId == null) {
      return;
    }

    try {
      await LocalPracticeRepository.instance.resetTranslations(
        id: localPracticeId,
        translatedLanguage: targetLocaleIdentifier,
      );
    } catch (_) {
      // Keep the in-memory translation flow responsive if disk writes fail.
    }
  }

  Future<TranslationLocaleOption?> _showTranslationLanguageSheet({
    required List<TranslationLocaleOption> locales,
    required TranslationLocaleOption? selected,
    required String title,
    required String description,
  }) {
    return showModalBottomSheet<TranslationLocaleOption>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) {
        return _TranslationLanguageSheet(
          locales: locales,
          selected: selected,
          title: title,
          description: description,
        );
      },
    );
  }

  Future<bool> _confirmTranslationLanguageSelection(
    TranslationLocaleOption locale,
  ) async {
    final confirmed =
        await showDialog<bool>(
          context: context,
          builder: (context) {
            final theme = Theme.of(context);
            return AlertDialog(
              title: const Text('Confirm Translation Language'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        _flagPrefixForIdentifier(locale.identifier),
                        style: theme.textTheme.headlineSmall,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          locale.displayName,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(locale.identifier, style: theme.textTheme.bodySmall),
                  const SizedBox(height: 14),
                  Text(
                    'Bantera will save this language to your profile and use it as the default translation language in future listening practice.',
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text('Confirm'),
                ),
              ],
            );
          },
        ) ??
        false;

    return confirmed;
  }

  TranslationLocaleOption? _findTranslationLocale(
    List<TranslationLocaleOption> locales,
    String? identifier,
  ) {
    final normalized = identifier?.trim().toLowerCase();
    if (normalized == null || normalized.isEmpty) {
      return null;
    }

    for (final locale in locales) {
      if (locale.identifier.toLowerCase() == normalized) {
        return locale;
      }
    }

    final normalizedLanguage = normalized.split('-').first;
    for (final locale in locales) {
      final localeLanguage = locale.identifier.toLowerCase().split('-').first;
      if (localeLanguage == normalizedLanguage) {
        return locale;
      }
    }

    return null;
  }

  TranslationLocaleOption? _bestMatchingTranslationLocale(
    List<TranslationLocaleOption> locales,
  ) {
    if (locales.isEmpty) {
      return null;
    }

    final systemTag = WidgetsBinding.instance.platformDispatcher.locale
        .toLanguageTag()
        .toLowerCase();
    final exact = locales.where(
      (locale) => locale.identifier.toLowerCase() == systemTag,
    );
    if (exact.isNotEmpty) {
      return exact.first;
    }

    final systemLanguage = systemTag.split('-').first;
    for (final locale in locales) {
      final localeLanguage = locale.identifier.toLowerCase().split('-').first;
      if (localeLanguage == systemLanguage) {
        return locale;
      }
    }

    return locales.firstWhere(
      (locale) => locale.identifier.toLowerCase().startsWith('en'),
      orElse: () => locales.first,
    );
  }

  String get _sourceLocaleIdentifier {
    final accent = widget.mediaItem.accent.trim();
    if (accent.isNotEmpty) {
      return accent;
    }

    final spokenLanguage = widget.mediaItem.spokenLanguage.trim();
    return spokenLanguage.isEmpty ? 'en' : spokenLanguage;
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

    if (widget.mediaItem.isAudioOnly) {
      final remoteUrl = widget.mediaItem.videoUrl?.trim();
      if (remoteUrl == null || remoteUrl.isEmpty) {
        if (mounted) setState(() => _isInitializingMedia = false);
        return;
      }
      try {
        // Download via dart:io HttpClient to bypass iOS ATS (HTTP blocked
        // for native AVPlayer). Save to temp file, then play locally.
        final uri = Uri.parse(remoteUrl);
        final httpRequest = await HttpClient().getUrl(uri);
        widget.mediaItem.mediaHeaders.forEach(
          (key, value) => httpRequest.headers.set(key, value),
        );
        final httpResponse = await httpRequest.close();
        if (httpResponse.statusCode < 200 || httpResponse.statusCode >= 300) {
          throw Exception('Server returned ${httpResponse.statusCode}');
        }
        final tempDir = await getTemporaryDirectory();
        final tempFile = File(
          '${tempDir.path}/bantera_audio_${widget.mediaItem.id}.wav',
        );
        final sink = tempFile.openWrite();
        await httpResponse.pipe(sink);

        final player = AudioPlayer();
        _audioPlayer = player;
        _audioPositionSub = player.onPositionChanged.listen((pos) {
          if (!mounted) return;
          final cue = widget.mediaItem.cues[_currentCueIndex];
          final cueEnd = Duration(milliseconds: cue.endTimeMs);
          if (_isPlaying && pos >= cueEnd) {
            unawaited(player.pause());
            if (mounted) setState(() => _isPlaying = false);
          }
        });
        await player.setSourceDeviceFile(tempFile.path);
        await player.seek(
          Duration(milliseconds: widget.mediaItem.cues[0].startTimeMs),
        );
        if (mounted) setState(() => _audioPlayerReady = true);
      } catch (e) {
        _mediaError = 'Audio error: $e';
      } finally {
        if (mounted) setState(() => _isInitializingMedia = false);
      }
      return;
    }

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
    final audioPlayer = _audioPlayer;
    if (audioPlayer != null && _audioPlayerReady) {
      if (_isPlaying) {
        await audioPlayer.pause();
        if (mounted) setState(() => _isPlaying = false);
      } else {
        final cue = widget.mediaItem.cues[_currentCueIndex];
        await audioPlayer.seek(Duration(milliseconds: cue.startTimeMs));
        await audioPlayer.resume();
        if (mounted) setState(() => _isPlaying = true);
      }
      return;
    }

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

    final audioPlayer = _audioPlayer;
    if (audioPlayer != null && _audioPlayerReady) {
      await audioPlayer.pause();
      await audioPlayer.seek(
        Duration(milliseconds: widget.mediaItem.cues[nextIndex].startTimeMs),
      );
    } else {
      final controller = _videoController;
      if (controller != null && controller.value.isInitialized) {
        await controller.pause();
        await controller.seekTo(
          Duration(milliseconds: widget.mediaItem.cues[nextIndex].startTimeMs),
        );
      }
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

class _TranslationLanguageSheet extends StatefulWidget {
  const _TranslationLanguageSheet({
    required this.locales,
    required this.selected,
    required this.title,
    required this.description,
  });

  final List<TranslationLocaleOption> locales;
  final TranslationLocaleOption? selected;
  final String title;
  final String description;

  @override
  State<_TranslationLanguageSheet> createState() =>
      _TranslationLanguageSheetState();
}

class _TranslationLanguageSheetState extends State<_TranslationLanguageSheet> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final results = widget.locales.where((locale) {
      final haystack = '${locale.displayName} ${locale.identifier}'
          .toLowerCase();
      return haystack.contains(_query.toLowerCase());
    }).toList();

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 8,
          bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        ),
        child: SizedBox(
          height: 560,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(widget.title, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              Text(
                widget.description,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _searchController,
                onChanged: (value) {
                  setState(() {
                    _query = value;
                  });
                },
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.search),
                  hintText: 'Search languages',
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: ListView.separated(
                  itemCount: results.length,
                  separatorBuilder: (_, index) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final locale = results[index];
                    final selected =
                        locale.identifier == widget.selected?.identifier;
                    return ListTile(
                      leading: selected
                          ? const Icon(Icons.check, size: 18)
                          : const SizedBox(width: 18),
                      title: Text(_translationLanguageLabel(locale)),
                      subtitle: Text(locale.identifier),
                      trailing: locale.isInstalled
                          ? Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.green.withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Text(
                                'Installed',
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(color: Colors.green.shade700),
                              ),
                            )
                          : null,
                      onTap: () => Navigator.of(context).pop(locale),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

String _translationLanguageLabel(TranslationLocaleOption locale) {
  return '${_flagPrefixForIdentifier(locale.identifier)} ${locale.displayName} (${locale.identifier})';
}

String _flagPrefixForIdentifier(String identifier) {
  final region = _regionCodeFromIdentifier(identifier);
  if (region == null) {
    return '🌐';
  }
  if (_isNumericRegion(region)) {
    return '🌎';
  }
  if (region.length != 2 || !_isAlphaRegion(region)) {
    return '🏳️';
  }

  final upper = region.toUpperCase();
  return String.fromCharCodes(
    upper.codeUnits.map((unit) => 0x1F1E6 + unit - 0x41),
  );
}

String? _regionCodeFromIdentifier(String identifier) {
  final components = identifier
      .replaceAll('_', '-')
      .split('-')
      .where((component) => component.isNotEmpty)
      .toList();

  if (components.isEmpty) {
    return null;
  }

  var candidateIndex = 1;
  if (components.length > 2 && _isScriptSubtag(components[1])) {
    candidateIndex = 2;
  }

  if (candidateIndex < components.length &&
      _isRegionSubtag(components[candidateIndex])) {
    return components[candidateIndex].toUpperCase();
  }

  for (final component in components.skip(1)) {
    if (_isRegionSubtag(component)) {
      return component.toUpperCase();
    }
  }

  return _defaultRegionForLanguageCode(components.first.toLowerCase());
}

bool _isRegionSubtag(String value) {
  return (value.length == 2 && _isAlphaRegion(value)) ||
      (value.length == 3 && _isNumericRegion(value));
}

bool _isScriptSubtag(String value) {
  return value.length == 4 && _isAlphaRegion(value);
}

bool _isAlphaRegion(String value) {
  final codeUnits = value.codeUnits;
  return codeUnits.every(
    (unit) => (unit >= 0x41 && unit <= 0x5A) || (unit >= 0x61 && unit <= 0x7A),
  );
}

bool _isNumericRegion(String value) {
  final codeUnits = value.codeUnits;
  return codeUnits.every((unit) => unit >= 0x30 && unit <= 0x39);
}

String? _defaultRegionForLanguageCode(String languageCode) {
  const defaults = <String, String>{
    'ar': 'SA',
    'ca': 'ES',
    'cs': 'CZ',
    'da': 'DK',
    'de': 'DE',
    'el': 'GR',
    'en': 'US',
    'es': 'ES',
    'fi': 'FI',
    'fr': 'FR',
    'he': 'IL',
    'hi': 'IN',
    'hr': 'HR',
    'hu': 'HU',
    'id': 'ID',
    'it': 'IT',
    'ja': 'JP',
    'ko': 'KR',
    'ms': 'MY',
    'nl': 'NL',
    'no': 'NO',
    'pl': 'PL',
    'pt': 'BR',
    'ro': 'RO',
    'ru': 'RU',
    'sk': 'SK',
    'sv': 'SE',
    'th': 'TH',
    'tr': 'TR',
    'uk': 'UA',
    'vi': 'VN',
    'yue': 'HK',
    'zh': 'CN',
  };

  return defaults[languageCode];
}

class _AdaptiveSubtitleText extends StatelessWidget {
  const _AdaptiveSubtitleText({
    required this.text,
    required this.textAlign,
    required this.style,
    required this.minFontSize,
    required this.maxFontSize,
    required this.maxHeight,
  });

  static const double _scrollBottomPadding = 14;

  final String text;
  final TextAlign textAlign;
  final TextStyle? style;
  final double minFontSize;
  final double maxFontSize;
  final double maxHeight;

  @override
  Widget build(BuildContext context) {
    if (text.trim().isEmpty) {
      return const SizedBox.shrink();
    }

    final baseStyle = style ?? Theme.of(context).textTheme.bodyLarge;
    return LayoutBuilder(
      builder: (context, constraints) {
        final resolvedHeight = _resolvedHeight(constraints.maxHeight);
        final fontSize = _bestFontSize(
          context,
          baseStyle,
          constraints.maxWidth,
          resolvedHeight,
        );

        return SizedBox(
          height: resolvedHeight,
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: resolvedHeight),
              child: Padding(
                padding: const EdgeInsets.only(
                  top: 2,
                  bottom: _scrollBottomPadding,
                ),
                child: Align(
                  alignment: Alignment.topCenter,
                  child: Text(
                    text,
                    textAlign: textAlign,
                    style: baseStyle?.copyWith(fontSize: fontSize),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  double _bestFontSize(
    BuildContext context,
    TextStyle? baseStyle,
    double maxWidth,
    double availableHeight,
  ) {
    final resolvedWidth = maxWidth.isFinite && maxWidth > 0 ? maxWidth : 320.0;
    final resolvedHeight = math.max(
      32,
      availableHeight - _scrollBottomPadding - 6,
    );
    final direction = Directionality.of(context);
    final scaler = MediaQuery.textScalerOf(context);

    var low = minFontSize;
    var high = math.max(minFontSize, maxFontSize);
    var best = minFontSize;

    for (var i = 0; i < 8; i++) {
      final mid = (low + high) / 2;
      final painter = TextPainter(
        text: TextSpan(
          text: text,
          style: baseStyle?.copyWith(fontSize: mid),
        ),
        textAlign: textAlign,
        textDirection: direction,
        textScaler: scaler,
      )..layout(maxWidth: resolvedWidth);

      if (painter.height <= resolvedHeight) {
        best = mid;
        low = mid;
      } else {
        high = mid;
      }
    }

    return best;
  }

  double _resolvedHeight(double fallbackHeight) {
    final resolved = maxHeight.isFinite && maxHeight > 0
        ? maxHeight
        : fallbackHeight;
    return resolved.isFinite && resolved > 0 ? resolved : 80;
  }
}
