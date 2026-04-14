import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;

import 'package:audioplayers/audioplayers.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';
import 'package:video_player/video_player.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../../core/apple_system_version.dart';
import '../../core/user_profile_notifier.dart';
import '../../domain/models/models.dart';
import '../../infrastructure/local_practice_repository.dart';
import '../../infrastructure/practice_audio_cache.dart';
import '../../infrastructure/saved_cue_repository.dart';
import '../../infrastructure/play_all_pause_store.dart';
import '../../infrastructure/practice_playback_speed_store.dart';
import '../../infrastructure/practice_progress_store.dart';
import '../../infrastructure/translation_service.dart';
import '../../infrastructure/video_processing_service.dart';
import '../../l10n/app_localizations.dart';
import 'cue_recording_pipeline.dart';
import 'record_compare_sheet.dart';
import 'session_compare_result_sheet.dart';

enum SubtitleState { hidden, original, translated }

class PracticePlayerScreen extends StatefulWidget {
  const PracticePlayerScreen({
    super.key,
    required this.mediaItem,
    this.initialCueIndex,
  });

  final MediaItem mediaItem;
  final int? initialCueIndex;

  @override
  State<PracticePlayerScreen> createState() => _PracticePlayerScreenState();
}

class _PracticePlayerScreenState extends State<PracticePlayerScreen> {
  AppLocalizations get _l10n => AppLocalizations.of(context)!;

  int _currentCueIndex = 0;
  SubtitleState _subtitleState = SubtitleState.hidden;
  bool _isPlaying = false;
  bool _isPlayingAll = false;
  bool _playAllInBetweenCueGap = false;
  int _playAllSessionId = 0;
  int _playAllCompletedPlaysForCurrentCue = 0;
  bool _isInitializingMedia = false;
  double? _mediaLoadProgress;
  String? _mediaError;
  VideoPlayerController? _videoController;
  VoidCallback? _videoListener;
  AudioPlayer? _audioPlayer;
  StreamSubscription<Duration>? _audioPositionSub;
  bool _audioPlayerReady = false;
  bool _isTimelineCueSelectionInFlight = false;
  int? _queuedTimelineCueIndex;
  int? _loadedMediaDurationMs;

  /// Last tick from [AudioPlayer.onPositionChanged] — [getCurrentPosition] can be
  /// wrong right after pause; single-cue resume prefers this when in-range for the cue.
  int? _lastKnownAudioPositionMs;
  int? _lastKnownVideoPositionMs;
  Map<String, String> _translatedCueTexts = const {};
  String? _translatedLanguageIdentifier;
  bool _isTranslating = false;
  bool _isBackgroundTranslating = false;
  String? _translationErrorMessage;
  int _translationGeneration = 0;
  double _playbackSpeed = 1.0;

  final AudioRecorder _cueRecorder = AudioRecorder();
  Timer? _practiceRecordingTimer;
  Timer? _practiceAutoStopTimer;
  static const _maxCueRecordingDuration = Duration(seconds: 30);
  Duration _practiceRecordingElapsed = Duration.zero;
  bool _isCueRecording = false;
  bool _isCueTranscribing = false;
  String? _cueRecordingTempPath;

  bool get _hasPlayableMedia =>
      (widget.mediaItem.localVideoPath?.trim().isNotEmpty ?? false) ||
      (widget.mediaItem.videoUrl?.trim().isNotEmpty ?? false);
  bool get _isSavedLocalPractice =>
      (widget.mediaItem.localVideoPath?.trim().isNotEmpty ?? false) &&
      !(widget.mediaItem.videoUrl?.trim().isNotEmpty ?? false) &&
      !widget.mediaItem.deleteLocalMediaOnDispose;
  String? get _savedLocalPracticeId =>
      _isSavedLocalPractice ? widget.mediaItem.id : null;

  // Uploaded server videos (have videoUrl but no local path) get a file-based
  // translation cache so translations survive between sessions.
  String? get _uploadedVideoId {
    final hasVideoUrl = widget.mediaItem.videoUrl?.trim().isNotEmpty ?? false;
    final hasLocalPath =
        widget.mediaItem.localVideoPath?.trim().isNotEmpty ?? false;
    if (hasVideoUrl &&
        !hasLocalPath &&
        !widget.mediaItem.deleteLocalMediaOnDispose) {
      return widget.mediaItem.id;
    }
    return null;
  }

  @override
  void initState() {
    super.initState();
    _seedPreloadedTranslations();
    unawaited(_startupPracticeSession());
    unawaited(SavedCueRepository.instance.load());
  }

  Future<void> _startupPracticeSession() async {
    final savedSpeed = await PracticePlaybackSpeedStore.instance.getSpeed();
    if (!mounted) {
      return;
    }
    setState(() => _playbackSpeed = savedSpeed);
    await _restoreProgress();
    if (!mounted) {
      return;
    }
    await _initializeMedia();
    if (!mounted) {
      return;
    }
    await _applyPlaybackSpeedToMedia();
    unawaited(_loadUploadedVideoTranslations());
  }

  Future<void> _applyPlaybackSpeedToMedia() async {
    final controller = _videoController;
    if (controller != null && controller.value.isInitialized) {
      await controller.setPlaybackSpeed(_playbackSpeed);
    }
    final ap = _audioPlayer;
    if (ap != null) {
      await ap.setPlaybackRate(_playbackSpeed);
    }
  }

  Future<void> _restoreProgress() async {
    final initial = widget.initialCueIndex;
    if (initial != null &&
        initial >= 0 &&
        initial < widget.mediaItem.cues.length) {
      if (mounted) setState(() => _currentCueIndex = initial);
      return;
    }
    final saved = await PracticeProgressStore.instance.getCueIndex(
      widget.mediaItem.id,
    );
    if (saved > 0 && saved < widget.mediaItem.cues.length && mounted) {
      setState(() => _currentCueIndex = saved);
    }
  }

  @override
  void dispose() {
    unawaited(WakelockPlus.disable());
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

    _practiceRecordingTimer?.cancel();
    _practiceAutoStopTimer?.cancel();
    if (_isCueRecording) {
      unawaited(_cueRecorder.stop());
    }
    unawaited(_cueRecorder.dispose());
    final tempRec = _cueRecordingTempPath;
    if (tempRec != null) {
      unawaited(_deleteCueTempRecordingFile(tempRec));
    }

    super.dispose();
  }

  void _nextCue() {
    final cues = widget.mediaItem.cues;
    if (cues.isEmpty) return;
    if (_currentCueIndex < cues.length - 1) {
      unawaited(_selectCue(_currentCueIndex + 1));
    } else {
      unawaited(_confirmGoToFirstCueFromLast());
    }
  }

  Future<void> _confirmGoToFirstCueFromLast() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        final l10n = AppLocalizations.of(ctx)!;
        return AlertDialog(
          title: Text(l10n.practiceNextFromLastTitle),
          content: Text(l10n.practiceNextFromLastBody),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: Text(l10n.cancel),
            ),
            FilledButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: Text(l10n.practiceGoToFirstCue),
            ),
          ],
        );
      },
    );
    if (confirmed == true && mounted) {
      await _selectCue(0);
    }
  }

  void _prevCue() {
    if (_currentCueIndex > 0) {
      unawaited(_selectCue(_currentCueIndex - 1));
    }
  }

  void _togglePlay() {
    if (_isPlayingAll) {
      unawaited(_stopPlayAll());
    } else {
      unawaited(_togglePlayback());
    }
  }

  Future<void> _setPlaybackSpeed(double speed) async {
    final snapped = nearestPracticePlaybackSpeed(speed);
    setState(() => _playbackSpeed = snapped);
    await PracticePlaybackSpeedStore.instance.setSpeed(snapped);
    await _applyPlaybackSpeedToMedia();
  }

  /// Where single-cue playback should stop: next cue's start when present
  /// (so audio through the gap is not cut off by an early [Cue.endTimeMs]),
  /// otherwise this cue's end. If data overlaps, never stop earlier than [Cue.endTimeMs].
  int _playbackStopMsForCueIndex(int cueIndex) {
    final cues = widget.mediaItem.cues;
    if (cueIndex < 0 || cueIndex >= cues.length) return 0;
    final cue = cues[cueIndex];
    if (cueIndex + 1 < cues.length) {
      final nextStart = cues[cueIndex + 1].startTimeMs;
      return nextStart > cue.endTimeMs ? nextStart : cue.endTimeMs;
    }
    final mediaDurationMs = _loadedMediaDurationMs;
    if (mediaDurationMs != null && mediaDurationMs > cue.endTimeMs) {
      return mediaDurationMs;
    }
    return cue.endTimeMs;
  }

  /// Resume from the paused time if it is still inside the current cue;
  /// otherwise seek to the cue start (e.g. position past cue end).
  int _seekMsResumeWithinCurrentCue({
    required int cueStartMs,
    required int cuePlaybackStopMs,
    required int? mediaPositionMs,
  }) {
    if (mediaPositionMs == null) return cueStartMs;
    if (mediaPositionMs >= cueStartMs && mediaPositionMs < cuePlaybackStopMs) {
      return mediaPositionMs;
    }
    return cueStartMs;
  }

  int _cueIndexForTimelineDx(double localDx, double width) {
    final cueCount = widget.mediaItem.cues.length;
    if (cueCount <= 1 || width <= 0) {
      return 0;
    }

    final normalizedDx = localDx.clamp(0.0, width);
    final progress = (normalizedDx / width).clamp(0.0, 1.0);
    final index = (progress * cueCount).floor();
    return index.clamp(0, cueCount - 1);
  }

  void _handleTimelineDrag(double localDx, double width) {
    if (_isPlayingAll) {
      return;
    }

    final nextIndex = _cueIndexForTimelineDx(localDx, width);
    if (nextIndex == _currentCueIndex) {
      return;
    }
    unawaited(_selectCueFromTimeline(nextIndex));
  }

  Future<void> _selectCueFromTimeline(int nextIndex) async {
    if (nextIndex < 0 || nextIndex >= widget.mediaItem.cues.length) {
      return;
    }
    if (_isTimelineCueSelectionInFlight) {
      _queuedTimelineCueIndex = nextIndex;
      return;
    }

    _isTimelineCueSelectionInFlight = true;
    try {
      await _selectCue(nextIndex);
    } finally {
      _isTimelineCueSelectionInFlight = false;
      final queuedIndex = _queuedTimelineCueIndex;
      _queuedTimelineCueIndex = null;
      if (queuedIndex != null && queuedIndex != _currentCueIndex) {
        unawaited(_selectCueFromTimeline(queuedIndex));
      }
    }
  }

  Future<void> _promptPlayAll() async {
    if (_isPlayingAll) {
      return;
    }
    final l10n = _l10n;
    final initial = await PlayAllPauseStore.instance.getSettings();
    if (!mounted) {
      return;
    }
    var selectedPause = initial.pauseBetweenCues;
    var selectedPlays = initial.playsPerCue.clamp(1, 3);
    final result = await showDialog<PlayAllSettings>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setLocal) {
          return AlertDialog(
            title: Text(l10n.practicePlayAllTitle),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.practicePlayAllDescription,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 12),
                  RadioListTile<PlayAllPauseBetweenCues>(
                    title: Text(l10n.practicePlayAllPauseZeroSeconds),
                    dense: true,
                    value: PlayAllPauseBetweenCues.none,
                    groupValue: selectedPause,
                    onChanged: (v) {
                      if (v != null) {
                        setLocal(() => selectedPause = v);
                      }
                    },
                  ),
                  RadioListTile<PlayAllPauseBetweenCues>(
                    title: Text(l10n.practicePlayAllPauseOneSecondLabel),
                    dense: true,
                    value: PlayAllPauseBetweenCues.oneSecond,
                    groupValue: selectedPause,
                    onChanged: (v) {
                      if (v != null) {
                        setLocal(() => selectedPause = v);
                      }
                    },
                  ),
                  RadioListTile<PlayAllPauseBetweenCues>(
                    title: Text(l10n.practicePlayAllPauseOneCuePlusOneSecond),
                    dense: true,
                    value: PlayAllPauseBetweenCues.oneCuePlusOneSecond,
                    groupValue: selectedPause,
                    onChanged: (v) {
                      if (v != null) {
                        setLocal(() => selectedPause = v);
                      }
                    },
                  ),
                  RadioListTile<PlayAllPauseBetweenCues>(
                    title: Text(l10n.practicePlayAllPauseOneCuePlusTwoSeconds),
                    dense: true,
                    value: PlayAllPauseBetweenCues.oneCuePlusTwoSeconds,
                    groupValue: selectedPause,
                    onChanged: (v) {
                      if (v != null) {
                        setLocal(() => selectedPause = v);
                      }
                    },
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.practicePlayAllTimesPerCueTitle,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: 8),
                  Center(
                    child: SegmentedButton<int>(
                      segments: [
                        ButtonSegment<int>(
                          value: 1,
                          label: Text(l10n.practicePlayAllTimesOnce),
                        ),
                        ButtonSegment<int>(
                          value: 2,
                          label: Text(l10n.practicePlayAllTimesTwice),
                        ),
                        ButtonSegment<int>(
                          value: 3,
                          label: Text(l10n.practicePlayAllTimesThrice),
                        ),
                      ],
                      selected: {selectedPlays},
                      onSelectionChanged: (Set<int> selection) {
                        setLocal(() {
                          selectedPlays = selection.single;
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: Text(l10n.cancel),
              ),
              FilledButton(
                onPressed: () => Navigator.of(ctx).pop(
                  PlayAllSettings(
                    pauseBetweenCues: selectedPause,
                    playsPerCue: selectedPlays,
                  ),
                ),
                child: Text(l10n.startLabel),
              ),
            ],
          );
        },
      ),
    );
    if (result == null || !mounted) {
      return;
    }
    await PlayAllPauseStore.instance.saveSettings(result);
    await _startPlayAll(result);
  }

  /// Wall-clock pause so shadowing time matches how long cues take to play at [playbackSpeed].
  int _playAllGapDelayMs({
    required PlayAllPauseBetweenCues mode,
    required Cue endedCue,
    required double playbackSpeed,
  }) {
    final s = playbackSpeed <= 0 ? 1.0 : playbackSpeed;
    final scale = 1.0 / s;
    int scaledWallMs(int baseMs) => (baseMs * scale).round();

    final cueLen = (endedCue.endTimeMs - endedCue.startTimeMs).clamp(
      0,
      1 << 30,
    );
    return switch (mode) {
      PlayAllPauseBetweenCues.none => 0,
      PlayAllPauseBetweenCues.oneSecond => scaledWallMs(1000),
      PlayAllPauseBetweenCues.oneCuePlusOneSecond => scaledWallMs(
        cueLen + 1000,
      ),
      PlayAllPauseBetweenCues.oneCuePlusTwoSeconds => scaledWallMs(
        cueLen + 2000,
      ),
    };
  }

  Future<void> _playAllGapThenNextCueAudio({
    required AudioPlayer audioPlayer,
    required PlayAllPauseBetweenCues pauseMode,
    required int endedCueIndex,
    required int sessionSnapshot,
  }) async {
    try {
      await audioPlayer.pause();
      if (!mounted || !_isPlayingAll || sessionSnapshot != _playAllSessionId) {
        return;
      }
      final cues = widget.mediaItem.cues;
      final delayMs = _playAllGapDelayMs(
        mode: pauseMode,
        endedCue: cues[endedCueIndex],
        playbackSpeed: _playbackSpeed,
      );
      await Future.delayed(Duration(milliseconds: delayMs));
      if (!mounted || !_isPlayingAll || sessionSnapshot != _playAllSessionId) {
        return;
      }
      final next = endedCueIndex + 1;
      await audioPlayer.seek(Duration(milliseconds: cues[next].startTimeMs));
      if (!mounted || !_isPlayingAll || sessionSnapshot != _playAllSessionId) {
        return;
      }
      _lastKnownAudioPositionMs = cues[next].startTimeMs;
      setState(() {
        _currentCueIndex = next;
        _playAllInBetweenCueGap = false;
      });
      unawaited(
        PracticeProgressStore.instance.setCueIndex(widget.mediaItem.id, next),
      );
      await audioPlayer.resume();
    } finally {
      if (mounted && _playAllInBetweenCueGap) {
        setState(() => _playAllInBetweenCueGap = false);
      }
    }
  }

  Future<void> _playAllGapThenNextCueVideo({
    required VideoPlayerController controller,
    required PlayAllPauseBetweenCues pauseMode,
    required int endedCueIndex,
    required int sessionSnapshot,
  }) async {
    try {
      await controller.pause();
      if (!mounted || !_isPlayingAll || sessionSnapshot != _playAllSessionId) {
        return;
      }
      final cues = widget.mediaItem.cues;
      final delayMs = _playAllGapDelayMs(
        mode: pauseMode,
        endedCue: cues[endedCueIndex],
        playbackSpeed: _playbackSpeed,
      );
      await Future.delayed(Duration(milliseconds: delayMs));
      if (!mounted || !_isPlayingAll || sessionSnapshot != _playAllSessionId) {
        return;
      }
      final next = endedCueIndex + 1;
      await controller.seekTo(Duration(milliseconds: cues[next].startTimeMs));
      if (!mounted || !_isPlayingAll || sessionSnapshot != _playAllSessionId) {
        return;
      }
      _lastKnownVideoPositionMs = cues[next].startTimeMs;
      setState(() {
        _currentCueIndex = next;
        _playAllInBetweenCueGap = false;
      });
      unawaited(
        PracticeProgressStore.instance.setCueIndex(widget.mediaItem.id, next),
      );
      await controller.play();
    } finally {
      if (mounted && _playAllInBetweenCueGap) {
        setState(() => _playAllInBetweenCueGap = false);
      }
    }
  }

  Future<void> _playAllGapThenReplaySameCueAudio({
    required AudioPlayer audioPlayer,
    required PlayAllPauseBetweenCues pauseMode,
    required int cueIndex,
    required int sessionSnapshot,
  }) async {
    try {
      await audioPlayer.pause();
      if (!mounted || !_isPlayingAll || sessionSnapshot != _playAllSessionId) {
        return;
      }
      final cues = widget.mediaItem.cues;
      final delayMs = _playAllGapDelayMs(
        mode: pauseMode,
        endedCue: cues[cueIndex],
        playbackSpeed: _playbackSpeed,
      );
      await Future.delayed(Duration(milliseconds: delayMs));
      if (!mounted || !_isPlayingAll || sessionSnapshot != _playAllSessionId) {
        return;
      }
      await audioPlayer.seek(
        Duration(milliseconds: cues[cueIndex].startTimeMs),
      );
      if (!mounted || !_isPlayingAll || sessionSnapshot != _playAllSessionId) {
        return;
      }
      _lastKnownAudioPositionMs = cues[cueIndex].startTimeMs;
      setState(() {
        _playAllInBetweenCueGap = false;
      });
      await audioPlayer.resume();
    } finally {
      if (mounted && _playAllInBetweenCueGap) {
        setState(() => _playAllInBetweenCueGap = false);
      }
    }
  }

  Future<void> _playAllGapThenReplaySameCueVideo({
    required VideoPlayerController controller,
    required PlayAllPauseBetweenCues pauseMode,
    required int cueIndex,
    required int sessionSnapshot,
  }) async {
    try {
      await controller.pause();
      if (!mounted || !_isPlayingAll || sessionSnapshot != _playAllSessionId) {
        return;
      }
      final cues = widget.mediaItem.cues;
      final delayMs = _playAllGapDelayMs(
        mode: pauseMode,
        endedCue: cues[cueIndex],
        playbackSpeed: _playbackSpeed,
      );
      await Future.delayed(Duration(milliseconds: delayMs));
      if (!mounted || !_isPlayingAll || sessionSnapshot != _playAllSessionId) {
        return;
      }
      await controller.seekTo(
        Duration(milliseconds: cues[cueIndex].startTimeMs),
      );
      if (!mounted || !_isPlayingAll || sessionSnapshot != _playAllSessionId) {
        return;
      }
      _lastKnownVideoPositionMs = cues[cueIndex].startTimeMs;
      setState(() {
        _playAllInBetweenCueGap = false;
      });
      await controller.play();
    } finally {
      if (mounted && _playAllInBetweenCueGap) {
        setState(() => _playAllInBetweenCueGap = false);
      }
    }
  }

  Future<void> _startPlayAll(PlayAllSettings settings) async {
    if (_isPlayingAll) {
      return;
    }
    final pauseMode = settings.pauseBetweenCues;
    final playsPerCue = settings.playsPerCue.clamp(1, 3);
    _playAllSessionId++;
    final sessionAtStart = _playAllSessionId;
    setState(() {
      _isPlayingAll = true;
      _playAllInBetweenCueGap = false;
      _playAllCompletedPlaysForCurrentCue = 0;
    });
    unawaited(WakelockPlus.enable());

    final audioPlayer = _audioPlayer;
    if (audioPlayer != null && _audioPlayerReady) {
      final cue = widget.mediaItem.cues[_currentCueIndex];
      final current = await audioPlayer.getCurrentPosition();
      final seekMs = _seekMsResumeWithinCurrentCue(
        cueStartMs: cue.startTimeMs,
        cuePlaybackStopMs: _playbackStopMsForCueIndex(_currentCueIndex),
        mediaPositionMs: current?.inMilliseconds,
      );
      await audioPlayer.seek(Duration(milliseconds: seekMs));
      await audioPlayer.resume();
      setState(() => _isPlaying = true);

      _audioPositionSub?.cancel();
      _audioPositionSub = audioPlayer.onPositionChanged.listen((pos) {
        if (!mounted || !_isPlayingAll) {
          return;
        }
        if (sessionAtStart != _playAllSessionId) {
          return;
        }
        if (_playAllInBetweenCueGap) {
          return;
        }
        _lastKnownAudioPositionMs = pos.inMilliseconds;
        final cues = widget.mediaItem.cues;
        final posMs = pos.inMilliseconds;
        final i = _currentCueIndex;

        final continuous =
            pauseMode == PlayAllPauseBetweenCues.none && playsPerCue == 1;

        if (continuous) {
          var newIndex = _currentCueIndex;
          for (var j = 0; j < cues.length; j++) {
            if (posMs >= cues[j].startTimeMs &&
                (j == cues.length - 1 || posMs < cues[j + 1].startTimeMs)) {
              newIndex = j;
              break;
            }
          }
          if (newIndex != _currentCueIndex) {
            setState(() => _currentCueIndex = newIndex);
            unawaited(
              PracticeProgressStore.instance.setCueIndex(
                widget.mediaItem.id,
                newIndex,
              ),
            );
          }
          if (posMs >= _playbackStopMsForCueIndex(cues.length - 1)) {
            unawaited(_stopPlayAll());
          }
          return;
        }

        if (posMs >= _playbackStopMsForCueIndex(i)) {
          _playAllInBetweenCueGap = true;
          _playAllCompletedPlaysForCurrentCue++;
          if (_playAllCompletedPlaysForCurrentCue < playsPerCue) {
            final snapshot = _playAllSessionId;
            unawaited(
              _playAllGapThenReplaySameCueAudio(
                audioPlayer: audioPlayer,
                pauseMode: pauseMode,
                cueIndex: i,
                sessionSnapshot: snapshot,
              ),
            );
            return;
          }
          _playAllCompletedPlaysForCurrentCue = 0;
          if (i < cues.length - 1) {
            final snapshot = _playAllSessionId;
            unawaited(
              _playAllGapThenNextCueAudio(
                audioPlayer: audioPlayer,
                pauseMode: pauseMode,
                endedCueIndex: i,
                sessionSnapshot: snapshot,
              ),
            );
          } else {
            unawaited(_stopPlayAll());
          }
        }
      });
      return;
    }

    final controller = _videoController;
    if (controller == null || !controller.value.isInitialized) {
      _playAllSessionId++;
      if (mounted) {
        setState(() {
          _isPlayingAll = false;
          _playAllInBetweenCueGap = false;
        });
      }
      unawaited(WakelockPlus.disable());
      return;
    }

    final vCue = widget.mediaItem.cues[_currentCueIndex];
    final vSeekMs = _seekMsResumeWithinCurrentCue(
      cueStartMs: vCue.startTimeMs,
      cuePlaybackStopMs: _playbackStopMsForCueIndex(_currentCueIndex),
      mediaPositionMs: controller.value.position.inMilliseconds,
    );
    await controller.seekTo(Duration(milliseconds: vSeekMs));

    final oldListener = _videoListener;
    if (oldListener != null) {
      controller.removeListener(oldListener);
    }

    _videoListener = () {
      if (!mounted || !_isPlayingAll) {
        return;
      }
      if (sessionAtStart != _playAllSessionId) {
        return;
      }
      if (_playAllInBetweenCueGap) {
        return;
      }
      if (!controller.value.isInitialized) {
        return;
      }
      final posMs = controller.value.position.inMilliseconds;
      _lastKnownVideoPositionMs = posMs;
      final cues = widget.mediaItem.cues;
      final i = _currentCueIndex;

      final continuous =
          pauseMode == PlayAllPauseBetweenCues.none && playsPerCue == 1;

      if (continuous) {
        var newIndex = _currentCueIndex;
        for (var j = 0; j < cues.length; j++) {
          if (posMs >= cues[j].startTimeMs &&
              (j == cues.length - 1 || posMs < cues[j + 1].startTimeMs)) {
            newIndex = j;
            break;
          }
        }
        if (newIndex != _currentCueIndex) {
          setState(() => _currentCueIndex = newIndex);
          unawaited(
            PracticeProgressStore.instance.setCueIndex(
              widget.mediaItem.id,
              newIndex,
            ),
          );
        }
        if (posMs >= _playbackStopMsForCueIndex(cues.length - 1)) {
          unawaited(_stopPlayAll());
        }
        return;
      }

      if (posMs >= _playbackStopMsForCueIndex(i)) {
        _playAllInBetweenCueGap = true;
        _playAllCompletedPlaysForCurrentCue++;
        if (_playAllCompletedPlaysForCurrentCue < playsPerCue) {
          final snapshot = _playAllSessionId;
          unawaited(
            _playAllGapThenReplaySameCueVideo(
              controller: controller,
              pauseMode: pauseMode,
              cueIndex: i,
              sessionSnapshot: snapshot,
            ),
          );
          return;
        }
        _playAllCompletedPlaysForCurrentCue = 0;
        if (i < cues.length - 1) {
          final snapshot = _playAllSessionId;
          unawaited(
            _playAllGapThenNextCueVideo(
              controller: controller,
              pauseMode: pauseMode,
              endedCueIndex: i,
              sessionSnapshot: snapshot,
            ),
          );
        } else {
          unawaited(_stopPlayAll());
        }
      }
    };
    controller.addListener(_videoListener!);
    await controller.play();
    setState(() => _isPlaying = true);
  }

  Future<void> _stopPlayAll() async {
    if (!_isPlayingAll) {
      return;
    }
    _playAllSessionId++;
    unawaited(WakelockPlus.disable());
    setState(() {
      _isPlayingAll = false;
      _isPlaying = false;
      _playAllInBetweenCueGap = false;
    });
    final ap = _audioPlayer;
    if (ap != null) {
      await ap.pause();
      // Restore per-cue stop listener.
      _audioPositionSub?.cancel();
      _audioPositionSub = ap.onPositionChanged.listen((pos) {
        if (!mounted) return;
        _lastKnownAudioPositionMs = pos.inMilliseconds;
        if (_isPlaying &&
            pos.inMilliseconds >=
                _playbackStopMsForCueIndex(_currentCueIndex)) {
          unawaited(ap.pause());
          unawaited(WakelockPlus.disable());
          if (mounted) setState(() => _isPlaying = false);
        }
      });
      return;
    }
    final controller = _videoController;
    if (controller != null && controller.value.isInitialized) {
      _lastKnownVideoPositionMs = controller.value.position.inMilliseconds;
      await controller.pause();
      // Restore per-cue stop listener.
      final oldListener = _videoListener;
      if (oldListener != null) controller.removeListener(oldListener);
      _videoListener = () {
        if (!mounted) return;
        _lastKnownVideoPositionMs = controller.value.position.inMilliseconds;
        if (_isPlaying &&
            controller.value.position.inMilliseconds >=
                _playbackStopMsForCueIndex(_currentCueIndex)) {
          controller.pause();
          unawaited(WakelockPlus.disable());
          if (mounted) setState(() => _isPlaying = false);
        }
      };
      controller.addListener(_videoListener!);
    }
  }

  Future<void> _handleSubtitleToggle() async {
    if (_isTranslating) {
      return;
    }

    if (!supportsBuiltInTranslation) {
      if (_subtitleState == SubtitleState.hidden) {
        setState(() {
          _subtitleState = SubtitleState.original;
          _translationErrorMessage = null;
        });
        return;
      }
      setState(() {
        _subtitleState = SubtitleState.hidden;
        _translationErrorMessage = null;
      });
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

  void _openRecordsSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      showDragHandle: true,
      builder: (context) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.75,
        minChildSize: 0.35,
        maxChildSize: 0.95,
        builder: (context, scrollController) => RecordCompareSheet(
          scrollController: scrollController,
          mediaItemId: widget.mediaItem.id,
          cue: widget.mediaItem.cues[_currentCueIndex],
          sourceLocaleIdentifier: _sourceLocaleIdentifier,
        ),
      ),
    );
  }

  Future<void> _deleteCueTempRecordingFile(String path) async {
    final file = File(path);
    if (await file.exists()) {
      await file.delete();
    }
  }

  Future<void> _abortCueRecordingIfActive() async {
    if (!_isCueRecording) return;
    _practiceRecordingTimer?.cancel();
    _practiceAutoStopTimer?.cancel();
    try {
      final stopped = await _cueRecorder.stop();
      final path = stopped ?? _cueRecordingTempPath;
      if (path != null && path.isNotEmpty) {
        await _deleteCueTempRecordingFile(path);
      }
    } catch (_) {
      // Best-effort cleanup.
    }
    _cueRecordingTempPath = null;
    if (mounted) {
      setState(() {
        _isCueRecording = false;
        _practiceRecordingElapsed = Duration.zero;
      });
    }
  }

  Future<void> _pausePracticePlaybackForRecording() async {
    if (_isPlayingAll) return;
    final audioPlayer = _audioPlayer;
    if (audioPlayer != null && _audioPlayerReady) {
      if (_isPlaying) {
        final p = await audioPlayer.getCurrentPosition();
        if (p != null) {
          _lastKnownAudioPositionMs = p.inMilliseconds;
        }
        await audioPlayer.pause();
        unawaited(WakelockPlus.disable());
        if (mounted) setState(() => _isPlaying = false);
      }
      return;
    }

    final controller = _videoController;
    if (controller != null && controller.value.isInitialized && _isPlaying) {
      _lastKnownVideoPositionMs = controller.value.position.inMilliseconds;
      await controller.pause();
      unawaited(WakelockPlus.disable());
      if (mounted) {
        setState(() {
          _isPlaying = false;
        });
      }
    }
  }

  Future<bool> _ensureMicrophonePermissionForCue() async {
    try {
      if (await _cueRecorder.hasPermission()) {
        return true;
      }
    } catch (_) {
      // Fall through to permission_handler.
    }

    var status = await Permission.microphone.status;
    if (status.isGranted) {
      return true;
    }

    if (status.isDenied) {
      status = await Permission.microphone.request();
      if (status.isGranted) {
        return true;
      }
    }

    if (!mounted) {
      return false;
    }

    final l10n = AppLocalizations.of(context)!;
    final message = switch (status) {
      PermissionStatus.permanentlyDenied =>
        l10n.compareMicrophoneDeniedPermanent,
      PermissionStatus.restricted => l10n.compareMicrophoneDeniedRestricted,
      _ => l10n.compareMicrophoneDeniedDefault,
    };

    final showSettings = status == PermissionStatus.permanentlyDenied;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        action: showSettings
            ? SnackBarAction(
                label: l10n.compareOpenIphoneSettings,
                onPressed: openAppSettings,
              )
            : null,
      ),
    );
    return false;
  }

  String _formatRecordingDuration(Duration d) {
    final minutes = d.inMinutes;
    final seconds = d.inSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  Future<void> _onRecordTap() async {
    if (_isCueTranscribing) {
      return;
    }
    if (_isCueRecording) {
      await _stopCueRecordingAndProcess();
      return;
    }
    await _startCueRecording();
  }

  Future<void> _startCueRecording() async {
    setState(() {
      _practiceRecordingElapsed = Duration.zero;
    });

    final granted = await _ensureMicrophonePermissionForCue();
    if (!granted || !mounted) {
      return;
    }

    final speechReady = await _ensureSpeechRecognitionReadyForCue();
    if (!speechReady || !mounted) {
      return;
    }

    await _pausePracticePlaybackForRecording();
    if (!mounted) return;

    final directory = await getTemporaryDirectory();
    final path =
        '${directory.path}/bantera_attempt_${DateTime.now().millisecondsSinceEpoch}.wav';

    final prev = _cueRecordingTempPath;
    if (prev != null && prev.isNotEmpty) {
      await _deleteCueTempRecordingFile(prev);
    }

    try {
      await _cueRecorder.start(
        const RecordConfig(
          encoder: AudioEncoder.wav,
          sampleRate: 16000,
          numChannels: 1,
        ),
        path: path,
      );
      _practiceRecordingTimer?.cancel();
      _practiceRecordingTimer = Timer.periodic(const Duration(seconds: 1), (_) {
        if (!mounted) return;
        setState(() {
          _practiceRecordingElapsed += const Duration(seconds: 1);
        });
      });
      _practiceAutoStopTimer?.cancel();
      _practiceAutoStopTimer = Timer(_maxCueRecordingDuration, () {
        if (mounted && _isCueRecording) {
          unawaited(_stopCueRecordingAndProcess());
        }
      });
      setState(() {
        _cueRecordingTempPath = path;
        _isCueRecording = true;
      });
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_l10n.compareCouldNotStartRecording)),
      );
    }
  }

  Future<bool> _ensureSpeechRecognitionReadyForCue() async {
    try {
      await VideoProcessingService.instance
          .ensureRecordedAudioTranscriptionReady(
            localeIdentifier: _sourceLocaleIdentifier,
          );
      return true;
    } on VideoProcessingException catch (error) {
      if (!mounted) return false;

      final l10n = AppLocalizations.of(context)!;
      final displayMessage = switch (error.code) {
        'speech_authorization_denied' =>
          l10n.compareSpeechRecognitionDeniedPermanent,
        'speech_authorization_restricted' =>
          l10n.compareSpeechRecognitionDeniedRestricted,
        'speech_unavailable' => l10n.compareSpeechRecognitionUnavailable,
        'unsupported_locale' => l10n.compareSpeechRecognitionUnsupportedLocale,
        _ => error.message,
      };
      final showSettings = error.code == 'speech_authorization_denied';

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(displayMessage),
          action: showSettings
              ? SnackBarAction(
                  label: l10n.compareOpenIphoneSettings,
                  onPressed: openAppSettings,
                )
              : null,
        ),
      );
      return false;
    }
  }

  Future<void> _stopCueRecordingAndProcess() async {
    _practiceRecordingTimer?.cancel();
    _practiceAutoStopTimer?.cancel();
    setState(() {
      _isCueRecording = false;
      _isCueTranscribing = true;
    });

    try {
      final stoppedPath = await _cueRecorder.stop();
      final resolvedPath = stoppedPath ?? _cueRecordingTempPath;
      if (resolvedPath == null || resolvedPath.isEmpty) {
        throw const VideoProcessingException(
          code: 'missing_recording',
          message: 'Bantera could not access the recorded audio.',
        );
      }

      final cue = widget.mediaItem.cues[_currentCueIndex];
      final processed = await processRecordingFile(
        audioFile: File(resolvedPath),
        expectedCueText: cue.originalText,
        mediaItemId: widget.mediaItem.id,
        cueId: cue.id,
        sourceLocaleIdentifier: _sourceLocaleIdentifier,
        recordingDurationMs: _practiceRecordingElapsed.inMilliseconds,
      );

      if (!mounted) return;

      setState(() {
        _isCueTranscribing = false;
        _practiceRecordingElapsed = Duration.zero;
        _cueRecordingTempPath = null;
      });

      await showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        showDragHandle: true,
        builder: (context) => DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.75,
          minChildSize: 0.35,
          maxChildSize: 0.95,
          builder: (context, scrollController) => SessionCompareResultSheet(
            scrollController: scrollController,
            cue: cue,
            sourceLocaleIdentifier: _sourceLocaleIdentifier,
            result: processed.comparison,
            audioPath: processed.resolvedAudioPath,
            saveErrorMessage: processed.saveErrorMessage,
            onTryAgain: () {},
          ),
        ),
      );
    } on VideoProcessingException catch (error) {
      if (!mounted) return;
      setState(() {
        _isCueTranscribing = false;
        _practiceRecordingElapsed = Duration.zero;
      });

      final l10n = AppLocalizations.of(context)!;
      final displayMessage = switch (error.code) {
        'missing_recording' => l10n.compareCouldNotAccessRecording,
        'empty_transcript' => l10n.compareNoTranscriptGenerated,
        _ => error.message,
      };
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(displayMessage)));
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isCueTranscribing = false;
        _practiceRecordingElapsed = Duration.zero;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_l10n.practiceRecordingProcessError)),
      );
    }
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
      return Scaffold(body: Center(child: Text(_l10n.practiceNoCues)));
    }

    final cue = widget.mediaItem.cues[_currentCueIndex];
    final colorScheme = Theme.of(context).colorScheme;
    final legacyApple = isLegacyAppleOsPre26;

    /// iOS/iPadOS major &lt; 26 only — Play all left of Show Transcript; macOS legacy unchanged.
    final iosLegacyPre26 = Platform.isIOS && legacyApple;

    if (!supportsBuiltInTranslation && _subtitleState == SubtitleState.translated) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() => _subtitleState = SubtitleState.original);
        }
      });
    }

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text(
          widget.mediaItem.title,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontSize: 14),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          // Speed button
          TextButton(
            onPressed: () async {
              final speed = nearestPracticePlaybackSpeed(_playbackSpeed);
              final currentIndex = kPracticePlaybackSpeedOptions.indexOf(speed);
              final idx = currentIndex >= 0
                  ? currentIndex
                  : kPracticePlaybackSpeedOptions.indexOf(1.0);
              final nextIndex =
                  (idx + 1) % kPracticePlaybackSpeedOptions.length;
              await _setPlaybackSpeed(kPracticePlaybackSpeedOptions[nextIndex]);
            },
            child: Text(
              _playbackSpeed == _playbackSpeed.truncateToDouble()
                  ? '${_playbackSpeed.toInt()}×'
                  : '$_playbackSpeed×',
              style: Theme.of(context).textTheme.labelLarge,
            ),
          ),
          if (supportsBuiltInTranslation)
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
              child: Builder(
                builder: (context) {
                  final transcriptButton = OutlinedButton.icon(
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
                            !supportsBuiltInTranslation
                                ? (_subtitleState == SubtitleState.hidden
                                      ? CupertinoIcons.eye
                                      : CupertinoIcons.eye_slash)
                                : (_subtitleState == SubtitleState.hidden
                                      ? CupertinoIcons.eye
                                      : _subtitleState == SubtitleState.original
                                      ? CupertinoIcons.globe
                                      : CupertinoIcons.eye_slash),
                          ),
                    label: Text(
                      _isTranslating
                          ? _l10n.practiceTranslating
                          : Platform.isIOS && !supportsBuiltInTranslation
                          ? _l10n.practiceTextLabel
                          : !supportsBuiltInTranslation
                          ? (_subtitleState == SubtitleState.hidden
                                ? _l10n.practiceShowTranscript
                                : _l10n.practiceHideText)
                          : (_subtitleState == SubtitleState.hidden
                                ? _l10n.practiceShowTranscript
                                : _subtitleState == SubtitleState.original
                                ? _l10n.practiceTranslate
                                : _l10n.practiceHideText),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  );

                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [transcriptButton],
                  );
                },
              ),
            ),
            if (_translationErrorMessage != null && supportsBuiltInTranslation)
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
                        color: !_isPlayingAll && _currentCueIndex > 0
                            ? colorScheme.primary
                            : colorScheme.primary.withValues(alpha: 0.2),
                        onPressed: _isPlayingAll ? null : _prevCue,
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
                        color: !_isPlayingAll
                            ? colorScheme.primary
                            : colorScheme.primary.withValues(alpha: 0.2),
                        onPressed: _isPlayingAll ? null : _nextCue,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      if (legacyApple && !iosLegacyPre26)
                        Expanded(
                          child: Center(
                            child: _buildActionBtn(
                              _isPlayingAll
                                  ? CupertinoIcons.stop_fill
                                  : CupertinoIcons.play_rectangle,
                              _isPlayingAll
                                  ? _l10n.practiceStop
                                  : _l10n.practicePlayAll,
                              () => _isPlayingAll
                                  ? unawaited(_stopPlayAll())
                                  : unawaited(_promptPlayAll()),
                              colorScheme,
                            ),
                          ),
                        )
                      else ...[
                        if (!legacyApple || iosLegacyPre26)
                          Expanded(
                            child: Center(
                              child: _buildActionBtn(
                                _isPlayingAll
                                    ? CupertinoIcons.stop_fill
                                    : CupertinoIcons.play_rectangle,
                                _isPlayingAll
                                    ? _l10n.practiceStop
                                    : _l10n.practicePlayAll,
                                () => _isPlayingAll
                                    ? unawaited(_stopPlayAll())
                                    : unawaited(_promptPlayAll()),
                                colorScheme,
                              ),
                            ),
                          ),
                        Expanded(
                          child: Center(
                            child: _buildRecordActionColumn(colorScheme),
                          ),
                        ),
                        Expanded(
                          child: Center(
                            child: _buildActionBtn(
                              CupertinoIcons.list_bullet,
                              _l10n.practiceRecords,
                              _isPlayingAll ? null : _openRecordsSheet,
                              colorScheme,
                            ),
                          ),
                        ),
                      ],
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
      if (!widget.mediaItem.isAudioOnly) {
        return const Center(child: CircularProgressIndicator());
      }
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(value: _mediaLoadProgress),
            const SizedBox(height: 12),
            Text(
              _mediaLoadProgress == null
                  ? _l10n.practiceAudioLoading
                  : _l10n.practiceAudioLoadingPercent(
                      (_mediaLoadProgress! * 100).clamp(0, 100).round(),
                    ),
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      );
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
      final coverUrl = widget.mediaItem.coverUrl.trim();
      if (coverUrl.isNotEmpty && _audioPlayerReady) {
        return GestureDetector(
          onTap: () {}, // absorb tap so cover doesn't trigger play/pause
          child: ClipRRect(
            borderRadius: BorderRadius.circular(28),
            child: Stack(
              fit: StackFit.expand,
              children: [
                CachedNetworkImage(
                  imageUrl: coverUrl,
                  fit: BoxFit.cover,
                  placeholder: (_, _) =>
                      ColoredBox(color: colorScheme.surfaceContainerHighest),
                  errorWidget: (_, _, _) => ColoredBox(
                    color: colorScheme.surfaceContainerHighest,
                    child: Icon(
                      Icons.audiotrack,
                      color: colorScheme.onSurfaceVariant,
                    ),
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
          ),
        );
      }
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
            child: Text(
              _l10n.practiceTranscriptHidden,
              style: const TextStyle(
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
            _l10n.practiceListenCarefully,
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
          ? _l10n.practiceTranslationUnavailableForCue
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
          GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTapDown: _isPlayingAll
                ? null
                : (details) =>
                      _handleTimelineDrag(details.localPosition.dx, 92),
            onHorizontalDragStart: _isPlayingAll
                ? null
                : (details) =>
                      _handleTimelineDrag(details.localPosition.dx, 92),
            onHorizontalDragUpdate: _isPlayingAll
                ? null
                : (details) =>
                      _handleTimelineDrag(details.localPosition.dx, 92),
            child: SizedBox(
              width: 92,
              height: 24,
              child: Center(
                child: Container(
                  width: 92,
                  height: 8,
                  decoration: BoxDecoration(
                    color: colorScheme.onSurface.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor:
                        ((_currentCueIndex + 1) / widget.mediaItem.cues.length)
                            .clamp(0.0, 1.0),
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: colorScheme.primary,
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            '${_currentCueIndex + 1}/${widget.mediaItem.cues.length}',
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: colorScheme.primary,
            ),
          ),
          const SizedBox(width: 4),
          Builder(
            builder: (context) {
              final isSaved = SavedCueRepository.instance.isSaved(
                widget.mediaItem.id,
                cue.id,
              );
              return GestureDetector(
                onTap: () {
                  unawaited(
                    SavedCueRepository.instance
                        .toggleSaveCue(
                          mediaItem: widget.mediaItem,
                          cue: cue,
                          cueIndex: _currentCueIndex,
                        )
                        .then((_) {
                          if (mounted) setState(() {});
                        }),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 8,
                  ),
                  child: Icon(
                    isSaved
                        ? CupertinoIcons.bookmark_fill
                        : CupertinoIcons.bookmark,
                    size: 18,
                    color: isSaved
                        ? colorScheme.primary
                        : colorScheme.onSurface.withValues(alpha: 0.4),
                  ),
                ),
              );
            },
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
      Future<Map<String, String>> translateOnce() {
        return TranslationService.instance.translateCues(
          sourceLocaleIdentifier: sourceLocaleIdentifier,
          targetLocaleIdentifier: targetLocale,
          cues: [cue],
        );
      }

      late final Map<String, String> translated;
      try {
        translated = await translateOnce();
      } on TranslationException catch (error) {
        if (error.code == 'translation_assets_not_installed' && mounted) {
          await TranslationService.instance.prepareTranslationAssets(
            sourceLocaleIdentifier: sourceLocaleIdentifier,
            targetLocaleIdentifier: targetLocale,
          );
          translated = await translateOnce();
        } else {
          rethrow;
        }
      }
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
      Future<Map<String, String>> translateOnce() {
        return TranslationService.instance.translateCues(
          sourceLocaleIdentifier: sourceLocaleIdentifier,
          targetLocaleIdentifier: targetLocaleIdentifier,
          cues: remainingCues,
        );
      }

      late final Map<String, String> translated;
      try {
        translated = await translateOnce();
      } on TranslationException catch (error) {
        if (error.code == 'translation_assets_not_installed') {
          await TranslationService.instance.prepareTranslationAssets(
            sourceLocaleIdentifier: sourceLocaleIdentifier,
            targetLocaleIdentifier: targetLocaleIdentifier,
          );
          translated = await translateOnce();
        } else {
          rethrow;
        }
      }
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
          _translationErrorMessage = _l10n.practiceNoTranslationLanguagesFound;
        });
      }
      return null;
    }

    final savedIdentifier = UserProfileNotifier.instance.translationLanguage;
    final savedLocale = _findTranslationLocale(locales, savedIdentifier);
    if (savedLocale != null) {
      try {
        await _ensureTranslationAssetsDownloaded(
          sourceLocaleIdentifier: sourceLocaleIdentifier,
          target: savedLocale,
        );
      } on TranslationException catch (error) {
        if (mounted) {
          setState(() {
            _translationErrorMessage = error.message;
          });
        }
        return null;
      }
      return savedLocale.identifier;
    }

    final selectedLocale = await _showTranslationLanguageSheet(
      locales: locales,
      selected: _bestMatchingTranslationLocale(locales) ?? locales.first,
      title: _l10n.practiceChooseTranslationLanguageTitle,
      description: _l10n.practiceChooseTranslationLanguageDescription,
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

    try {
      await _ensureTranslationAssetsDownloaded(
        sourceLocaleIdentifier: sourceLocaleIdentifier,
        target: selectedLocale,
      );
    } on TranslationException catch (error) {
      if (mounted) {
        setState(() {
          _translationErrorMessage = error.message;
        });
      }
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
            UserProfileNotifier.instance.localizedError(_l10n) ??
            _l10n.practiceCouldNotSaveTranslationLanguage;
      });
      return null;
    }

    return selectedLocale.identifier;
  }

  /// Downloads on-device translation models when needed (iOS system sheet).
  Future<void> _ensureTranslationAssetsDownloaded({
    required String sourceLocaleIdentifier,
    required TranslationLocaleOption target,
  }) async {
    if (target.isInstalled) {
      return;
    }
    await TranslationService.instance.prepareTranslationAssets(
      sourceLocaleIdentifier: sourceLocaleIdentifier,
      targetLocaleIdentifier: target.identifier,
    );
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
      title: _l10n.practiceChangeTranslationLanguageTitle,
      description: _l10n.practiceChangeTranslationLanguageDescription,
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

    try {
      await _ensureTranslationAssetsDownloaded(
        sourceLocaleIdentifier: sourceLocaleIdentifier,
        target: selectedLocale,
      );
    } on TranslationException catch (error) {
      if (mounted) {
        setState(() {
          _translationErrorMessage = error.message;
        });
      }
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
            UserProfileNotifier.instance.localizedError(_l10n) ??
            _l10n.practiceCouldNotSaveTranslationLanguage;
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
    if (translations.isEmpty) return;

    final localPracticeId = _savedLocalPracticeId;
    if (localPracticeId != null) {
      try {
        await LocalPracticeRepository.instance.storeTranslations(
          id: localPracticeId,
          translatedLanguage: targetLocaleIdentifier,
          translations: translations,
        );
      } catch (_) {
        // Local persistence should not block practice playback.
      }
      return;
    }

    unawaited(
      _persistUploadedVideoTranslations(
        targetLocaleIdentifier: targetLocaleIdentifier,
        translations: translations,
      ),
    );
  }

  Future<Directory> _getTranslationCacheDir() async {
    final base = await getApplicationSupportDirectory();
    final dir = Directory('${base.path}/video_translations');
    if (!await dir.exists()) await dir.create(recursive: true);
    return dir;
  }

  Future<void> _loadUploadedVideoTranslations() async {
    final videoId = _uploadedVideoId;
    if (videoId == null) return;
    try {
      final dir = await _getTranslationCacheDir();
      final langFile = File('${dir.path}/${videoId}__lang.txt');
      if (!await langFile.exists()) return;
      final lang = (await langFile.readAsString()).trim();
      if (lang.isEmpty) return;
      final cacheFile = File('${dir.path}/${videoId}__$lang.json');
      if (!await cacheFile.exists()) return;
      final decoded = jsonDecode(await cacheFile.readAsString());
      if (decoded is! Map) return;
      final translations = decoded.cast<String, String>();
      if (!mounted) return;
      setState(() {
        _translatedCueTexts = {..._translatedCueTexts, ...translations};
        _translatedLanguageIdentifier = lang;
      });
      // Pre-translate any remaining cues in the background so they're ready
      // when the user taps translate — same strategy as local video practice.
      unawaited(
        _translateRemainingCuesInBackground(
          sourceLocaleIdentifier: _sourceLocaleIdentifier,
          targetLocaleIdentifier: lang,
          generation: _translationGeneration,
          excludedCueId: '',
        ),
      );
    } catch (_) {
      // Cache load failures should never break the practice session.
    }
  }

  Future<void> _persistUploadedVideoTranslations({
    required String targetLocaleIdentifier,
    required Map<String, String> translations,
  }) async {
    final videoId = _uploadedVideoId;
    if (videoId == null || translations.isEmpty) return;
    try {
      final dir = await _getTranslationCacheDir();
      final cacheFile = File(
        '${dir.path}/${videoId}__$targetLocaleIdentifier.json',
      );
      Map<String, String> existing = {};
      if (await cacheFile.exists()) {
        final decoded = jsonDecode(await cacheFile.readAsString());
        if (decoded is Map) existing = decoded.cast<String, String>();
      }
      existing.addAll(translations);
      await cacheFile.writeAsString(jsonEncode(existing));
      await File(
        '${dir.path}/${videoId}__lang.txt',
      ).writeAsString(targetLocaleIdentifier);
    } catch (_) {
      // Cache write failures should never break the practice session.
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
          builder: (dialogContext) {
            final theme = Theme.of(dialogContext);
            final l10n = AppLocalizations.of(dialogContext)!;
            return AlertDialog(
              title: Text(l10n.practiceConfirmTranslationLanguageTitle),
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
                    l10n.practiceConfirmTranslationLanguageBody,
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(false),
                  child: Text(l10n.cancel),
                ),
                FilledButton(
                  onPressed: () => Navigator.of(dialogContext).pop(true),
                  child: Text(l10n.confirmLabel),
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
    VoidCallback? onTap,
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

  Widget _buildRecordActionColumn(ColorScheme colorScheme) {
    final disabled =
        _isPlayingAll ||
        _isCueTranscribing ||
        (_isInitializingMedia && _hasPlayableMedia);
    final onTap = disabled ? null : () => unawaited(_onRecordTap());
    final isRecording = _isCueRecording;

    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: isRecording
                ? Colors.redAccent
                : colorScheme.primary,
            foregroundColor: isRecording ? Colors.white : colorScheme.onPrimary,
            child: _isCueTranscribing
                ? const SizedBox(
                    width: 28,
                    height: 28,
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      color: Colors.white,
                    ),
                  )
                : Icon(
                    isRecording
                        ? CupertinoIcons.stop_fill
                        : CupertinoIcons.mic_solid,
                    size: 28,
                  ),
          ),
          const SizedBox(height: 8),
          Text(
            isRecording
                ? _formatRecordingDuration(_practiceRecordingElapsed)
                : _l10n.practiceRecord,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: isRecording ? Colors.redAccent : colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }

  void _handleAudioCacheProgress(PracticeAudioCacheProgress progress) {
    final fraction = progress.fraction;
    if (!mounted || fraction == _mediaLoadProgress) {
      return;
    }
    setState(() => _mediaLoadProgress = fraction);
  }

  Future<void> _initializeMedia() async {
    if (!_hasPlayableMedia) {
      return;
    }

    setState(() {
      _isInitializingMedia = true;
      _mediaLoadProgress = null;
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
        // for native AVPlayer). Cache locally, then play from the cached file.
        final cachedAudio = await PracticeAudioCache.instance.getAudioFile(
          mediaId: widget.mediaItem.id,
          url: remoteUrl,
          headers: widget.mediaItem.mediaHeaders,
          onProgress: _handleAudioCacheProgress,
        );

        final player = AudioPlayer();
        _audioPlayer = player;
        _audioPositionSub = player.onPositionChanged.listen((pos) {
          if (!mounted) return;
          _lastKnownAudioPositionMs = pos.inMilliseconds;
          final stopMs = _playbackStopMsForCueIndex(_currentCueIndex);
          final cueEnd = Duration(milliseconds: stopMs);
          if (_isPlaying && pos >= cueEnd) {
            unawaited(player.pause());
            unawaited(WakelockPlus.disable());
            if (mounted) setState(() => _isPlaying = false);
          }
        });
        await player.setSourceDeviceFile(cachedAudio.file.path);
        final audioDuration = await player.getDuration();
        _loadedMediaDurationMs = audioDuration?.inMilliseconds;
        await player.seek(
          Duration(milliseconds: widget.mediaItem.cues[0].startTimeMs),
        );
        _lastKnownAudioPositionMs = widget.mediaItem.cues[0].startTimeMs;
        if (mounted) setState(() => _audioPlayerReady = true);
      } catch (e) {
        _mediaError = _l10n.practiceAudioError(e.toString());
      } finally {
        if (mounted) {
          setState(() {
            _isInitializingMedia = false;
            _mediaLoadProgress = null;
          });
        }
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

        _lastKnownVideoPositionMs = controller.value.position.inMilliseconds;
        final stopMs = _playbackStopMsForCueIndex(_currentCueIndex);
        final cueEnd = Duration(milliseconds: stopMs);
        if (_isPlaying && controller.value.position >= cueEnd) {
          controller.pause();
          unawaited(WakelockPlus.disable());
          if (mounted) {
            setState(() {
              _isPlaying = false;
            });
          }
        }
      };
      controller.addListener(_videoListener!);

      await controller.initialize();
      _loadedMediaDurationMs = controller.value.duration.inMilliseconds;
      await controller.pause();
      await controller.seekTo(
        Duration(
          milliseconds: widget.mediaItem.cues[_currentCueIndex].startTimeMs,
        ),
      );
      _lastKnownVideoPositionMs =
          widget.mediaItem.cues[_currentCueIndex].startTimeMs;
    } catch (_) {
      _mediaError = _l10n.practiceVideoOpenError;
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
        final p = await audioPlayer.getCurrentPosition();
        if (p != null) {
          _lastKnownAudioPositionMs = p.inMilliseconds;
        }
        await audioPlayer.pause();
        unawaited(WakelockPlus.disable());
        if (mounted) setState(() => _isPlaying = false);
      } else {
        final cue = widget.mediaItem.cues[_currentCueIndex];
        final stopMs = _playbackStopMsForCueIndex(_currentCueIndex);
        final apiMs = (await audioPlayer.getCurrentPosition())?.inMilliseconds;
        final lastMs = _lastKnownAudioPositionMs;
        int? rawMs;
        if (lastMs != null && lastMs >= cue.startTimeMs && lastMs < stopMs) {
          rawMs = lastMs;
        } else {
          rawMs = apiMs;
        }
        final seekMs = _seekMsResumeWithinCurrentCue(
          cueStartMs: cue.startTimeMs,
          cuePlaybackStopMs: stopMs,
          mediaPositionMs: rawMs,
        );
        await audioPlayer.seek(Duration(milliseconds: seekMs));
        await audioPlayer.resume();
        unawaited(WakelockPlus.enable());
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
      _lastKnownVideoPositionMs = controller.value.position.inMilliseconds;
      await controller.pause();
      unawaited(WakelockPlus.disable());
      if (mounted) {
        setState(() {
          _isPlaying = false;
        });
      }
      return;
    }

    final cue = widget.mediaItem.cues[_currentCueIndex];
    final stopMs = _playbackStopMsForCueIndex(_currentCueIndex);
    final apiMs = controller.value.position.inMilliseconds;
    final lastMs = _lastKnownVideoPositionMs;
    int rawMs;
    if (lastMs != null && lastMs >= cue.startTimeMs && lastMs < stopMs) {
      rawMs = lastMs;
    } else {
      rawMs = apiMs;
    }
    final seekMs = _seekMsResumeWithinCurrentCue(
      cueStartMs: cue.startTimeMs,
      cuePlaybackStopMs: stopMs,
      mediaPositionMs: rawMs,
    );
    await controller.seekTo(Duration(milliseconds: seekMs));
    await controller.play();
    unawaited(WakelockPlus.enable());
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

    await _abortCueRecordingIfActive();

    final audioPlayer = _audioPlayer;
    if (audioPlayer != null && _audioPlayerReady) {
      await audioPlayer.pause();
      final startMs = widget.mediaItem.cues[nextIndex].startTimeMs;
      await audioPlayer.seek(Duration(milliseconds: startMs));
      _lastKnownAudioPositionMs = startMs;
    } else {
      final controller = _videoController;
      if (controller != null && controller.value.isInitialized) {
        await controller.pause();
        final startMs = widget.mediaItem.cues[nextIndex].startTimeMs;
        await controller.seekTo(Duration(milliseconds: startMs));
        _lastKnownVideoPositionMs = startMs;
      }
    }

    if (!mounted) return;

    setState(() {
      _currentCueIndex = nextIndex;
      _subtitleState = SubtitleState.hidden;
      _isPlaying = false;
    });

    unawaited(
      PracticeProgressStore.instance.setCueIndex(
        widget.mediaItem.id,
        nextIndex,
      ),
    );

    // Auto-play the new cue.
    await _togglePlayback();
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
    final l10n = AppLocalizations.of(context)!;
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
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.search),
                  hintText: l10n.practiceSearchLanguagesHint,
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
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: locale.isInstalled
                              ? Colors.green.withValues(alpha: 0.08)
                              : Colors.orange.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (!locale.isInstalled) ...[
                              Icon(
                                Icons.download_rounded,
                                size: 13,
                                color: Colors.orange.shade700,
                              ),
                              const SizedBox(width: 4),
                            ],
                            Text(
                              locale.isInstalled
                                  ? l10n.practiceTranslationInstalled
                                  : l10n.practiceTranslationDownload,
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    color: locale.isInstalled
                                        ? Colors.green.shade700
                                        : Colors.orange.shade700,
                                  ),
                            ),
                          ],
                        ),
                      ),
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
