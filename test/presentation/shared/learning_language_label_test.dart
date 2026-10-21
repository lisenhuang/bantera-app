import 'package:app/infrastructure/learning_language_catalog.dart';
import 'package:app/presentation/shared/learning_language_label.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'multiple accents show the selected lowercase locale and country flag',
    () {
      expect(goalLearningLanguageLabel('EN_us'), 'English(en-us 🇺🇸)');
      expect(goalLearningLanguageLabel('en-NZ'), 'English(en-nz 🇳🇿)');
      expect(goalLearningLanguageLabel('fr-CA'), 'French(fr-ca 🇨🇦)');
      expect(goalLearningLanguageLabel('pt-BR'), 'Portuguese(pt-br 🇧🇷)');
      expect(goalLearningLanguageLabel('nl-BE'), 'Dutch(nl-be 🇧🇪)');
      expect(goalLearningLanguageLabel('ar-SA'), 'Arabic(ar-sa 🇸🇦)');
    },
  );

  test('single-accent languages omit the code', () {
    expect(goalLearningLanguageLabel('ja-JP'), 'Japanese 🇯🇵');
    expect(goalLearningLanguageLabel('ja'), 'Japanese 🇯🇵');
    expect(goalLearningLanguageLabel('ko-KR'), 'Korean 🇰🇷');
    expect(goalLearningLanguageLabel('fi-FI'), 'Finnish 🇫🇮');
    expect(goalLearningLanguageLabel('hi-IN'), 'Hindi 🇮🇳');
  });

  test(
    'Latin American Spanish retains its code without a globe or country flag',
    () {
      expect(goalLearningLanguageLabel('es-419'), 'Spanish(es-419)');
      for (final locale in kFallbackLearningLanguages) {
        expect(
          goalLearningLanguageLabel(locale.identifier),
          isNot(matches(RegExp('[🌍🌎🌏🌐]', unicode: true))),
        );
      }
    },
  );

  test('Mandarin and Cantonese accents are counted separately', () {
    expect(goalLearningLanguageLabel('zh-CN'), 'Mandarin(zh-cn 🇨🇳)');
    expect(goalLearningLanguageLabel('zh-TW'), 'Mandarin(zh-tw 🇹🇼)');
    expect(goalLearningLanguageLabel('zh-HK'), 'Cantonese(zh-hk 🇭🇰)');
    expect(goalLearningLanguageLabel('yue-CN'), 'Cantonese(yue-cn 🇨🇳)');
  });

  test(
    'legacy accent identifiers remain normalized and missing languages stay hidden',
    () {
      expect(goalLearningLanguageLabel('fr'), 'French(fr-fr 🇫🇷)');
      expect(goalLearningLanguageLabel(null), '');
      expect(goalLearningLanguageLabel(''), '');
      expect(goalLearningLanguageLabel('unknown-ZZ'), '');
    },
  );

  test('share label stays language-only', () {
    expect(learningLanguageLabel('en-US'), (name: 'English', flag: '🇺🇸'));
  });
}
