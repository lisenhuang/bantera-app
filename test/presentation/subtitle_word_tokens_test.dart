import 'package:app/presentation/practice/subtitle_word_tokens.dart';
import 'package:flutter_test/flutter_test.dart';

List<String> _texts(String s) =>
    subtitleWordTokens(s).map((t) => t.text).toList();

void main() {
  test('keeps the word pattern for spaced languages', () {
    expect(_texts("Hey! Don't be late, it's 7:30."), [
      'Hey',
      "Don't",
      'be',
      'late',
      "it's",
      '7',
      '30',
    ]);
    expect(_texts('안녕하세요 친구'), ['안녕하세요', '친구']);
  });

  test('splits Chinese into characters, keeping offsets into the text', () {
    const text = '你好，我的iPhone。';
    final tokens = subtitleWordTokens(text);
    expect(tokens.map((t) => t.text), ['你', '好', '我', '的', 'iPhone']);
    for (final t in tokens) {
      expect(text.substring(t.start, t.end), t.text);
    }
  });

  test('joins small kana and the long-vowel mark to the previous character', () {
    expect(_texts('きょうはコーヒー'), ['きょ', 'う', 'は', 'コー', 'ヒー']);
  });

  test('handles characters outside the basic plane', () {
    const text = '𠮷野家';
    final tokens = subtitleWordTokens(text);
    expect(tokens.map((t) => t.text), ['𠮷', '野', '家']);
    expect(tokens.first.end, 2);
  });

  test('subtitleWordKey keeps letters of every script', () {
    expect(subtitleWordKey('Café!'), 'café');
    expect(subtitleWordKey('吧。'), '吧');
    expect(subtitleWordKey('こんにちは'), 'こんにちは');
  });
}
