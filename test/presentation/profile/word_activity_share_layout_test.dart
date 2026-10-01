import 'dart:io';

import '../../support/share_card_fonts.dart';
import 'dart:ui' as ui;

import 'package:app/domain/activity/word_activity.dart';
import 'package:app/l10n/app_localizations.dart';
import 'package:app/presentation/profile/word_activity_image_encoder.dart';
import 'package:app/presentation/profile/word_activity_share_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    await loadShareCardFonts();
    // Real glyph metrics on this Mac; portable tests still run with test fonts.
    for (final entry in {
      'ShareLatin': '/System/Library/Fonts/Supplemental/Arial.ttf',
      'ShareChinese': '/System/Library/Fonts/Hiragino Sans GB.ttc',
      'ShareJapanese': '/System/Library/Fonts/ヒラギノ角ゴシック W6.ttc',
      'ShareKorean': '/System/Library/Fonts/AppleSDGothicNeo.ttc',
      'ShareThai': '/System/Library/Fonts/ThonburiUI.ttc',
      'Apple Color Emoji': '/System/Library/Fonts/Apple Color Emoji.ttc',
    }.entries) {
      final file = File(entry.value);
      if (await file.exists()) {
        await (FontLoader(
          entry.key,
        )..addFont(file.readAsBytes().then(ByteData.sublistView))).load();
      }
    }
    await (FontLoader(
      'MaterialIcons',
    )..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'))).load();
  });

  for (final locale in AppLocalizations.supportedLocales) {
    testWidgets('localized artwork keeps exact counts inside slots: $locale', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(540, 960);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final capture = GlobalKey();
      for (final count in [0, 1, 2, 5, 21, 296, 9999, 99999, 12345678]) {
        await tester.pumpWidget(
          MaterialApp(
            locale: locale,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            theme: ThemeData(
              fontFamily: 'ShareLatin',
              fontFamilyFallback: [
                'ShareChinese',
                'ShareJapanese',
                'ShareKorean',
                'ShareThai',
              ],
            ),
            // A large device text scale must not alter the exported canvas.
            home: MediaQuery(
              data: const MediaQueryData(textScaler: TextScaler.linear(2)),
              child: RepaintBoundary(
                key: capture,
                child: WordActivityShareCard(
                  name: count == 296
                      ? 'Ethan Hunt'
                      : 'Alexandra Nguyễn 山田 지민 with a very long multilingual profile name',
                  learningLanguage: count == 1 ? 'unknown-ZZ' : 'en-NZ',
                  today: WordTotals(
                    spoken: count,
                    listened: count == 296 ? 346 : count,
                  ),
                  week: const WordTotals(),
                  total: const WordTotals(),
                ),
              ),
            ),
          ),
        );
        await tester.runAsync(() async {
          final context = tester.element(find.byType(WordActivityShareCard));
          for (final asset in [
            WordActivityShareCard.backgroundAsset,
            WordActivityShareCard.qrAsset,
            'assets/icon.png',
          ]) {
            await precacheImage(AssetImage(asset), context);
          }
        });
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull, reason: '$locale / $count');
        final context = tester.element(find.byType(WordActivityShareCard));
        final l10n = AppLocalizations.of(context)!;
        if (locale.languageCode == 'zh' && count != 1) {
          expect(
            find.text(locale.scriptCode == 'Hant' ? '把英語\n說出口。' : '把英语\n说出口。'),
            findsOneWidget,
          );
        }
        final number = find.byKey(const ValueKey('share-spoken-number'));
        final unit = find.byKey(const ValueKey('share-spoken-unit'));
        final caption = find.byKey(const ValueKey('share-listened'));
        final numberText = find.descendant(
          of: number,
          matching: find.byType(Text),
        );
        final text = tester.widget<Text>(numberText);
        expect(
          text.textSpan!.toPlainText(),
          NumberFormat.decimalPattern(locale.toLanguageTag()).format(count),
        );
        expect(
          find.descendant(
            of: unit,
            matching: find.text(l10n.wordActivityShareWordUnit(count)),
          ),
          findsOneWidget,
        );
        final numberRect = tester.getRect(numberText);
        final unitRect = tester.getRect(unit);
        expect(numberRect.right, lessThanOrEqualTo(unitRect.left));
        expect(numberRect.bottom, lessThan(tester.getRect(caption).top));
        // 4/5 digits remain readable, not just technically free of overflow.
        if (count >= 296 && count <= 99999) {
          expect(text.style!.fontSize, greaterThanOrEqualTo(64));
        }
        for (final element in find.byType(Text).evaluate()) {
          final paragraph = element.findRenderObject()! as RenderParagraph;
          expect(
            paragraph.didExceedMaxLines,
            isFalse,
            reason: '$locale / $count: ${(element.widget as Text).data}',
          );
          final rect = paragraph.localToGlobal(Offset.zero) & paragraph.size;
          expect(rect.left, greaterThanOrEqualTo(0));
          expect(rect.top, greaterThanOrEqualTo(0));
          expect(rect.right, lessThanOrEqualTo(540));
          expect(rect.bottom, lessThanOrEqualTo(960));
        }
        final directory = Platform.environment['BANTERA_SHARE_LAYOUT_OUTPUT'];
        if (directory != null && (count == 296 || count == 99999)) {
          await tester.runAsync(
            () => Future<void>.delayed(const Duration(milliseconds: 100)),
          );
          await tester.pump(const Duration(milliseconds: 16));
          await tester.runAsync(() async {
            final boundary =
                capture.currentContext!.findRenderObject()!
                    as RenderRepaintBoundary;
            final image = await boundary.toImage(pixelRatio: 2);
            final data = await image.toByteData(format: ui.ImageByteFormat.png);
            image.dispose();
            await Directory(directory).create(recursive: true);
            await File(
              '$directory/${locale.toLanguageTag()}-$count.jpg',
            ).writeAsBytes(encodeWordActivityJpeg(data!.buffer.asUint8List()));
          });
        }
      }
    });
  }

  test('word units follow Slavic plural categories', () async {
    for (final entry in {
      'pl': ['słowo', 'słowa', 'słów', 'słów', 'słowa', 'słów'],
      'ru': ['слово', 'слова', 'слов', 'слово', 'слова', 'слов'],
      'uk': ['слово', 'слова', 'слів', 'слово', 'слова', 'слів'],
    }.entries) {
      final l10n = await AppLocalizations.delegate.load(Locale(entry.key));
      final counts = [1, 2, 5, 21, 22, 25];
      for (var i = 0; i < counts.length; i++) {
        expect(l10n.wordActivityShareWordUnit(counts[i]), entry.value[i]);
      }
    }
  });
}
