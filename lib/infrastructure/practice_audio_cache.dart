import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

class PracticeAudioCacheProgress {
  const PracticeAudioCacheProgress({required this.received, this.total});

  final int received;
  final int? total;

  double? get fraction {
    final t = total;
    if (t == null || t <= 0) {
      return null;
    }
    return (received / t).clamp(0.0, 1.0);
  }
}

class PracticeAudioCacheResult {
  const PracticeAudioCacheResult({required this.file, required this.cacheHit});

  final File file;
  final bool cacheHit;
}

class PracticeAudioCache {
  PracticeAudioCache._();

  static final PracticeAudioCache instance = PracticeAudioCache._();

  Future<PracticeAudioCacheResult> getAudioFile({
    required String mediaId,
    required String url,
    required Map<String, String> headers,
    void Function(PracticeAudioCacheProgress progress)? onProgress,
  }) async {
    final directory = await _cacheDirectory;
    await directory.create(recursive: true);

    final safeId = _safeFilePart(mediaId);
    final uri = Uri.parse(url);
    final extension = _extensionFromUri(uri);
    final mediaFile = File('${directory.path}/$safeId$extension');
    final metadataFile = File('${directory.path}/$safeId.json');

    if (await _isValidCachedFile(
      mediaFile: mediaFile,
      metadataFile: metadataFile,
      url: url,
    )) {
      onProgress?.call(const PracticeAudioCacheProgress(received: 1, total: 1));
      return PracticeAudioCacheResult(file: mediaFile, cacheHit: true);
    }

    final partFile = File('${mediaFile.path}.part');
    await _download(
      uri: uri,
      headers: headers,
      partFile: partFile,
      onProgress: onProgress,
    );

    if (await mediaFile.exists()) {
      await mediaFile.delete();
    }
    await partFile.rename(mediaFile.path);
    await metadataFile.writeAsString(
      jsonEncode(<String, dynamic>{
        'url': url,
        'path': mediaFile.path,
        'cachedAt': DateTime.now().toUtc().toIso8601String(),
      }),
      flush: true,
    );

    return PracticeAudioCacheResult(file: mediaFile, cacheHit: false);
  }

  Future<Directory> get _cacheDirectory async {
    final base = await getApplicationSupportDirectory();
    return Directory('${base.path}/practice_audio_cache');
  }

  Future<bool> _isValidCachedFile({
    required File mediaFile,
    required File metadataFile,
    required String url,
  }) async {
    if (!await mediaFile.exists() || !await metadataFile.exists()) {
      return false;
    }
    try {
      final metadata = jsonDecode(await metadataFile.readAsString());
      if (metadata is! Map<String, dynamic>) {
        return false;
      }
      return metadata['url'] == url && await mediaFile.length() > 0;
    } catch (_) {
      return false;
    }
  }

  Future<void> _download({
    required Uri uri,
    required Map<String, String> headers,
    required File partFile,
    void Function(PracticeAudioCacheProgress progress)? onProgress,
  }) async {
    final client = HttpClient();
    IOSink? sink;
    try {
      if (await partFile.exists()) {
        await partFile.delete();
      }
      await partFile.parent.create(recursive: true);

      final request = await client.getUrl(uri);
      headers.forEach((key, value) => request.headers.set(key, value));
      final response = await request.close();
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw Exception('Server returned ${response.statusCode}');
      }

      final total = response.contentLength > 0 ? response.contentLength : null;
      var received = 0;
      onProgress?.call(PracticeAudioCacheProgress(received: 0, total: total));
      sink = partFile.openWrite();
      await for (final chunk in response) {
        received += chunk.length;
        sink.add(chunk);
        onProgress?.call(
          PracticeAudioCacheProgress(received: received, total: total),
        );
      }
      await sink.flush();
      await sink.close();
      sink = null;
    } catch (_) {
      await sink?.close();
      if (await partFile.exists()) {
        await partFile.delete();
      }
      rethrow;
    } finally {
      client.close(force: true);
    }
  }

  String _safeFilePart(String value) {
    final safe = value.replaceAll(RegExp(r'[^A-Za-z0-9_.-]'), '_');
    return safe.isEmpty ? 'audio' : safe;
  }

  String _extensionFromUri(Uri uri) {
    final path = uri.path.toLowerCase();
    for (final extension in const ['.m4a', '.mp3', '.aac', '.wav', '.caf']) {
      if (path.endsWith(extension)) {
        return extension;
      }
    }
    return '.wav';
  }
}
