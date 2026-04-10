import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../domain/models/models.dart';
import '../../infrastructure/local_practice_repository.dart';
import '../../l10n/app_localizations.dart';
import 'attempt_comparison.dart';

/// Bottom sheet: saved attempts for the current cue (no recording UI).
class RecordCompareSheet extends StatefulWidget {
  const RecordCompareSheet({
    super.key,
    required this.scrollController,
    required this.mediaItemId,
    required this.cue,
    required this.sourceLocaleIdentifier,
  });

  /// From [DraggableScrollableSheet] so the sheet can be dragged to dismiss
  /// while the inner list scrolls when content is tall (e.g. attempt history).
  final ScrollController scrollController;

  final String mediaItemId;
  final Cue cue;
  final String sourceLocaleIdentifier;

  @override
  State<RecordCompareSheet> createState() => _RecordCompareSheetState();
}

class _RecordCompareSheetState extends State<RecordCompareSheet> {
  late final AudioPlayer _audioPlayer;
  StreamSubscription<PlayerState>? _playerStateSub;

  final LocalPracticeRepository _localPracticeRepository =
      LocalPracticeRepository.instance;

  bool _isPlayingAttempt = false;
  bool _isLoadingHistory = true;
  AttemptComparisonResult? _result;
  LocalCuePracticeAttempt? _selectedAttempt;
  List<LocalCuePracticeAttempt> _attemptHistory = const [];
  String? _playbackPath;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    _playerStateSub = _audioPlayer.onPlayerStateChanged.listen((state) {
      if (!mounted) return;
      setState(() {
        _isPlayingAttempt = state == PlayerState.playing;
      });
    });
    unawaited(_loadAttemptHistory());
  }

  @override
  void dispose() {
    unawaited(_playerStateSub?.cancel());
    unawaited(_audioPlayer.dispose());
    super.dispose();
  }

  Future<void> _loadAttemptHistory() async {
    try {
      final attempts = await _localPracticeRepository.fetchCueAttempts(
        mediaItemId: widget.mediaItemId,
        cueId: widget.cue.id,
      );
      if (!mounted) return;

      setState(() {
        _attemptHistory = attempts;
        _isLoadingHistory = false;
      });

      if (attempts.isNotEmpty) {
        _selectAttempt(attempts.first);
      }
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isLoadingHistory = false;
      });
    }
  }

  void _selectAttempt(LocalCuePracticeAttempt attempt) {
    if (!mounted) return;

    setState(() {
      _selectedAttempt = attempt;
      _playbackPath = attempt.audioPath;
      _result = buildAttemptComparison(
        expectedText: widget.cue.originalText,
        actualText: attempt.transcriptText,
      );
    });
  }

  Future<void> _playSavedAttempt(LocalCuePracticeAttempt attempt) async {
    _selectAttempt(attempt);
    await _toggleAttemptPlayback();
  }

  Future<void> _toggleAttemptPlayback() async {
    final path = _playbackPath;
    if (path == null || path.isEmpty) return;

    if (_isPlayingAttempt) {
      await _audioPlayer.pause();
      return;
    }

    await _audioPlayer.play(DeviceFileSource(path));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          controller: widget.scrollController,
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                l10n.practiceRecords,
                style: theme.textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: colorScheme.outlineVariant),
                ),
                child: Text(
                  widget.cue.originalText,
                  style: theme.textTheme.bodyLarge?.copyWith(fontSize: 18),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                l10n.compareTranscriptionLanguage(widget.sourceLocaleIdentifier),
                style: theme.textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              if (_isLoadingHistory && _attemptHistory.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (_attemptHistory.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Text(
                    l10n.practiceRecordsEmpty,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                )
              else ...[
                Text(
                  l10n.compareRecentAttempts,
                  style: theme.textTheme.titleMedium,
                ),
                const SizedBox(height: 16),
                ..._attemptHistory.map((attempt) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _AttemptHistoryCard(
                      attempt: attempt,
                      isSelected: _selectedAttempt?.id == attempt.id,
                      isPlaying:
                          _isPlayingAttempt && _selectedAttempt?.id == attempt.id,
                      timestampLabel: _formatAttemptTimestamp(attempt.createdAt),
                      l10n: l10n,
                      onSelect: () => _selectAttempt(attempt),
                      onPlay: () => unawaited(_playSavedAttempt(attempt)),
                    ),
                  );
                }),
              ],
              if (_result != null && _selectedAttempt != null) ...[
                const SizedBox(height: 20),
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
                          _isPlayingAttempt
                              ? l10n.comparePauseAttempt
                              : l10n.comparePlayAttempt,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _SummaryChipsRow(l10n: l10n, result: _result!),
                const SizedBox(height: 18),
                Text(
                  l10n.compareYourTranscribedAttempt,
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
                  child: _AttemptTranscriptRichText(result: _result!),
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
                        l10n.compareHighlightHint,
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
              ],
              const SizedBox(height: 28),
              Text(
                l10n.practiceRecordsLocalOnlyFooter,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
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
}

class _AttemptHistoryCard extends StatelessWidget {
  const _AttemptHistoryCard({
    required this.attempt,
    required this.isSelected,
    required this.isPlaying,
    required this.timestampLabel,
    required this.l10n,
    required this.onSelect,
    required this.onPlay,
  });

  final LocalCuePracticeAttempt attempt;
  final bool isSelected;
  final bool isPlaying;
  final String timestampLabel;
  final AppLocalizations l10n;
  final VoidCallback onSelect;
  final VoidCallback onPlay;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: isSelected
          ? theme.colorScheme.primary.withValues(alpha: 0.08)
          : theme.colorScheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onSelect,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      timestampLabel,
                      style: theme.textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: isSelected
                            ? theme.colorScheme.primary
                            : theme.colorScheme.onSurface,
                      ),
                    ),
                  ),
                  if (isSelected)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Icon(
                        CupertinoIcons.check_mark_circled_solid,
                        color: theme.colorScheme.primary,
                        size: 18,
                      ),
                    ),
                  IconButton(
                    onPressed: onPlay,
                    icon: Icon(
                      isPlaying
                          ? CupertinoIcons.pause_fill
                          : CupertinoIcons.play_fill,
                    ),
                    tooltip: isPlaying
                        ? l10n.comparePauseAttemptTooltip
                        : l10n.comparePlayAttemptTooltip,
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _SummaryChip(
                    label: l10n.compareMatchedCount(attempt.matchedCount),
                    color: Colors.green,
                    textStyle: theme.textTheme.labelMedium,
                  ),
                  _SummaryChip(
                    label: l10n.compareDifferentCount(attempt.unexpectedCount),
                    color: Colors.orange,
                    textStyle: theme.textTheme.labelMedium,
                  ),
                  if (attempt.missingCount > 0)
                    _SummaryChip(
                      label: l10n.compareMissingCount(attempt.missingCount),
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
}

class _SummaryChipsRow extends StatelessWidget {
  const _SummaryChipsRow({
    required this.l10n,
    required this.result,
  });

  final AppLocalizations l10n;
  final AttemptComparisonResult result;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _SummaryChip(
          label: l10n.compareMatchedCount(result.matchedCount),
          color: Colors.green,
          textStyle: theme.textTheme.labelLarge,
        ),
        _SummaryChip(
          label: l10n.compareDifferentCount(result.unexpectedCount),
          color: Colors.orange,
          textStyle: theme.textTheme.labelLarge,
        ),
        if (result.missingCount > 0)
          _SummaryChip(
            label: l10n.compareMissingCount(result.missingCount),
            color: Colors.redAccent,
            textStyle: theme.textTheme.labelLarge,
          ),
      ],
    );
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

class _AttemptTranscriptRichText extends StatelessWidget {
  const _AttemptTranscriptRichText({required this.result});

  final AttemptComparisonResult result;

  @override
  Widget build(BuildContext context) {
    final baseStyle = Theme.of(
      context,
    ).textTheme.bodyLarge?.copyWith(fontSize: 18);
    final mismatchStyle = baseStyle?.copyWith(
      color: Colors.orange[800],
      fontWeight: FontWeight.bold,
      decoration: TextDecoration.underline,
    );

    final spans = <InlineSpan>[];
    for (var i = 0; i < result.segments.length; i += 1) {
      final segment = result.segments[i];
      spans.add(
        TextSpan(
          text: segment.text,
          style: segment.isMatch ? baseStyle : mismatchStyle,
        ),
      );
      if (result.joinSegmentsWithSpace && i != result.segments.length - 1) {
        spans.add(const TextSpan(text: ' '));
      }
    }

    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(style: baseStyle, children: spans),
    );
  }
}
