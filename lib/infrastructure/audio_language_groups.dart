import 'learning_language_catalog.dart';
import 'transcription_locale_option.dart';

String audioLanguageGroupCode(String identifier) {
  final code = normalizeLocaleIdentifierForLookup(identifier);
  if (code == 'zh-hk' ||
      code == 'zh-hant-hk' ||
      code == 'yue' ||
      code.startsWith('yue-')) {
    return 'yue';
  }
  if (code == 'zh-tw' || code == 'zh-hant-tw') {
    return 'zh-tw';
  }
  if (code == 'zh' || code.startsWith('zh-')) {
    return 'zh-cn';
  }
  return code.split('-').first;
}

class AudioLanguageGroup {
  const AudioLanguageGroup(this.code, this.name, this.flagEmoji, this.count);
  final String code;
  final String name;
  final String flagEmoji;
  final int count;
}

List<AudioLanguageGroup> groupAudioLanguages(
  Iterable<TranscriptionLocaleOption> entries,
) {
  final members = <String, List<TranscriptionLocaleOption>>{};
  for (final entry in entries) {
    members
        .putIfAbsent(audioLanguageGroupCode(entry.identifier), () => [])
        .add(entry);
  }
  return members.entries.map((entry) {
    final code = entry.key;
    final name = switch (code) {
      'yue' => 'Cantonese',
      'zh-cn' => 'Mandarin (Mainland China)',
      'zh-tw' => 'Mandarin (Taiwan)',
      _ => entry.value.first.displayName.split(' (').first,
    };
    final flags = [
      ...kFallbackLearningLanguages.where(
        (locale) => audioLanguageGroupCode(locale.identifier) == code,
      ),
      ...entry.value,
    ].map((locale) => locale.flagEmoji ?? '🌐').toSet();
    final flag = switch (code) {
      'yue' => '🇭🇰',
      'zh-cn' => '🇨🇳',
      'zh-tw' => '🇹🇼',
      _ => flags.length > 1 ? '🌐' : flags.first,
    };
    return AudioLanguageGroup(code, name, flag, entry.value.length);
  }).toList()..sort((a, b) => b.count.compareTo(a.count));
}
