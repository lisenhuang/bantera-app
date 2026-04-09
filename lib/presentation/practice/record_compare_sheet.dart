import 'dart:async';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:characters/characters.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';

import '../../core/theme.dart';
import '../../domain/models/models.dart';
import '../../infrastructure/local_practice_repository.dart';
import '../../infrastructure/video_processing_service.dart';

class RecordCompareSheet extends StatefulWidget {
  const RecordCompareSheet({
    super.key,
    required this.mediaItemId,
    required this.cue,
    required this.sourceLocaleIdentifier,
  });

  final String mediaItemId;
  final Cue cue;
  final String sourceLocaleIdentifier;

  @override
  State<RecordCompareSheet> createState() => _RecordCompareSheetState();
}

class _RecordCompareSheetState extends State<RecordCompareSheet> {
  late final AudioRecorder _audioRecorder;
  late final AudioPlayer _audioPlayer;
  final LocalPracticeRepository _localPracticeRepository =
      LocalPracticeRepository.instance;

  String? _recordingPath;
  String? _temporaryRecordingPath;
  bool _isRecording = false;
  bool _isProcessing = false;
  bool _isPlayingAttempt = false;
  bool _isLoadingHistory = true;
  static const _maxRecordingDuration = Duration(seconds: 30);
  Duration _recordingDuration = Duration.zero;
  Timer? _recordingTimer;
  Timer? _autoStopTimer;
  String? _errorMessage;
  bool _showsOpenSettingsAction = false;
  _AttemptComparisonResult? _result;
  LocalCuePracticeAttempt? _selectedAttempt;
  List<LocalCuePracticeAttempt> _attemptHistory = const [];

  @override
  void initState() {
    super.initState();
    _audioRecorder = AudioRecorder();
    _audioPlayer = AudioPlayer();
    _audioPlayer.onPlayerStateChanged.listen((state) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isPlayingAttempt = state == PlayerState.playing;
      });
    });
    unawaited(_loadAttemptHistory());
  }

  @override
  void dispose() {
    _recordingTimer?.cancel();
    _autoStopTimer?.cancel();
    _audioRecorder.dispose();
    _audioPlayer.dispose();
    final path = _temporaryRecordingPath;
    if (path != null && path.isNotEmpty) {
      unawaited(_deleteFileIfExists(path));
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: BanteraTheme.surfaceColorLight,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Record your version',
                style: theme.textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: BanteraTheme.backgroundLight,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: Text(
                  widget.cue.originalText,
                  style: theme.textTheme.bodyLarge?.copyWith(fontSize: 18),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Transcription language: ${widget.sourceLocaleIdentifier}',
                style: theme.textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 28),
              Center(
                child: GestureDetector(
                  onTap: _isProcessing ? null : _handlePrimaryTap,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    height: 88,
                    width: 88,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _isRecording
                          ? Colors.redAccent.withValues(alpha: 0.1)
                          : BanteraTheme.primaryColor.withValues(alpha: 0.1),
                      border: Border.all(
                        color: _isRecording
                            ? Colors.redAccent
                            : BanteraTheme.primaryColor,
                        width: 4,
                      ),
                    ),
                    child: Center(
                      child: _isProcessing
                          ? const SizedBox(
                              width: 28,
                              height: 28,
                              child: CircularProgressIndicator(strokeWidth: 3),
                            )
                          : Icon(
                              _isRecording
                                  ? CupertinoIcons.stop_fill
                                  : CupertinoIcons.mic_solid,
                              color: _isRecording
                                  ? Colors.redAccent
                                  : BanteraTheme.primaryColor,
                              size: 34,
                            ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                _statusText,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 8),
              Text(
                _recordingDuration == Duration.zero
                    ? ' '
                    : _formatDuration(_recordingDuration),
                textAlign: TextAlign.center,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: _isRecording ? Colors.redAccent : colorScheme.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (_errorMessage != null) ...[
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.red.withValues(alpha: 0.2)),
                  ),
                  child: Text(
                    _errorMessage!,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.red.shade700,
                    ),
                  ),
                ),
                if (_showsOpenSettingsAction) ...[
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: openAppSettings,
                    icon: const Icon(CupertinoIcons.settings),
                    label: const Text('Open iPhone Settings'),
                  ),
                ],
              ],
              if (_result != null) ...[
                const SizedBox(height: 28),
                const Divider(),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _toggleAttemptPlayback,
                        icon: Icon(
                          _isPlayingAttempt
                              ? CupertinoIcons.pause_fill
                              : CupertinoIcons.play_fill,
                        ),
                        label: Text(
                          _isPlayingAttempt ? 'Pause Attempt' : 'Play Attempt',
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildSummaryChips(context, _result!),
                const SizedBox(height: 18),
                Text(
                  'Your transcribed attempt',
                  style: theme.textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.orange.withValues(alpha: 0.2),
                    ),
                  ),
                  child: _buildAttemptTranscript(context, _result!),
                ),
                const SizedBox(height: 14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Colors.orange[800],
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        'Words that Bantera recognised differently are highlighted.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.orange[800],
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        onPressed: _resetForRetry,
                        child: const Text('Try Again'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: const Text('Done'),
                      ),
                    ),
                  ],
                ),
              ],
              if (_isLoadingHistory || _attemptHistory.isNotEmpty) ...[
                const SizedBox(height: 28),
                const Divider(),
                const SizedBox(height: 18),
                _buildAttemptHistorySection(context),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String get _statusText {
    if (_isProcessing) {
      return 'Transcribing your attempt on iPhone...';
    }
    if (_isRecording) {
      return 'Recording... Tap again to stop.';
    }
    if (_selectedAttempt != null) {
      return 'Showing a saved attempt for this cue. You can replay it or try again.';
    }
    if (_result != null) {
      return 'You can replay this attempt or try the cue again.';
    }
    return 'Tap to start recording your version of this cue.';
  }

  Future<void> _loadAttemptHistory() async {
    try {
      final attempts = await _localPracticeRepository.fetchCueAttempts(
        mediaItemId: widget.mediaItemId,
        cueId: widget.cue.id,
      );
      if (!mounted) {
        return;
      }

      setState(() {
        _attemptHistory = attempts;
        _isLoadingHistory = false;
      });

      if (attempts.isNotEmpty) {
        _selectAttempt(attempts.first);
      }
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _isLoadingHistory = false;
      });
    }
  }

  void _selectAttempt(LocalCuePracticeAttempt attempt) {
    if (!mounted) {
      return;
    }

    setState(() {
      _selectedAttempt = attempt;
      _recordingPath = attempt.audioPath;
      _temporaryRecordingPath = null;
      _recordingDuration = Duration(milliseconds: attempt.recordingDurationMs);
      _result = _buildComparisonResult(
        expectedText: widget.cue.originalText,
        actualText: attempt.transcriptText,
      );
      _errorMessage = null;
      _showsOpenSettingsAction = false;
    });
  }

  Future<void> _handlePrimaryTap() async {
    if (_isRecording) {
      await _stopRecordingAndTranscribe();
      return;
    }

    await _startRecording();
  }

  Future<void> _startRecording() async {
    setState(() {
      _errorMessage = null;
      _showsOpenSettingsAction = false;
      _result = null;
      _selectedAttempt = null;
      _recordingDuration = Duration.zero;
    });

    final granted = await _ensureMicrophonePermission();
    if (!granted) {
      return;
    }

    if (_isPlayingAttempt) {
      await _audioPlayer.stop();
    }

    final directory = await getTemporaryDirectory();
    final path =
        '${directory.path}/bantera_attempt_${DateTime.now().millisecondsSinceEpoch}.wav';

    await _deleteCurrentRecordingIfNeeded();

    try {
      await _audioRecorder.start(
        const RecordConfig(
          encoder: AudioEncoder.wav,
          sampleRate: 16000,
          numChannels: 1,
        ),
        path: path,
      );
      _recordingTimer?.cancel();
      _recordingTimer = Timer.periodic(const Duration(seconds: 1), (_) {
        if (!mounted) {
          return;
        }
        setState(() {
          _recordingDuration += const Duration(seconds: 1);
        });
      });
      _autoStopTimer?.cancel();
      _autoStopTimer = Timer(_maxRecordingDuration, () {
        if (mounted && _isRecording) _stopRecordingAndTranscribe();
      });
      setState(() {
        _recordingPath = path;
        _temporaryRecordingPath = path;
        _isRecording = true;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _errorMessage = 'Bantera could not start recording right now.';
        _showsOpenSettingsAction = false;
      });
    }
  }

  Future<void> _stopRecordingAndTranscribe() async {
    _recordingTimer?.cancel();
    _autoStopTimer?.cancel();
    setState(() {
      _isRecording = false;
      _isProcessing = true;
      _errorMessage = null;
    });

    try {
      final path = await _audioRecorder.stop();
      final resolvedPath = path ?? _recordingPath;
      if (resolvedPath == null || resolvedPath.isEmpty) {
        throw const VideoProcessingException(
          code: 'missing_recording',
          message: 'Bantera could not access the recorded audio.',
        );
      }

      final transcription = await VideoProcessingService.instance
          .transcribeRecordedAudio(
            inputFile: File(resolvedPath),
            localeIdentifier: widget.sourceLocaleIdentifier,
          );
      final recognizedText = transcription.transcriptText.trim();
      if (recognizedText.isEmpty) {
        throw const VideoProcessingException(
          code: 'empty_transcript',
          message:
              'No transcript could be generated for this attempt. Try again closer to the microphone.',
        );
      }

      if (!mounted) {
        return;
      }

      final comparison = _buildComparisonResult(
        expectedText: widget.cue.originalText,
        actualText: recognizedText,
      );

      LocalCuePracticeAttempt? savedAttempt;
      String? saveFailureMessage;
      try {
        savedAttempt = await _localPracticeRepository.saveCueAttempt(
          mediaItemId: widget.mediaItemId,
          cueId: widget.cue.id,
          transcriptText: recognizedText,
          sourceLocaleIdentifier: widget.sourceLocaleIdentifier,
          audioPath: resolvedPath,
          matchedCount: comparison.matchedCount,
          unexpectedCount: comparison.unexpectedCount,
          missingCount: comparison.missingCount,
          recordingDurationMs: _recordingDuration.inMilliseconds,
        );
      } on LocalPracticeRepositoryException catch (error) {
        saveFailureMessage = error.message;
      }

      setState(() {
        _recordingPath = savedAttempt?.audioPath ?? resolvedPath;
        _temporaryRecordingPath = savedAttempt == null ? resolvedPath : null;
        _selectedAttempt = savedAttempt;
        _result = comparison;
        _errorMessage = saveFailureMessage;
        _showsOpenSettingsAction = false;
        if (savedAttempt != null) {
          _attemptHistory = [
            savedAttempt,
            ..._attemptHistory.where((attempt) => attempt.id != savedAttempt!.id),
          ];
        }
      });
    } on VideoProcessingException catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _errorMessage = error.message;
        _showsOpenSettingsAction = false;
      });
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  Future<void> _toggleAttemptPlayback() async {
    final path = _recordingPath;
    if (path == null || path.isEmpty) {
      return;
    }

    if (_isPlayingAttempt) {
      await _audioPlayer.pause();
      return;
    }

    await _audioPlayer.play(DeviceFileSource(path));
  }

  Future<void> _resetForRetry() async {
    if (_isPlayingAttempt) {
      await _audioPlayer.stop();
    }
    await _deleteCurrentRecordingIfNeeded();
    if (!mounted) {
      return;
    }
    setState(() {
      _recordingDuration = Duration.zero;
      _errorMessage = null;
      _showsOpenSettingsAction = false;
      _result = null;
      _selectedAttempt = null;
      _recordingPath = null;
      _temporaryRecordingPath = null;
    });
  }

  Future<bool> _ensureMicrophonePermission() async {
    try {
      if (await _audioRecorder.hasPermission()) {
        return true;
      }
    } catch (_) {
      // Fall through to permission_handler for clearer recovery UX.
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

    final message = switch (status) {
      PermissionStatus.permanentlyDenied =>
        'Microphone access is turned off for Bantera. Open iPhone Settings > Bantera > Microphone and enable it to record your own version.',
      PermissionStatus.restricted =>
        'This iPhone is currently restricting microphone access for Bantera. Check Screen Time, device management, or system settings to enable it.',
      _ =>
        'Microphone permission is required to record your own version. If you dismissed the prompt before, open iPhone Settings > Bantera > Microphone and enable it.',
    };

    setState(() {
      _errorMessage = message;
      _showsOpenSettingsAction = true;
    });

    return false;
  }

  Widget _buildSummaryChips(
    BuildContext context,
    _AttemptComparisonResult result,
  ) {
    final theme = Theme.of(context);
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _SummaryChip(
          label: '${result.matchedCount} matched',
          color: Colors.green,
          textStyle: theme.textTheme.labelLarge,
        ),
        _SummaryChip(
          label: '${result.unexpectedCount} different',
          color: Colors.orange,
          textStyle: theme.textTheme.labelLarge,
        ),
        if (result.missingCount > 0)
          _SummaryChip(
            label: '${result.missingCount} missing',
            color: Colors.redAccent,
            textStyle: theme.textTheme.labelLarge,
          ),
      ],
    );
  }

  Widget _buildAttemptHistorySection(BuildContext context) {
    final theme = Theme.of(context);
    if (_isLoadingHistory && _attemptHistory.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Recent attempts', style: theme.textTheme.titleMedium),
          const SizedBox(height: 12),
          const Center(child: CircularProgressIndicator()),
        ],
      );
    }

    if (_attemptHistory.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Recent attempts', style: theme.textTheme.titleMedium),
        const SizedBox(height: 8),
        Text(
          'Bantera keeps your attempts on this iPhone so you can review progress on the same cue.',
          style: theme.textTheme.bodySmall,
        ),
        const SizedBox(height: 16),
        ..._attemptHistory.map((attempt) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _buildAttemptHistoryCard(context, attempt),
          );
        }),
      ],
    );
  }

  Widget _buildAttemptHistoryCard(
    BuildContext context,
    LocalCuePracticeAttempt attempt,
  ) {
    final theme = Theme.of(context);
    final isSelected = _selectedAttempt?.id == attempt.id;

    return Material(
      color: isSelected
          ? BanteraTheme.primaryColor.withValues(alpha: 0.08)
          : BanteraTheme.backgroundLight,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () {
          _selectAttempt(attempt);
        },
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      _formatAttemptTimestamp(attempt.createdAt),
                      style: theme.textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: isSelected
                            ? BanteraTheme.primaryColor
                            : theme.colorScheme.onSurface,
                      ),
                    ),
                  ),
                  if (isSelected)
                    const Padding(
                      padding: EdgeInsets.only(right: 8),
                      child: Icon(
                        CupertinoIcons.check_mark_circled_solid,
                        color: BanteraTheme.primaryColor,
                        size: 18,
                      ),
                    ),
                  IconButton(
                    onPressed: () {
                      unawaited(_playSavedAttempt(attempt));
                    },
                    icon: Icon(
                      _isPlayingAttempt && isSelected
                          ? CupertinoIcons.pause_fill
                          : CupertinoIcons.play_fill,
                    ),
                    tooltip: _isPlayingAttempt && isSelected
                        ? 'Pause attempt'
                        : 'Play attempt',
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _SummaryChip(
                    label: '${attempt.matchedCount} matched',
                    color: Colors.green,
                    textStyle: theme.textTheme.labelMedium,
                  ),
                  _SummaryChip(
                    label: '${attempt.unexpectedCount} different',
                    color: Colors.orange,
                    textStyle: theme.textTheme.labelMedium,
                  ),
                  if (attempt.missingCount > 0)
                    _SummaryChip(
                      label: '${attempt.missingCount} missing',
                      color: Colors.redAccent,
                      textStyle: theme.textTheme.labelMedium,
                    ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                attempt.transcriptText,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _playSavedAttempt(LocalCuePracticeAttempt attempt) async {
    _selectAttempt(attempt);
    await _toggleAttemptPlayback();
  }

  Widget _buildAttemptTranscript(
    BuildContext context,
    _AttemptComparisonResult result,
  ) {
    final baseStyle = Theme.of(
      context,
    ).textTheme.bodyLarge?.copyWith(fontSize: 18);
    final mismatchStyle = baseStyle?.copyWith(
      color: Colors.orange[800],
      fontWeight: FontWeight.bold,
      decoration: TextDecoration.underline,
    );

    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        style: baseStyle,
        children: _buildDiffSpans(
          result.segments,
          baseStyle: baseStyle,
          mismatchStyle: mismatchStyle,
          joinWithSpace: result.joinSegmentsWithSpace,
        ),
      ),
    );
  }

  List<InlineSpan> _buildDiffSpans(
    List<_DiffSegment> segments, {
    required TextStyle? baseStyle,
    required TextStyle? mismatchStyle,
    bool joinWithSpace = true,
  }) {
    final spans = <InlineSpan>[];
    for (var i = 0; i < segments.length; i += 1) {
      final segment = segments[i];
      spans.add(
        TextSpan(
          text: segment.text,
          style: segment.isMatch ? baseStyle : mismatchStyle,
        ),
      );
      if (joinWithSpace && i != segments.length - 1) {
        spans.add(const TextSpan(text: ' '));
      }
    }
    return spans;
  }

  _AttemptComparisonResult _buildComparisonResult({
    required String expectedText,
    required String actualText,
  }) {
    final expectedClean = _stripInvisibleSeparators(expectedText.trim());
    final actualClean = _stripInvisibleSeparators(actualText.trim());
    final useCharacterTokens =
        _containsCjk(expectedClean) || _containsCjk(actualClean);

    final expectedTokens = _tokenize(
      expectedClean,
      useCharacterTokens: useCharacterTokens,
    );
    final actualTokens = _tokenize(
      actualClean,
      useCharacterTokens: useCharacterTokens,
    );

    final expComp = _comparableTokensForLcs(expectedTokens);
    final actComp = _comparableTokensForLcs(actualTokens);
    final lcs = _longestCommonSubsequence(expComp.norms, actComp.norms);

    final matchedActualOriginalIndexes = <int>{};
    for (final pair in lcs) {
      matchedActualOriginalIndexes.add(actComp.sourceIndexes[pair.$2]);
    }

    final segments = <_DiffSegment>[];
    for (var i = 0; i < actualTokens.length; i += 1) {
      final punctOnly = actualTokens[i].normalized.isEmpty;
      segments.add(
        _DiffSegment(
          text: actualTokens[i].display,
          isMatch: punctOnly || matchedActualOriginalIndexes.contains(i),
        ),
      );
    }

    final contentMatches = lcs.length;
    final contentUnexpected = actComp.norms.length - contentMatches;
    final contentMissing = expComp.norms.length - contentMatches;

    return _AttemptComparisonResult(
      transcriptText: actualText,
      segments: segments,
      matchedCount: contentMatches,
      unexpectedCount: contentUnexpected,
      missingCount: contentMissing,
      joinSegmentsWithSpace: !useCharacterTokens,
    );
  }

  List<_DiffToken> _tokenize(
    String text, {
    required bool useCharacterTokens,
  }) {
    if (useCharacterTokens) {
      return Characters(text)
          .map(
            (g) => _DiffToken(
              display: g,
              normalized: _normalizeGraphemeForCompare(g),
            ),
          )
          .toList(growable: false);
    }

    return text
        .trim()
        .split(RegExp(r'\s+'))
        .where((token) => token.trim().isNotEmpty)
        .map((token) => _DiffToken(display: token, normalized: _normalizeToken(token)))
        .toList(growable: false);
  }

  String _normalizeToken(String token) {
    var t = _normalizeConfusableQuotesForTokenCompare(token.trim());
    t = t.toLowerCase();
    t = t.replaceAll(
      RegExp(r'^[\.,!?:;"“”‘’()\[\]{}]+|[\.,!?:;"“”‘’()\[\]{}]+$'),
      '',
    );
    return _stripIgnorableForComparison(t);
  }

  /// Indices in [tokens] where [normalized] is non-empty — used so LCS ignores
  /// punctuation-only units while segments still show the full transcript.
  ({List<String> norms, List<int> sourceIndexes}) _comparableTokensForLcs(
    List<_DiffToken> tokens,
  ) {
    final norms = <String>[];
    final sourceIndexes = <int>[];
    for (var i = 0; i < tokens.length; i += 1) {
      final n = tokens[i].normalized;
      if (n.isEmpty) {
        continue;
      }
      norms.add(n);
      sourceIndexes.add(i);
    }
    return (norms: norms, sourceIndexes: sourceIndexes);
  }

  List<(int, int)> _longestCommonSubsequence(
    List<String> expected,
    List<String> actual,
  ) {
    final rows = expected.length + 1;
    final cols = actual.length + 1;
    final dp = List.generate(rows, (_) => List.filled(cols, 0));

    for (var i = expected.length - 1; i >= 0; i -= 1) {
      for (var j = actual.length - 1; j >= 0; j -= 1) {
        if (expected[i] == actual[j]) {
          dp[i][j] = dp[i + 1][j + 1] + 1;
        } else {
          dp[i][j] = dp[i + 1][j] >= dp[i][j + 1]
              ? dp[i + 1][j]
              : dp[i][j + 1];
        }
      }
    }

    final matches = <(int, int)>[];
    var i = 0;
    var j = 0;
    while (i < expected.length && j < actual.length) {
      if (expected[i] == actual[j]) {
        matches.add((i, j));
        i += 1;
        j += 1;
      } else if (dp[i + 1][j] >= dp[i][j + 1]) {
        i += 1;
      } else {
        j += 1;
      }
    }

    return matches;
  }

  static String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  static String _formatAttemptTimestamp(DateTime dateTime) {
    const monthNames = <String>[
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
    final local = dateTime.toLocal();
    final hour = local.hour % 12 == 0 ? 12 : local.hour % 12;
    final minute = local.minute.toString().padLeft(2, '0');
    final suffix = local.hour >= 12 ? 'PM' : 'AM';
    return '${monthNames[local.month - 1]} ${local.day}, $hour:$minute $suffix';
  }

  Future<void> _deleteCurrentRecordingIfNeeded() async {
    final path = _temporaryRecordingPath;
    if (path == null || path.isEmpty) {
      return;
    }
    await _deleteFileIfExists(path);
    _temporaryRecordingPath = null;
  }

  Future<void> _deleteFileIfExists(String path) async {
    final file = File(path);
    if (await file.exists()) {
      await file.delete();
    }
  }
}

class _SummaryChip extends StatelessWidget {
  const _SummaryChip({
    required this.label,
    required this.color,
    required this.textStyle,
  });

  final String label;
  final Color color;
  final TextStyle? textStyle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: textStyle?.copyWith(
          color: color,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

/// Zero-width / BOM characters that often differ between ASR and stored text.
String _stripInvisibleSeparators(String s) {
  return s.replaceAll(RegExp(r'[\u200B-\u200D\uFEFF\u2060]'), '');
}

/// Whether [s] contains scripts that are not meaningfully split on ASCII spaces.
bool _containsCjk(String s) {
  for (final r in s.runes) {
    if (_isCjkKanaHangulOrFullwidthPunctRune(r)) {
      return true;
    }
  }
  return false;
}

bool _isCjkKanaHangulOrFullwidthPunctRune(int r) {
  return (r >= 0x2E80 && r <= 0x9FFF) ||
      (r >= 0xA960 && r <= 0xA97F) ||
      (r >= 0xAC00 && r <= 0xD7AF) ||
      (r >= 0xF900 && r <= 0xFAFF) ||
      (r >= 0xFE10 && r <= 0xFE19) ||
      (r >= 0xFE30 && r <= 0xFE4F) ||
      (r >= 0xFF00 && r <= 0xFFEF) ||
      (r >= 0x1B000 && r <= 0x1B122) ||
      (r >= 0x20000 && r <= 0x3134F);
}

/// Normalize one user-perceived character for comparison (CJK / mixed scripts).
/// Punctuation and symbols map to empty so they do not affect LCS or counts.
String _normalizeGraphemeForCompare(String grapheme) {
  var t = _normalizeConfusableQuotesForTokenCompare(grapheme);
  t = t.toLowerCase();
  final mapped = _fullwidthToHalfwidthForCompare(t);
  return _stripIgnorableForComparison(mapped.trim());
}

/// Removes characters that should not affect transcript comparison (punctuation,
/// spaces, symbols). Keeps letters, digits, CJK, kana, hangul, and in-word `'` / `-`.
String _stripIgnorableForComparison(String t) {
  if (t.isEmpty) {
    return t;
  }
  final b = StringBuffer();
  for (final g in Characters(t)) {
    if (!_isIgnorableForComparisonGrapheme(g)) {
      b.write(g);
    }
  }
  return b.toString();
}

bool _isIgnorableForComparisonGrapheme(String g) {
  if (g.isEmpty) {
    return true;
  }
  // Contractions and hyphenated words (ASCII and common dash variants).
  if (g == "'" ||
      g == '-' ||
      g == '\u2010' ||
      g == '\u2011' ||
      g == '\u2013') {
    return false;
  }
  for (final r in g.runes) {
    if (_isLetterDigitOrIdeographOrKanaRune(r)) {
      return false;
    }
  }
  return true;
}

bool _isLetterDigitOrIdeographOrKanaRune(int r) {
  // ASCII letters and digits.
  if ((r >= 0x30 && r <= 0x39) ||
      (r >= 0x41 && r <= 0x5A) ||
      (r >= 0x61 && r <= 0x7A)) {
    return true;
  }
  // Latin extended (covers most European languages).
  if ((r >= 0x00C0 && r <= 0x024F) || (r >= 0x1E00 && r <= 0x1EFF)) {
    return true;
  }
  // Greek, Cyrillic.
  if ((r >= 0x0370 && r <= 0x052F) || (r >= 0x0400 && r <= 0x052F)) {
    return true;
  }
  // Arabic, Hebrew.
  if ((r >= 0x0600 && r <= 0x06FF) || (r >= 0x0590 && r <= 0x05FF)) {
    return true;
  }
  // Indic / Southeast Asian scripts (broad block).
  if (r >= 0x0900 && r <= 0x0FFF) {
    return true;
  }
  // Thai, Lao, Khmer, Myanmar.
  if (r >= 0x0E00 && r <= 0x109F) {
    return true;
  }
  // Ethiopic.
  if (r >= 0x1200 && r <= 0x137F) {
    return true;
  }
  // Georgian.
  if (r >= 0x10A0 && r <= 0x10FF) {
    return true;
  }
  // Hangul jamo and syllables.
  if ((r >= 0x1100 && r <= 0x11FF) ||
      (r >= 0x3130 && r <= 0x318F) ||
      (r >= 0xA960 && r <= 0xA97F) ||
      (r >= 0xAC00 && r <= 0xD7AF)) {
    return true;
  }
  // Hiragana, Katakana, Katakana phonetic extensions.
  if ((r >= 0x3040 && r <= 0x30FF) || (r >= 0x31F0 && r <= 0x31FF)) {
    return true;
  }
  // CJK Unified Ideographs and compatibility, extensions.
  if ((r >= 0x2E80 && r <= 0x9FFF) ||
      (r >= 0xF900 && r <= 0xFAFF) ||
      (r >= 0x20000 && r <= 0x3134F)) {
    return true;
  }
  // Combining marks (treated as content when paired with letters in one grapheme).
  if (r >= 0x0300 && r <= 0x036F) {
    return true;
  }
  return false;
}

const _cjkPunctMap = <String, String>{
  '，': ',',
  '。': '.',
  '、': ',',
  '．': '.',
  '？': '?',
  '！': '!',
  '：': ':',
  '；': ';',
  '（': '(',
  '）': ')',
  '【': '[',
  '】': ']',
  '「': '"',
  '」': '"',
  '『': '"',
  '』': '"',
  '《': '<',
  '》': '>',
  '〈': '<',
  '〉': '>',
  '…': '.',
  '—': '-',
  '–': '-',
  '・': '.',
  '·': '.',
};

String _fullwidthToHalfwidthForCompare(String t) {
  if (t.isEmpty) return t;
  final b = StringBuffer();
  for (final ch in Characters(t)) {
    if (ch.length == 1) {
      final c = ch.codeUnitAt(0);
      if (c >= 0xFF01 && c <= 0xFF5E) {
        b.writeCharCode(c - 0xFEE0);
        continue;
      }
      if (c == 0x3000) {
        b.write(' ');
        continue;
      }
    }
    b.write(_cjkPunctMap[ch] ?? ch);
  }
  return b.toString();
}

/// Maps typographic / fullwidth apostrophes and common curly quotes to ASCII so
/// transcript tokens like `i've` and recognition `I've` (U+2019) still match.
String _normalizeConfusableQuotesForTokenCompare(String input) {
  var s = input.replaceAll(
    RegExp(r"[\u2018\u2019\u201B\u0060\u00B4\u02BC\u02BB\uFF07\u2032]"),
    "'",
  );
  s = s.replaceAll(
    RegExp(r'[\u201C\u201D\u201E\u00AB\u00BB]'),
    '"',
  );
  return s;
}

class _AttemptComparisonResult {
  const _AttemptComparisonResult({
    required this.transcriptText,
    required this.segments,
    required this.matchedCount,
    required this.unexpectedCount,
    required this.missingCount,
    this.joinSegmentsWithSpace = true,
  });

  final String transcriptText;
  final List<_DiffSegment> segments;
  final int matchedCount;
  final int unexpectedCount;
  final int missingCount;

  /// False for CJK character-level diff — inserting spaces would break Chinese.
  final bool joinSegmentsWithSpace;
}

class _DiffSegment {
  const _DiffSegment({required this.text, required this.isMatch});

  final String text;
  final bool isMatch;
}

class _DiffToken {
  const _DiffToken({required this.display, required this.normalized});

  final String display;
  final String normalized;
}
