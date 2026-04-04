import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

import '../domain/models/models.dart';

class CachedUserProfile {
  const CachedUserProfile({required this.profile, required this.avatarPath});

  final UserProfile profile;
  final String? avatarPath;
}

class UserProfileCacheStore {
  UserProfileCacheStore._();

  static final UserProfileCacheStore instance = UserProfileCacheStore._();

  Future<CachedUserProfile?> read(String cacheKey) async {
    try {
      final file = await _profileFile(cacheKey);
      if (!await file.exists()) {
        return null;
      }

      final raw = await file.readAsString();
      if (raw.isEmpty) {
        return null;
      }

      final decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) {
        return null;
      }

      final avatarPath = decoded['avatarPath']?.toString();
      final resolvedAvatarPath = await _resolveAvatarPath(avatarPath);

      return CachedUserProfile(
        profile: UserProfile(
          id: decoded['id']?.toString() ?? '',
          name: decoded['name']?.toString() ?? '',
          avatarUrl: decoded['avatarUrl']?.toString(),
          translationLanguage: decoded['translationLanguage']?.toString(),
        ),
        avatarPath: resolvedAvatarPath,
      );
    } catch (_) {
      return null;
    }
  }

  Future<void> write(
    String cacheKey,
    UserProfile profile, {
    String? avatarPath,
  }) async {
    final file = await _profileFile(cacheKey);
    await file.parent.create(recursive: true);
    await file.writeAsString(
      jsonEncode(<String, dynamic>{
        'id': profile.id,
        'name': profile.name,
        'avatarUrl': profile.avatarUrl,
        'translationLanguage': profile.translationLanguage,
        'avatarPath': avatarPath,
      }),
    );
  }

  Future<String?> cacheAvatarFromFile(String cacheKey, File sourceFile) async {
    if (!await sourceFile.exists()) {
      return null;
    }

    final extension = _normalizedExtension(sourceFile.path);
    await _deleteAvatarFiles(cacheKey);

    final output = await _avatarFile(cacheKey, extension);
    await output.parent.create(recursive: true);
    await sourceFile.copy(output.path);
    return output.path;
  }

  Future<String?> cacheAvatarFromUrl(String cacheKey, String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) {
      return null;
    }

    final client = HttpClient();
    try {
      final request = await client.getUrl(uri);
      final response = await request.close();
      if (response.statusCode < 200 || response.statusCode >= 300) {
        return null;
      }

      final bytes = await consolidateHttpClientResponseBytes(response);
      final extension =
          _extensionFromMimeType(response.headers.contentType?.mimeType) ??
          _normalizedExtension(uri.path);

      await _deleteAvatarFiles(cacheKey);
      final output = await _avatarFile(cacheKey, extension);
      await output.parent.create(recursive: true);
      await output.writeAsBytes(bytes, flush: true);
      return output.path;
    } catch (_) {
      return null;
    } finally {
      client.close(force: true);
    }
  }

  Future<void> clearAvatar(String cacheKey) async {
    await _deleteAvatarFiles(cacheKey);
  }

  Future<File> _profileFile(String cacheKey) async {
    final directory = await _cacheDirectory;
    return File('${directory.path}/${_safeCacheKey(cacheKey)}.json');
  }

  Future<File> _avatarFile(String cacheKey, String extension) async {
    final directory = await _cacheDirectory;
    final normalizedExtension = extension.startsWith('.')
        ? extension.substring(1)
        : extension;
    return File(
      '${directory.path}/${_safeCacheKey(cacheKey)}_avatar.$normalizedExtension',
    );
  }

  Future<String?> _resolveAvatarPath(String? avatarPath) async {
    if (avatarPath == null || avatarPath.isEmpty) {
      return null;
    }

    final file = File(avatarPath);
    return await file.exists() ? file.path : null;
  }

  Future<void> _deleteAvatarFiles(String cacheKey) async {
    final directory = await _cacheDirectory;
    if (!await directory.exists()) {
      return;
    }

    final prefix = '${_safeCacheKey(cacheKey)}_avatar.';
    await for (final entity in directory.list()) {
      if (entity is File && entity.uri.pathSegments.last.startsWith(prefix)) {
        try {
          await entity.delete();
        } catch (_) {
          // Ignore cache cleanup failures.
        }
      }
    }
  }

  Future<Directory> get _cacheDirectory async {
    final supportDirectory = await getApplicationSupportDirectory();
    return Directory('${supportDirectory.path}/profile_cache');
  }

  static String _safeCacheKey(String value) {
    return base64Url.encode(utf8.encode(value)).replaceAll('=', '');
  }

  static String _normalizedExtension(String path) {
    final extension = path.split('.').last.toLowerCase();
    if (extension == path.toLowerCase()) {
      return 'jpg';
    }
    return extension;
  }

  static String? _extensionFromMimeType(String? mimeType) {
    return switch (mimeType) {
      'image/png' => 'png',
      'image/webp' => 'webp',
      'image/heic' => 'heic',
      'image/heif' => 'heif',
      _ => mimeType == null ? null : 'jpg',
    };
  }
}
