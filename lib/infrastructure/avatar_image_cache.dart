import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

/// Disk first, then background revalidation. Entries are shared by URL so a
/// person appearing in several chat rows only needs one download.
class AvatarImageCache {
  AvatarImageCache({
    required this.readCached,
    required this.download,
    this.restoreCached,
  });

  static final _disk = CacheManager(
    Config(
      'profile-avatars-v1',
      stalePeriod: const Duration(days: 30),
      maxNrOfCacheObjects: 300,
    ),
  );
  static final instance = AvatarImageCache(
    restoreCached: (url, bytes) async {
      await _disk.putFile(url, bytes, key: url);
    },
    readCached: (url) async =>
        (await _disk.getFileFromCache(url))?.file.readAsBytes(),
    download: (url) async => (await _disk.downloadFile(
      url,
      key: url,
      force: true,
      authHeaders: {'Cache-Control': 'no-cache'},
    )).file.readAsBytes(),
  );

  final Future<Uint8List?> Function(String) readCached;
  final Future<Uint8List> Function(String) download;
  final Future<void> Function(String, Uint8List)? restoreCached;
  final _entries = <String, AvatarImageEntry>{};

  AvatarImageEntry entry(String url) {
    final entry = _entries.remove(url) ?? AvatarImageEntry();
    _entries[url] = entry;
    // Bound retained compressed images. Mounted avatars keep their own entry.
    while (_entries.length > 80 ||
        (_entries.length > 1 &&
            _entries.values.fold<int>(0, (n, e) => n + (e.value?.length ?? 0)) >
                16 * 1024 * 1024)) {
      final removable = _entries.keys.where(
        (key) =>
            key != url &&
            !_entries[key]!.isObserved &&
            _entries[key]!._pending == null,
      );
      if (removable.isEmpty) break;
      _entries.remove(removable.first);
    }
    return entry;
  }

  Future<void> refresh(String url, {bool force = false}) {
    final current = entry(url);
    if (current._pending case final pending?) return pending;
    if (!force &&
        current._lastAttempt != null &&
        DateTime.now().difference(current._lastAttempt!) <
            const Duration(minutes: 1)) {
      return Future.value();
    }
    current._lastAttempt = DateTime.now();
    final task = _load(url, current);
    current._pending = task;
    return task.whenComplete(() => current._pending = null);
  }

  Future<void> _load(String url, AvatarImageEntry current) async {
    if (current.value == null) {
      try {
        final cached = await readCached(url);
        if (cached != null) await _publish(current, cached);
      } catch (_) {
        // A missing/evicted disk cache must not prevent downloading the avatar.
      }
    }
    try {
      await _publish(
        current,
        await download(url).timeout(const Duration(seconds: 20)),
      );
    } catch (_) {
      // Keep the last good image on network, server or image decoding failure.
      if (current.value != null && restoreCached != null) {
        try {
          await restoreCached!(url, current.value!);
        } catch (_) {}
      }
    }
  }

  Future<void> _publish(AvatarImageEntry current, Uint8List bytes) async {
    if (listEquals(current.value, bytes)) return;
    if (bytes.isEmpty || bytes.length > 5 * 1024 * 1024) {
      throw const FormatException("Invalid avatar size");
    }
    // Do not replace a good cached image with an HTML error or corrupt payload.
    final codec = await ui.instantiateImageCodec(bytes, targetWidth: 256);
    try {
      final frame = await codec.getNextFrame();
      frame.image.dispose();
    } finally {
      codec.dispose();
    }
    current.value = bytes;
  }
}

class AvatarImageEntry extends ValueNotifier<Uint8List?> {
  AvatarImageEntry() : super(null);
  bool get isObserved => hasListeners;
  Future<void>? _pending;
  DateTime? _lastAttempt;
}
