import 'package:app/infrastructure/ai/ai_spoken_words.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/services.dart';

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
  TestWidgetsFlutterBinding.ensureInitialized();
  const channel = MethodChannel('bantera/ai_audio');
  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  test(
    'counts clear English despite uncertain greetings and short windows',
    () async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (call) async {
            expect(call.method, 'identifyLanguages');
            return (call.arguments as List).map((text) {
              // Representative Apple Natural Language results, reproduced locally.
              if (text == 'Hi') return evidence('ca', .803, tags: ['ca']);
              if (text == 'practise speaking English') {
                return evidence('en', .563);
              }
              return evidence('en', .999, tags: ['en']);
            }).toList();
          });
      expect(
        await AiSpokenWords.count('Hi, I went shopping today.', 'en-NZ'),
        5,
      );
      expect(
        await AiSpokenWords.count(
          'I would like to practise speaking English with you today.',
          'en-NZ',
        ),
        10,
      );
    },
  );

  test(
    'rejects the entire mixed message even with a confident English majority',
    () async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
            channel,
            (call) async => (call.arguments as List)
                .map(
                  (text) => text == 'quiero comprar pan'
                      ? evidence('es', .99, tags: ['es'])
                      : evidence('en', .99, tags: ['en']),
                )
                .toList(),
          );
      expect(
        await AiSpokenWords.count(
          'I went shopping today. quiero comprar pan',
          'en-NZ',
        ),
        0,
      );
    },
  );

  test('unavailable local detection gives no guessed credit', () async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          channel,
          (_) async => throw PlatformException(code: 'unavailable'),
        );
    expect(await AiSpokenWords.count('I went shopping today.', 'en-NZ'), 0);
  });

  test('requires confident context and rejects detected foreign language', () {
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
  });
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
