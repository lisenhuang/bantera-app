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
  Future<void> toggleSavedMessage(AiMessage message) async {
    if (fail) throw StateError('write failed');
    unsaved.add(message.id);
    message.savedAt = null;
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

  Widget app({Locale locale = const Locale('en'), Widget? home}) => MaterialApp(
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
      await tester.tap(find.byTooltip('Unsave dialogue'));
      await tester.pumpAndSettle();
      expect(find.text('Keep my original bubble'), findsOneWidget);
      expect(message.savedAt, isNotNull);
      expect(find.byType(SnackBar), findsOneWidget);
      controller.fail = false;
      await tester.tap(find.byTooltip('Unsave dialogue'));
      await tester.pumpAndSettle();
      expect(controller.unsaved, ['saved']);
      expect(controller.store.messages, contains(message));
      expect(find.text('No saved dialogues yet'), findsOneWidget);
    },
  );

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
      await tester.pumpWidget(app(locale: locale));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull, reason: locale.toString());
    }
  });
}
