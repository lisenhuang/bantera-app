import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:app/infrastructure/ai/ai_history_store.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late Directory root;
  setUp(() async {
    root = await Directory.systemTemp.createTemp('bantera-ai-history-test');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('bantera/ai_audio'),
          (call) async => call.method == 'storagePath' ? root.path : null,
        );
  });
  tearDown(() async {
    await root.delete(recursive: true);
  });
  test(
    'history and audio stay isolated per account and clear removes both',
    () async {
      final alice = AiHistoryStore('account:alice');
      await alice.load();
      final bob = AiHistoryStore('account:bob');
      await bob.load();
      final audio = await alice.saveAudio(Uint8List.fromList([1, 2, 3]));
      alice.messages.add(
        AiMessage(role: 'user', text: 'I live in Auckland', audio: audio),
      );
      await alice.save();
      bob.messages.add(AiMessage(role: 'user', text: 'Bonjour'));
      await bob.save();
      final restored = AiHistoryStore('account:alice');
      await restored.load();
      expect(restored.messages.single.text, 'I live in Auckland');
      expect(await File(restored.path(audio)).exists(), isTrue);
      await restored.clear();
      final cleared = AiHistoryStore('account:alice');
      await cleared.load();
      expect(cleared.messages, isEmpty);
      expect(await File(restored.path(audio)).exists(), isFalse);
      final other = AiHistoryStore('account:bob');
      await other.load();
      expect(other.messages.single.text, 'Bonjour');
    },
  );
  test('queued writes cannot restore cleared conversation memory', () async {
    final store = AiHistoryStore('account');
    await store.load();
    store.messages.add(AiMessage(role: 'user', text: 'Forget me'));
    final saving = store.save();
    final clearing = store.clear();
    await Future.wait([saving, clearing]);
    final restored = AiHistoryStore('account');
    await restored.load();
    expect(restored.context(), isEmpty);
  });
  test(
    'bounded context keeps early details and recent conversation, excluding failed messages',
    () {
      final messages = List.generate(
        120,
        (i) => AiMessage(role: i.isEven ? 'user' : 'model', text: 'message $i'),
      );
      messages.add(AiMessage(role: 'user', text: 'unsent', failed: true));
      final context = AiHistoryStore.contextFor(messages);
      expect(context.length, 80);
      expect(context.first['text'], 'message 0');
      expect(context.last['text'], 'message 119');
      expect(jsonEncode(context), isNot(contains('unsent')));
      final long = AiHistoryStore.contextFor(
        List.generate(100, (_) => AiMessage(role: 'user', text: 'x' * 5000)),
      );
      expect(
        long.fold<int>(0, (sum, t) => sum + t['text']!.length),
        lessThanOrEqualTo(70000),
      );
    },
  );
  test(
    'context includes UTC timestamps and keeps the latest turn within the budget',
    () async {
      final last = DateTime.utc(2026, 10, 9, 1);
      final messages = List.generate(
        100,
        (i) => AiMessage(
          role: i.isEven ? 'user' : 'model',
          text: 'message $i ${'x' * 3000}',
          createdAt: last.subtract(Duration(minutes: 99 - i)),
        ),
      );
      final context = AiHistoryStore.contextFor(messages);
      expect(context.last['text'], startsWith('message 99 '));
      expect(context.last['createdAt'], last.toIso8601String());
      expect(
        context.map((m) => m['createdAt']).toList(),
        orderedEquals((context.map((m) => m['createdAt']!).toList()..sort())),
      );
      final store = AiHistoryStore('timing');
      await store.load();
      store.messages.addAll(messages);
      await store.save();
      final reopened = AiHistoryStore('timing');
      await reopened.load();
      expect(reopened.context().last['createdAt'], last.toIso8601String());
      expect(
        reopened.context(excluding: messages.last.id).last['text'],
        startsWith('message 98 '),
      );
      await reopened.clear();
      expect(reopened.context(), isEmpty);
    },
  );
  test(
    'new messages retain their original zone after travelling and reopening',
    () async {
      var zone = 'Pacific/Auckland';
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
            const MethodChannel('flutter_timezone'),
            (_) async => zone,
          );
      addTearDown(
        () => TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(
              const MethodChannel('flutter_timezone'),
              null,
            ),
      );
      final store = AiHistoryStore('traveller');
      await store.load();
      final before = AiMessage(role: 'user', text: 'I plan to fly tomorrow');
      store.messages.add(before);
      await store.save();
      expect(before.timeZone, 'Pacific/Auckland');
      zone = 'Asia/Shanghai';
      store.messages.add(AiMessage(role: 'user', text: 'Hello again'));
      await store.save();
      final reopened = AiHistoryStore('traveller');
      await reopened.load();
      expect(reopened.context().first['timeZone'], 'Pacific/Auckland');
      expect(reopened.context().last['timeZone'], 'Asia/Shanghai');
      expect(
        reopened.messages.first.createdAt.toUtc(),
        before.createdAt.toUtc(),
      );
      expect(reopened.messages.first.toJson()['createdAt'], endsWith('Z'));
      final legacy = AiMessage.fromJson({
        'role': 'user',
        'text': 'Old message',
        'createdAt': '2026-10-08T10:00:00',
      });
      store.messages.add(legacy);
      await store.save();
      expect(legacy.timeZone, isNull); // Do not invent the zone of old history.
    },
  );
  test(
    'meeting flag is shared across modes and persists after clearing history',
    () async {
      final voice = AiHistoryStore('alice');
      final call = AiHistoryStore('alice');
      await voice.load();
      await call.load();
      expect(await voice.hasMetBefore(), isFalse);
      // Receiving the first reply counts even before its transcript is saved.
      await voice.markMet();
      expect(await call.hasMetBefore(), isTrue);
      await voice.clear();
      final reopened = AiHistoryStore('alice');
      await reopened.load();
      expect(await reopened.hasMetBefore(), isTrue);
      expect(reopened.context(), isEmpty);
      final bob = AiHistoryStore('bob');
      await bob.load();
      expect(await bob.hasMetBefore(), isFalse);
    },
  );
  test(
    'cancelled or failed attempts do not consume the first meeting',
    () async {
      final store = AiHistoryStore('alice');
      await store.load();
      store.messages.add(AiMessage(role: 'user', text: 'Hi', failed: true));
      store.messages.add(
        AiMessage(role: 'model', text: 'Failed reply', failed: true),
      );
      await store.save();
      final reopened = AiHistoryStore('alice');
      await reopened.load();
      expect(await reopened.hasMetBefore(), isFalse);
    },
  );
  test(
    'existing model history migrates and deleting local data resets meeting',
    () async {
      final store = AiHistoryStore('alice');
      await store.load();
      // Simulate a history file created before the meeting flag existed.
      await File(store.path('history.json')).writeAsString(
        jsonEncode([AiMessage(role: 'model', text: 'Hello there').toJson()]),
      );
      final upgraded = AiHistoryStore('alice');
      await upgraded.load();
      expect(await upgraded.hasMetBefore(), isTrue);
      await root.delete(recursive: true);
      await root.create();
      final reinstalled = AiHistoryStore('alice');
      await reinstalled.load();
      expect(await reinstalled.hasMetBefore(), isFalse);
    },
  );
  test(
    'new audio duration is saved before playback and survives reopening',
    () async {
      final store = AiHistoryStore('duration');
      await store.load();
      final name = await store.saveAudio(
        aiWave(Uint8List(16000 * 2 * 7), 16000),
      );
      store.messages.add(AiMessage(role: 'user', audio: name));
      await store.save();
      expect(store.messages.single.durationMs, 7000);
      final reopened = AiHistoryStore('duration');
      await reopened.load();
      expect(reopened.messages.single.durationMs, 7000);
    },
  );
  test(
    'legacy call and reply WAV headers supply duration without playback',
    () async {
      final store = AiHistoryStore('legacy');
      await store.load();
      await File(
        store.path('reply.wav'),
      ).writeAsBytes(aiWave(Uint8List(24000 * 2 * 11), 24000));
      await File(store.path('history.json')).writeAsString(
        jsonEncode([
          AiMessage(role: 'model', audio: 'reply.wav').toJson(),
          AiMessage(role: 'user', audio: 'missing.wav').toJson(),
        ]),
      );
      final reopened = AiHistoryStore('legacy');
      await reopened.load();
      expect(reopened.messages.first.durationMs, 11000);
      expect(reopened.messages.last.durationMs, isNull);
      final persisted =
          jsonDecode(await File(store.path('history.json')).readAsString())
              as List;
      expect(persisted.first['durationMs'], 11000);
    },
  );
  test(
    'WAV duration accepts extra chunks and rejects truncated or invalid audio',
    () {
      final wave = aiWave(Uint8List(16000), 16000);
      expect(aiWaveDurationMs(wave), 500);
      expect(
        aiWaveDurationMs(wave.sublist(0, 44), fileLength: wave.length),
        500,
      );
      expect(aiWaveDurationMs(wave.sublist(0, 44)), isNull);
      expect(aiWaveDurationMs(Uint8List(44)), isNull);
      final extra = Uint8List(wave.length + 12);
      extra.setRange(0, 12, wave);
      extra.setRange(12, 16, ascii.encode('JUNK'));
      ByteData.sublistView(extra).setUint32(16, 4, Endian.little);
      extra.setRange(24, extra.length, wave.sublist(12));
      ByteData.sublistView(extra).setUint32(4, extra.length - 8, Endian.little);
      expect(aiWaveDurationMs(extra), 500);
    },
  );
  test('PCM recordings have correct sample-rate and WAV byte counts', () {
    final wave = aiWave(Uint8List.fromList([1, 2, 3, 4]), 16000);
    final data = ByteData.sublistView(wave);
    expect(ascii.decode(wave.sublist(0, 4)), 'RIFF');
    expect(data.getUint32(24, Endian.little), 16000);
    expect(data.getUint32(40, Endian.little), 4);
    expect(wave.sublist(44), [1, 2, 3, 4]);
  });
}
