import 'dart:io';
import 'package:app/infrastructure/ai/ai_history_store.dart';
import 'package:app/presentation/chats/ai/ai_chat_controller.dart';
import 'package:app/presentation/chats/ai/ai_image_composer.dart';
import 'package:app/presentation/chats/ai/ai_image_cards.dart';
import 'package:app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;

void main() {
  testWidgets(
    'narrow AI composer previews four images, removes a draft and locks recording',
    (tester) async {
      tester.view.physicalSize = const Size(320, 780);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final dir = Directory.systemTemp.createTempSync('ai-image-ui');
      final file = File('${dir.path}/sample.png')
        ..writeAsBytesSync(img.encodePng(img.Image(width: 40, height: 30)));
      final messenger =
          TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
      messenger.setMockMethodCallHandler(
        const MethodChannel('com.llfbandit.record/messages'),
        (_) async => null,
      );
      messenger.setMockMethodCallHandler(
        AiChatController.audio,
        (call) async => call.method == 'storagePath' ? dir.path : null,
      );
      final chat = AiChatController.forTesting(AiHistoryStore('ui-images'));
      await tester.runAsync(() async {
        await chat.initialize();
        await chat.attachImages(List.filled(4, file.path));
      });
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: Align(
              alignment: Alignment.bottomCenter,
              child: ListenableBuilder(
                listenable: chat,
                builder: (_, _) => AiImageComposer(
                  chat: chat,
                  child: const SizedBox(
                    height: 64,
                    child: Center(child: Text('Tap or hold to record')),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pump();
      expect(find.byType(Image), findsNWidgets(4));
      await tester.tap(find.byTooltip('Remove image').first);
      await tester.pump();
      expect(chat.draftImages, hasLength(3));
      chat.recording = true;
      chat.changed();
      await tester.pump();
      expect(find.byIcon(Icons.lock_outline), findsNWidgets(3));
      expect(tester.takeException(), null);
      chat.recording = false;
      final message = AiMessage(
        role: 'user',
        images: chat.draftImages.toList(),
      );
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: SingleChildScrollView(
              child: AiImageCards(message: message, path: chat.store.path),
            ),
          ),
        ),
      );
      await tester.pump();
      expect(
        find.byType(TextButton),
        findsNothing,
      ); // No invented source/usage rights for own photos.
      expect(tester.takeException(), null);
      await tester.pumpWidget(const SizedBox());
      chat.dispose();
      await tester.runAsync(() async {
        await Future<void>.delayed(const Duration(milliseconds: 20));
        await dir.delete(recursive: true);
      });
      messenger.setMockMethodCallHandler(AiChatController.audio, null);
    },
  );
}
