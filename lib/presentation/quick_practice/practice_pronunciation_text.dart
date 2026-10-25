import 'package:flutter/material.dart';
import '../practice/subtitle_word_tokens.dart';
import 'practice_word_text.dart';

/// Aligned ruby-like readings. Original sentence offsets still drive word taps.
class PracticePronunciationText extends StatelessWidget {
  const PracticePronunciationText(
    this.text, {
    super.key,
    required this.segments,
    this.style,
    this.textDirection,
    this.selectedWord,
    required this.onSelect,
    required this.onWord,
  });
  final String text;
  final List<dynamic> segments;
  final TextStyle? style;
  final TextDirection? textDirection;
  final SubtitleWordToken? selectedWord;
  final ValueChanged<SubtitleWordToken> onSelect, onWord;
  @override
  Widget build(BuildContext context) {
    final valid =
        segments.isNotEmpty &&
        segments.every(
          (p) => p is Map && p['text'] is String && p['reading'] is String,
        ) &&
        segments.map((p) => p['text']).join() == text;
    if (!valid) {
      return PracticeWordText(
        text,
        style: style,
        textDirection: textDirection,
        selectedWord: selectedWord,
        onSelect: onSelect,
        onWord: onWord,
      );
    }
    final tokens = subtitleWordTokens(text);
    return LayoutBuilder(
      builder: (context, constraints) {
        var offset = 0;
        final children = <Widget>[];
        for (final p in segments) {
          final source = p['text'] as String, reading = p['reading'] as String;
          final start = offset;
          offset += source.length;
          SubtitleWordToken whole(SubtitleWordToken part) => tokens.firstWhere(
            (t) => t.start <= start + part.start && t.end > start + part.start,
            orElse: () => SubtitleWordToken(
              start + part.start,
              start + part.end,
              part.text,
            ),
          );
          final selected = selectedWord;
          final localSelected =
              selected != null &&
                  selected.start < offset &&
                  selected.end > start
              ? SubtitleWordToken(
                  (selected.start - start).clamp(0, source.length),
                  (selected.end - start).clamp(0, source.length),
                  source.substring(
                    (selected.start - start).clamp(0, source.length),
                    (selected.end - start).clamp(0, source.length),
                  ),
                )
              : null;
          children.add(
            ConstrainedBox(
              constraints: BoxConstraints(maxWidth: constraints.maxWidth),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: reading.isEmpty ? 0 : 1,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      reading.isEmpty ? ' ' : reading,
                      textDirection: TextDirection.ltr,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        height: 1.2,
                      ),
                    ),
                    PracticeWordText(
                      source,
                      style: style,
                      textDirection: textDirection,
                      selectedWord: localSelected,
                      onSelect: (t) => onSelect(whole(t)),
                      onWord: (t) => onWord(whole(t)),
                    ),
                  ],
                ),
              ),
            ),
          );
        }
        return Wrap(
          textDirection: textDirection,
          crossAxisAlignment: WrapCrossAlignment.end,
          runSpacing: 6,
          children: children,
        );
      },
    );
  }
}
