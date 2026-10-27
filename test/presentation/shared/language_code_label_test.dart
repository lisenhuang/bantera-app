import 'package:app/presentation/shared/language_code_label.dart';
import 'package:app/presentation/chats/chat_language_label.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'display casing preserves languages, regions, scripts and extensions',
    () {
      const cases = {
        'en-nz': 'en-NZ',
        ' EN_us ': 'en-US',
        'ZH-cn': 'zh-CN',
        'zh_hk': 'zh-HK',
        'MI_nz': 'mi-NZ',
        'zh-hANT-tw': 'zh-Hant-TW',
        'es-419': 'es-419',
        'DE-de-u-CO-PHONEBK': 'de-DE-u-co-phonebk',
        'en-x-TEST': 'en-x-test',
        'JA': 'ja',
        '': '',
      };
      for (final entry in cases.entries) {
        expect(languageCodeLabel(entry.key), entry.value);
      }
      expect(chatLanguageLabel('en_nz'), 'en-NZ 🇳🇿');
      expect(chatLanguageLabel('mi-nz'), 'mi-NZ 🇳🇿');
      expect(chatLanguageLabel(null), isNull);
      expect(chatLanguageLabel(''), isNull);
    },
  );
}
