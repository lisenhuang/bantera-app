import 'dart:async';
import 'dart:convert';
import 'package:app/infrastructure/practice_audio_cache.dart';
import 'dart:io';
import 'package:app/infrastructure/local_audio_storage.dart';
import 'package:app/infrastructure/ai/ai_history_store.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const channel = MethodChannel('bantera/local_audio_storage');
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
  late Directory root;
  late File wav;
  late Uint8List bytes;
  setUp(() async {
    root = await Directory.systemTemp.createTemp('aac-test');
    bytes = aiWave(Uint8List(32000), 16000);
    wav = await File('${root.path}/audio.wav').writeAsBytes(bytes);
  });
  tearDown(() async {
    messenger.setMockMethodCallHandler(channel, null);
    messenger.setMockMethodCallHandler(
      const MethodChannel('plugins.flutter.io/path_provider'),
      null,
    );
    messenger.setMockMethodCallHandler(
      const MethodChannel('bantera/ai_audio'),
      null,
    );
    if (await root.exists()) await root.delete(recursive: true);
  });
  void encode({bool valid = true, int size = 8000}) {
    messenger.setMockMethodCallHandler(channel, (call) async {
      await File(
        call.arguments['output'] as String,
      ).writeAsBytes(Uint8List(size));
      return valid;
    });
  }

  test(
    'only replaces validated smaller WAVs; stable old references resolve M4A',
    () async {
      encode();
      final results = await Future.wait([
        LocalAudioStorage.compress(wav.path),
        LocalAudioStorage.compress(wav.path),
      ]);
      expect(results.toSet(), {'${wav.path}.m4a'});
      expect(await wav.exists(), false);
      expect(LocalAudioStorage.resolve(wav.path), results.first);
      expect(await File(results.first).length(), 8000);
      await LocalAudioStorage.delete(wav.path);
      expect(await File(results.first).exists(), false);
    },
  );
  test(
    'failure and larger output keep original intact and clean temporary files',
    () async {
      encode(valid: false);
      expect(await LocalAudioStorage.compress(wav.path), wav.path);
      expect(await wav.readAsBytes(), bytes);
      encode(size: bytes.length + 1);
      expect(await LocalAudioStorage.compress(wav.path), wav.path);
      expect(await root.list().length, 1);
    },
  );
  test('clear during conversion cannot resurrect attachments', () async {
    final entered = Completer<void>(), finish = Completer<void>();
    messenger.setMockMethodCallHandler(channel, (call) async {
      await File(
        call.arguments['output'] as String,
      ).writeAsBytes(Uint8List(8000));
      entered.complete();
      await finish.future;
      return true;
    });
    final converting = LocalAudioStorage.compress(wav.path);
    await entered.future;
    await LocalAudioStorage.delete(wav.path);
    finish.complete();
    await converting;
    expect(await root.list().length, 0);
  });
  test('compressed and mislabelled downloads are untouched', () async {
    messenger.setMockMethodCallHandler(
      channel,
      (_) async => fail('Must not transcode'),
    );
    final mp3 = await File(
      '${root.path}/voice.mp3',
    ).writeAsBytes(Uint8List(9000));
    expect(await LocalAudioStorage.compress(mp3.path), mp3.path);
    await wav.writeAsBytes(Uint8List(9000));
    expect(await LocalAudioStorage.compress(wav.path), wav.path);
  });
  test('retry reads PCM correctly with nonstandard RIFF chunks', () async {
    final withJunk = Uint8List.fromList([
      ...bytes.sublist(0, 36),
      ...'JUNK'.codeUnits,
      2,
      0,
      0,
      0,
      7,
      7,
      ...bytes.sublist(36),
    ]);
    await wav.writeAsBytes(withJunk);
    expect(await LocalAudioStorage.readVoicePcm(wav.path), Uint8List(32000));
  });
  test('compressed retry uses native mono 16k decoder', () async {
    encode();
    await LocalAudioStorage.compress(wav.path);
    messenger.setMockMethodCallHandler(channel, (call) async {
      expect(call.method, 'decodeVoice');
      expect(call.arguments['input'], '${wav.path}.m4a');
      return Uint8List.fromList([1, 2, 3, 4]);
    });
    expect(await LocalAudioStorage.readVoicePcm(wav.path), [1, 2, 3, 4]);
  });
  test(
    'AI saves M4A, preserves duration, reloads and deletes correctly',
    () async {
      encode();
      messenger.setMockMethodCallHandler(
        const MethodChannel('bantera/ai_audio'),
        (call) async => root.path,
      );
      final store = AiHistoryStore('owner');
      await store.load();
      final name = await store.saveAudio(bytes);
      await LocalAudioStorage.compress(store.path(name));
      expect(store.path(name), endsWith('.m4a'));
      store.messages.add(AiMessage(role: 'user', audio: name));
      await store.save();
      final restored = AiHistoryStore('owner');
      await restored.load();
      expect(restored.messages.single.durationMs, 1000);
      expect(await File(restored.path(name)).length(), 8000);
      await restored.deleteMessage(restored.messages.single);
      expect(await File(restored.path(name)).exists(), false);
    },
  );
  test(
    'old AI references survive migration and a stale history snapshot',
    () async {
      encode();
      messenger.setMockMethodCallHandler(
        const MethodChannel('bantera/ai_audio'),
        (_) async => root.path,
      );
      final original = AiHistoryStore('legacy');
      await original.load();
      final path = original.path('old.wav');
      await File(path).writeAsBytes(bytes);
      original.messages.add(
        AiMessage(role: 'user', audio: 'old.wav', durationMs: 1000),
      );
      await original.save();
      await LocalAudioStorage.migrate([path]);
      await original
          .save(); // An older controller may still use the stable WAV reference.
      final loaded = AiHistoryStore('legacy');
      await loaded.load();
      expect(loaded.messages.single.audio, 'old.wav');
      expect(loaded.path('old.wav'), '$path.m4a');
      expect(await File(loaded.path('old.wav')).length(), 8000);
      await loaded.clear();
      expect(await File('$path.m4a').exists(), false);
    },
  );

  test(
    'updated practice URL replaces a converted cache rather than stale audio',
    () async {
      encode();
      final previousOverride = HttpOverrides.current;
      HttpOverrides.global = null;
      addTearDown(() => HttpOverrides.global = previousOverride);
      messenger.setMockMethodCallHandler(
        const MethodChannel('plugins.flutter.io/path_provider'),
        (_) async => root.path,
      );
      final directory = await Directory(
        '${root.path}/practice_audio_cache',
      ).create();
      final previous = File('${directory.path}/lesson.wav.m4a');
      await previous.writeAsBytes([4, 5, 6]);
      await File(
        '${directory.path}/lesson.json',
      ).writeAsString(jsonEncode({'url': 'old-url'}));
      final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
      var requests = 0;
      server.listen((request) async {
        requests++;
        request.response.add(bytes);
        await request.response.close();
      });
      try {
        final url = 'http://127.0.0.1:${server.port}/new.wav';
        final first = await PracticeAudioCache.instance.getAudioFile(
          mediaId: 'lesson',
          url: url,
          headers: {},
        );
        expect(first.cacheHit, false);
        expect(await first.file.length(), 8000);
        final second = await PracticeAudioCache.instance.getAudioFile(
          mediaId: 'lesson',
          url: url,
          headers: {},
        );
        expect(second.cacheHit, true);
        expect(second.file.path, first.file.path);
        expect(requests, 1);
      } finally {
        await server.close(force: true);
      }
    },
  );
  test(
    'saving a new AI message does not wait for background encoding',
    () async {
      messenger.setMockMethodCallHandler(
        const MethodChannel('bantera/ai_audio'),
        (_) async => root.path,
      );
      final entered = Completer<void>(), finish = Completer<void>();
      messenger.setMockMethodCallHandler(channel, (call) async {
        entered.complete();
        await finish.future;
        await File(
          call.arguments['output'] as String,
        ).writeAsBytes(Uint8List(8000));
        return true;
      });
      final store = AiHistoryStore('fast-send');
      await store.load();
      final saved = store.saveAudio(bytes);
      await entered.future;
      final name = await saved.timeout(const Duration(seconds: 1));
      expect(await File(store.path(name)).exists(), true);
      finish.complete();
      await LocalAudioStorage.compress(store.path(name));
      expect(store.path(name), endsWith('.m4a'));
    },
  );
}
