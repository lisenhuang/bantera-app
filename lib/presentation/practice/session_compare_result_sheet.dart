import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../domain/models/models.dart';
import '../../l10n/app_localizations.dart';
import 'attempt_comparison.dart';

/// Bottom sheet shown after inline recording stops: comparison only (no history).
class SessionCompareResultSheet extends StatefulWidget {
  const SessionCompareResultSheet({
    super.key,
    required this.scrollController,
    required this.cue,
    required this.sourceLocaleIdentifier,
    required this.result,
    required this.audioPath,
    this.saveErrorMessage,
    required this.onTryAgain,
  });

  final ScrollController scrollController;
  final Cue cue;
  final String sourceLocaleIdentifier;
  final AttemptComparisonResult result;
  final String audioPath;
  final String? saveErrorMessage;
  final VoidCallback onTryAgain;

  @override
  State<SessionCompareResultSheet> createState() =>
      _SessionCompareResultSheetState();
}

class _SessionCompareResultSheetState extends State<SessionCompareResultSheet> {
  late final AudioPlayer _audioPlayer;
  StreamSubscription<PlayerState>? _playerStateSub;
  bool _isPlayingAttempt = false;

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
  }

  @override
  void dispose() {
    unawaited(_playerStateSub?.cancel());
    unawaited(_audioPlayer.dispose());
    super.dispose();
  }

  Future<void> _togglePlayback() async {
    if (_isPlayingAttempt) {
      await _audioPlayer.pause();
      return;
    }
    await _audioPlayer.play(DeviceFileSource(widget.audioPath));
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
                l10n.compareRecordYourVersion,
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
              if (widget.saveErrorMessage != null) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.orange.withValues(alpha: 0.25),
                    ),
                  ),
                  child: Text(
                    widget.saveErrorMessage!,
                    style: theme.textTheme.bodyMedium,
                  ),
                ),
              ],
              const SizedBox(height: 28),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _togglePlayback,
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
              _SummaryChipsRow(l10n: l10n, result: widget.result),
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
                child: _AttemptTranscriptRichText(result: widget.result),
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
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                        widget.onTryAgain();
                      },
                      child: Text(l10n.compareTryAgain),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text(l10n.compareDone),
                    ),
                  ),
                ],
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
