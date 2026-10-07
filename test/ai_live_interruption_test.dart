import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:app/infrastructure/ai/ai_history_store.dart';
import 'package:app/presentation/chats/ai/ai_chat_controller.dart';

class _SlowAudioStore extends AiHistoryStore {
  _SlowAudioStore() : super('call');
  Completer<void>? audioGate;
  @override
  Future<String> saveAudio(Uint8List audio, {String extension = 'wav'}) async {
    await audioGate?.future;
    return super.saveAudio(audio, extension: extension);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late Directory root;
  late _SlowAudioStore store;
  late AiChatController controller;
  final methods = <String>[];
  Future<void> event(String type, {String? text}) =>
      controller.receiveCallEventForTesting(
        jsonEncode({
          'type': type,
          if (text != null) ...{'role': 'model', 'text': text},
        }),
      );
  setUp(() async {
    methods.clear();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('com.llfbandit.record/messages'),
          (_) async => null,
        );
    root = await Directory.systemTemp.createTemp('bantera-call-interruption');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(AiChatController.audio, (call) async {
          methods.add(call.method);
          if (call.method == 'storagePath') return root.path;
          if (call.method == 'playedFrames') return 0;
          return null;
        });
    store = _SlowAudioStore();
    await store.load();
    controller = AiChatController.forTesting(store)..loaded = true;
  });
  tearDown(() async {
    controller.dispose();
    await root.delete(recursive: true);
  });
  test(
    'interruption before transcription preserves visible audio and duration after reload',
    () async {
      await controller.receiveCallEventForTesting(Uint8List(24000));
      final bubble = controller.messages.single;
      expect(controller.isReceiving(bubble), isTrue);
      expect(bubble.durationMs, 500);
      await event('interrupted');
      expect(controller.messages.single, same(bubble));
      expect(controller.isReceiving(bubble), isFalse);
      expect(bubble.audio, isNotNull);
      expect(bubble.failed, isFalse);
      expect(methods, contains('clear'));
      await event('turnComplete');
      expect(controller.messages, hasLength(1));
      final restored = AiHistoryStore('call');
      await restored.load();
      expect(restored.messages.single.id, bubble.id);
      expect(restored.messages.single.durationMs, 500);
      expect(await File(restored.path(bubble.audio!)).length(), 24044);
    },
  );
  test(
    'partial bubble stays visible during slow interruption save and later reply is distinct',
    () async {
      await controller.receiveCallEventForTesting(Uint8List(48000));
      await event('transcript', text: 'Here is my unfinished');
      final bubble = controller.messages.single;
      store.audioGate = Completer<void>();
      final interrupt = event('interrupted');
      expect(controller.messages.single, same(bubble));
      expect(bubble.text, 'Here is my unfinished');
      store.audioGate!.complete();
      await interrupt;
      await event('turnComplete');
      await controller.receiveCallEventForTesting(Uint8List(24000));
      await event('transcript', text: 'Go ahead.');
      expect(controller.messages, hasLength(2));
      expect(controller.messages.last.id, isNot(bubble.id));
      await event('turnComplete');
      expect(controller.messages.first, same(bubble));
      expect(controller.messages.last.text, 'Go ahead.');
    },
  );
}
