import 'package:flutter/material.dart';

/// Keep controls above the timeline so it can use the entire bubble width.
class ChatAudioHeader extends StatelessWidget {
  const ChatAudioHeader({
    super.key,
    required this.playing,
    required this.progress,
    required this.onPlay,
    this.duration,
    this.playTooltip,
    this.trailing,
  });

  final bool playing;
  final double progress;
  final VoidCallback? onPlay;
  final String? duration, playTooltip;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            IconButton.filled(
              tooltip: playTooltip,
              onPressed: onPlay,
              icon: Icon(
                playing ? Icons.pause_rounded : Icons.play_arrow_rounded,
              ),
            ),
            if (duration != null) ...[
              const SizedBox(width: 8),
              Flexible(
                child: Text(duration!, style: theme.textTheme.bodySmall),
              ),
            ],
            const Spacer(),
            ?trailing,
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(99),
          child: LinearProgressIndicator(
            value: progress.clamp(0.0, 1.0),
            minHeight: 6,
            backgroundColor: theme.colorScheme.outlineVariant,
            color: theme.colorScheme.primary,
          ),
        ),
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
