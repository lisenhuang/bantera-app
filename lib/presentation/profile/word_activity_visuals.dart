import 'package:flutter/material.dart';

Color activityColor(BuildContext context, {required bool listening}) {
  final dark = Theme.of(context).brightness == Brightness.dark;
  return listening
      ? (dark ? const Color(0xFF62DDC2) : const Color(0xFF087F68))
      : Theme.of(context).colorScheme.primary;
}

class ActivityIcon extends StatelessWidget {
  const ActivityIcon({super.key, required this.listening, this.size = 36});
  final bool listening;
  final double size;

  @override
  Widget build(BuildContext context) {
    final color = activityColor(context, listening: listening);
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withValues(alpha: .10),
        borderRadius: BorderRadius.circular(size * .32),
      ),
      child: Icon(
        listening ? Icons.headphones_outlined : Icons.mic_none_outlined,
        size: size * .58,
        color: color,
      ),
    );
  }
}
