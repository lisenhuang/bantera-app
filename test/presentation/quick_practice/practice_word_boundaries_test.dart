import 'dart:async';
import 'package:app/presentation/practice/subtitle_word_tokens.dart';
import 'package:app/presentation/quick_practice/practice_pronunciation_text.dart';
import 'package:app/presentation/quick_practice/practice_word_boundaries.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
  void mock(Future<dynamic> Function(MethodCall)? handler) => messenger
      .setMockMethodCallHandler(PracticeWordBoundaries.channel, handler);
  tearDown(() => mock(null));

  test(
    'native ranges preserve UTF-16 offsets after emoji and punctuation',
    () async {
      mock((call) async {
        expect(call.method, 'tokenize');
        expect(call.arguments, {'text': '🙂「学校」学校。', 'locale': 'ja-JP'});
        return [
          {'start': 3, 'end': 5},
          {'start': 6, 'end': 8},
        ];
      });
      final words = await PracticeWordBoundaries.resolve('🙂「学校」学校。', 'ja-JP');
      expect(words.map((t) => (t.start, t.end, t.text)), [
        (3, 5, '学校'),
        (6, 8, '学校'),
      ]);
    },
  );

  for (final invalid in <dynamic>[
    null,
    [],
    [
      {'start': 0, 'end': 1},
    ], // missing the second character
    [
      {'start': -1, 'end': 2},
    ],
    [
      {'start': 0, 'end': 3},
    ],
    [
      {'start': 1, 'end': 2},
      {'start': 0, 'end': 1},
    ],
    [
      {'start': 0, 'end': 2},
      {'start': 1, 'end': 2},
    ],
    [
      {'start': '0', 'end': 2},
    ],
  ]) {
    test('invalid or incomplete native result falls back: $invalid', () async {
      mock((_) async => invalid);
      expect(
        (await PracticeWordBoundaries.resolve(
          '学校',
          'ja-JP',
        )).map((t) => t.text),
        ['学', '校'],
      );
    });
  }

  test(
    'unavailable native tokenizer safely falls back and keeps vowel marks',
    () async {
      mock((_) async => throw PlatformException(code: 'unavailable'));
      final text = 'cafe\u0301 नमस्ते';
      final words = await PracticeWordBoundaries.resolve(text, 'hi-IN');
      expect(words.first.text, 'cafe\u0301');
      expect(words.skip(1).map((t) => t.text).join(), 'नमस्ते');
      mock(null);
      expect((await PracticeWordBoundaries.resolve('学校', 'ja-JP')).length, 2);
    },
  );

  test('native boundaries cannot split graphemes or surrogate pairs', () async {
    mock(
      (_) async => [
        {'start': 0, 'end': 4},
      ],
    );
    expect(
      (await PracticeWordBoundaries.resolve('cafe\u0301', 'fr')).single.text,
      'cafe\u0301',
    );
    mock(
      (_) async => [
        {'start': 0, 'end': 1},
        {'start': 1, 'end': 2},
      ],
    );
    expect(
      (await PracticeWordBoundaries.resolve('𠮷', 'ja')).single.text,
      '𠮷',
    );
  });

  for (final ruby in [false, true]) {
    testWidgets(
      'whole word selects then confirms across characters, ruby=$ruby',
      (tester) async {
        mock(
          (_) async => [
            {'start': 0, 'end': 2},
            {'start': 3, 'end': 5},
          ],
        );
        SubtitleWordToken? selected, confirmed;
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: StatefulBuilder(
                builder: (context, setState) => PracticePronunciationText(
                  '学校、学校。',
                  locale: 'ja-JP',
                  segments: ruby
                      ? [
                          {'text': '学', 'reading': 'gak'},
                          {'text': '校、', 'reading': 'kō'},
                          {'text': '学', 'reading': 'gak'},
                          {'text': '校。', 'reading': 'kō'},
                        ]
                      : [],
                  selectedWord: selected,
                  onSelect: (word) => setState(() => selected = word),
                  onWord: (word) => confirmed = word,
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        final first = ruby
            ? find.textRange.ofSubstring('校、')
            : find.textRange.ofSubstring('学校、');
        await tester.tapOnText(first);
        await tester.pump();
        expect(selected?.text, '学校');
        expect(selected?.start, 0);
        expect(confirmed, isNull);
        final underlined = tester
            .widgetList<Text>(find.byType(Text))
            .where((text) => text.textSpan != null)
            .expand(
              (text) => (text.textSpan as TextSpan).children ?? <InlineSpan>[],
            )
            .whereType<TextSpan>()
            .where((s) => s.style?.decoration == TextDecoration.underline);
        expect(underlined.map((s) => s.text).join(), '学校');
        await tester.tapOnText(
          ruby ? find.textRange.ofSubstring('学').first : first,
        );
        expect(
          (confirmed?.text, confirmed?.start, confirmed?.end),
          ('学校', 0, 2),
        );
        confirmed = null;
        await tester.tapOnText(
          ruby
              ? find.textRange.ofSubstring('校。')
              : find.textRange.ofSubstring('学校。'),
        );
        await tester.pump();
        expect(selected?.start, 3);
        expect(confirmed, isNull);
      },
    );
  }

  testWidgets(
    'late boundaries expand a first tap without losing two-tap behavior',
    (tester) async {
      final response = Completer<dynamic>();
      mock((_) => response.future);
      SubtitleWordToken? selected, confirmed;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) => PracticePronunciationText(
                '学校',
                locale: 'ja',
                segments: [],
                selectedWord: selected,
                onSelect: (t) => setState(() => selected = t),
                onWord: (t) => confirmed = t,
              ),
            ),
          ),
        ),
      );
      await tester.tapOnText(find.textRange.ofSubstring('校'));
      await tester.pump();
      expect(selected?.text, '校');
      response.complete([
        {'start': 0, 'end': 2},
      ]);
      await tester.pumpAndSettle();
      await tester.tapOnText(find.textRange.ofSubstring('学'));
      expect(confirmed?.text, '学校');
    },
  );

  testWidgets('stale and disposed requests cannot replace a new sentence', (
    tester,
  ) async {
    final old = Completer<dynamic>();
    final pending = Completer<dynamic>();
    mock(
      (call) async =>
          call.arguments['text'] == '学校' ? old.future : pending.future,
    );
    SubtitleWordToken? selected;
    Widget page(String text) => MaterialApp(
      home: Scaffold(
        body: PracticePronunciationText(
          text,
          locale: 'ja',
          segments: [],
          onSelect: (t) => selected = t,
          onWord: (_) {},
        ),
      ),
    );
    await tester.pumpWidget(page('学校'));
    await tester.pumpWidget(page('銀行'));
    pending.complete([
      {'start': 0, 'end': 2},
    ]);
    await tester.pump();
    old.complete([
      {'start': 0, 'end': 1},
      {'start': 1, 'end': 2},
    ]);
    await tester.pumpAndSettle();
    await tester.tapOnText(find.textRange.ofSubstring('行'));
    expect(selected?.text, '銀行');
    final disposed = Completer<dynamic>();
    mock((_) => disposed.future);
    await tester.pumpWidget(page('友達'));
    await tester.pumpWidget(const SizedBox());
    disposed.complete([
      {'start': 0, 'end': 2},
    ]);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}
