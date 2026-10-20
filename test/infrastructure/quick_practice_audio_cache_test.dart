import 'dart:async';
import 'dart:io';
import 'package:app/infrastructure/quick_practice_audio_cache.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late HttpServer server;
  late Directory directory;
  late QuickPracticeAudioCache cache;
  late String base;
  setUp(() async {
    directory = await Directory.systemTemp.createTemp('practice-cache-test-');
    cache = QuickPracticeAudioCache(temporaryDirectory: () async => directory);
    server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    base = 'http://${server.address.address}:${server.port}';
  });
  tearDown(() async {
    await cache.dispose();
    await server.close(force: true);
    await directory.delete(recursive: true);
  });
  test(
    'preload, waveform and Play share one download; all three clips are ready',
    () async {
      var requests = 0;
      final release = Completer<void>();
      server.listen((request) async {
        requests++;
        await release.future;
        request.response.add([1, 2, 3, 4]);
        await request.response.close();
      });
      final cue = cache.prepare('$base/cue.wav');
      final waveform = cache.prepare('$base/cue.wav');
      final play = cache.prepare('$base/cue.wav');
      final choices = [
        cache.prepare('$base/a.wav'),
        cache.prepare('$base/b.wav'),
      ];
      release.complete();
      final paths = await Future.wait([cue, waveform, play, ...choices]);
      expect(requests, 3);
      expect(paths[0], paths[1]);
      expect(paths[1], paths[2]);
      expect(await File(paths[0]!).readAsBytes(), [1, 2, 3, 4]);
      expect(await cache.prepare('$base/cue.wav'), paths[0]);
      expect(requests, 3);
      await cache.dispose();
      expect(await File(paths[0]!).exists(), isFalse);
      expect(await cache.prepare('$base/late.wav'), isNull);
    },
  );
  test(
    'a failed preload is retryable and does not leave a partial file',
    () async {
      var requests = 0;
      server.listen((request) async {
        if (++requests == 1) {
          request.response.statusCode = 503;
        } else {
          request.response.add([5, 6]);
        }
        await request.response.close();
      });
      expect(await cache.prepare('$base/cue.wav'), isNull);
      final path = await cache.prepare('$base/cue.wav');
      expect(await File(path!).readAsBytes(), [5, 6]);
      expect(requests, 2);
    },
  );
  test(
    'changing exercise cancels unfinished downloads and removes its files',
    () async {
      final started = Completer<void>();
      server.listen((request) async {
        request.response.add([1]);
        await request.response.flush();
        started.complete();
      });
      final pending = cache.prepare('$base/slow.wav');
      await started.future;
      await cache.dispose();
      expect(await pending, isNull);
      expect(await directory.list().toList(), isEmpty);
    },
  );
}
