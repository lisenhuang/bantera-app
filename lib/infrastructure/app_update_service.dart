import 'dart:convert';
import 'dart:io';

import 'package:package_info_plus/package_info_plus.dart';

class AppUpdateService {
  AppUpdateService._();

  static const String _appStoreId = '6761799720';
  static const String _storeUrl =
      'https://apps.apple.com/app/id$_appStoreId';

  static Future<({bool needsUpdate, String storeUrl})?> checkForUpdate() async {
    try {
      final info = await PackageInfo.fromPlatform();
      final currentVersion = info.version;

      final client = HttpClient();
      final request = await client.getUrl(
        Uri.parse('https://itunes.apple.com/lookup?id=$_appStoreId'),
      );
      final response = await request.close();
      final body = await response.transform(utf8.decoder).join();
      client.close();

      final json = jsonDecode(body) as Map<String, dynamic>;
      final results = json['results'] as List<dynamic>?;
      if (results == null || results.isEmpty) return null;

      final storeVersion =
          (results[0] as Map<String, dynamic>)['version'] as String?;
      if (storeVersion == null) return null;

      return (
        needsUpdate: _isNewer(storeVersion, currentVersion),
        storeUrl: _storeUrl,
      );
    } catch (_) {
      return null;
    }
  }

  static bool _isNewer(String storeVersion, String currentVersion) {
    final storeParts =
        storeVersion.split('.').map((s) => int.tryParse(s) ?? 0).toList();
    final currentParts =
        currentVersion.split('.').map((s) => int.tryParse(s) ?? 0).toList();
    final len = storeParts.length > currentParts.length
        ? storeParts.length
        : currentParts.length;
    for (var i = 0; i < len; i++) {
      final s = i < storeParts.length ? storeParts[i] : 0;
      final c = i < currentParts.length ? currentParts[i] : 0;
      if (s > c) return true;
      if (s < c) return false;
    }
    return false;
  }
}
