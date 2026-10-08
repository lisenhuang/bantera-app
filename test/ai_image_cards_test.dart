import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:app/infrastructure/ai/ai_history_store.dart';
import 'package:app/infrastructure/ai/ai_image_search.dart';
import 'package:app/presentation/chats/ai/ai_image_cards.dart';
import 'package:app/l10n/app_localizations.dart';

void main() {
  for (final brightness in Brightness.values) {
    testWidgets(
      'image card and full-screen viewer fit narrow $brightness chat',
      (tester) async {
        tester.view.physicalSize = const Size(390, 844);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        final root = Directory.systemTemp.createTempSync('bantera-image-card');
        addTearDown(() => root.deleteSync(recursive: true));
        const sample = String.fromEnvironment('BANTERA_IMAGE_SAMPLE');
        final file = File('${root.path}/kiwi.png');
        await tester.runAsync(() async {
          if (sample.isNotEmpty) {
            await File(sample).copy(file.path);
          } else {
            final recorder = ui.PictureRecorder();
            Canvas(recorder).drawColor(Colors.teal, BlendMode.src);
            final picture = recorder.endRecording();
            final image = await picture.toImage(4, 4);
            final bytes = await image.toByteData(
              format: ui.ImageByteFormat.png,
            );
            await file.writeAsBytes(bytes!.buffer.asUint8List());
            image.dispose();
            picture.dispose();
          }
        });
        const fontPath = String.fromEnvironment('BANTERA_PREVIEW_FONT');
        if (fontPath.isNotEmpty) {
          await tester.runAsync(() async {
            final loader = FontLoader('Preview')
              ..addFont(
                File(
                  fontPath,
                ).readAsBytes().then((b) => ByteData.sublistView(b)),
              );
            await loader.load();
          });
        }
        await tester.pumpWidget(const MaterialApp(home: SizedBox()));
        await tester.runAsync(
          () => precacheImage(
            ResizeImage.resizeIfNeeded(800, null, FileImage(file)),
            tester.element(find.byType(SizedBox)),
          ).timeout(const Duration(seconds: 10)),
        );
        final key = GlobalKey();
        final message = AiMessage(
          role: 'model',
          images: [
            const AiImageAttachment(
              title: 'Apteryx owenii · Little spotted kiwi',
              url:
                  'https://upload.wikimedia.org/wikipedia/commons/a/ab/Kiwi.png',
              sourceUrl: 'https://commons.wikimedia.org/wiki/File:Kiwi.png',
              author: 'Wikimedia Commons contributor',
              license: 'Public domain',
              mime: 'image/png',
              file: 'kiwi.png',
            ),
          ],
        );
        await tester.pumpWidget(
          MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            theme: ThemeData(
              brightness: brightness,
              colorSchemeSeed: Colors.deepPurple,
              fontFamily: fontPath.isEmpty ? null : 'Preview',
            ),
            home: RepaintBoundary(
              key: key,
              child: Scaffold(
                appBar: AppBar(title: const Text('Bantera AI')),
                body: ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    const Text(
                      'Here is a kiwi bird. How would you describe it?',
                    ),
                    AiImageCards(
                      message: message,
                      path: (name) => '${root.path}/$name',
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(tester.widget<RawImage>(find.byType(RawImage)).image, isNotNull);
        expect(find.text('Wikimedia Commons'), findsOneWidget);
        expect(
          find.text('Pictures unavailable. Try again later.'),
          findsNothing,
        );
        expect(find.textContaining('Public domain'), findsOneWidget);
        expect(tester.takeException(), isNull);
        if (sample.isNotEmpty) {
          final boundary =
              key.currentContext!.findRenderObject() as RenderRepaintBoundary;
          await tester.runAsync(() async {
            final image = await boundary.toImage(pixelRatio: 2);
            final bytes = await image.toByteData(
              format: ui.ImageByteFormat.png,
            );
            await File(
              '/tmp/bantera-image-card-${brightness.name}.png',
            ).writeAsBytes(bytes!.buffer.asUint8List());
            image.dispose();
          });
        }
        await tester.tap(find.byType(Image));
        await tester.pumpAndSettle();
        expect(find.byType(InteractiveViewer), findsOneWidget);
        expect(find.byTooltip('Save or share image'), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );
  }
}
