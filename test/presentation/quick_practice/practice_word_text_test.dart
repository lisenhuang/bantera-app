import 'package:app/presentation/quick_practice/practice_word_text.dart';
import 'package:app/presentation/practice/subtitle_word_tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  for (final sample in [
    ('Where’s the bank?', 'Where’s', 0),
    ('銀行在哪裡？', '行', 1),
    ('銀行はどこですか？', '行', 1),
    ('은행은 어디에 있나요?', '어디에', 4),
  ]) {
    testWidgets('tap selects ${sample.$2} without changing sentence layout', (
      tester,
    ) async {
      SubtitleWordToken? tapped;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PracticeWordText(sample.$1, onWord: (word) => tapped = word),
          ),
        ),
      );
      expect(find.text(sample.$1), findsOneWidget);
      await tester.tapOnText(find.textRange.ofSubstring(sample.$2));
      expect(tapped?.text, sample.$2);
      expect(tapped?.start, sample.$3);
      expect(sample.$1.substring(tapped!.start, tapped!.end), sample.$2);
      await tester.pumpWidget(const SizedBox());
      expect(tester.takeException(), isNull);
    });
  }
}
