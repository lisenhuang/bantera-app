import 'dart:async';
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:app/infrastructure/avatar_image_cache.dart';

Future<Uint8List> png(ui.Color color) async {
  final recorder = ui.PictureRecorder();
  ui.Canvas(recorder).drawPaint(ui.Paint()..color = color);
  final picture = recorder.endRecording();
  final image = await picture.toImage(2, 2);
  final data = await image.toByteData(format: ui.ImageByteFormat.png);
  image.dispose();
  picture.dispose();
  return data!.buffer.asUint8List();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'disk image is published before slow network and survives offline failure',
    () async {
      final old = await png(const ui.Color(0xffff0000));
      final network = Completer<Uint8List>();
      final visible = Completer<void>();
      var requests = 0;
      final cache = AvatarImageCache(
        readCached: (_) async => old,
        download: (_) {
          requests++;
          return network.future;
        },
      );
      final entry = cache.entry('person');
      entry.addListener(() {
        if (!visible.isCompleted) visible.complete();
      });
      final load = cache.refresh('person');
      await visible.future;
      expect(entry.value, old);
      final second = cache.refresh('person', force: true);
      network.completeError(Exception('offline'));
      await Future.wait([load, second]);
      expect(entry.value, old);
      expect(requests, 1);
    },
  );

  test(
    'changed bytes replace cache; identical refresh does not blink',
    () async {
      final old = await png(const ui.Color(0xffff0000));
      final fresh = await png(const ui.Color(0xff00ff00));
      final cache = AvatarImageCache(
        readCached: (_) async => old,
        download: (_) async => fresh,
      );
      final entry = cache.entry('person');
      var changes = 0;
      entry.addListener(() => changes++);
      await cache.refresh('person');
      expect(entry.value, fresh);
      expect(changes, 2);
      await cache.refresh('person', force: true);
      expect(changes, 2);
    },
  );

  test('corrupt refresh preserves the last good image', () async {
    final old = await png(const ui.Color(0xffff0000));
    final cache = AvatarImageCache(
      readCached: (_) async => old,
      download: (_) async => Uint8List.fromList([1, 2, 3]),
    );
    await cache.refresh('person');
    expect(cache.entry('person').value, old);
  });

  test(
    'new process cache can read persisted bytes and URLs remain isolated',
    () async {
      final old = await png(const ui.Color(0xffff0000));
      final fresh = await png(const ui.Color(0xff00ff00));
      final disk = <String, Uint8List>{};
      final first = AvatarImageCache(
        readCached: (url) async => disk[url],
        download: (url) async => disk[url] = url == 'a' ? old : fresh,
      );
      await first.refresh('a');
      await first.refresh('b');
      final restarted = AvatarImageCache(
        readCached: (url) async => disk[url],
        download: (_) async => throw Exception('offline'),
      );
      await restarted.refresh('a');
      await restarted.refresh('b');
      expect(restarted.entry('a').value, old);
      expect(restarted.entry('b').value, fresh);
    },
  );
}
