import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

import 'app_locale.dart';
import 'ios_dev_version_bridge.dart';

class SettingsNotifier extends ChangeNotifier {
  SettingsNotifier._();

  ThemeMode _themeMode = ThemeMode.system;
  bool _notificationsEnabled = true;
  String? _lastTranscriptionLocale;
  AppLocalePreference _appLocalePreference = AppLocalePreference.system;
  bool _isInitialized = false;
  int? _devMockIosMajorVersion;

  ThemeMode get themeMode => _themeMode;
  bool get notificationsEnabled => _notificationsEnabled;
  String? get lastTranscriptionLocale => _lastTranscriptionLocale;
  AppLocalePreference get appLocalePreference => _appLocalePreference;
  bool get isInitialized => _isInitialized;
  /// Dev-only: when non-null, overrides the iOS major version used for all feature checks.
  int? get devMockIosMajorVersion => _devMockIosMajorVersion;

  Future<void> initialize() async {
    if (_isInitialized) {
      return;
    }

    try {
      final file = await _settingsFile;
      if (await file.exists()) {
        final raw = await file.readAsString();
        if (raw.isNotEmpty) {
          final decoded = jsonDecode(raw);
          if (decoded is Map<String, dynamic>) {
            _themeMode = _themeModeFromString(decoded['themeMode']?.toString());
            _notificationsEnabled =
                decoded['notificationsEnabled'] as bool? ?? true;
            final savedLocale = decoded['lastTranscriptionLocale']
                ?.toString()
                .trim();
            _lastTranscriptionLocale =
                savedLocale == null || savedLocale.isEmpty ? null : savedLocale;
            _appLocalePreference = AppLocalePreference.fromStorage(
              decoded['appLocale']?.toString(),
            );
            _devMockIosMajorVersion = _coerceDevMockIosMajorVersion(
              decoded['devMockIosMajorVersion'],
            );
          }
        }
      }
    } catch (_) {
      _themeMode = ThemeMode.system;
      _notificationsEnabled = true;
      _lastTranscriptionLocale = null;
      _appLocalePreference = AppLocalePreference.system;
      _devMockIosMajorVersion = null;
    } finally {
      _isInitialized = true;
    }
    await _syncDevMockIosToNativeAsync();
  }

  /// Only `null`, `17`, and `18` are valid; older persisted values (e.g. 15, 26) clear the mock.
  static int? _coerceDevMockIosMajorVersion(dynamic raw) {
    if (raw is! int) return null;
    if (raw == 17 || raw == 18) return raw;
    return null;
  }

  Future<void> _syncDevMockIosToNativeAsync() async {
    if (!Platform.isIOS) return;
    await IosDevVersionBridge.syncDevMockIosMajorVersionToNative(
      _devMockIosMajorVersion,
    );
  }

  void _syncDevMockIosToNative() {
    unawaited(_syncDevMockIosToNativeAsync());
  }

  void setThemeMode(ThemeMode mode) {
    if (_themeMode != mode) {
      _themeMode = mode;
      notifyListeners();
      _persist();
    }
  }

  void toggleNotifications(bool value) {
    if (_notificationsEnabled != value) {
      _notificationsEnabled = value;
      notifyListeners();
      _persist();
    }
  }

  void setAppLocalePreference(AppLocalePreference value) {
    if (_appLocalePreference == value) {
      return;
    }
    _appLocalePreference = value;
    notifyListeners();
    _persist();
  }

  /// Call when the device locale changes and [appLocalePreference] is [system].
  void notifyLocaleChanged() {
    notifyListeners();
  }

  void setDevMockIosMajorVersion(int? value) {
    final next = value == null || value == 17 || value == 18 ? value : null;
    if (_devMockIosMajorVersion == next) return;
    _devMockIosMajorVersion = next;
    notifyListeners();
    _persist();
    _syncDevMockIosToNative();
  }

  void setLastTranscriptionLocale(String? identifier) {
    final normalized = identifier?.trim();
    final nextValue = normalized == null || normalized.isEmpty
        ? null
        : normalized;

    if (_lastTranscriptionLocale == nextValue) {
      return;
    }

    _lastTranscriptionLocale = nextValue;
    notifyListeners();
    _persist();
  }

  static final SettingsNotifier instance = SettingsNotifier._();

  Future<void> _persist() async {
    try {
      final file = await _settingsFile;
      await file.parent.create(recursive: true);
      await file.writeAsString(
        jsonEncode(<String, dynamic>{
          'themeMode': _themeMode.name,
          'notificationsEnabled': _notificationsEnabled,
          'lastTranscriptionLocale': _lastTranscriptionLocale,
          'appLocale': _appLocalePreference.storageValue,
          'devMockIosMajorVersion': _devMockIosMajorVersion,
        }),
      );
    } catch (_) {
      // Ignore local persistence failures and keep the in-memory setting.
    }
  }

  Future<File> get _settingsFile async {
    final directory = await getApplicationSupportDirectory();
    return File('${directory.path}/settings.json');
  }

  static ThemeMode _themeModeFromString(String? value) {
    return switch (value) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      'system' => ThemeMode.system,
      _ => ThemeMode.system,
    };
  }
}
