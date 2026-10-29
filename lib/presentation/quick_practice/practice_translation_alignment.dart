import 'package:flutter/material.dart';
import '../practice/subtitle_word_tokens.dart';

final _alignmentWord = RegExp(
  r"[\p{L}\p{M}\p{N}]+(?:['’ʼ][\p{L}\p{M}\p{N}]+)*",
  unicode: true,
);

bool _validRange(String text, dynamic start, dynamic end, dynamic exact) {
  if (start is! int ||
      end is! int ||
      exact is! String ||
      start < 0 ||
      end <= start ||
      end > text.length ||
      text.substring(start, end) != exact)
    return false;
  // Both runtimes use UTF-16. Reject mid-word/mid-surrogate offsets rather
  // than underlining a plausible but incorrect fragment from stale data.
  for (final offset in [start, end]) {
    if (offset > 0 &&
        offset < text.length &&
        text.codeUnitAt(offset) >= 0xDC00 &&
        text.codeUnitAt(offset) <= 0xDFFF &&
        text.codeUnitAt(offset - 1) >= 0xD800 &&
        text.codeUnitAt(offset - 1) <= 0xDBFF)
      return false;
  }
  return !_alignmentWord
      .allMatches(text)
      .any(
        (m) =>
            (m.start < start && m.end > start) ||
            (m.start < end && m.end > end),
      );
}

/// Only server-provided links against the exact visible sentence are used.
/// A Māori word can map to an English phrase or several non-adjacent spans.
List<TextRange> practiceTranslationHighlights({
  required String source,
  required String target,
  required Object? alignments,
  required SubtitleWordToken? selected,
}) {
  if (selected == null ||
      alignments is! List ||
      alignments.length > 256 ||
      !_validRange(source, selected.start, selected.end, selected.text))
    return const [];
  final ranges = <TextRange>[];
  for (final value in alignments) {
    if (value is! Map ||
        !_validRange(
          source,
          value['sourceStart'],
          value['sourceEnd'],
          value['sourceText'],
        ) ||
        !_validRange(
          target,
          value['targetStart'],
          value['targetEnd'],
          value['targetText'],
        ))
      continue;
    if (value['sourceStart'] <= selected.start &&
        value['sourceEnd'] >= selected.end) {
      ranges.add(
        TextRange(start: value['targetStart'], end: value['targetEnd']),
      );
    }
  }
  ranges.sort((a, b) => a.start.compareTo(b.start));
  final merged = <TextRange>[];
  for (final range in ranges) {
    if (merged.isNotEmpty && range.start <= merged.last.end) {
      final previous = merged.removeLast();
      merged.add(
        TextRange(
          start: previous.start,
          end: range.end > previous.end ? range.end : previous.end,
        ),
      );
    } else {
      merged.add(range);
    }
  }
  return merged;
}

List<TextSpan> practiceTranslationSpans(
  String text,
  List<TextRange> highlights,
) {
  final spans = <TextSpan>[];
  var offset = 0;
  for (final range in highlights) {
    if (range.start > offset)
      spans.add(TextSpan(text: text.substring(offset, range.start)));
    spans.add(
      TextSpan(
        text: text.substring(range.start, range.end),
        style: const TextStyle(
          fontWeight: FontWeight.w700,
          decoration: TextDecoration.underline,
          decorationThickness: 2,
        ),
      ),
    );
    offset = range.end;
  }
  if (offset < text.length) spans.add(TextSpan(text: text.substring(offset)));
  return spans;
}
