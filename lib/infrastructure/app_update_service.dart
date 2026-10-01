import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:package_info_plus/package_info_plus.dart';

class AppUpdateService {
  AppUpdateService._();

  static const String _appStoreId = '6761799720';
  static const String _iosStoreUrl =
      'https://apps.apple.com/app/id$_appStoreId';
  static const String androidStoreUrl =
      'https://play.google.com/store/apps/details?id=com.lisenhuang.bantera';
  static const _androidUpdates = MethodChannel('bantera/app_updates');

  static Future<
    ({
      bool needsUpdate,
      String storeUrl,
      String currentVersion,
      String storeVersion,
    })?
  >
  checkForUpdate() async {
    try {
      final info = await PackageInfo.fromPlatform();
      if (defaultTargetPlatform == TargetPlatform.android) {
        return await _checkAndroid(info);
      }
      if (defaultTargetPlatform == TargetPlatform.iOS) {
        return await _checkIos(info.version);
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  static Future<
    ({
      bool needsUpdate,
      String storeUrl,
      String currentVersion,
      String storeVersion,
    })?
  >
  _checkIos(String currentVersion) async {
    final json = await _getJson(
      Uri.parse('https://itunes.apple.com/lookup?id=$_appStoreId'),
    );
    if (json == null) return null;

    final results = json['results'] as List<dynamic>?;
    if (results == null || results.isEmpty) return null;

    final storeVersion =
        (results[0] as Map<String, dynamic>)['version'] as String?;
    if (storeVersion == null) return null;

    return (
      needsUpdate: _isNewer(storeVersion, currentVersion),
      storeUrl: _iosStoreUrl,
      currentVersion: currentVersion,
      storeVersion: storeVersion,
    );
  }

  static Future<
    ({
      bool needsUpdate,
      String storeUrl,
      String currentVersion,
      String storeVersion,
    })?
  >
  _checkAndroid(PackageInfo info) async {
    final needsUpdate = await _androidUpdates
        .invokeMethod<bool>('checkForUpdate')
        .timeout(const Duration(seconds: 15));
    if (needsUpdate == null) return null;

    return (
      needsUpdate: needsUpdate,
      storeUrl: androidStoreUrl,
      currentVersion: info.version,
      // Play exposes a version code, not the store's display version name.
      storeVersion: '',
    );
  }

  static Future<Map<String, dynamic>?> _getJson(Uri uri) async {
    final client = HttpClient();
    try {
      final request = await client.getUrl(uri);
      final response = await request.close();
      if (response.statusCode != HttpStatus.ok) return null;

      final body = await response.transform(utf8.decoder).join();
      final decoded = jsonDecode(body);
      return decoded is Map<String, dynamic> ? decoded : null;
    } finally {
      client.close(force: true);
    }
  }

  static bool _isNewer(String storeVersion, String currentVersion) =>
      _compareVersions(storeVersion, currentVersion) > 0;

  static int _compareVersions(String storeVersion, String currentVersion) {
    final storeParts = storeVersion
        .split('.')
        .map((s) => int.tryParse(s) ?? 0)
        .toList();
    final currentParts = currentVersion
        .split('.')
        .map((s) => int.tryParse(s) ?? 0)
        .toList();
    final len = storeParts.length > currentParts.length
        ? storeParts.length
        : currentParts.length;
    for (var i = 0; i < len; i++) {
      final s = i < storeParts.length ? storeParts[i] : 0;
      final c = i < currentParts.length ? currentParts[i] : 0;
      if (s > c) return 1;
      if (s < c) return -1;
    }
    return 0;
  }
}
