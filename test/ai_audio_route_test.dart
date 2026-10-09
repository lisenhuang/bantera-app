import 'dart:async';
import 'package:app/infrastructure/ai/ai_history_store.dart';
import 'package:app/presentation/chats/ai/ai_chat_controller.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
  late AiChatController chat;
  setUp(() {
    messenger.setMockMethodCallHandler(
      const MethodChannel('com.llfbandit.record/messages'),
      (_) async => null,
    );
    chat = AiChatController.forTesting(AiHistoryStore('route-test'))
      ..calling = true;
  });
  tearDown(() {
    chat.dispose();
    messenger.setMockMethodCallHandler(AiChatController.audio, null);
  });

  test(
    'button reflects hardware even when the requested route is unavailable',
    () async {
      final requested = <Object?>[];
      messenger.setMockMethodCallHandler(AiChatController.audio, (call) async {
        requested.add(call.arguments);
        return true; // Receiver is unavailable; speaker remains selected.
      });
      await chat.setSpeaker();
      expect(requested, [false]);
      expect(chat.speaker, isTrue);
      expect(chat.calling, isTrue);
      messenger.setMockMethodCallHandler(
        AiChatController.audio,
        (_) async => false,
      );
      await chat.setSpeaker();
      expect(chat.speaker, isFalse);
    },
  );

  test('rapid taps do not race native route changes', () async {
    var count = 0;
    final route = Completer<bool>();
    messenger.setMockMethodCallHandler(AiChatController.audio, (_) {
      count++;
      return route.future;
    });
    final pending = chat.setSpeaker();
    await chat.setSpeaker();
    await Future<void>.delayed(Duration.zero);
    expect(count, 1);
    route.complete(false);
    await pending;
    expect(chat.speaker, isFalse);
  });

  test(
    'failed switch preserves a route update and never ends the call',
    () async {
      messenger.setMockMethodCallHandler(AiChatController.audio, (_) async {
        chat.updateSpeakerRoute(
          false,
        ); // A connected headset changed the route.
        throw PlatformException(code: 'route_unavailable');
      });
      await chat.setSpeaker();
      expect(chat.speaker, isFalse);
      expect(chat.calling, isTrue);
      expect(chat.failed, isFalse);
    },
  );

  test('late platform reply cannot change a closed chat', () async {
    final route = Completer<bool>();
    messenger.setMockMethodCallHandler(
      AiChatController.audio,
      (_) => route.future,
    );
    final pending = chat.setSpeaker();
    chat.calling = false;
    route.complete(false);
    await pending;
    expect(chat.speaker, isTrue);
  });

  test('older native bridges returning no route remain compatible', () async {
    messenger.setMockMethodCallHandler(
      AiChatController.audio,
      (_) async => null,
    );
    await chat.setSpeaker();
    expect(chat.speaker, isFalse);
    await chat.setSpeaker();
    expect(chat.speaker, isTrue);
  });
}
