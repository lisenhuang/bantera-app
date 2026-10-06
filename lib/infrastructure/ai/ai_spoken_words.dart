import 'package:flutter/services.dart';
import '../../domain/activity/listening_word_tracker.dart';
import '../../domain/activity/word_activity.dart';

/// Conservative transcript-based estimate. A mixed or uncertain utterance
/// earns no credit, rather than counting just its target-language fragments.
class AiSpokenWords {
  static const _channel = MethodChannel('bantera/ai_audio');

  static Future<int> count(String text, String learningLanguage) async {
    final probes = languageProbes(text);
    final target = wordActivityLanguageKey(learningLanguage);
    if (probes.isEmpty || target.isEmpty) return 0;
    try {
      final evidence = await _channel
          .invokeListMethod<dynamic>('identifyLanguages', probes)
          .timeout(const Duration(seconds: 10));
      if (!accepts(evidence, probes.length, target)) return 0;
      return activityWordCount(text);
    } catch (_) {
      return 0; // No guess or cloud fallback when local detection is unavailable.
    }
  }

  static List<String> languageProbes(String text) {
    final clean = text.trim();
    final words = clean.split(RegExp(r'\s+'));
    if (clean.length < 8 ||
        clean.length > 4000 ||
        activityWordCount(clean) < 3 ||
        words.length > 200) {
      return [];
    }
    final probes = <String>{clean};
    // Check every clause; a different-language clause rejects the whole message.
    for (final clause in clean.split(RegExp(r'[.!?。！？;；,，\n]+'))) {
      if (clause.trim().isNotEmpty) probes.add(clause.trim());
    }
    // Short overlapping windows help expose code-switching within a sentence.
    for (var i = 0; i + 3 <= words.length; i += 2) {
      probes.add(words.sublist(i, i + 3).join(' '));
    }
    if (words.length > 3) probes.add(words.sublist(words.length - 3).join(' '));
    return probes.toList();
  }

  static bool accepts(List<dynamic>? evidence, int expected, String target) {
    if (evidence == null || evidence.length != expected || expected == 0) {
      return false;
    }
    for (final item in evidence) {
      if (item is! Map) return false;
      final hypotheses = item['hypotheses'];
      if (hypotheses is! List || hypotheses.isEmpty) return false;
      final ranked = hypotheses.whereType<Map>().toList()
        ..sort(
          (a, b) => ((b['confidence'] as num?) ?? 0).compareTo(
            (a['confidence'] as num?) ?? 0,
          ),
        );
      if (ranked.isEmpty ||
          wordActivityLanguageKey(ranked.first['language']?.toString()) !=
              target ||
          ((ranked.first['confidence'] as num?) ?? 0) < 0.85) {
        return false;
      }
      // iOS additionally supplies context-aware word-level language tags.
      final tags = item['languages'];
      if (tags is List &&
          tags.any(
            (tag) => wordActivityLanguageKey(tag.toString()) != target,
          )) {
        return false;
      }
    }
    return true;
  }
}
