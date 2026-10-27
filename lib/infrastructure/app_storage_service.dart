import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'avatar_image_cache.dart';
import 'last_snapshot_cache.dart';
import 'quick_practice_audio_cache.dart';

enum StorageCategory {
  images,
  snapshots,
  temporaryAudio,
  aiChats,
  directMessages,
  practice,
  other,
}

class StorageUsage {
  StorageUsage(this.bytes, this.clearable, {this.partial = false});
  final Map<StorageCategory, int> bytes;
  final Map<StorageCategory, int> clearable;
  final bool partial;
  int get total => bytes.values.fold(0, (a, b) => a + b);
  int get safeToClear => clearable.values.fold(0, (a, b) => a + b);
}

/// Counts app-owned files, never the app bundle or OS-managed language models.
/// Clearing uses a narrow allowlist. Unknown files and personal data are kept.
class AppStorageService {
  AppStorageService({
    required this.roots,
    required this.temporary,
    required this.support,
    required this.clearImages,
    required this.clearSnapshots,
    Set<String> Function()? activeAudio,
  }) : activeAudio =
           activeAudio ?? (() => QuickPracticeAudioCache.activeDirectories);

  final List<Directory> roots;
  final Directory temporary, support;
  final Future<void> Function() clearImages, clearSnapshots;
  final Set<String> Function() activeAudio;

  static Future<AppStorageService> open() async {
    final support = await getApplicationSupportDirectory();
    final temporary = await getTemporaryDirectory();
    final documents = await getApplicationDocumentsDirectory();
    // Android keeps AI history in noBackupFilesDir, outside the standard roots.
    final ai = await const MethodChannel(
      'bantera/ai_audio',
    ).invokeMethod<String>('storagePath');
    return AppStorageService(
      roots: [support, temporary, documents, if (ai != null) Directory(ai)],
      temporary: temporary,
      support: support,
      clearImages: () async {
        await AvatarImageCache.clearDiskCache();
        await DefaultCacheManager().emptyCache();
      },
      clearSnapshots: () async {
        await LastSnapshotCache.leaderboard.clearAll();
        await LastSnapshotCache.practice.clearAll();
      },
    );
  }

  List<Directory> get _uniqueRoots {
    final paths = roots.map((r) => p.normalize(p.absolute(r.path))).toSet();
    return paths
        .where((path) => !paths.any((other) => p.isWithin(other, path)))
        .map(Directory.new)
        .toList();
  }

  bool _inside(String directory, String file) => p.isWithin(directory, file);
  String? _temporaryClipDirectory(String file) {
    if (!_inside(temporary.path, file)) return null;
    final parts = p.split(p.relative(file, from: temporary.path));
    if (parts.length < 2 || !parts.first.startsWith('quick-practice-')) {
      return null;
    }
    return p.join(temporary.path, parts.first);
  }

  StorageCategory _category(String file) {
    for (final key in ['profile-avatars-v1', 'libCachedImageData']) {
      if (_inside(p.join(temporary.path, key), file)) {
        return StorageCategory.images;
      }
    }
    final name = p.basename(file);
    if (p.dirname(file) == support.path &&
        [
          'speaking-leaderboard-cache-v1.json',
          'last-practice-cache-v1.json',
          'speaking-leaderboard-cache-v1.json.tmp',
          'last-practice-cache-v1.json.tmp',
        ].contains(name)) {
      return StorageCategory.snapshots;
    }
    if (_temporaryClipDirectory(file) != null) {
      return StorageCategory.temporaryAudio;
    }
    final parts = p.split(file);
    if (parts.contains('bantera_ai')) return StorageCategory.aiChats;
    if (parts.contains('chat_audio') ||
        name.startsWith('bantera_local_chat.sqlite')) {
      return StorageCategory.directMessages;
    }
    if (parts.any(
          [
            'practice_audio_cache',
            'local_practice_videos',
            'compare_attempts',
          ].contains,
        ) ||
        name.startsWith('bantera_local_practice.sqlite') ||
        name == 'saved_practice.json') {
      return StorageCategory.practice;
    }
    return StorageCategory.other;
  }

  bool _safe(String file, StorageCategory category) => switch (category) {
    StorageCategory.images || StorageCategory.snapshots => true,
    StorageCategory.temporaryAudio =>
      p.dirname(file) == _temporaryClipDirectory(file) &&
          RegExp(
            r'^\d+\.(wav|wav\.m4a|mp3|m4a|aac|caf)$',
          ).hasMatch(p.basename(file)) &&
          !activeAudio().contains(_temporaryClipDirectory(file)),
    _ => false,
  };

  Future<StorageUsage> scan() async {
    final bytes = <StorageCategory, int>{},
        clearable = <StorageCategory, int>{};
    var partial = false;
    for (final root in _uniqueRoots) {
      try {
        if (await FileSystemEntity.type(root.path, followLinks: false) !=
            FileSystemEntityType.directory) {
          continue;
        }
        await for (final entity in root.list(
          recursive: true,
          followLinks: false,
        )) {
          if (entity is! File) continue;
          try {
            final stat = await entity.stat();
            final category = _category(entity.path);
            bytes.update(
              category,
              (n) => n + stat.size,
              ifAbsent: () => stat.size,
            );
            if (_safe(entity.path, category)) {
              clearable.update(
                category,
                (n) => n + stat.size,
                ifAbsent: () => stat.size,
              );
            }
          } on FileSystemException {
            partial = true;
          }
        }
      } on FileSystemException {
        partial = true;
      }
    }
    return StorageUsage(bytes, clearable, partial: partial);
  }

  Future<StorageUsage> clearSafeCache() async {
    // Use the owners' APIs so their indexes and in-memory snapshots stay valid.
    await clearImages();
    await clearSnapshots();
    if (await FileSystemEntity.type(temporary.path, followLinks: false) ==
        FileSystemEntityType.directory) {
      await for (final entity in temporary.list(followLinks: false)) {
        if (entity is! Directory ||
            !p.basename(entity.path).startsWith('quick-practice-') ||
            activeAudio().contains(entity.path)) {
          continue;
        }
        // No recursive delete: leave symlinks and unrecognized files untouched.
        await for (final file in entity.list(followLinks: false)) {
          if (file is File &&
              RegExp(
                r'^\d+\.(wav|wav\.m4a|mp3|m4a|aac|caf)$',
              ).hasMatch(p.basename(file.path))) {
            if (!activeAudio().contains(entity.path)) await file.delete();
          }
        }
        if (!activeAudio().contains(entity.path) &&
            await entity.list().isEmpty) {
          await entity.delete();
        }
      }
    }
    return scan(); // Downloads in use may legitimately add new cache meanwhile.
  }
}
