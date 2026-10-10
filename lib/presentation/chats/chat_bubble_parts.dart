import 'package:flutter/material.dart';
import 'chat_audio_waveform.dart';

/// Keep audio actions on one row and give the timeline all remaining width.
class ChatAudioHeader extends StatelessWidget {
  const ChatAudioHeader({
    super.key,
    required this.playing,
    required this.progress,
    required this.onPlay,
    this.duration,
    this.playTooltip,
    this.trailing,
    this.receiving = false,
    this.audioKey,
    this.loadAudioPath,
  });

  final String? audioKey;
  final Future<String> Function()? loadAudioPath;
  final bool playing;
  final bool receiving;
  final double progress;
  final VoidCallback? onPlay;
  final String? duration, playTooltip;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        IconButton.filled(
          tooltip: playTooltip,
          onPressed: onPlay,
          icon: Icon(
            receiving
                ? Icons.graphic_eq
                : playing
                ? Icons.pause_rounded
                : Icons.play_arrow_rounded,
          ),
        ),
        if (duration != null) ...[
          const SizedBox(width: 4),
          Text(
            duration!,
            style: theme.textTheme.bodySmall,
            textScaler: MediaQuery.textScalerOf(
              context,
            ).clamp(maxScaleFactor: 1.6),
          ),
        ],
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: ChatAudioWaveform(
              progress: progress,
              receiving: receiving,
              audioKey: audioKey,
              loadAudioPath: loadAudioPath,
            ),
          ),
        ),
        ?trailing,
      ],
    );
  }
}

class ChatMessageTimestamp extends StatelessWidget {
  const ChatMessageTimestamp({super.key, required this.sentAt});
  final DateTime sentAt;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 8),
    child: Align(
      alignment: Alignment.bottomRight,
      child: Text(
        _formatTimestamp(sentAt.toLocal()),
        textAlign: TextAlign.right,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
    ),
  );
}

String _formatTimestamp(DateTime time) {
  final hour = time.hour.toString().padLeft(2, '0');
  final minute = time.minute.toString().padLeft(2, '0');
  final timeStr = '$hour:$minute';
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final msgDay = DateTime(time.year, time.month, time.day);
  final diff = today.difference(msgDay).inDays;
  if (diff == 0) return timeStr;
  if (diff > 0 && diff < 7) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return '${days[time.weekday - 1]} $timeStr';
  }
  const months = [
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
  return '${time.day} ${months[time.month - 1]} $timeStr';
}
