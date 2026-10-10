import 'dart:async';
import 'package:app/core/ai_callback_notifier.dart';
import 'package:app/infrastructure/ai/ai_history_store.dart';
import 'package:app/infrastructure/callkit_service.dart';
import 'package:app/presentation/chats/ai/ai_chat_controller.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

class _Call extends AiChatController {
  _Call() : super.forTesting(AiHistoryStore('test'), callKitManaged: true);
  int starts = 0, ends = 0;
  bool disposed = false;
  @override
  Future<void> initialize() async {
    loaded = true;
  }

  @override
  Future<void> startCall() async {
    starts++;
    calling = true;
    connected = true;
    changed();
  }

  @override
  Future<void> endCall() async {
    if (!calling) return;
    ends++;
    calling = false;
    changed();
  }

  @override
  void dispose() {
    disposed = true;
    super.dispose();
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const channel = MethodChannel('bantera/callkit');
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
  setUp(() {
    messenger.setMockMethodCallHandler(
      const MethodChannel('com.llfbandit.record/messages'),
      (_) async => null,
    );
  });
  Future<void> event(
    String type, {
    String id = 'callback',
    bool muted = false,
    bool speaker = false,
  }) async {
    await messenger.handlePlatformMessage(
      channel.name,
      const StandardMethodCodec().encodeMethodCall(
        MethodCall('event', {
          'event': type,
          'callId': id,
          'callerUserId': AiCallbackNotifier.identity,
          'muted': muted,
          'speaker': speaker,
        }),
      ),
      (_) {},
    );
    await Future<void>.delayed(const Duration(milliseconds: 10));
  }

  test(
    'answer waits for system audio then talks without any chat widget; system mute and end work',
    () async {
      final service = CallKitService.forTesting();
      final methods = <String>[];
      messenger.setMockMethodCallHandler(channel, (call) async {
        methods.add(call.method);
        return true;
      });
      final chat = _Call();
      final accepted = Completer<int>();
      final callback = AiCallbackNotifier.forTesting(
        callKit: service,
        createController: () => chat,
        acceptCallback: (_) => accepted.future,
      );
      callback.id = 'callback';
      callback.ringing = true;
      addTearDown(callback.dispose);
      await event('answer');
      expect(chat.starts, 0);
      // Activation queued during backend acceptance must wait for initialization.
      await event('audioActivated');
      expect(chat.starts, 0);
      accepted.complete(200);
      await Future<void>.delayed(const Duration(milliseconds: 20));
      expect(methods, ['answerReady', 'audioStarted']);
      expect(callback.accepted, isTrue);
      expect(chat.starts, 1);
      expect(chat.calling, isTrue);
      await event('audioActivated');
      expect(chat.starts, 1);
      final previousMethods = List<String>.of(methods);
      await event('audioRoute', speaker: true);
      expect(chat.speaker, isTrue);
      await event('audioRoute', speaker: false);
      expect(chat.speaker, isFalse);
      expect(
        methods,
        previousMethods,
      ); // Never write observed routes back to iOS.
      await event('mute', muted: true);
      expect(chat.muted, isTrue);
      chat.toggleMute();
      await Future<void>.delayed(Duration.zero);
      expect(methods.last, 'requestMute');
      await event('ended', id: 'stale-callback');
      expect(chat.calling, isTrue);
      await event('ended');
      expect(chat.ends, 1);
      expect(chat.disposed, isTrue);
      expect(callback.id, isNull);
      expect(methods.last, 'end');
    },
  );
  test(
    'activation before answer is retained without starting before acceptance',
    () async {
      final service = CallKitService.forTesting();
      final methods = <String>[];
      messenger.setMockMethodCallHandler(channel, (call) async {
        methods.add(call.method);
        return true;
      });
      final chat = _Call();
      final callback = AiCallbackNotifier.forTesting(
        callKit: service,
        createController: () => chat.disposed ? _Call() : chat,
        acceptCallback: (_) async => 200,
      );
      callback.id = 'callback';
      callback.ringing = true;
      addTearDown(callback.dispose);
      await event('audioActivated');
      await event('audioRoute', speaker: true);
      expect(chat.starts, 0);
      await event('answer');
      expect(chat.starts, 1);
      expect(chat.speaker, isTrue);
      expect(methods, ['answerReady', 'audioStarted']);
      await event('audioActivated');
      expect(chat.starts, 1);
      await event('ended');
      // An old activation must never start a subsequent callback.
      callback.id = 'second';
      callback.ringing = true;
      await event('answer', id: 'second');
      expect(chat.starts, 1);
      await callback.close();
    },
  );
  test(
    'native audio failure ends the system call without opening a view',
    () async {
      final service = CallKitService.forTesting();
      final methods = <String>[];
      messenger.setMockMethodCallHandler(channel, (call) async {
        methods.add(call.method);
        return true;
      });
      final callback = AiCallbackNotifier.forTesting(
        callKit: service,
        createController: _Call.new,
        acceptCallback: (_) async => 200,
      );
      callback.id = 'callback';
      callback.ringing = true;
      addTearDown(callback.dispose);
      await event('answer');
      await event('audioFailed');
      expect(callback.id, isNull);
      expect(methods.last, 'end');
    },
  );
  test('ending from conversation also closes the system call', () async {
    final service = CallKitService.forTesting();
    final methods = <String>[];
    messenger.setMockMethodCallHandler(channel, (call) async {
      methods.add(call.method);
      return true;
    });
    final chat = _Call();
    final callback = AiCallbackNotifier.forTesting(
      callKit: service,
      createController: () => chat,
      acceptCallback: (_) async => 200,
    );
    callback.id = 'callback';
    callback.ringing = true;
    addTearDown(callback.dispose);
    await event('answer');
    expect(chat.starts, 0);
    await event('audioActivated');
    await chat.endCall();
    await Future<void>.delayed(Duration.zero);
    expect(callback.id, isNull);
    expect(methods, ['answerReady', 'audioStarted', 'end']);
  });
}
