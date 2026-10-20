import 'package:app/infrastructure/learning_language_catalog.dart';
import 'package:app/infrastructure/transcription_locale_option.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TranscriptionLocaleOption option(String code) => TranscriptionLocaleOption(
    identifier: code,
    displayName: code,
    isInstalled: true,
  );
  test('retired Māori is excluded from every picker source', () {
    final options = ['mi', 'mi-NZ', 'MI_nz', 'en-NZ'].map(option);
    for (final native in [true, false]) {
      expect(
        availableProfileLanguages(
          options,
          nativeLanguage: native,
        ).map((o) => o.identifier),
        ['en-NZ'],
      );
    }
    expect(
      kFallbackLearningLanguages.any((o) => o.identifier == 'mi-NZ'),
      isFalse,
    );
  });
  test('mainland Cantonese is hidden only from native choices', () {
    final options = ['yue-CN', 'YUE_cn', 'zh-HK', 'zh-CN', 'en-NZ'].map(option);
    expect(
      availableProfileLanguages(
        options,
        nativeLanguage: true,
      ).map((o) => o.identifier),
      ['zh-HK', 'zh-CN', 'en-NZ'],
    );
    expect(availableProfileLanguages(options).map((o) => o.identifier), [
      'yue-CN',
      'YUE_cn',
      'zh-HK',
      'zh-CN',
      'en-NZ',
    ]);
  });
  test(
    'retired audio generation is blocked without affecting other languages',
    () {
      expect(supportsAudioDialogueLanguage('mi-NZ'), isFalse);
      expect(supportsAudioDialogueLanguage('en-NZ'), isTrue);
      expect(supportsAudioDialogueLanguage('yue-CN'), isTrue);
      expect(supportsAudioDialogueLanguage('zh-HK'), isTrue);
    },
  );
}
