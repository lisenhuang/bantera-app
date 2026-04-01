import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

class ApiConfigNotifier extends ChangeNotifier {
  ApiConfigNotifier._();

  static const String defaultBaseUrl = 'https://api.bantera.app';
  static const String defaultCustomBaseUrl = 'http://192.168.8.153:5218';
  static final ApiConfigNotifier instance = ApiConfigNotifier._();

  bool _isInitialized = false;
  bool _hasConfiguredBaseUrl = false;
  String _baseUrl = defaultBaseUrl;

  bool get isInitialized => _isInitialized;
  bool get hasConfiguredBaseUrl => _hasConfiguredBaseUrl;
  String get baseUrl => _baseUrl;
  bool get isUsingDefaultBaseUrl => _baseUrl == defaultBaseUrl;

  Future<void> initialize() async {
    if (_isInitialized) {
      return;
    }

    _baseUrl = defaultBaseUrl;

    try {
      final file = await _configFile;
      if (await file.exists()) {
        final raw = await file.readAsString();
        if (raw.isNotEmpty) {
          final decoded = jsonDecode(raw);
          if (decoded is Map<String, dynamic>) {
            final storedBaseUrl = decoded['baseUrl']?.toString();
            if (storedBaseUrl != null && storedBaseUrl.isNotEmpty) {
              _baseUrl = normalizeBaseUrl(storedBaseUrl);
              _hasConfiguredBaseUrl = true;
            }
          }
        }
      }
    } catch (_) {
      _baseUrl = defaultBaseUrl;
      _hasConfiguredBaseUrl = false;
    } finally {
      _isInitialized = true;
    }
  }

  Future<bool> saveBaseUrl(String value) async {
    final normalized = normalizeBaseUrl(value);
    final changed = !_hasConfiguredBaseUrl || normalized != _baseUrl;

    _baseUrl = normalized;
    _hasConfiguredBaseUrl = true;

    final file = await _configFile;
    await file.parent.create(recursive: true);
    await file.writeAsString(jsonEncode(<String, String>{
      'baseUrl': normalized,
    }));

    notifyListeners();
    return changed;
  }

  static String normalizeBaseUrl(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      throw const ApiConfigException('Enter an API base URL.');
    }

    final uri = Uri.tryParse(trimmed);
    if (uri == null || !uri.isAbsolute) {
      throw const ApiConfigException('Enter a full URL like https://api.bantera.app.');
    }

    if (uri.scheme != 'https' && uri.scheme != 'http') {
      throw const ApiConfigException('Only http and https URLs are supported.');
    }

    if (uri.host.isEmpty) {
      throw const ApiConfigException('The API base URL must include a host.');
    }

    if (uri.hasQuery || uri.hasFragment) {
      throw const ApiConfigException('Do not include query params or fragments in the base URL.');
    }

    final normalized = trimmed.replaceAll(RegExp(r'/+$'), '');
    return normalized.isEmpty ? trimmed : normalized;
  }

  Future<File> get _configFile async {
    final directory = await getApplicationSupportDirectory();
    return File('${directory.path}/api_config.json');
  }
}

class ApiConfigException implements Exception {
  const ApiConfigException(this.message);

  final String message;
}
