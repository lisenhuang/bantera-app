import 'dart:convert';
import 'dart:io';
import 'package:app/presentation/quick_practice/practice_pronunciation_alignment.dart';
import 'package:app/presentation/quick_practice/practice_pronunciation_controller.dart';
import 'package:app/presentation/quick_practice/practice_pronunciation_text.dart';
import 'package:app/presentation/quick_practice/practice_word_boundaries.dart';
import 'package:app/presentation/practice/subtitle_word_tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'practice_pronunciation_test.dart' show MemoryPreferences;

void main() {
  final fixtures =
      (jsonDecode(
                File(
                  'test/fixtures/pronunciation_alignment.json',
                ).readAsStringSync(),
              )
              as List)
          .cast<Map<String, dynamic>>();
  for (final f in fixtures) {
    test('${f['locale']} validates ${f['text']}', () {
      expect(
        PracticePronunciationAlignment.valid(
          f['segments'],
          f['text'],
          f['locale'],
        ),
        f['valid'],
      );
    });
  }
  for (final scale in [1.0, 2.5]) {
    for (final f in fixtures.where((f) => f['valid'] == true)) {
      testWidgets(
        '${f['locale']} atomic alignment at scale $scale: ${f['text']}',
        (tester) async {
          final rtl = ['ar-SA', 'he-IL'].contains(f['locale']);
          await tester.pumpWidget(
            MaterialApp(
              theme: ThemeData(
                brightness: scale == 1 ? Brightness.light : Brightness.dark,
              ),
              home: Scaffold(
                body: MediaQuery(
                  data: MediaQueryData(textScaler: TextScaler.linear(scale)),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: SizedBox(
                      width: 180,
                      child: PracticePronunciationText(
                        f['text'],
                        locale: f['locale'],
                        segments: f['segments'],
                        style: const TextStyle(fontSize: 24),
                        textDirection: rtl
                            ? TextDirection.rtl
                            : TextDirection.ltr,
                        onSelect: (_) {},
                        onWord: (_) {},
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
          for (final unit in f['segments']) {
            if (unit['reading'] == '') continue;
            final reading = find.text(unit['reading']).first;
            final source = find
                .byWidgetPredicate(
                  (w) => w is Text && w.textSpan?.toPlainText() == unit['text'],
                )
                .first;
            expect(
              tester.getBottomLeft(reading).dy,
              lessThanOrEqualTo(tester.getTopLeft(source).dy + 1),
            );
            expect(
              tester.getCenter(reading).dx,
              closeTo(tester.getCenter(source).dx, 1),
            );
          }
          // Neither line may independently wrap, even if the unit needs scrolling.
          for (final rich in tester.renderObjectList<RenderParagraph>(
            find.byType(RichText),
          )) {
            expect(rich.softWrap, isFalse);
          }
        },
      );
    }
  }
  for (final f in fixtures.where((f) => f['valid'] == true).take(14)) {
    testWidgets(
      '${f['locale']} long sentence wraps atomically in a wide window',
      (tester) async {
        final parts = <dynamic>[];
        for (var n = 0; n < 8; n++) {
          if (n > 0) parts.add({'text': ' ', 'reading': ''});
          parts.addAll(f['segments']);
        }
        final text = parts.map((p) => p['text']).join();
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(
                child: SizedBox(
                  width: 720,
                  child: PracticePronunciationText(
                    text,
                    locale: f['locale'],
                    segments: parts,
                    style: const TextStyle(fontSize: 24),
                    onSelect: (_) {},
                    onWord: (_) {},
                  ),
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        final first = (f['segments'] as List).firstWhere(
          (p) => p['reading'] != '',
        );
        final readings = tester.getTopLeft(find.text(first['reading']).first);
        final lastReadings = tester.getTopLeft(
          find.text(first['reading']).last,
        );
        expect(lastReadings.dy, greaterThan(readings.dy));
        for (final rich in tester.renderObjectList<RenderParagraph>(
          find.byType(RichText),
        )) {
          expect(rich.softWrap, isFalse);
        }
      },
    );
  }
  testWidgets(
    'invalid phrase shows only original text; punctuation stays on the same run',
    (tester) async {
      Widget page(List parts) => MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 60,
            child: PracticePronunciationText(
              '朋友。',
              locale: 'zh-CN',
              segments: parts,
              style: const TextStyle(fontSize: 24),
              onSelect: (_) {},
              onWord: (_) {},
            ),
          ),
        ),
      );
      await tester.pumpWidget(
        page([
          {'text': '朋友', 'reading': 'péng you'},
          {'text': '。', 'reading': ''},
        ]),
      );
      expect(find.text('péng you'), findsNothing);
      expect(find.text('朋友。'), findsOneWidget);
      await tester.pumpWidget(
        page([
          {'text': '朋', 'reading': 'péng'},
          {'text': '友', 'reading': 'you'},
          {'text': '。', 'reading': ''},
        ]),
      );
      await tester.pumpAndSettle();
      expect(
        tester.getBottomLeft(find.text('友')).dy,
        tester.getBottomLeft(find.text('。')).dy,
      );
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets('independent whole-word selection spans two Han reading cells', (
    tester,
  ) async {
    final messenger =
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    messenger.setMockMethodCallHandler(
      PracticeWordBoundaries.channel,
      (_) async => [
        {'start': 0, 'end': 2},
      ],
    );
    addTearDown(
      () => messenger.setMockMethodCallHandler(
        PracticeWordBoundaries.channel,
        null,
      ),
    );
    SubtitleWordToken? selected, confirmed;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: StatefulBuilder(
            builder: (context, update) => PracticePronunciationText(
              '朋友',
              locale: 'zh-CN',
              segments: const [
                {'text': '朋', 'reading': 'péng'},
                {'text': '友', 'reading': 'you'},
              ],
              selectedWord: selected,
              onSelect: (v) => update(() => selected = v),
              onWord: (v) => confirmed = v,
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tapOnText(find.textRange.ofSubstring('朋'));
    await tester.pump();
    expect(selected?.text, '朋友');
    expect(confirmed, isNull);
    await tester.tapOnText(find.textRange.ofSubstring('友'));
    expect(confirmed?.text, '朋友');
    expect(find.text('péng'), findsOneWidget);
    expect(find.text('you'), findsOneWidget);
  });
  test(
    'invalid cached ready data refreshes once and remains bounded on an old server',
    () async {
      final prefs = MemoryPreferences()..value = 'on';
      final c = PracticePronunciationController(preferences: prefs);
      final invalid = {
        'status': 'ready',
        'cue': [
          {'text': '朋友', 'reading': 'péng you'},
        ],
        'choices': [[], []],
      };
      var calls = 0;
      c.configure(
        owner: 'a',
        locale: 'zh-CN',
        id: 'x',
        embedded: invalid,
        active: true,
        fetch: (_) async {
          calls++;
          return invalid;
        },
      );
      expect(c.data, isNull);
      await Future<void>.delayed(const Duration(milliseconds: 20));
      expect(c.status, 'unavailable');
      expect(c.data, isNull);
      expect(calls, 1);
      c.dispose();
    },
  );
  testWidgets(
    'copy preserves original text rather than readings and wrap spacing',
    (tester) async {
      String? copied;
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(SystemChannels.platform, (call) async {
            if (call.method == 'Clipboard.setData') {
              copied = (call.arguments as Map)['text'];
            }
            return null;
          });
      addTearDown(
        () => TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(SystemChannels.platform, null),
      );
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 90,
              child: PracticePronunciationText(
                '朋友。',
                locale: 'zh-CN',
                segments: const [
                  {'text': '朋', 'reading': 'péng'},
                  {'text': '友', 'reading': 'you'},
                  {'text': '。', 'reading': ''},
                ],
                onSelect: (_) {},
                onWord: (_) {},
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.longPress(find.text('péng'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Copy'));
      await tester.pumpAndSettle();
      expect(copied, '朋友。');
    },
  );
  test(
    'repaired data replaces stale cache and rechecks on foreground',
    () async {
      final prefs = MemoryPreferences()..value = 'on';
      final c = PracticePronunciationController(preferences: prefs);
      final repaired = {
        'status': 'ready',
        'alignmentVersion': 2,
        'cue': [
          {'text': '朋', 'reading': 'péng'},
          {'text': '友', 'reading': 'you'},
        ],
        'choices': [
          [
            {'text': '你', 'reading': 'nǐ'},
          ],
          [
            {'text': '好', 'reading': 'hǎo'},
          ],
        ],
      };
      var calls = 0;
      void configure(bool active) => c.configure(
        owner: 'a',
        locale: 'zh-CN',
        id: 'x',
        source: ['朋友', '你', '好'],
        embedded: {
          'status': 'ready',
          'cue': [
            {'text': '朋友', 'reading': 'péng you'},
          ],
          'choices': [[], []],
        },
        active: active,
        fetch: (_) async {
          calls++;
          return repaired;
        },
      );
      configure(true);
      expect(c.data, isNull);
      await Future<void>.delayed(const Duration(milliseconds: 20));
      expect(c.status, 'ready');
      expect(c.data, repaired);
      expect(calls, 1);
      configure(false);
      configure(true);
      await Future<void>.delayed(const Duration(milliseconds: 20));
      expect(calls, 2);
      expect(c.data, repaired);
      c.dispose();
    },
  );
}
