import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:uuid/uuid.dart';
import 'package:path_provider/path_provider.dart';

/// Compresses completed, app-owned WAV files locally. Stable WAV references in
/// old databases resolve to a validated M4A companion without rewriting history.
/// No audio session is opened, and compressed downloads are never transcoded.
class LocalAudioStorage {
  static const _channel = MethodChannel('bantera/local_audio_storage');
  static final _jobs = <String, Future<String>>{};
  static final _migrations = <String>{};

  static String resolve(String path) {
    if (path.toLowerCase().endsWith('.wav') && File('$path.m4a').existsSync()) {
      return '$path.m4a';
    }
    return path;
  }

  static Future<String> compress(String path) {
    if (!path.toLowerCase().endsWith('.wav')) return Future.value(path);
    return _jobs.putIfAbsent(path, () async {
      try {
        return await _compress(path);
      } finally {
        _jobs.remove(path);
      }
    });
  }

  static Future<String> _compress(String path) async {
    final existing = resolve(path);
    if (existing != path) return existing;
    final source = File(path);
    final temporary = File('$path.${const Uuid().v4()}.compressing.m4a');
    try {
      final before = await source.stat();
      if (before.type != FileSystemEntityType.file || before.size < 4096) {
        return path;
      }
      final reader = await source.open();
      late Uint8List header;
      try {
        header = await reader.read(12);
      } finally {
        await reader.close();
      }
      if (header.length != 12 ||
          String.fromCharCodes(header.sublist(0, 4)) != 'RIFF' ||
          String.fromCharCodes(header.sublist(8, 12)) != 'WAVE') {
        return path;
      }
      // Native code verifies AAC decoding, duration and channels before success.
      final valid = await _channel.invokeMethod<bool>('compress', {
        'input': path,
        'output': temporary.path,
      });
      if (valid != true || !await temporary.exists()) return path;
      // Commit synchronously: deletion/clear cannot interleave with replacement.
      final now = source.statSync();
      if (now.type != FileSystemEntityType.file ||
          now.size != before.size ||
          now.modified != before.modified ||
          temporary.lengthSync() >= before.size) {
        return path;
      }
      final target = '$path.m4a';
      temporary.renameSync(target);
      source.deleteSync();
      return target;
    } on Exception {
      return resolve(
        path,
      ); // Keep the original on unsupported codecs or failure.
    } finally {
      try {
        if (temporary.existsSync()) temporary.deleteSync();
      } on FileSystemException {
        /* Best effort after a concurrent clear. */
      }
    }
  }

  /// One file at a time; foreground recording/streaming does not wait for this.
  static Future<void> migrate(Iterable<String> paths) async {
    for (final path in paths.toSet()) {
      if (!_migrations.add(path)) continue;
      try {
        await compress(path);
        await Future<void>.delayed(const Duration(milliseconds: 250));
      } finally {
        _migrations.remove(path);
      }
    }
  }

  static Future<void> migratePractice() async {
    try {
      final root = await getApplicationSupportDirectory();
      for (final folder in [
        'practice_audio_cache',
        'compare_attempts',
        'chat_audio',
      ]) {
        final directory = Directory('${root.path}/$folder');
        if (!await directory.exists()) continue;
        await for (final file in directory.list(
          recursive: true,
          followLinks: false,
        )) {
          if (file is File && file.path.endsWith('.wav')) {
            await migrate([file.path]);
          }
        }
      }
    } on Exception {
      /* Optional maintenance must not interrupt startup. */
    }
  }

  static Future<void> delete(String path) async {
    // Invalidate an in-flight conversion by removing its source too.
    final paths = {path, resolve(path)};
    for (final item in paths) {
      try {
        await File(item).delete();
      } on FileSystemException {
        /* Already gone. */
      }
    }
  }

  static Future<Uint8List> readVoicePcm(String path) async {
    final actual = resolve(path);
    if (actual.toLowerCase().endsWith('.wav')) {
      final bytes = await File(actual).readAsBytes();
      final view = ByteData.sublistView(bytes);
      var mono16k = false;
      if (bytes.length >= 12 &&
          String.fromCharCodes(bytes.sublist(0, 4)) == 'RIFF' &&
          String.fromCharCodes(bytes.sublist(8, 12)) == 'WAVE') {
        for (var offset = 12; offset + 8 <= bytes.length;) {
          final size = view.getUint32(offset + 4, Endian.little);
          final start = offset + 8;
          if (start + size > bytes.length) break;
          final type = String.fromCharCodes(bytes.sublist(offset, start - 4));
          if (type == 'fmt ' && size >= 16) {
            mono16k =
                view.getUint16(start, Endian.little) == 1 &&
                view.getUint16(start + 2, Endian.little) == 1 &&
                view.getUint32(start + 4, Endian.little) == 16000 &&
                view.getUint16(start + 14, Endian.little) == 16;
          }
          if (type == 'data' && mono16k && size > 0) {
            return Uint8List.sublistView(bytes, start, start + size);
          }
          offset = start + size + (size & 1);
        }
      }
    }
    // The native decoder handles RIFF chunks and AAC; never assume a 44-byte
    // header. AI voice retry always needs 16 kHz, mono, signed 16-bit PCM.
    final pcm = await _channel.invokeMethod<Uint8List>('decodeVoice', {
      'input': actual,
    });
    if (pcm == null || pcm.isEmpty) throw const FormatException('Empty audio');
    return pcm;
  }
}
