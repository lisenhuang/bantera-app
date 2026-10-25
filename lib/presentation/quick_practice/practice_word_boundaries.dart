import 'package:flutter/services.dart';
import 'package:characters/characters.dart';
import '../practice/subtitle_word_tokens.dart';

/// Selection boundaries only. Subtitle/audio timing keeps its own tokenizer.
class PracticeWordBoundaries {
  static const channel = MethodChannel('bantera/word_boundaries');
  static final _word = RegExp(r'[\p{L}\p{N}]', unicode: true);

  static Future<List<SubtitleWordToken>> resolve(
    String text,
    String locale,
  ) async {
    final fallback = practiceWordFallback(text);
    if (text.isEmpty || locale.isEmpty) return fallback;
    try {
      final result = await channel.invokeListMethod<dynamic>('tokenize', {
        'text': text,
        'locale': locale,
      });
      if (result == null || result.isEmpty) return fallback;
      final boundaries = <int>{0};
      var offset = 0;
      for (final cluster in text.characters) {
        offset += cluster.length;
        boundaries.add(offset);
      }
      final tokens = <SubtitleWordToken>[];
      var end = 0;
      for (final entry in result) {
        if (entry is! Map) return fallback;
        final a = entry['start'], b = entry['end'];
        if (a is! int ||
            b is! int ||
            a < end ||
            b <= a ||
            !boundaries.contains(a) ||
            !boundaries.contains(b) ||
            _word.hasMatch(text.substring(end, a))) {
          return fallback;
        }
        final source = text.substring(a, b);
        if (!_word.hasMatch(source)) return fallback;
        tokens.add(SubtitleWordToken(a, b, source));
        end = b;
      }
      if (_word.hasMatch(text.substring(end))) return fallback;
      return tokens;
    } on MissingPluginException {
      return fallback;
    } on PlatformException {
      return fallback;
    }
  }
}

/// Retain readable character selection if the OS cannot segment this language.
/// Expand the existing tokens to graphemes so vowel marks are never separated.
List<SubtitleWordToken> practiceWordFallback(String text) {
  final clusters = <({int start, int end})>[];
  var offset = 0;
  for (final cluster in text.characters) {
    clusters.add((start: offset, end: offset + cluster.length));
    offset += cluster.length;
  }
  final words = <SubtitleWordToken>[];
  for (final token in subtitleWordTokens(text)) {
    final a = clusters.firstWhere((c) => c.end > token.start).start;
    final b = clusters.lastWhere((c) => c.start < token.end).end;
    if (words.isNotEmpty && a < words.last.end) {
      final previous = words.removeLast();
      words.add(
        SubtitleWordToken(previous.start, b, text.substring(previous.start, b)),
      );
    } else {
      words.add(SubtitleWordToken(a, b, text.substring(a, b)));
    }
  }
  return words;
}
