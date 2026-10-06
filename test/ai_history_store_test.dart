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
  test('PCM recordings have correct sample-rate and WAV byte counts', () {
    final wave = aiWave(Uint8List.fromList([1, 2, 3, 4]), 16000);
    final data = ByteData.sublistView(wave);
    expect(ascii.decode(wave.sublist(0, 4)), 'RIFF');
    expect(data.getUint32(24, Endian.little), 16000);
    expect(data.getUint32(40, Endian.little), 4);
    expect(wave.sublist(44), [1, 2, 3, 4]);
  });
}
