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
      SubtitleWordToken? selected;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) => PracticeWordText(
                sample.$1,
                selectedWord: selected,
                onSelect: (word) => setState(() => selected = word),
                onWord: (word) => tapped = word,
              ),
            ),
          ),
        ),
      );
      expect(find.text(sample.$1), findsOneWidget);
      await tester.tapOnText(find.textRange.ofSubstring(sample.$2));
      await tester.pump();
      expect(tapped, isNull);
      expect(selected?.text, sample.$2);
      final rich =
          tester.widget<Text>(find.text(sample.$1)).textSpan! as TextSpan;
      final underlined = rich.children!.cast<TextSpan>().where(
        (span) => span.style?.decoration == TextDecoration.underline,
      );
      expect(underlined.single.text, sample.$2);
      expect(underlined.single.style?.fontWeight, FontWeight.w700);
      expect(underlined.single.style?.backgroundColor, isNull);
      expect(underlined.single.style?.background, isNull);
      await tester.tapOnText(find.textRange.ofSubstring(sample.$2));
      expect(tapped?.text, sample.$2);
      expect(tapped?.start, sample.$3);
      expect(sample.$1.substring(tapped!.start, tapped!.end), sample.$2);
      await tester.pumpWidget(const SizedBox());
      expect(tester.takeException(), isNull);
    });
  }
}
