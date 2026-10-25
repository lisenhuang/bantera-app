import 'dart:ui' as ui;
import 'package:app/core/theme.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:app/l10n/app_localizations.dart';
import 'package:app/presentation/quick_practice/quick_practice_screen.dart';
import 'dart:async';
import 'dart:io';
import 'package:app/infrastructure/practice_translation_preferences.dart';
import 'package:app/presentation/quick_practice/practice_pronunciation_controller.dart';
import 'package:app/presentation/quick_practice/practice_pronunciation_text.dart';
import 'package:app/presentation/practice/subtitle_word_tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class MemoryPreferences extends PracticeTranslationPreferences {
  MemoryPreferences() : super(file: () async => throw UnimplementedError());
  String? value;
  @override
  Future<String?> load(String owner, String language) async => value;
  @override
  Future<void> save(String owner, String language, String target) async {
    value = target;
  }
}

void main() {
  testWidgets(
    'Practice toggle displays late readings without replacing sentence or choices',
    (tester) async {
      final messenger =
          TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
      messenger.setMockMethodCallHandler(
        const MethodChannel('FlutterWebRTC.Method'),
        (_) async => {'textureId': 1},
      );
      messenger.setMockMethodCallHandler(
        const MethodChannel('FlutterWebRTC.Event'),
        (_) async => null,
      );
      messenger.setMockMethodCallHandler(
        const MethodChannel('FlutterWebRTC/Texture1'),
        (_) async => null,
      );
      addTearDown(() {
        messenger.setMockMethodCallHandler(
          const MethodChannel('FlutterWebRTC.Method'),
          null,
        );
        messenger.setMockMethodCallHandler(
          const MethodChannel('FlutterWebRTC.Event'),
          null,
        );
        messenger.setMockMethodCallHandler(
          const MethodChannel('FlutterWebRTC/Texture1'),
          null,
        );
      });
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      final prefs = MemoryPreferences();
      final controller = PracticePronunciationController(preferences: prefs);
      final response = Completer<Map<String, dynamic>>();
      final key = GlobalKey();
      // Flutter's Ahem test font is wider than the real iOS font.
      final width = Platform.environment['BANTERA_CAPTURE_PRONUNCIATION'] == '1'
          ? 393.0
          : 500.0;
      tester.view.physicalSize = Size(width, 852);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      if (Platform.environment['BANTERA_CAPTURE_PRONUNCIATION'] == '1') {
        await tester.runAsync(() async {
          await (FontLoader('MaterialIcons')
                ..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf')))
              .load();
          await (FontLoader('packages/cupertino_icons/CupertinoIcons')..addFont(
                rootBundle.load(
                  'packages/cupertino_icons/assets/CupertinoIcons.ttf',
                ),
              ))
              .load();
          final f = File(
            '/System/Library/Fonts/Supplemental/Arial Unicode.ttf',
          );
          if (await f.exists()) {
            await (FontLoader('Roboto')..addFont(
                  Future.value(ByteData.sublistView(await f.readAsBytes())),
                ))
                .load();
          }
        });
      }
      await tester.pumpWidget(
        MaterialApp(
          theme: BanteraTheme.lightTheme.copyWith(platform: TargetPlatform.iOS),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: RepaintBoundary(
            key: key,
            child: QuickPracticeScreen.preview(
              previewPronunciation: controller,
              previewApi: (path, body) {
                expect(path, 'sample/pronunciation');
                return response.future;
              },
              previewExercise: {
                'id': 'sample',
                'locale': 'zh-CN',
                'level': 'A1',
                'cue': '你好！',
                'cueAudioUrl': '',
                'choices': [
                  {'text': '你好！', 'audioUrl': ''},
                  {'text': '再见！', 'audioUrl': ''},
                ],
              },
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      final toggle = find.byKey(
        const ValueKey('practice-pronunciation-toggle'),
      );
      final level = find.byKey(const ValueKey('practice-level-menu'));
      final offSize = tester.getSize(toggle);
      expect(tester.getTopLeft(level).dx, 24);
      expect(tester.getTopRight(toggle).dx, width - 24);
      expect(
        tester.getTopLeft(toggle).dx,
        greaterThan(tester.getTopRight(level).dx),
      );
      expect(tester.getCenter(toggle).dy, tester.getCenter(level).dy);
      expect(tester.widget<Switch>(toggle).value, isFalse);
      await tester.tap(toggle);
      await tester.pumpAndSettle();
      expect(find.text('Preparing pronunciation…'), findsOneWidget);
      expect(
        tester.getTopRight(find.text('Preparing pronunciation…')).dx,
        width - 24,
      );
      expect(
        tester.getTopLeft(find.text('Preparing pronunciation…')).dy,
        greaterThan(tester.getBottomLeft(toggle).dy),
      );
      expect(tester.getSize(toggle), offSize);
      expect(tester.widget<Switch>(toggle).value, isTrue);
      response.complete({
        'status': 'ready',
        'cue': [
          {'text': '你', 'reading': 'nǐ'},
          {'text': '好', 'reading': 'hǎo'},
          {'text': '！', 'reading': ''},
        ],
        'choices': [
          [
            {'text': '你', 'reading': 'nǐ'},
            {'text': '好', 'reading': 'hǎo'},
            {'text': '！', 'reading': ''},
          ],
          [
            {'text': '再', 'reading': 'zài'},
            {'text': '见', 'reading': 'jiàn'},
            {'text': '！', 'reading': ''},
          ],
        ],
      });
      await tester.pumpAndSettle();
      expect(find.text('nǐ'), findsNWidgets(2));
      expect(find.text('zài'), findsOneWidget);
      expect(tester.takeException(), isNull);
      if (Platform.environment['BANTERA_CAPTURE_PRONUNCIATION'] == '1') {
        await tester.runAsync(() async {
          final image =
              await (key.currentContext!.findRenderObject()
                      as RenderRepaintBoundary)
                  .toImage(pixelRatio: 2);
          final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
          await File(
            '/tmp/bantera-pronunciation-preview.png',
          ).writeAsBytes(bytes!.buffer.asUint8List());
          image.dispose();
        });
      }
      await tester.tap(
        find.byKey(const ValueKey('practice-pronunciation-toggle')),
      );
      await tester.pumpAndSettle();
      expect(find.text('nǐ'), findsNothing);
      expect(prefs.value, 'off');
      tester.view.physicalSize = const Size(320, 852);
      tester.platformDispatcher.textScaleFactorTestValue = 2;
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(
        tester.getTopLeft(toggle).dy,
        greaterThan(tester.getBottomLeft(level).dy),
      );
      expect(tester.getSize(toggle).width, lessThanOrEqualTo(272));
      await tester.pumpWidget(const SizedBox());
    },
  );
  test(
    'settings persist per account/language; late responses cannot replace another exercise',
    () async {
      final dir = await Directory.systemTemp.createTemp('pronunciation');
      final prefs = PracticeTranslationPreferences(
        file: () async => File('${dir.path}/settings.json'),
      );
      final first = Completer<Map<String, dynamic>>();
      final c = PracticePronunciationController(preferences: prefs);
      Future<void> settle() =>
          Future<void>.delayed(const Duration(milliseconds: 30));
      void configure(
        String owner,
        String locale,
        String id, {
        bool active = true,
      }) => c.configure(
        owner: owner,
        locale: locale,
        id: id,
        embedded: null,
        active: active,
        fetch: (id) => id == 'first'
            ? first.future
            : Future.value({'status': 'ready', 'cue': id}),
      );
      configure('one', 'zh-CN', 'first');
      await settle();
      expect(c.enabled, false);
      expect(await c.setEnabled(true), true);
      configure('one', 'zh-CN', 'second');
      await settle();
      expect(c.data?['cue'], 'second');
      first.complete({'status': 'ready', 'cue': 'stale'});
      await settle();
      expect(c.data?['cue'], 'second');
      configure('two', 'zh-CN', 'third');
      await settle();
      expect(c.enabled, false);
      configure('one', 'ja-JP', 'fourth');
      await settle();
      expect(c.enabled, false);
      configure('one', 'zh-CN', 'fifth');
      await settle();
      expect(c.enabled, true);
      c.dispose();
      final reopened = PracticePronunciationController(preferences: prefs);
      reopened.configure(
        owner: 'one',
        locale: 'zh-CN',
        id: 'reopen',
        embedded: {'status': 'ready'},
        active: true,
        fetch: (_) async => throw StateError('should use embedded'),
      );
      await settle();
      expect(reopened.enabled, true);
      expect(reopened.status, 'ready');
      reopened.dispose();
      await dir.delete(recursive: true);
    },
  );
  test('off and inactive states do not fetch; failures can retry', () async {
    final dir = await Directory.systemTemp.createTemp('pronunciation');
    final prefs = PracticeTranslationPreferences(
      file: () async => File('${dir.path}/settings.json'),
    );
    final c = PracticePronunciationController(preferences: prefs);
    var calls = 0;
    Future<Map<String, dynamic>> fetch(String _) async {
      calls++;
      if (calls == 1) throw Exception();
      return {'status': 'ready'};
    }

    c.configure(
      owner: 'one',
      locale: 'ko-KR',
      id: 'a',
      embedded: null,
      active: false,
      fetch: fetch,
    );
    await Future<void>.delayed(const Duration(milliseconds: 30));
    await c.setEnabled(true);
    expect(calls, 0);
    c.configure(
      owner: 'one',
      locale: 'ko-KR',
      id: 'a',
      embedded: null,
      active: true,
      fetch: fetch,
    );
    await Future<void>.delayed(const Duration(milliseconds: 30));
    expect(c.status, 'unavailable');
    c.retry();
    await Future<void>.delayed(const Duration(milliseconds: 30));
    expect(c.status, 'ready');
    c.dispose();
    await dir.delete(recursive: true);
  });
  for (final entry in [
    ('zh-CN', '你好', 'nǐ hǎo'),
    ('zh-HK', '香港', 'hoeng1 gong2'),
    ('ja-JP', 'ありがとう', 'arigatō'),
    ('ko-KR', '안녕하세요', 'annyeonghaseyo'),
    ('th-TH', 'สวัสดี', 'sà-wàt-dii'),
    ('hi-IN', 'नमस्ते', 'namaste'),
    ('ar-SA', 'سلام', 'salām'),
    ('he-IL', 'שלום', 'shalóm'),
    ('ru-RU', 'привет', 'privét'),
    ('uk-UA', 'привіт', 'pryvít'),
    ('el-GR', 'καλημέρα', 'kaliméra'),
  ]) {
    testWidgets('${entry.$1} reading fits narrow screens at large text sizes', (
      tester,
    ) async {
      expect(supportsPracticePronunciation(entry.$1), true);
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MediaQuery(
              data: const MediaQueryData(textScaler: TextScaler.linear(2)),
              child: SizedBox(
                width: 180,
                child: PracticePronunciationText(
                  entry.$2,
                  segments: [
                    {'text': entry.$2, 'reading': entry.$3},
                  ],
                  textDirection: ['ar-SA', 'he-IL'].contains(entry.$1)
                      ? TextDirection.rtl
                      : TextDirection.ltr,
                  style: const TextStyle(fontSize: 24),
                  onSelect: (_) {},
                  onWord: (_) {},
                ),
              ),
            ),
          ),
        ),
      );
      expect(find.text(entry.$3), findsOneWidget);
      expect(tester.takeException(), isNull);
      expect(
        tester.getTopLeft(find.text(entry.$3)).dy,
        lessThan(tester.getTopLeft(find.text(entry.$2)).dy),
      );
    });
  }
  testWidgets(
    'two taps retain original word offsets across pronunciation segments',
    (tester) async {
      SubtitleWordToken? selected, confirmed;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) => PracticePronunciationText(
                '你好！',
                segments: [
                  {'text': '你', 'reading': 'nǐ'},
                  {'text': '好', 'reading': 'hǎo'},
                  {'text': '！', 'reading': ''},
                ],
                selectedWord: selected,
                onSelect: (t) => setState(() => selected = t),
                onWord: (t) => confirmed = t,
              ),
            ),
          ),
        ),
      );
      await tester.tapOnText(find.textRange.ofSubstring('好'));
      await tester.pump();
      expect(selected?.start, 1);
      expect(confirmed, isNull);
      await tester.tapOnText(find.textRange.ofSubstring('好'));
      await tester.pump();
      expect(confirmed?.text, '好');
      expect(confirmed?.start, 1);
    },
  );
}
