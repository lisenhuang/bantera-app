import 'dart:async';
import 'dart:io';
import 'package:app/infrastructure/ai/ai_history_store.dart';
import 'package:app/l10n/app_localizations.dart';
import 'package:app/presentation/chats/ai/ai_clear_history_dialog.dart';
import 'package:app/presentation/chats/ai/ai_vocabulary_example.dart';
import 'package:app/presentation/leaderboard/speaking_leaderboard.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late Directory root;
  setUp(() async {
    root = await Directory.systemTemp.createTemp('bantera-clear');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('bantera/ai_audio'),
          (call) async => call.method == 'storagePath' ? root.path : null,
        );
  });
  tearDown(() async => root.delete(recursive: true));
  Future<AiHistoryStore> history() async {
    final store = AiHistoryStore('alice');
    await store.load();
    store.messages.addAll(
      List.generate(
        22,
        (i) => AiMessage(
          role: i.isEven ? 'user' : 'model',
          text: 'Message $i',
          audio: i < 2 ? '$i.wav' : null,
          durationMs: i < 2 ? 100 : null,
          timeZone: 'UTC',
        ),
      ),
    );
    await File(store.path('0.wav')).writeAsBytes([1, 2, 3]);
    await File(store.path('0.wav.m4a')).writeAsBytes([4, 5]);
    await File(store.path('1.wav')).writeAsBytes([6, 7, 8]);
    await File(store.path('photo.jpg')).writeAsBytes([9]);
    await store.save();
    await store.refreshMemory(
      (_, _) async => {'summary': 'Remember my interests'},
      active: () => true,
    );
    return store;
  }

  test(
    'audio-only clears both speakers and compressed companions, retains text/images after reload',
    () async {
      final store = await history();
      final usage = await store.storageUsage();
      expect(usage.audioBytes, 8);
      expect(usage.hasSummary, true);
      expect(
        usage.reclaimable(AiHistoryClearMode.all, true),
        usage.totalBytes - usage.summaryBytes,
      );
      final other = AiHistoryStore('bob');
      await other.load();
      await File(other.path('other.wav')).writeAsBytes([1]);
      await store.clear(mode: AiHistoryClearMode.audioOnly, keepSummary: true);
      final restored = AiHistoryStore('alice');
      await restored.load();
      expect(restored.messages.length, 22);
      expect(
        restored.messages.every((m) => m.audio == null && m.durationMs == null),
        true,
      );
      expect(restored.messages.first.text, 'Message 0');
      expect(await File(restored.path('photo.jpg')).exists(), true);
      expect(await File(restored.path('0.wav')).exists(), false);
      expect(await File(restored.path('0.wav.m4a')).exists(), false);
      expect(await File(other.path('other.wav')).exists(), true);
      expect(restored.memory?['summary'], 'Remember my interests');
      expect((await restored.storageUsage()).audioBytes, 0);
    },
  );
  test(
    'retained summary survives complete clear and extends with new conversation',
    () async {
      final store = await history();
      final oldId = store.conversationId;
      await store.clear(keepSummary: true);
      final restored = AiHistoryStore('alice');
      await restored.load();
      expect(restored.conversationId, isNot(oldId));
      expect(restored.messages, isEmpty);
      expect(
        restored.context().single['text'],
        contains('Remember my interests'),
      );
      expect(await File(restored.path('photo.jpg')).exists(), false);
      restored.messages.addAll(
        List.generate(
          22,
          (i) => AiMessage(role: 'user', text: 'New $i', timeZone: 'UTC'),
        ),
      );
      var called = false;
      await restored.refreshMemory((previous, rows) async {
        called = true;
        expect(previous, 'Remember my interests');
        expect(rows.first['text'], 'New 0');
        return {'summary': 'Old and new interests'};
      }, active: () => true);
      expect(called, true);
      expect(restored.memory?['retainedAfterClear'], isNull);
      await restored.clear(mode: AiHistoryClearMode.audioOnly);
      expect(restored.memory, isNull);
      expect(await File(restored.path('memory.json')).exists(), false);
    },
  );
  test('late summary cannot replace a deliberately retained summary', () async {
    final store = await history();
    store.messages.add(AiMessage(role: 'user', text: 'New', timeZone: 'UTC'));
    final gate = Completer<Map<String, dynamic>>();
    final started = Completer<void>();
    final pending = store.refreshMemory((_, _) {
      started.complete();
      return gate.future;
    }, active: () => true);
    await started.future;
    await store.clear(keepSummary: true);
    gate.complete({'summary': 'Should not return'});
    await pending;
    expect(store.memory?['summary'], 'Remember my interests');
  });
  testWidgets(
    'clear dialog starts unchecked and disabled, radio choices exclusive and summary optional',
    (tester) async {
      AiHistoryClearChoice? selected;
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Builder(
            builder: (context) => TextButton(
              onPressed: () async {
                selected = await showDialog<AiHistoryClearChoice>(
                  context: context,
                  builder: (_) => AiClearHistoryDialog(
                    usage: Future.value(
                      const AiHistoryStorageUsage(
                        audioBytes: 1000000,
                        totalBytes: 2000000,
                        summaryBytes: 100000,
                        hasSummary: true,
                      ),
                    ),
                  ),
                );
              },
              child: const Text('Open'),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      expect(
        tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
        isNull,
      );
      expect(
        tester.widget<CheckboxListTile>(find.byType(CheckboxListTile)).value,
        false,
      );
      await tester.tap(find.text('Audio only'));
      await tester.pumpAndSettle();
      expect(
        tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
        isNotNull,
      );
      await tester.tap(find.text('All messages and audio'));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.byType(CheckboxListTile));
      await tester.tap(find.byType(CheckboxListTile));
      await tester.pumpAndSettle();
      expect(find.textContaining('1.9 MB'), findsOneWidget);
      await tester.tap(find.byType(FilledButton));
      await tester.pumpAndSettle();
      expect(selected?.mode, AiHistoryClearMode.all);
      expect(selected?.keepSummary, true);
    },
  );
  testWidgets('clear dialog fits all locales on a narrow phone', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    for (final locale in AppLocalizations.supportedLocales) {
      await tester.pumpWidget(
        MaterialApp(
          locale: locale,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: AiClearHistoryDialog(
              key: ValueKey(locale),
              usage: Future.value(
                const AiHistoryStorageUsage(
                  audioBytes: 100,
                  totalBytes: 1000,
                  summaryBytes: 0,
                  hasSummary: false,
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull, reason: '$locale');
    }
  });
  test(
    'example highlights whole words, phrases and continuous scripts safely',
    () {
      const style = TextStyle(fontWeight: FontWeight.bold);
      List<String?> hits(String text, String word) => vocabularyExampleSpans(
        text,
        word,
        style,
      ).where((s) => s.style == style).map((s) => s.text).toList();
      expect(hits('The theme: he said HE.', 'he'), ['he', 'HE']);
      expect(hits('I use C++ today.', 'C++'), ['C++']);
      expect(hits('我喜欢学校。学校很好。', '学校'), ['学校', '学校']);
      expect(hits('We take off soon.', 'take off'), ['take off']);
      expect(hits('No match here.', 'passport'), isEmpty);
    },
  );
  test(
    'leaderboard abbreviates names with Unicode spaces without altering unspaced names',
    () {
      expect(leaderboardFirstName('  Ethan Smith '), 'Ethan');
      expect(leaderboardFirstName('李　小明'), '李');
      expect(leaderboardFirstName('小明'), '小明');
      expect(leaderboardFirstName('Ana\u00a0Silva'), 'Ana');
      expect(leaderboardFirstName(' '), null);
    },
  );
}
