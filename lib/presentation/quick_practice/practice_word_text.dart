import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import '../practice/subtitle_word_tokens.dart';

/// Preserves the original sentence layout and punctuation. CJK selections may
/// be characters; the full sentence and exact range travel with the request.
class PracticeWordText extends StatefulWidget {
  const PracticeWordText(
    this.text, {
    super.key,
    this.style,
    this.textDirection,
    required this.onWord,
    required this.onSelect,
    this.selectedWord,
  });
  final String text;
  final TextStyle? style;
  final TextDirection? textDirection;
  final void Function(SubtitleWordToken token) onWord;
  final void Function(SubtitleWordToken token) onSelect;
  final SubtitleWordToken? selectedWord;
  @override
  State<PracticeWordText> createState() => _PracticeWordTextState();
}

class _PracticeWordTextState extends State<PracticeWordText> {
  final _recognizers = <TapGestureRecognizer>[];
  List<InlineSpan> _spans = [];
  @override
  void initState() {
    super.initState();
    _update();
  }

  @override
  void didUpdateWidget(PracticeWordText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.text != widget.text ||
        oldWidget.selectedWord != widget.selectedWord) {
      _update();
    }
  }

  void _update() {
    for (final recognizer in _recognizers) {
      recognizer.dispose();
    }
    _recognizers.clear();
    _spans = [];
    var offset = 0;
    for (final token in subtitleWordTokens(widget.text)) {
      if (token.start > offset) {
        _spans.add(TextSpan(text: widget.text.substring(offset, token.start)));
      }
      final selected = widget.selectedWord;
      final isSelected =
          selected?.start == token.start &&
          selected?.end == token.end &&
          selected?.text == token.text;
      final recognizer = TapGestureRecognizer()
        ..onTap = () =>
            isSelected ? widget.onWord(token) : widget.onSelect(token);
      _recognizers.add(recognizer);
      _spans.add(
        TextSpan(
          text: token.text,
          style: isSelected
              ? const TextStyle(
                  decoration: TextDecoration.underline,
                  decorationThickness: 2,
                )
              : null,
          recognizer: recognizer,
          mouseCursor: SystemMouseCursors.click,
        ),
      );
      offset = token.end;
    }
    if (offset < widget.text.length) {
      _spans.add(TextSpan(text: widget.text.substring(offset)));
    }
  }

  @override
  void dispose() {
    for (final recognizer in _recognizers) {
      recognizer.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Text.rich(
    TextSpan(children: _spans),
    textDirection: widget.textDirection,
    style: widget.style,
  );
}
