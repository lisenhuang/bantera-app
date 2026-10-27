import 'package:app/infrastructure/learning_language_catalog.dart';
import 'package:app/presentation/shared/learning_language_label.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'multiple accents show the selected conventional locale and country flag',
    () {
      expect(goalLearningLanguageLabel('EN_us'), 'English(en-US 🇺🇸)');
      expect(goalLearningLanguageLabel('en-NZ'), 'English(en-NZ 🇳🇿)');
      expect(goalLearningLanguageLabel('fr-CA'), 'French(fr-CA 🇨🇦)');
      expect(goalLearningLanguageLabel('pt-BR'), 'Portuguese(pt-BR 🇧🇷)');
      expect(goalLearningLanguageLabel('nl-BE'), 'Dutch(nl-BE 🇧🇪)');
      expect(goalLearningLanguageLabel('ar-SA'), 'Arabic(ar-SA 🇸🇦)');
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
    expect(goalLearningLanguageLabel('zh-CN'), 'Mandarin(zh-CN 🇨🇳)');
    expect(goalLearningLanguageLabel('zh-TW'), 'Mandarin(zh-TW 🇹🇼)');
    expect(goalLearningLanguageLabel('zh-HK'), 'Cantonese(zh-HK 🇭🇰)');
    expect(goalLearningLanguageLabel('yue-CN'), 'Cantonese(yue-CN 🇨🇳)');
  });

  test(
    'legacy accent identifiers remain normalized and missing languages stay hidden',
    () {
      expect(goalLearningLanguageLabel('fr'), 'French(fr-FR 🇫🇷)');
      expect(goalLearningLanguageLabel(null), '');
      expect(goalLearningLanguageLabel(''), '');
      expect(goalLearningLanguageLabel('unknown-ZZ'), '');
    },
  );

  test('Maori profile label includes its name and New Zealand flag', () {
    expect(goalLearningLanguageLabel('mi-NZ'), 'Māori 🇳🇿');
    expect(goalLearningLanguageLabel('MI_nz'), 'Māori 🇳🇿');
  });

  test('share label stays language-only', () {
    expect(learningLanguageLabel('en-US'), (name: 'English', flag: '🇺🇸'));
  });
}
