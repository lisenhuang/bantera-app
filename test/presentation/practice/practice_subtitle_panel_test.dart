import 'package:app/presentation/practice/practice_subtitle_panel.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

const frenchCue =
    "J'en reviens pas que t'aies préféré le deuxième film au premier. "
    "Pour moi, l'histoire et les personnages étaient beaucoup moins convaincants.";
const translation =
    'I cannot believe you preferred the second film to the first. '
    'To me, the story and characters were much less convincing.';

Future<void> pumpPanel(
  WidgetTester tester, {
  required Size viewport,
  String text = frenchCue,
  String? translatedText,
  double textScale = 1,
  bool hasPlayableMedia = true,
  TextDirection direction = TextDirection.ltr,
  Set<int>? highlights,
  void Function(int)? onWordTap,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      home: MediaQuery(
        data: MediaQueryData(textScaler: TextScaler.linear(textScale)),
        child: Directionality(
          textDirection: direction,
          child: Center(
            child: SizedBox.fromSize(
              size: viewport,
              child: PracticeSubtitlePanel(
                originalText: text,
                translatedText: translatedText,
                hasPlayableMedia: hasPlayableMedia,
                highlightCharStarts: highlights,
                onWordTap: onWordTap,
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

void expectCompleteTextVisible(WidgetTester tester, String text) {
  final richText = find.descendant(
    of: find.byType(PracticeSubtitlePanel),
    matching: find.byWidgetPredicate(
      (widget) => widget is RichText && widget.text.toPlainText() == text,
    ),
  );
  expect(richText, findsOneWidget);
  final paragraph = tester.renderObject<RenderParagraph>(richText);
  expect(paragraph.didExceedMaxLines, isFalse);
  final panel = tester.getRect(find.byType(PracticeSubtitlePanel));
  final origin = paragraph.localToGlobal(Offset.zero);
  // Selection boxes for trailing wrap spaces can extend beyond the line even
  // though those spaces paint nothing. Check every visible token instead.
  final boxes = RegExp(r'\S+')
      .allMatches(text)
      .expand(
        (match) => paragraph.getBoxesForSelection(
          TextSelection(baseOffset: match.start, extentOffset: match.end),
        ),
      )
      .toList();
  expect(boxes, isNotEmpty);
  for (final box in boxes) {
    final rect = box.toRect().shift(origin);
    expect(rect.left, greaterThanOrEqualTo(panel.left + 16 - 0.1));
    expect(rect.right, lessThanOrEqualTo(panel.right - 16 + 0.1));
    expect(rect.top, greaterThanOrEqualTo(panel.top + 16 - 0.1));
    expect(rect.bottom, lessThanOrEqualTo(panel.bottom - 16 + 0.1));
    // Check against the allocated text section as well as the whole panel.
    expect(box.bottom, lessThanOrEqualTo(paragraph.size.height + 0.1));
  }
  expect(find.byType(Scrollable), findsNothing);
  expect(tester.takeException(), isNull);
}

void main() {
  // Media viewport after card padding and cover insets, including the 375pt
  // phone in the report. Height varies with screen height and player controls.
  for (final viewport in [
    const Size(196, 90),
    const Size(251, 117),
    const Size(266, 200),
    const Size(306, 340),
    const Size(644, 460),
  ]) {
    for (final translated in [false, true]) {
      for (final scale in [1.0, 2.0]) {
        testWidgets('fits $viewport translated=$translated scale=$scale', (
          tester,
        ) async {
          await pumpPanel(
            tester,
            viewport: viewport,
            translatedText: translated ? translation : null,
            textScale: scale,
          );
          expectCompleteTextVisible(tester, frenchCue);
          if (translated) expectCompleteTextVisible(tester, translation);
        });
      }
    }
  }

  testWidgets('refits when cue, viewport and text scale change', (
    tester,
  ) async {
    await pumpPanel(tester, viewport: const Size(306, 340), text: 'Bonjour.');
    final shortSize = tester
        .widget<Text>(find.text('Bonjour.'))
        .style!
        .fontSize!;
    expect(shortSize, 30);
    await pumpPanel(
      tester,
      viewport: const Size(196, 90),
      text: '$frenchCue\n$frenchCue\n$frenchCue',
      textScale: 2,
    );
    expectCompleteTextVisible(tester, '$frenchCue\n$frenchCue\n$frenchCue');
    final longSize = tester
        .widget<Text>(find.byType(Text).last)
        .style!
        .fontSize!;
    expect(longSize, lessThan(shortSize));
    expect(longSize, lessThan(16));
  });

  testWidgets('fits CJK and RTL cues with and without media', (tester) async {
    for (final media in [false, true]) {
      for (final text in [
        '我真的不敢相信你更喜欢第二部电影。第一部电影的故事和人物都更精彩。',
        'لا أصدق أنك فضلت الفيلم الثاني على الأول. كانت القصة والشخصيات أكثر إقناعاً.',
        'SupercalifragilisticexpialidociousWithoutAnySpacesAtAll',
      ]) {
        await pumpPanel(
          tester,
          viewport: const Size(196, 90),
          text: text,
          hasPlayableMedia: media,
          direction: text.startsWith('لا')
              ? TextDirection.rtl
              : TextDirection.ltr,
        );
        expectCompleteTextVisible(tester, text);
      }
    }
  });

  testWidgets('highlighted text fits and words retain their tap targets', (
    tester,
  ) async {
    int? tapped;
    await pumpPanel(
      tester,
      viewport: const Size(251, 117),
      highlights: {0},
      onWordTap: (start) => tapped = start,
    );
    expectCompleteTextVisible(tester, frenchCue);
    final richText = find.descendant(
      of: find.byType(PracticeSubtitlePanel),
      matching: find.byType(RichText),
    );
    final paragraph = tester.renderObject<RenderParagraph>(richText);
    final firstWord = paragraph
        .getBoxesForSelection(
          const TextSelection(baseOffset: 0, extentOffset: 4),
        )
        .first
        .toRect();
    await tester.tapAt(paragraph.localToGlobal(firstWord.center));
    expect(tapped, 0);
  });
}
