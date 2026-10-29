import 'dart:async';
import 'dart:io';

import 'package:app/infrastructure/ai/ai_history_store.dart';
import 'package:app/presentation/chats/ai/ai_chat_controller.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

class _ControlledHistoryStore extends AiHistoryStore {
  _ControlledHistoryStore() : super('test');

  Completer<void>? saveGate;
  bool failSave = false;
  int saves = 0;

  @override
  Future<void> save({AiMessage? audioMessage, Uint8List? audioBytes}) async {
    saves++;
    await saveGate?.future;
    if (failSave) throw const FileSystemException('Storage unavailable');
    await super.save(audioMessage: audioMessage, audioBytes: audioBytes);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late Directory root;
  setUp(() async {
    root = await Directory.systemTemp.createTemp('bantera-ai-saved-test');
    final messenger =
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    messenger.setMockMethodCallHandler(
      AiChatController.audio,
      (call) async => call.method == 'storagePath' ? root.path : null,
    );
    messenger.setMockMethodCallHandler(
      const MethodChannel('com.llfbandit.record/messages'),
      (_) async => null,
    );
  });
  tearDown(() async => root.delete(recursive: true));

  test('old history and invalid optional saved dates remain readable', () {
    final legacy = AiMessage(role: 'model', text: 'A useful reply').toJson();
    expect(legacy, isNot(contains('savedAt')));
    expect(AiMessage.fromJson(legacy).savedAt, isNull);
    expect(
      AiMessage.fromJson({...legacy, 'savedAt': 'not a date'}).savedAt,
      isNull,
    );
    expect(AiMessage.fromJson({...legacy, 'savedAt': 1}).savedAt, isNull);
  });

  test(
    'bookmark and removal survive reopen and stay in their account',
    () async {
      final store = AiHistoryStore('test');
      final chat = AiChatController.forTesting(store);
      addTearDown(chat.dispose);
      await chat.initialize();
      final message = AiMessage(
        role: 'model',
        text: 'A useful dialogue',
        timeZone: 'UTC',
      );
      store.messages.add(message);
      var notifications = 0;
      chat.addListener(() => notifications++);

      await chat.toggleSavedMessage(message);
      expect(message.savedAt, isNotNull);
      expect(notifications, 2);
      final restored = AiHistoryStore('test');
      await restored.load();
      expect(restored.messages.single.id, message.id);
      expect(restored.messages.single.savedAt, message.savedAt!.toUtc());
      expect(restored.context().single, isNot(contains('savedAt')));
      final otherAccount = AiHistoryStore('other');
      await otherAccount.load();
      expect(otherAccount.messages, isEmpty);

      await chat.toggleSavedMessage(message);
      final removed = AiHistoryStore('test');
      await removed.load();
      expect(removed.messages.single.savedAt, isNull);
      expect(removed.messages.single.id, message.id);
      expect(removed.messages.single.text, 'A useful dialogue');
    },
  );

  test(
    'repeated taps cannot toggle a bookmark during its pending write',
    () async {
      final store = _ControlledHistoryStore();
      final chat = AiChatController.forTesting(store);
      addTearDown(chat.dispose);
      await chat.initialize();
      final message = AiMessage(
        role: 'user',
        text: 'Keep this',
        timeZone: 'UTC',
      );
      store.messages.add(message);
      store.saveGate = Completer<void>();
      final saving = chat.toggleSavedMessage(message);
      final savedAt = message.savedAt;
      expect(chat.canSaveMessage(message), isFalse);
      await chat.toggleSavedMessage(message);
      expect(message.savedAt, savedAt);
      expect(store.saves, 1);
      store.saveGate!.complete();
      await saving;
      expect(chat.canSaveMessage(message), isTrue);
    },
  );

  test('failed write rolls back bookmark state and allows retry', () async {
    final store = _ControlledHistoryStore();
    final chat = AiChatController.forTesting(store);
    addTearDown(chat.dispose);
    await chat.initialize();
    final message = AiMessage(
      role: 'model',
      text: 'Keep this',
      timeZone: 'UTC',
    );
    store.messages.add(message);
    store.failSave = true;
    await expectLater(
      chat.toggleSavedMessage(message),
      throwsA(isA<FileSystemException>()),
    );
    expect(message.savedAt, isNull);
    expect(chat.canSaveMessage(message), isTrue);
    store.failSave = false;
    await chat.toggleSavedMessage(message);
    final savedAt = message.savedAt;
    store.failSave = true;
    await expectLater(
      chat.toggleSavedMessage(message),
      throwsA(isA<FileSystemException>()),
    );
    expect(message.savedAt, savedAt);
  });

  test(
    'only finished messages still in the current history can be saved',
    () async {
      final store = AiHistoryStore('test');
      final chat = AiChatController.forTesting(store);
      addTearDown(chat.dispose);
      await chat.initialize();
      final message = AiMessage(role: 'model', text: 'Keep this');
      expect(chat.canSaveMessage(message), isFalse);
      store.messages.add(message);
      expect(chat.canSaveMessage(message), isTrue);
      chat.busy = true;
      await chat.toggleSavedMessage(message);
      expect(message.savedAt, isNull);
      chat.busy = false;
      message.failed = true;
      expect(chat.canSaveMessage(message), isFalse);
      message.failed = false;
      chat.calling = true;
      expect(chat.canSaveMessage(message), isFalse);
      chat.calling = false;
      chat.recording = true;
      expect(chat.canSaveMessage(message), isFalse);
      chat.recording = false;
      message.text = '';
      expect(chat.canSaveMessage(message), isFalse);
      message.text = 'Keep this';
      store.messages.remove(message);
      await chat.toggleSavedMessage(message);
      expect(message.savedAt, isNull);
    },
  );

  test(
    'audio-only bookmarks can be removed after their audio is cleared',
    () async {
      final store = AiHistoryStore('test');
      final chat = AiChatController.forTesting(store);
      addTearDown(chat.dispose);
      await chat.initialize();
      final message = AiMessage(
        role: 'model',
        audio: 'voice.wav',
        timeZone: 'UTC',
      );
      store.messages.add(message);
      await File(store.path('voice.wav')).writeAsBytes([1, 2, 3]);
      await chat.toggleSavedMessage(message);
      await store.clear(mode: AiHistoryClearMode.audioOnly);
      expect(message.audio, isNull);
      expect(message.displayText, isEmpty);
      expect(message.savedAt, isNotNull);
      expect(chat.canSaveMessage(message), isTrue);
      await chat.toggleSavedMessage(message);
      expect(chat.canSaveMessage(message), isFalse);
      final restored = AiHistoryStore('test');
      await restored.load();
      expect(restored.messages.single.savedAt, isNull);
    },
  );

  test(
    'audio cleanup keeps saved text, deletion and full clear remove it',
    () async {
      final store = AiHistoryStore('test');
      await store.load();
      final message = AiMessage(
        role: 'model',
        text: 'Saved dialogue',
        audio: 'voice.wav',
        timeZone: 'UTC',
        savedAt: DateTime.utc(2026, 10, 29),
      );
      store.messages.add(message);
      await File(store.path('voice.wav')).writeAsBytes([1, 2, 3]);
      await store.save();
      await store.clear(mode: AiHistoryClearMode.audioOnly);
      final restored = AiHistoryStore('test');
      await restored.load();
      expect(restored.messages.single.savedAt, message.savedAt);
      expect(restored.messages.single.text, 'Saved dialogue');
      expect(restored.messages.single.audio, isNull);
      await restored.deleteMessage(restored.messages.single);
      final afterDelete = AiHistoryStore('test');
      await afterDelete.load();
      expect(afterDelete.messages, isEmpty);
      afterDelete.messages.add(message);
      await afterDelete.save();
      await afterDelete.clear();
      final afterClear = AiHistoryStore('test');
      await afterClear.load();
      expect(afterClear.messages, isEmpty);
    },
  );
}
