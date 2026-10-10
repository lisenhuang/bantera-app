import 'package:app/core/ai_callback_notifier.dart';
import 'package:app/infrastructure/ai/ai_history_store.dart';
import 'package:app/infrastructure/callkit_service.dart';
import 'package:app/l10n/app_localizations.dart';
import 'package:app/presentation/chats/ai/ai_callback_host.dart';
import 'package:app/presentation/chats/ai/ai_chat_controller.dart';
import 'package:app/presentation/chats/ai/ai_chat_navigation.dart';
import 'package:app/presentation/chats/ai/ai_chat_screen.dart';
import 'package:app/presentation/chats/ai/ai_message_markdown.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

class _AppCallKit extends CallKitService {
  _AppCallKit() : super.forTesting();
  @override
  bool get supported => false;
}

class _OpeningController extends AiChatController {
  _OpeningController() : super.forTesting(AiHistoryStore('test'));
  int loads = 0;
  @override
  Future<void> initialize() async {
    loads++;
    loaded = true;
    changed();
  }
}

void main() {
  setUp(() {
    final messenger =
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    for (final channel in [
      'xyz.luan/audioplayers.global',
      'xyz.luan/audioplayers.global/events',
      'com.llfbandit.record/messages',
    ]) {
      messenger.setMockMethodCallHandler(
        MethodChannel(channel),
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
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'history waits for completed entrance and cancelled opens never load',
    (tester) async {
      final navigator = GlobalKey<NavigatorState>();
      await tester.pumpWidget(
        MaterialApp(
          navigatorKey: navigator,
          theme: ThemeData(platform: TargetPlatform.iOS),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const Scaffold(),
        ),
      );
      final first = _OpeningController();
      navigator.currentState!.push(
        MaterialPageRoute<void>(
          builder: (_) => AiChatScreen.ownedControllerForTesting(
            createController: () => first,
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      expect(first.loads, 0);
      await tester.pumpAndSettle();
      expect(first.loads, 1);
      navigator.currentState!.pop();
      await tester.pumpAndSettle();
      final cancelled = _OpeningController();
      navigator.currentState!.push(
        MaterialPageRoute<void>(
          builder: (_) => AiChatScreen.ownedControllerForTesting(
            createController: () => cancelled,
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));
      navigator.currentState!.pop();
      await tester.pumpAndSettle();
      expect(cancelled.loads, 0);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'large conversation opens at newest message and lazily renders Markdown',
    (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final store = AiHistoryStore('test');
      for (var i = 0; i < 2000; i++) {
        store.messages.add(
          AiMessage(
            role: 'model',
            text: '**Practice $i**\n\n- Speak clearly\n- Listen carefully',
          ),
        );
      }
      final chat = AiChatController.forTesting(store)..loaded = true;
      final navigation = AiChatNavigation();
      final navigator = GlobalKey<NavigatorState>();
      await tester.pumpWidget(
        MaterialApp(
          navigatorKey: navigator,
          theme: ThemeData(platform: TargetPlatform.iOS),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const Scaffold(body: Text('Chats')),
        ),
      );
      // Start a real iOS page transition; the controller changes as it completes.
      navigation.open(
        navigator.currentState!,
        (_) => AiChatScreen(controller: chat),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      chat.changed();
      await tester.pumpAndSettle();
      final list = tester.widget<ListView>(find.byType(ListView));
      expect(list.childrenDelegate, isA<SliverChildBuilderDelegate>());
      expect(list.controller!.position.pixels, 0);
      expect(list.controller!.position.isScrollingNotifier.value, isFalse);
      final visible = tester
          .widgetList<AiMessageMarkdown>(find.byType(AiMessageMarkdown))
          .toList();
      expect(visible.length, lessThan(20));
      expect(visible.any((m) => m.text.contains('Practice 1999')), isTrue);
      expect(visible.any((m) => m.text.contains('Practice 0**')), isFalse);
      expect(
        find.textContaining('Practice 1999', findRichText: true).hitTestable(),
        findsOneWidget,
      );
      expect(
        ModalRoute.of(
          tester.element(find.byType(AiChatScreen)),
        )!.animation!.isCompleted,
        isTrue,
      );
      store.messages.add(
        AiMessage(role: 'model', text: '# New reply\n\n**Broth** is *light*.'),
      );
      chat.changed();
      await tester.pumpAndSettle();
      expect(
        find
            .textContaining('Broth is light.', findRichText: true)
            .hitTestable(),
        findsOneWidget,
      );
      expect(list.controller!.position.pixels, 0);
      expect(tester.takeException(), isNull);
      navigator.currentState!.pop();
      await tester.pumpAndSettle();
      chat.dispose();
    },
  );

  testWidgets(
    'system callbacks never create an automatic in-app conversation',
    (tester) async {
      for (final system in [true, false]) {
        final service = system ? CallKitService.forTesting() : _AppCallKit();
        final chat = AiChatController.forTesting(AiHistoryStore('test'))
          ..loaded = true;
        final callback = AiCallbackNotifier.forTesting(
          callKit: service,
          createController: () => chat,
          acceptCallback: (_) async => 200,
        );
        callback.id = 'callback';
        callback.ringing = true;
        await tester.pumpWidget(
          MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Stack(
              children: [
                const Scaffold(body: Text('Your current page')),
                AiCallbackHost(callback: callback),
              ],
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(
          find.text('Your current page').hitTestable(),
          system ? findsOneWidget : findsNothing,
        );
        expect(find.text('Accept'), system ? findsNothing : findsOneWidget);
        if (system) {
          callback.accepted = true;
          callback.controller = chat;
          callback.notifyListeners();
          await tester.pumpAndSettle();
          expect(find.byType(AiChatScreen), findsNothing);
          expect(find.text('Your current page').hitTestable(), findsOneWidget);
        }
        await tester.pumpWidget(const SizedBox.shrink());
        callback.dispose();
        chat.dispose();
      }
    },
  );
}
