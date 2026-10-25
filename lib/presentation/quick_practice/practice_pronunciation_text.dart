import 'package:flutter/material.dart';
import '../practice/subtitle_word_tokens.dart';
import 'practice_word_text.dart';
import 'practice_word_boundaries.dart';

/// Aligned ruby-like readings. Original sentence offsets still drive word taps.
class PracticePronunciationText extends StatefulWidget {
  const PracticePronunciationText(
    this.text, {
    super.key,
    required this.segments,
    this.locale = '',
    this.style,
    this.textDirection,
    this.selectedWord,
    required this.onSelect,
    required this.onWord,
  });
  final String text;
  final String locale;
  final List<dynamic> segments;
  final TextStyle? style;
  final TextDirection? textDirection;
  final SubtitleWordToken? selectedWord;
  final ValueChanged<SubtitleWordToken> onSelect, onWord;
  @override
  State<PracticePronunciationText> createState() =>
      _PracticePronunciationTextState();
}

class _PracticePronunciationTextState extends State<PracticePronunciationText> {
  List<SubtitleWordToken> _tokens = [];
  int _generation = 0;

  @override
  void initState() {
    super.initState();
    _resolve();
  }

  @override
  void didUpdateWidget(PracticePronunciationText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.text != widget.text || oldWidget.locale != widget.locale) {
      _resolve();
    }
  }

  void _resolve() {
    final generation = ++_generation;
    _tokens = practiceWordFallback(widget.text);
    PracticeWordBoundaries.resolve(widget.text, widget.locale).then((tokens) {
      if (!mounted || generation != _generation) return;
      setState(() => _tokens = tokens);
    });
  }

  @override
  Widget build(BuildContext context) {
    final text = widget.text;
    final segments = widget.segments;
    final style = widget.style;
    final textDirection = widget.textDirection;
    final onSelect = widget.onSelect;
    final onWord = widget.onWord;
    // A user may tap before native boundaries arrive. Expand that selection
    // to the containing word so the next tap still confirms the same word.
    final original = widget.selectedWord;
    final selectedWord = original == null
        ? null
        : _tokens
              .where((t) => t.start <= original.start && t.end > original.start)
              .firstOrNull;
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
        words: _tokens,
        onSelect: onSelect,
        onWord: onWord,
      );
    }
    final tokens = _tokens;
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
                      words: tokens
                          .where((t) => t.start < offset && t.end > start)
                          .map((t) {
                            final a = (t.start - start).clamp(0, source.length);
                            final b = (t.end - start).clamp(0, source.length);
                            return SubtitleWordToken(
                              a,
                              b,
                              source.substring(a, b),
                            );
                          })
                          .toList(),
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
