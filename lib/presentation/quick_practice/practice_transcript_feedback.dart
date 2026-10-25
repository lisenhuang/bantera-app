import 'package:flutter/material.dart';
import '../../domain/practice/practice_transcript_comparison.dart';
import '../../l10n/app_localizations.dart';

class PracticeTranscriptFeedback extends StatelessWidget {
  const PracticeTranscriptFeedback({
    super.key,
    required this.transcript,
    required this.choices,
    required this.locale,
    this.choice,
    this.textEquivalent = false,
    this.onReplay,
    this.replayEnabled = true,
    this.replaying = false,
    this.replayPaused = false,
    this.replayLoading = false,
    this.uncertainWords = const [],
  });
  final String transcript, locale;
  final List<String> choices, uncertainWords;
  final int? choice;
  final bool textEquivalent;
  final VoidCallback? onReplay;
  final bool replayEnabled, replaying, replayPaused, replayLoading;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!,
        theme = Theme.of(context),
        c = theme.colorScheme;
    final diff = PracticeTranscriptComparison.compare(
      transcript,
      choices,
      locale,
      matchedChoice: choice,
      textEquivalent: textEquivalent,
      uncertainWords: uncertainWords,
    );
    final highlighted = diff.heard.isNotEmpty || diff.reference.isNotEmpty;
    final direction =
        const ['ar', 'he', 'fa', 'ur'].contains(locale.split('-').first)
        ? TextDirection.rtl
        : TextDirection.ltr;
    Widget label(String text) => Text(
      text,
      style: theme.textTheme.labelLarge?.copyWith(color: c.onSurfaceVariant),
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 14),
        label(l.quickHeard),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: c.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: c.outlineVariant),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: transcript.trim().isEmpty
                    ? Text(
                        l.compareNoTranscriptGenerated,
                        style: theme.textTheme.bodyMedium,
                      )
                    : _highlightedText(
                        context,
                        transcript,
                        diff.heard,
                        direction,
                        'practice-heard-text',
                      ),
              ),
              if (onReplay != null) ...[
                const SizedBox(width: 8),
                IconButton.filledTonal(
                  key: const ValueKey('practice-replay-recording'),
                  tooltip: replaying
                      ? l.quickPauseAudio
                      : replayPaused
                      ? l.quickResumeAudio
                      : l.comparePlayAttempt,
                  onPressed: replayEnabled ? onReplay : null,
                  icon: replayLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Icon(
                          replaying
                              ? Icons.pause_rounded
                              : Icons.play_arrow_rounded,
                        ),
                  constraints: const BoxConstraints(
                    minWidth: 48,
                    minHeight: 48,
                  ),
                ),
              ],
            ],
          ),
        ),
        if (diff.choice != null && highlighted) ...[
          const SizedBox(height: 14),
          label(l.quickCompareReply),
          const SizedBox(height: 8),
          _highlightedText(
            context,
            choices[diff.choice!],
            diff.reference,
            direction,
            'practice-reference-text',
          ),
        ],
        const SizedBox(height: 10),
        Text(
          highlighted ? l.quickDifferenceHint : l.quickRecognitionNote,
          style: theme.textTheme.bodySmall?.copyWith(
            color: c.onSurfaceVariant,
            height: 1.4,
          ),
        ),
      ],
    );
  }

  Widget _highlightedText(
    BuildContext context,
    String text,
    List<TranscriptRange> ranges,
    TextDirection direction,
    String key,
  ) {
    final theme = Theme.of(context), c = theme.colorScheme;
    final dark = theme.brightness == Brightness.dark;
    final boundaries = {
      0,
      text.length,
      for (final r in ranges) ...[r.start, r.end],
    }.toList()..sort();
    return Text.rich(
      TextSpan(
        children: [
          for (var i = 0; i < boundaries.length - 1; i++)
            TextSpan(
              text: text.substring(boundaries[i], boundaries[i + 1]),
              style:
                  ranges.any(
                    (r) =>
                        r.start <= boundaries[i] && r.end >= boundaries[i + 1],
                  )
                  ? TextStyle(
                      backgroundColor: dark
                          ? const Color(0xFF59431C)
                          : const Color(0xFFFFE8B5),
                      color: dark
                          ? const Color(0xFFFFE3A3)
                          : const Color(0xFF654400),
                      decoration: TextDecoration.underline,
                      fontWeight: FontWeight.w700,
                    )
                  : null,
            ),
        ],
      ),
      key: ValueKey(key),
      textDirection: direction,
      semanticsLabel: text,
      style: theme.textTheme.bodyLarge?.copyWith(
        color: c.onSurface,
        height: 1.65,
      ),
    );
  }
}
