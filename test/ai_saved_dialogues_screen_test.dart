import 'package:app/infrastructure/ai/ai_history_store.dart';
import 'package:app/l10n/app_localizations.dart';
import 'package:app/presentation/chats/ai/ai_chat_controller.dart';
import 'package:app/presentation/chats/ai/ai_saved_dialogues_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

class _SavedController extends AiChatController {
  _SavedController() : super.forTesting(AiHistoryStore('test'));

  bool fail = false;
  final unsaved = <String>[];

  @override
  bool canSaveMessage(AiMessage message) => true;

  @override
  Future<void> removeSavedMessages(List<AiMessage> messages) async {
    if (fail) throw StateError('write failed');
    for (final message in messages) {
      unsaved.add(message.id);
      message.savedAt = null;
    }
    changed();
  }
}

void main() {
  late _SavedController controller;
  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('com.llfbandit.record/messages'),
          (_) async => null,
        );
    controller = _SavedController();
  });
  tearDown(() => controller.dispose());

  Widget app({
    Locale locale = const Locale('en'),
    Widget? home,
    double textScale = 1,
    Brightness brightness = Brightness.light,
  }) => MaterialApp(
    theme: ThemeData(brightness: brightness),
    builder: (context, child) => MediaQuery(
      data: MediaQuery.of(
        context,
      ).copyWith(textScaler: TextScaler.linear(textScale)),
      child: child!,
    ),
    locale: locale,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: home ?? AiSavedDialoguesScreen(controller: controller),
  );

  testWidgets('saved rows are newest first and tap returns the original ID', (
    tester,
  ) async {
    controller.store.messages.addAll([
      AiMessage(id: 'unsaved', role: 'user', text: 'Not saved'),
      AiMessage(
        id: 'older',
        role: 'user',
        text: 'The first saved bubble',
        savedAt: DateTime.utc(2026, 10, 28),
      ),
      AiMessage(
        id: 'newer',
        role: 'model',
        text: 'Spoken answer',
        formattedText:
            '## Try **this**\n\nRead [the example](https://example.com).',
        savedAt: DateTime.utc(2026, 10, 29),
      ),
    ]);
    String? chosen;
    await tester.pumpWidget(
      app(
        home: Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () async {
                chosen = await Navigator.of(context).push<String>(
                  MaterialPageRoute(
                    builder: (_) =>
                        AiSavedDialoguesScreen(controller: controller),
                  ),
                );
              },
              child: const Text('Open saved'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Open saved'));
    await tester.pumpAndSettle();
    expect(find.text('Not saved'), findsNothing);
    expect(find.text('Try this Read the example.'), findsOneWidget);
    expect(
      tester
          .getTopLeft(find.byKey(const ValueKey('ai-saved-dialogue-newer')))
          .dy,
      lessThan(
        tester
            .getTopLeft(find.byKey(const ValueKey('ai-saved-dialogue-older')))
            .dy,
      ),
    );
    await tester.tap(find.text('Try this Read the example.'));
    await tester.pumpAndSettle();
    expect(chosen, 'newer');
    expect(find.text('Open saved'), findsOneWidget);
  });

  testWidgets(
    'unsave keeps the original bubble and errors keep the saved row',
    (tester) async {
      final message = AiMessage(
        id: 'saved',
        role: 'user',
        text: 'Keep my original bubble',
        savedAt: DateTime.utc(2026, 10, 29),
      );
      controller.store.messages.add(message);
      await tester.pumpWidget(app());
      controller.fail = true;
      await tester.drag(
        find.byKey(const ValueKey('ai-saved-dialogue-saved')),
        const Offset(-160, 0),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Unsave dialogue'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(FilledButton, 'Unsave dialogue'));
      await tester.pumpAndSettle();
      expect(find.text('Keep my original bubble'), findsOneWidget);
      expect(message.savedAt, isNotNull);
      expect(find.byType(SnackBar), findsOneWidget);
      controller.fail = false;
      await tester.drag(
        find.byKey(const ValueKey('ai-saved-dialogue-saved')),
        const Offset(-160, 0),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Unsave dialogue'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(FilledButton, 'Unsave dialogue'));
      await tester.pumpAndSettle();
      expect(controller.unsaved, ['saved']);
      expect(controller.store.messages, contains(message));
      expect(find.text('No saved dialogues yet'), findsOneWidget);
    },
  );

  testWidgets('swipe reveals only; cancel keeps bookmark; clear all confirms', (
    tester,
  ) async {
    for (final id in ['one', 'two']) {
      controller.store.messages.add(
        AiMessage(
          id: id,
          role: 'user',
          text: id,
          savedAt: DateTime.utc(2026, 10, 29),
        ),
      );
    }
    await tester.pumpWidget(app());
    expect(find.byTooltip('Unsave dialogue'), findsNothing);
    await tester.drag(
      find.byKey(const ValueKey('ai-saved-dialogue-one')),
      const Offset(-160, 0),
    );
    await tester.pumpAndSettle();
    expect(controller.unsaved, isEmpty);
    await tester.tap(find.byTooltip('Unsave dialogue'));
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsOneWidget);
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(controller.unsaved, isEmpty);
    await tester.tap(find.byTooltip('Clear all'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(controller.unsaved, isEmpty);
    await tester.tap(find.byTooltip('Clear all'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Clear all'));
    await tester.pumpAndSettle();
    expect(controller.unsaved, containsAll(['one', 'two']));
    expect(controller.store.messages.length, 2);
    expect(find.text('No saved dialogues yet'), findsOneWidget);
    expect(
      tester
          .widget<IconButton>(
            find.byWidgetPredicate(
              (widget) => widget is IconButton && widget.tooltip == 'Clear all',
            ),
          )
          .onPressed,
      isNull,
    );
  });

  testWidgets('failed clear all leaves saved dialogues available to retry', (
    tester,
  ) async {
    controller.store.messages.add(
      AiMessage(
        id: 'one',
        role: 'user',
        text: 'Keep me',
        savedAt: DateTime.utc(2026, 10, 29),
      ),
    );
    controller.fail = true;
    await tester.pumpWidget(app());
    await tester.tap(find.byTooltip('Clear all'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Clear all'));
    await tester.pumpAndSettle();
    expect(find.text('Keep me'), findsOneWidget);
    expect(controller.store.messages.single.savedAt, isNotNull);
    expect(find.byType(SnackBar), findsOneWidget);
    expect(
      tester
          .widget<IconButton>(
            find.byWidgetPredicate(
              (widget) => widget is IconButton && widget.tooltip == 'Clear all',
            ),
          )
          .onPressed,
      isNotNull,
    );
  });

  testWidgets('saved list fits narrow phones in every supported locale', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 720);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    controller.store.messages.add(
      AiMessage(
        role: 'user',
        text:
            'A long saved dialogue that wraps across several lines without overflowing the available width.',
        savedAt: DateTime.utc(2026, 10, 29),
      ),
    );
    for (final locale in AppLocalizations.supportedLocales) {
      await tester.pumpWidget(
        app(locale: locale, textScale: 2, brightness: Brightness.dark),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull, reason: locale.toString());
      await tester.tap(find.byIcon(Icons.delete_outline_rounded));
      await tester.pumpAndSettle();
      expect(find.byType(AlertDialog), findsOneWidget);
      expect(tester.takeException(), isNull, reason: 'dialog $locale');
      await tester.tap(find.byType(TextButton));
      await tester.pumpAndSettle();
    }
  });
}
