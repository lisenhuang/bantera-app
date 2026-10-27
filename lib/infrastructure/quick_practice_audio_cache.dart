import 'local_audio_storage.dart';
import 'dart:async';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

/// One exercise's clips. Shared futures avoid a second download when Play or
/// waveform extraction arrives during preloading. Files are temporary and are
/// removed when the exercise changes; preloading never opens an audio session.
class QuickPracticeAudioCache {
  QuickPracticeAudioCache({Future<Directory> Function()? temporaryDirectory})
    : _temporaryDirectory = temporaryDirectory ?? getTemporaryDirectory;

  final Future<Directory> Function() _temporaryDirectory;
  static final activeDirectories = <String>{};

  final _downloads = <String, Future<String?>>{};
  final _clients = <HttpClient>{};
  Future<Directory>? _directory;
  bool _disposed = false;
  int _serial = 0;

  Future<String?> prepare(String url) {
    if (_disposed || url.isEmpty) return Future.value(null);
    return _downloads.putIfAbsent(url, () async {
      final path = await _download(url);
      if (path == null) _downloads.remove(url);
      return path;
    });
  }

  Future<String?> _download(String url) async {
    final client = HttpClient()
      ..connectionTimeout = const Duration(seconds: 10);
    _clients.add(client);
    final deadline = Timer(
      const Duration(seconds: 20),
      () => client.close(force: true),
    );
    IOSink? sink;
    File? file;
    try {
      final uri = Uri.parse(url);
      if (uri.scheme != 'https' && uri.scheme != 'http') return null;
      final directory = await (_directory ??= _temporaryDirectory().then((
        base,
      ) async {
        final directory = await base.createTemp('quick-practice-');
        activeDirectories.add(directory.path);
        return directory;
      }));
      if (_disposed) return null;
      final extension =
          RegExp(
            r'\.(wav|mp3|m4a|aac|caf)$',
            caseSensitive: false,
          ).firstMatch(uri.path)?.group(0) ??
          '.wav';
      file = File('${directory.path}/${_serial++}$extension');
      final response = await (await client.getUrl(uri)).close();
      if (response.statusCode != HttpStatus.ok || _disposed) return null;
      const limit = 10 * 1024 * 1024;
      if (response.contentLength > limit) return null;
      sink = file.openWrite();
      var size = 0;
      await for (final chunk in response) {
        size += chunk.length;
        if (_disposed || size > limit) {
          throw const HttpException('Clip too large or cancelled');
        }
        sink.add(chunk);
      }
      await sink.flush();
      await sink.close();
      sink = null;
      if (size == 0 || _disposed) {
        throw const HttpException('Empty or cancelled clip');
      }
      return await LocalAudioStorage.compress(file.path);
    } catch (_) {
      try {
        await sink?.close();
        if (file != null && await file.exists()) await file.delete();
      } catch (_) {
        /* Temporary directory may already have been removed. */
      }
      return null; // Playback can still stream if preloading failed.
    } finally {
      deadline.cancel();
      client.close(force: true);
      _clients.remove(client);
    }
  }

  Future<void> dispose() async {
    _disposed = true;
    for (final client in _clients.toList()) {
      client.close(force: true);
    }
    await Future.wait(_downloads.values.toList());
    _downloads.clear();
    try {
      final directory = await _directory;
      if (directory != null) {
        activeDirectories.remove(directory.path);
        if (await directory.exists()) await directory.delete(recursive: true);
      }
    } catch (_) {
      /* The OS may already have removed temporary files. */
    }
  }
}
