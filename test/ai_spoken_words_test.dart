import 'package:app/infrastructure/ai/ai_spoken_words.dart';
import 'package:flutter_test/flutter_test.dart';

Map<String, dynamic> evidence(
  String language,
  double confidence, {
  List<String> tags = const [],
}) => {
  'hypotheses': [
    {'language': language, 'confidence': confidence},
  ],
  'languages': tags,
};

void main() {
  test(
    'accepts only confident target-language evidence for every fragment',
    () {
      expect(
        AiSpokenWords.accepts(
          [evidence('en', .99), evidence('en-US', .96)],
          2,
          'en',
        ),
        isTrue,
      );
      expect(
        AiSpokenWords.accepts(
          [evidence('en', .99), evidence('zh-Hans', .99)],
          2,
          'en',
        ),
        isFalse,
      );
      expect(
        AiSpokenWords.accepts(
          [
            evidence('en', .99, tags: ['en', 'fr']),
          ],
          1,
          'en',
        ),
        isFalse,
      );
      expect(AiSpokenWords.accepts([evidence('en', .6)], 1, 'en'), isFalse);
      expect(AiSpokenWords.accepts([evidence('en', .99)], 2, 'en'), isFalse);
      expect(AiSpokenWords.accepts(null, 1, 'en'), isFalse);
      expect(
        AiSpokenWords.accepts([evidence('zh-Hant', .99)], 1, 'yue'),
        isFalse,
      );
    },
  );
  test(
    'checks separate languages within an utterance and rejects short ambiguity',
    () {
      final probes = AiSpokenWords.languageProbes(
        'I went shopping today. 今天我去了超市。',
      );
      expect(probes, contains('今天我去了超市'));
      expect(probes, contains('I went shopping'));
      expect(AiSpokenWords.languageProbes('yes'), isEmpty);
      expect(AiSpokenWords.languageProbes('OK thanks'), isEmpty);
    },
  );
}
