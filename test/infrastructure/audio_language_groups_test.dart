import 'package:app/infrastructure/audio_language_groups.dart';
import 'package:app/infrastructure/transcription_locale_option.dart';
import 'package:flutter_test/flutter_test.dart';

TranscriptionLocaleOption locale(String code, String name, String flag) =>
    TranscriptionLocaleOption(
      identifier: code,
      displayName: name,
      isInstalled: false,
      flagEmoji: flag,
    );

void main() {
  test('Cantonese accents share a Hong Kong group and counts', () {
    final groups = groupAudioLanguages([
      locale('zh-HK', 'Cantonese (Hong Kong)', '🇭🇰'),
      locale('yue-CN', 'Cantonese (China mainland)', '🇨🇳'),
      locale('ZH_HK', 'Cantonese (Hong Kong)', '🇭🇰'),
    ]);
    expect(groups.length, 1);
    expect(groups.single.code, 'yue');
    expect(groups.single.name, 'Cantonese');
    expect(groups.single.flagEmoji, '🇭🇰');
    expect(groups.single.count, 3);
  });

  test(
    'multi-country languages use a globe, even when only one accent has audio',
    () {
      final groups = groupAudioLanguages([
        locale('en-NZ', 'English (New Zealand)', '🇳🇿'),
        locale('fr-CA', 'French (Canada)', '🇨🇦'),
        locale('ja-JP', 'Japanese', '🇯🇵'),
      ]);
      expect(groups.firstWhere((g) => g.code == 'en').flagEmoji, '🌐');
      expect(groups.firstWhere((g) => g.code == 'fr').flagEmoji, '🌐');
      expect(groups.firstWhere((g) => g.code == 'ja').flagEmoji, '🇯🇵');
    },
  );

  test(
    'Mainland and Taiwan Chinese stay separate from each other and Cantonese',
    () {
      final groups = groupAudioLanguages([
        locale('zh', 'Chinese', '🇨🇳'),
        locale('zh-CN', 'Chinese (China mainland)', '🇨🇳'),
        locale('zh-TW', 'Chinese (Taiwan)', '🇹🇼'),
        locale('zh-HK', 'Cantonese (Hong Kong)', '🇭🇰'),
      ]);
      expect(groups.map((g) => g.code).toSet(), {'zh-cn', 'zh-tw', 'yue'});
      expect(groups.firstWhere((g) => g.code == 'zh-cn').count, 2);
      expect(groups.firstWhere((g) => g.code == 'zh-cn').flagEmoji, '🇨🇳');
      expect(groups.firstWhere((g) => g.code == 'zh-tw').flagEmoji, '🇹🇼');
      expect(
        groups.firstWhere((g) => g.code == 'zh-tw').name,
        'Mandarin (Taiwan)',
      );
    },
  );

  test(
    'all accent spellings select the same group and empty audio lists stay empty',
    () {
      expect(
        audioLanguageGroupCode(' en_US '),
        audioLanguageGroupCode('en-NZ'),
      );
      expect(
        audioLanguageGroupCode('zh-hant-hk'),
        audioLanguageGroupCode('yue-CN'),
      );
      expect(audioLanguageGroupCode('zh-Hant-TW'), 'zh-tw');
      expect(groupAudioLanguages([]), isEmpty);
    },
  );
}
