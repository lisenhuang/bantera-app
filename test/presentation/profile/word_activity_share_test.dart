import 'dart:io';
import 'dart:ui' as ui;

import 'package:app/domain/activity/word_activity.dart';
import 'package:app/l10n/app_localizations.dart';
import 'package:app/presentation/profile/word_activity_share_card.dart';
import 'package:app/presentation/profile/word_activity_share_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

Widget page({Locale locale = const Locale('en')}) => MaterialApp(
  locale: locale,
  theme: ThemeData(fontFamily: 'PreviewSans'),
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  home: const WordActivityShareScreen(
    name: 'Alex Morgan',
    learningLanguage: 'en-NZ',
    today: WordTotals(listened: 380, spoken: 120),
    week: WordTotals(listened: 4320, spoken: 1280),
    total: WordTotals(listened: 28460, spoken: 8120),
  ),
);

Future<void> prepared(WidgetTester tester) async {
  for (
    var i = 0;
    i < 20 && find.byType(CircularProgressIndicator).evaluate().isNotEmpty;
    i++
  ) {
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 50)),
    );
    await tester.pump();
  }
  await tester.pumpAndSettle();
  expect(find.byType(WordActivityShareCard), findsOneWidget);
}

void main() {
  const photos = MethodChannel('bantera/photos');
  final binding = TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    // A readable optional developer preview; normal tests work without this font.
    if (Platform.environment['BANTERA_SHARE_PREVIEW_OUTPUT'] != null) {
      final font = File('/System/Library/Fonts/Supplemental/Arial.ttf');
      if (await font.exists()) {
        final loader = FontLoader('PreviewSans')
          ..addFont(
            font.readAsBytes().then((bytes) => ByteData.sublistView(bytes)),
          );
        await loader.load();
        final icons = FontLoader('MaterialIcons')
          ..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'));
        await icons.load();
        final emoji = File('/System/Library/Fonts/Apple Color Emoji.ttc');
        if (await emoji.exists()) {
          final loader = FontLoader('Apple Color Emoji')
            ..addFont(emoji.readAsBytes().then(ByteData.sublistView));
          await loader.load();
        }
      }
    }
  });
  tearDown(() {
    binding.defaultBinaryMessenger.setMockMethodCallHandler(photos, null);
  });

  testWidgets(
    'Share sends a JPEG with a popover origin to the native share sheet',
    (tester) async {
      const share = MethodChannel('dev.fluttercommunity.plus/share');
      const pathProvider = MethodChannel('plugins.flutter.io/path_provider');
      final directory = await tester.runAsync(
        () => Directory.systemTemp.createTemp('bantera-share-verify'),
      );
      Map? params;
      binding.defaultBinaryMessenger.setMockMethodCallHandler(
        pathProvider,
        (_) async => directory!.path,
      );
      binding.defaultBinaryMessenger.setMockMethodCallHandler(share, (
        call,
      ) async {
        params = call.arguments as Map;
        return 'test.activity';
      });
      addTearDown(() async {
        binding.defaultBinaryMessenger.setMockMethodCallHandler(share, null);
        binding.defaultBinaryMessenger.setMockMethodCallHandler(
          pathProvider,
          null,
        );
        await directory!.delete(recursive: true);
      });
      await tester.pumpWidget(page());
      await prepared(tester);
      await tester.tap(find.text('Share'));
      await tester.pump();
      for (var i = 0; i < 100 && params == null; i++) {
        await tester.runAsync(
          () => Future<void>.delayed(const Duration(milliseconds: 50)),
        );
        await tester.pump();
      }
      await tester.pumpAndSettle();
      expect(params, isNotNull);
      expect(params!['mimeTypes'], ['image/jpeg']);
      expect(params!['originWidth'], greaterThan(0));
      expect(params!['originHeight'], greaterThan(0));
      await tester.runAsync(() async {
        final path = (params!['paths'] as List).single as String;
        expect(path.endsWith('bantera-word-progress.jpg'), isTrue);
        final codec = await ui.instantiateImageCodec(
          await File(path).readAsBytes(),
        );
        final frame = await codec.getNextFrame();
        expect(frame.image.width, 1080);
        expect(frame.image.height, 1920);
        frame.image.dispose();
        codec.dispose();
      });
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('preview saves the actual 1080x1920 JPEG to Photos', (
    tester,
  ) async {
    Uint8List? saved;
    binding.defaultBinaryMessenger.setMockMethodCallHandler(photos, (
      call,
    ) async {
      expect(call.method, 'saveImage');
      saved = (call.arguments as Map)['bytes'] as Uint8List;
      return null;
    });
    await tester.pumpWidget(page());
    await prepared(tester);
    expect(find.text('Alex Morgan'), findsOneWidget);
    expect(find.text('My speaking\ntoday'), findsOneWidget);
    expect(
      tester.getTopLeft(find.text('120')).dy,
      lessThan(tester.getTopLeft(find.text('380')).dy),
    );
    expect(find.text('Learning English'), findsOneWidget);
    expect(find.textContaining('New Zealand'), findsNothing);
    expect(find.textContaining('en-NZ'), findsNothing);
    expect(find.text('🇳🇿'), findsOneWidget);
    expect(find.textContaining('Native'), findsNothing);
    expect(find.text('4,320'), findsOneWidget);
    expect(find.text('1,280'), findsOneWidget);
    expect(find.text('380'), findsOneWidget);
    expect(find.text('120'), findsOneWidget);
    expect(
      tester.getTopLeft(find.text('380')).dy,
      lessThan(tester.getTopLeft(find.text('4,320')).dy),
    );
    expect(find.text('This week'), findsOneWidget);
    expect(find.text('iOS/Android'), findsOneWidget);
    expect(find.text('bantera.app'), findsNothing);
    await tester.tap(find.text('Save to Photos'));
    await tester.pump();
    for (var i = 0; i < 100 && saved == null; i++) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 50)),
      );
      await tester.pump();
    }
    await tester.pumpAndSettle();
    expect(saved, isNotNull);
    await tester.runAsync(() async {
      final codec = await ui.instantiateImageCodec(saved!);
      final frame = await codec.getNextFrame();
      expect(frame.image.width, 1080);
      expect(frame.image.height, 1920);
      frame.image.dispose();
      codec.dispose();
      final output = Platform.environment['BANTERA_SHARE_PREVIEW_OUTPUT'];
      if (output != null) await File(output).writeAsBytes(saved!);
    });
    expect(find.text('Saved to Photos'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('denied Photos access gives guidance and allows retry', (
    tester,
  ) async {
    var attempts = 0;
    binding.defaultBinaryMessenger.setMockMethodCallHandler(photos, (_) async {
      attempts++;
      throw PlatformException(code: 'permission_denied');
    });
    await tester.pumpWidget(page());
    await prepared(tester);
    await tester.tap(find.text('Save to Photos'));
    await tester.pump();
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(seconds: 2)),
    );
    await tester.pumpAndSettle();
    expect(attempts, 1);
    expect(find.text('Saved to Photos'), findsNothing);
    expect(find.textContaining('Allow Bantera'), findsOneWidget);
    final button = tester.widget<OutlinedButton>(
      find.widgetWithText(OutlinedButton, 'Save to Photos'),
    );
    expect(button.onPressed, isNotNull);
    expect(tester.takeException(), isNull);
  });

  for (final entry in {
    'en-NZ': 'English',
    'en': 'English',
    'fr-CA': 'French',
    'ja-JP': 'Japanese',
    'zh-TW': 'Mandarin',
    'zh-HK': 'Cantonese',
    'yue-CN': 'Cantonese',
    'unknown-ZZ': null,
  }.entries) {
    testWidgets('learning language ${entry.key} has no code or accent', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: FittedBox(
              child: WordActivityShareCard(
                name: 'Alex',
                learningLanguage: entry.key,
                today: const WordTotals(),
                week: const WordTotals(),
                total: const WordTotals(),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      if (entry.value == null) {
        expect(find.textContaining('Learning '), findsNothing);
      } else {
        expect(find.text('Learning ${entry.value}'), findsOneWidget);
      }
      expect(
        entry.key.contains('-')
            ? find.textContaining(entry.key)
            : find.text(entry.key),
        findsNothing,
      );
      expect(tester.takeException(), isNull);
    });
  }

  for (final locale in AppLocalizations.supportedLocales) {
    testWidgets('share artwork fits large counts and long names in $locale', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(540, 960);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        MaterialApp(
          locale: locale,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const Scaffold(
            body: WordActivityShareCard(
              name:
                  'A very long profile nickname that can span eighty characters comfortably',
              learningLanguage: 'en-AE',
              today: WordTotals(listened: 12345678, spoken: 12345678),
              week: WordTotals(listened: 1234567890, spoken: 1234567890),
              total: WordTotals(listened: 123456789012, spoken: 123456789012),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  }
}
