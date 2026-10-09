import 'dart:async';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:app/infrastructure/ai/ai_history_store.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late Directory root;
  setUp(() async {
    root = await Directory.systemTemp.createTemp('bantera-memory-test');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('bantera/ai_audio'),
          (call) async => call.method == 'storagePath' ? root.path : null,
        );
  });
  tearDown(() async => root.delete(recursive: true));
  Future<AiHistoryStore> history(int count) async {
    final store = AiHistoryStore('alice');
    await store.load();
    store.messages.addAll(
      List.generate(
        count,
        (i) => AiMessage(
          id: 'message$i',
          role: i.isEven ? 'user' : 'model',
          text: 'Message $i',
          createdAt: DateTime.utc(2026, 10, 1).add(Duration(minutes: i)),
          timeZone: 'Pacific/Auckland',
          utcOffsetMinutes: 780,
        ),
      ),
    );
    await store.save();
    return store;
  }

  test(
    'rolling summary is bounded, incremental, durable and keeps newest 20',
    () async {
      final store = await history(70);
      var calls = 0;
      final seen = <String>[];
      Future<Map<String, dynamic>> summarize(
        String? previous,
        List<Map<String, String>> rows,
      ) async {
        expect(rows.length, lessThanOrEqualTo(24));
        expect(
          rows.fold<int>(0, (sum, row) => sum + row['text']!.length),
          lessThanOrEqualTo(24000),
        );
        expect(previous, calls == 0 ? null : 'Summary $calls');
        seen.addAll(rows.map((r) => r['id']!));
        calls++;
        return {'summary': 'Summary $calls'};
      }

      await store.refreshMemory(summarize, active: () => true);
      expect(calls, 3);
      expect(seen.toSet().length, 50);
      expect(store.context().length, 21);
      expect(store.context()[1]['text'], 'Message 50');
      expect(store.context().last['text'], 'Message 69');
      expect(store.context().first.containsKey('createdAt'), isFalse);
      final restored = AiHistoryStore('alice');
      await restored.load();
      expect(restored.memory, store.memory);
      expect(restored.conversationId, store.conversationId);
      await restored.refreshMemory(summarize, active: () => true);
      expect(calls, 3);
      restored.messages.addAll([
        AiMessage(id: 'new70', role: 'user', text: 'New question'),
        AiMessage(id: 'new71', role: 'model', text: 'New reply'),
      ]);
      await restored.refreshMemory(summarize, active: () => true);
      expect(calls, 4);
      expect(seen.last, 'message51:0');
    },
  );
  test('very long single message is chunked without losing its tail', () async {
    final store = await history(21);
    store.messages.first.text = 'x' * 50001;
    final seen = <String>[];
    await store.refreshMemory((previous, rows) async {
      seen.addAll(rows.map((r) => r['text']!));
      return {'summary': 'Long message memory'};
    }, active: () => true);
    expect(seen.join(), 'x' * 50001);
    expect(store.memory!['through'], 'message0:48000');
  });
  test(
    'clear removes memory and prevents an in-flight result resurrecting it',
    () async {
      final store = await history(21);
      final before = store.conversationId;
      final pending = Completer<Map<String, dynamic>>();
      final started = Completer<void>();
      final work = store.refreshMemory((previous, rows) {
        started.complete();
        return pending.future;
      }, active: () => true);
      await started.future;
      await store.clear();
      pending.complete({'summary': 'Must not reappear'});
      await work;
      expect(store.memory, isNull);
      expect(store.conversationId, isNot(before));
      final restored = AiHistoryStore('alice');
      await restored.load();
      expect(restored.memory, isNull);
      expect(restored.messages, isEmpty);
    },
  );
  test(
    'summary failure leaves usable history and account memory is isolated',
    () async {
      final store = await history(21);
      await store.refreshMemory(
        (previous, rows) async => throw StateError('offline'),
        active: () => true,
      );
      expect(store.memory, isNull);
      expect(store.context().last['text'], 'Message 20');
      final bob = AiHistoryStore('bob');
      await bob.load();
      expect(bob.memory, isNull);
      expect(bob.conversationId, isNot(store.conversationId));
    },
  );
}
