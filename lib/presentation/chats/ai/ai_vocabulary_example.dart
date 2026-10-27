import 'package:flutter/material.dart';

/// Highlight literal occurrences, never regex syntax from user vocabulary.
/// Avoid matching Latin substrings ("he" in "the"); continuous-script words
/// can appear without surrounding whitespace.
List<TextSpan> vocabularyExampleSpans(
  String example,
  String word,
  TextStyle highlight,
) {
  final needle = word.trim();
  if (needle.isEmpty) return [TextSpan(text: example)];
  final matches = RegExp(
    RegExp.escape(needle),
    caseSensitive: false,
    unicode: true,
  ).allMatches(example);
  final latin = RegExp(r'[A-Za-zÀ-ÖØ-öø-ÿ0-9]');
  final spans = <TextSpan>[];
  var start = 0;
  for (final match in matches) {
    if (latin.hasMatch(needle[0]) &&
        match.start > 0 &&
        latin.hasMatch(example[match.start - 1])) {
      continue;
    }
    if (latin.hasMatch(needle[needle.length - 1]) &&
        match.end < example.length &&
        latin.hasMatch(example[match.end])) {
      continue;
    }
    if (match.start > start) {
      spans.add(TextSpan(text: example.substring(start, match.start)));
    }
    spans.add(
      TextSpan(
        text: example.substring(match.start, match.end),
        style: highlight,
      ),
    );
    start = match.end;
  }
  if (start < example.length) {
    spans.add(TextSpan(text: example.substring(start)));
  }
  return spans;
}

class VocabularyExample extends StatelessWidget {
  const VocabularyExample({
    super.key,
    required this.word,
    required this.example,
  });
  final String word, example;
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Text.rich(
      TextSpan(
        children: vocabularyExampleSpans(
          example,
          word,
          TextStyle(
            fontWeight: FontWeight.w700,
            color: theme.colorScheme.onPrimaryContainer,
            backgroundColor: theme.colorScheme.primaryContainer,
          ),
        ),
      ),
      style: theme.textTheme.bodyLarge,
      semanticsLabel: example,
    );
  }
}
