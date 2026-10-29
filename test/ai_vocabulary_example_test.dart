import 'package:app/presentation/chats/ai/ai_vocabulary_example.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  for (final brightness in Brightness.values) {
    testWidgets(
      'vocabulary example uses bold underline without fill in $brightness',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            theme: ThemeData(brightness: brightness),
            home: const Scaffold(
              body: VocabularyExample(
                word: 'take off',
                example: 'We take off soon.',
              ),
            ),
          ),
        );
        final text = tester.widget<Text>(find.byType(Text).first);
        final span = text.textSpan! as TextSpan;
        final match = span.children!.cast<TextSpan>().singleWhere(
          (span) => span.text == 'take off',
        );
        expect(match.style?.fontWeight, FontWeight.w700);
        expect(match.style?.decoration, TextDecoration.underline);
        expect(match.style?.backgroundColor, isNull);
        expect(match.style?.background, isNull);
        expect(
          match.style?.color,
          isNull,
          reason: 'Keep inherited readable text colour.',
        );
        expect(text.semanticsLabel, 'We take off soon.');
      },
    );
  }
}
