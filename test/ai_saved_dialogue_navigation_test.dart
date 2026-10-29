import 'package:app/infrastructure/ai/ai_history_store.dart';
import 'package:app/l10n/app_localizations.dart';
import 'package:app/presentation/chats/ai/ai_chat_controller.dart';
import 'package:app/presentation/chats/ai/ai_chat_screen.dart';
import 'package:app/presentation/chats/ai/ai_saved_dialogues_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

class _History extends AiHistoryStore {
  _History() : super('test');

  @override
  Future<void> save({AiMessage? audioMessage, Uint8List? audioBytes}) async {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    final messenger =
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    for (final name in [
      'xyz.luan/audioplayers.global',
      'xyz.luan/audioplayers.global/events',
      'com.llfbandit.record/messages',
    ]) {
      messenger.setMockMethodCallHandler(
        MethodChannel(name),
        (_) async => null,
      );
    }
    messenger.setMockMethodCallHandler(
      const MethodChannel('xyz.luan/audioplayers'),
      (call) async {
        if (call.method == 'create') {
          final id = (call.arguments as Map)['playerId'];
          messenger.setMockMethodCallHandler(
            MethodChannel('xyz.luan/audioplayers/events/$id'),
            (_) async => null,
          );
        }
        return null;
      },
    );
  });

  Future<void> openSaved(WidgetTester tester) async {
    await tester.tap(find.byIcon(Icons.more_horiz));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Saved dialogues'));
    await tester.pumpAndSettle();
    expect(find.byType(AiSavedDialoguesScreen), findsOneWidget);
  }

  Future<void> chooseSaved(WidgetTester tester, AiMessage message) async {
    await openSaved(tester);
    await tester.tap(find.byKey(ValueKey('ai-saved-dialogue-${message.id}')));
    await tester.pumpAndSettle();
    expect(find.byType(AiSavedDialoguesScreen), findsNothing);
    final viewport = tester.getRect(find.byType(CustomScrollView));
    final bubble = tester.getRect(
      find.byKey(ValueKey('ai-message-content-${message.id}')),
    );
    // The beginning remains visible even when the selected bubble is taller
    // than the viewport; choosing a saved message never lands mid-response.
    expect(bubble.top, greaterThanOrEqualTo(viewport.top));
    expect(bubble.top, lessThan(viewport.top + viewport.height / 2));
    expect(bubble.bottom, greaterThan(viewport.top));
  }

  testWidgets(
    'save, reopen and select exact bubbles in long mixed-height history',
    (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final store = _History();
      for (var index = 0; index < 200; index++) {
        store.messages.add(
          AiMessage(
            id: 'message-$index',
            role: index.isEven ? 'model' : 'user',
            text: index == 70
                ? 'Tall saved response\n${List.filled(60, 'A line of explanation.').join('\n')}'
                : 'History message $index\n${List.filled(index % 4, 'Some more context.').join('\n')}',
            savedAt: [0, 70].contains(index) ? DateTime(2026, 10, 29) : null,
          ),
        );
      }
      final chat = AiChatController.forTesting(store)..loaded = true;
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: AiChatScreen(controller: chat),
        ),
      );
      await tester.pumpAndSettle();
      final newest = store.messages.last;
      expect(find.byTooltip('Save dialogue'), findsNothing);
      final swipe = find.byKey(ValueKey('ai-message-swipe-${newest.id}'));
      await tester.drag(swipe, const Offset(-180, 0));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Save dialogue'));
      await tester.pumpAndSettle();
      expect(find.text('Save this dialogue?'), findsOneWidget);
      expect(newest.savedAt, isNull);
      await tester.tap(find.widgetWithText(TextButton, 'Cancel'));
      await tester.pumpAndSettle();
      expect(newest.savedAt, isNull);
      expect(find.byTooltip('Save dialogue'), findsNothing);

      await tester.drag(swipe, const Offset(-180, 0));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Save dialogue'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(FilledButton, 'Save'));
      await tester.pumpAndSettle();
      expect(newest.savedAt, isNotNull);
      expect(find.byTooltip('Unsave dialogue'), findsNothing);

      await chooseSaved(tester, store.messages[70]);
      expect(
        find
            .byWidgetPredicate(
              (widget) =>
                  widget.key is ValueKey<String> &&
                  (widget.key! as ValueKey<String>).value.startsWith(
                    'ai-message-content-',
                  ),
            )
            .evaluate()
            .length,
        lessThan(15),
        reason: 'Selecting old history must keep offscreen bubbles lazy.',
      );
      // Reopening the list and selecting the same bubble must restore its start.
      await tester.drag(find.byType(CustomScrollView), const Offset(0, -500));
      await tester.pumpAndSettle();
      await chooseSaved(tester, store.messages[70]);

      // A late AI reply is inserted before the newest user message. It must not
      // be mistaken for a newly sent user message and throw away the target.
      store.messages.insert(
        199,
        AiMessage(role: 'model', text: 'Late AI reply'),
      );
      chat.changed();
      await tester.pumpAndSettle();
      expect(find.byType(CustomScrollView), findsOneWidget);
      expect(
        find.textContaining('Tall saved response', findRichText: true),
        findsOneWidget,
      );

      await chooseSaved(tester, store.messages.first);
      await tester.timedDrag(
        find.byType(CustomScrollView),
        const Offset(0, -180),
        const Duration(seconds: 1),
      );
      await tester.pumpAndSettle();
      expect(
        tester
            .getTopLeft(
              find.byKey(const ValueKey('ai-message-content-message-1')),
            )
            .dy,
        lessThan(
          tester
              .getTopLeft(
                find.byKey(const ValueKey('ai-message-content-message-2')),
              )
              .dy,
        ),
      );
      await chooseSaved(tester, newest);
      await tester.timedDrag(
        find.byType(CustomScrollView),
        const Offset(0, 180),
        const Duration(seconds: 1),
      );
      await tester.pumpAndSettle();
      expect(
        find.byKey(const ValueKey('ai-message-content-message-198')),
        findsOneWidget,
      );

      final sent = AiMessage(role: 'user', text: 'A newly sent message');
      store.messages.add(sent);
      chat.changed();
      await tester.pumpAndSettle();
      expect(find.text('A newly sent message').hitTestable(), findsOneWidget);
      expect(find.byType(ListView), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
      chat.dispose();
    },
    variant: TargetPlatformVariant.only(TargetPlatform.iOS),
  );

  testWidgets(
    'save confirmation fits narrow iPhones in all app languages',
    (tester) async {
      tester.view.physicalSize = const Size(320, 650);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final store = _History();
      final message = AiMessage(
        id: 'localised-save',
        role: 'model',
        text: 'A short note.',
      );
      store.messages.add(message);
      final chat = AiChatController.forTesting(store)..loaded = true;
      for (final locale in AppLocalizations.supportedLocales) {
        await tester.pumpWidget(
          MaterialApp(
            locale: locale,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: AiChatScreen(controller: chat),
          ),
        );
        await tester.pumpAndSettle();
        final l = AppLocalizations.of(
          tester.element(find.byType(AiChatScreen)),
        )!;
        await tester.drag(
          find.byKey(const ValueKey('ai-message-swipe-localised-save')),
          const Offset(-180, 0),
        );
        await tester.pumpAndSettle();
        await tester.tap(find.byTooltip(l.aiSaveDialogue));
        await tester.pumpAndSettle();
        expect(
          find.text(l.aiSaveDialogueConfirmTitle),
          findsOneWidget,
          reason: locale.toString(),
        );
        expect(
          find.text(l.aiSaveDialogueConfirmBody),
          findsOneWidget,
          reason: locale.toString(),
        );
        final save = find.widgetWithText(FilledButton, l.saveLabel);
        expect(save.hitTestable(), findsOneWidget, reason: locale.toString());
        final cancel = find.widgetWithText(TextButton, l.cancel);
        expect(cancel.hitTestable(), findsOneWidget, reason: locale.toString());
        expect(tester.takeException(), isNull, reason: locale.toString());
        await tester.tap(cancel);
        await tester.pumpAndSettle();
        expect(message.savedAt, isNull);
      }
      await tester.pumpWidget(const SizedBox());
      chat.dispose();
    },
    variant: TargetPlatformVariant.only(TargetPlatform.iOS),
  );
}
