import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../domain/models/models.dart';
import '../../l10n/app_localizations.dart';

/// Shared content for Discover lessons and the user's own audio details.
class LessonDetailsBody extends StatefulWidget {
  const LessonDetailsBody({
    super.key,
    required this.mediaItem,
    required this.creatorAvatar,
    required this.onStartPractice,
    this.creatorName,
    this.isPrivate = false,
    this.resolution,
    this.isTranscribing = false,
    this.transcriptionError,
  });

  final MediaItem mediaItem;
  final Widget creatorAvatar;
  final String? creatorName;
  final VoidCallback onStartPractice;
  final bool isPrivate;
  final String? resolution;
  final bool isTranscribing;
  final String? transcriptionError;

  @override
  State<LessonDetailsBody> createState() => _LessonDetailsBodyState();
}

class _LessonDetailsBodyState extends State<LessonDetailsBody> {
  bool _transcriptExpanded = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context)!;
    final media = widget.mediaItem;
    final hasCover = media.coverUrl.trim().isNotEmpty;
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            color: colorScheme.surface,
            border: Border.all(
              color: colorScheme.outline.withValues(alpha: 0.12),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: !hasCover
                      ? LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            colorScheme.primary.withValues(alpha: 0.16),
                            colorScheme.tertiary.withValues(alpha: 0.14),
                          ],
                        )
                      : null,
                  image: hasCover
                      ? DecorationImage(
                          image: CachedNetworkImageProvider(media.coverUrl),
                          fit: BoxFit.cover,
                          colorFilter: ColorFilter.mode(
                            Colors.black.withValues(alpha: 0.45),
                            BlendMode.darken,
                          ),
                        )
                      : null,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (!hasCover) ...[
                      Icon(
                        media.isAudioOnly
                            ? Icons.audiotrack_rounded
                            : Icons.ondemand_video_rounded,
                        size: 42,
                        color: colorScheme.primary,
                      ),
                      const SizedBox(height: 18),
                    ] else
                      const SizedBox(height: 8),
                    Text(
                      media.title,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        color: hasCover ? Colors.white : null,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        if (widget.isPrivate)
                          _MetaChip(
                            label: l10n.createPrivateBadge,
                            icon: Icons.lock_outline,
                          ),
                        _MetaChip(
                          label: media.spokenLanguage,
                          icon: Icons.translate_outlined,
                        ),
                        _MetaChip(
                          label: l10n.createVideoMetaCues(media.cues.length),
                          icon: Icons.subtitles_outlined,
                        ),
                        _MetaChip(
                          label: _formatDuration(media.durationMs),
                          icon: Icons.schedule_outlined,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  widget.creatorAvatar,
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      widget.creatorName ?? media.creator.displayName,
                      style: theme.textTheme.titleMedium,
                    ),
                  ),
                  if (media.createdAt != null)
                    Text(
                      _formatDateLabel(context, media.createdAt!),
                      style: theme.textTheme.bodySmall,
                    ),
                ],
              ),
              const SizedBox(height: 20),
              if (widget.resolution != null)
                _InfoRow(
                  label: l10n.uploadedDetailResolution,
                  value: widget.resolution!,
                ),
              _InfoRow(
                label: l10n.mediaTranscript,
                value: media.accent.isEmpty
                    ? media.spokenLanguage
                    : '${media.spokenLanguage} · ${media.accent.toUpperCase()}',
              ),
            ],
          ),
        ),

        // Transcription status banner
        if (widget.isTranscribing) ...[
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              color: colorScheme.primaryContainer.withValues(alpha: 0.5),
            ),
            child: Row(
              children: [
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    l10n.uploadedDetailTranscribing,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onPrimaryContainer,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ] else if (widget.transcriptionError != null) ...[
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              color: colorScheme.errorContainer.withValues(alpha: 0.5),
            ),
            child: Text(
              widget.transcriptionError!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onErrorContainer,
              ),
            ),
          ),
        ],

        const SizedBox(height: 18),
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: widget.isTranscribing || media.cues.isEmpty
                ? null
                : widget.onStartPractice,
            icon: const Icon(Icons.headphones_rounded),
            label: Text(l10n.mediaStartPractice),
          ),
        ),
        const SizedBox(height: 18),
        // Transcript section – collapsed by default
        InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: () =>
              setState(() => _transcriptExpanded = !_transcriptExpanded),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                Expanded(
                  child: Wrap(
                    spacing: 6,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(
                        l10n.mediaTranscript,
                        style: theme.textTheme.titleLarge,
                      ),
                      if (media.cues.isNotEmpty)
                        Text(
                          '(${l10n.createVideoMetaCues(media.cues.length)})',
                          style: theme.textTheme.bodySmall,
                        ),
                    ],
                  ),
                ),
                Icon(
                  _transcriptExpanded
                      ? Icons.keyboard_arrow_up_rounded
                      : Icons.keyboard_arrow_down_rounded,
                  color: colorScheme.primary,
                ),
                const SizedBox(width: 2),
                Text(
                  _transcriptExpanded ? l10n.mediaHide : l10n.mediaShow,
                  style: TextStyle(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
        if (_transcriptExpanded) ...[
          const SizedBox(height: 12),
          if (media.cues.isEmpty)
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                color: colorScheme.surface,
                border: Border.all(
                  color: colorScheme.outline.withValues(alpha: 0.12),
                ),
              ),
              child: Text(l10n.uploadedDetailNoTranscriptCuesYet),
            )
          else
            ...media.cues.asMap().entries.map((entry) {
              final cue = entry.value;
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  color: colorScheme.surface,
                  border: Border.all(
                    color: colorScheme.outline.withValues(alpha: 0.1),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${entry.key + 1}. ${_formatCueRange(cue)}',
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(cue.originalText, style: theme.textTheme.bodyLarge),
                  ],
                ),
              );
            }),
        ],
      ],
    );
  }

  static String _formatDuration(int durationMs) {
    final totalSeconds = (durationMs / 1000).round();
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  String _formatDateLabel(BuildContext context, DateTime value) {
    return DateFormat.yMMMd(
      Localizations.localeOf(context).toString(),
    ).format(value.toLocal());
  }

  static String _formatCueRange(Cue cue) {
    return '${_formatTimestamp(cue.startTimeMs)} - ${_formatTimestamp(cue.endTimeMs)}';
  }

  static String _formatTimestamp(int milliseconds) {
    final totalSeconds = milliseconds ~/ 1000;
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({required this.label, required this.icon});

  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: colorScheme.surface.withValues(alpha: 0.8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: colorScheme.primary),
          const SizedBox(width: 8),
          Text(label, style: Theme.of(context).textTheme.labelLarge),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          SizedBox(
            width: 104,
            child: Text(
              label,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
