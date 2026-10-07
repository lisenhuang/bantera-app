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
      for (var offset = 0; offset < probes.length; offset += 200) {
        final batch = probes.sublist(
          offset,
          (offset + 200).clamp(0, probes.length),
        );
        final evidence = await _channel
            .invokeListMethod<dynamic>('identifyLanguages', batch)
            .timeout(const Duration(seconds: 10));
        if (!accepts(
          evidence,
          batch.length,
          target,
          requireTargetAtStart: offset == 0,
        )) {
          return 0;
        }
      }
      return activityWordCount(text);
    } catch (_) {
      return 0; // No guess or cloud fallback when local detection is unavailable.
    }
  }

  static List<String> languageProbes(String text) {
    final clean = text.trim();
    final words = clean.split(RegExp(r'\s+'));
    if (clean.length < 8 ||
        clean.length > 12000 ||
        activityWordCount(clean) < 3) {
      return [];
    }
    // Keep a substantial context first. Tiny clauses such as "Hi" cannot
    // independently establish the language of an otherwise clear utterance.
    final probes = <String>{clean.substring(0, clean.length.clamp(0, 4000))};
    // Check every clause; a different-language clause rejects the whole message.
    for (final clause in clean.split(RegExp(r'[.!?。！？;；,，\n]+'))) {
      if (clause.trim().isNotEmpty && clause.trim().length <= 4000) {
        probes.add(clause.trim());
      }
    }
    // Short overlapping windows help expose code-switching within a sentence.
    for (var i = 0; i + 3 <= words.length; i += 2) {
      probes.add(words.sublist(i, i + 3).join(' '));
    }
    if (words.length > 3) probes.add(words.sublist(words.length - 3).join(' '));
    return probes.toList();
  }

  static bool accepts(
    List<dynamic>? evidence,
    int expected,
    String target, {
    bool requireTargetAtStart = true,
  }) {
    if (evidence == null || evidence.length != expected || expected == 0) {
      return false;
    }
    for (var index = 0; index < evidence.length; index++) {
      final item = evidence[index];
      if (item is! Map) return false;
      final hypotheses = item['hypotheses'];
      if (hypotheses is! List || hypotheses.isEmpty) return false;
      final ranked = hypotheses.whereType<Map>().toList()
        ..sort(
          (a, b) => ((b['confidence'] as num?) ?? 0).compareTo(
            (a['confidence'] as num?) ?? 0,
          ),
        );
      if (ranked.isEmpty) return false;
      final best = ranked.first;
      final confident = ((best['confidence'] as num?) ?? 0) >= 0.85;
      final matches =
          wordActivityLanguageKey(best['language']?.toString()) == target;
      final isContext = requireTargetAtStart && index == 0;
      // Require positive evidence for the complete utterance. For short
      // fragments, uncertainty is not evidence that the user switched language.
      if (isContext && (!confident || !matches)) return false;
      if (confident && !matches) return false;
      // Whole-context tags can expose mixed speech even when its dominant
      // language is the target. Fragment tags lack that disambiguating context.
      final tags = item['languages'];
      if (isContext &&
          tags is List &&
          tags.any(
            (tag) => wordActivityLanguageKey(tag.toString()) != target,
          )) {
        return false;
      }
    }
    return true;
  }
}
