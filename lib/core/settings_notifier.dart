import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class SettingsNotifier extends ChangeNotifier {
  SettingsNotifier._();

  ThemeMode _themeMode = ThemeMode.system;
  bool _notificationsEnabled = true;
  bool _isInitialized = false;

  ThemeMode get themeMode => _themeMode;
  bool get notificationsEnabled => _notificationsEnabled;
  bool get isInitialized => _isInitialized;

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
          }
        }
      }
    } catch (_) {
      _themeMode = ThemeMode.system;
      _notificationsEnabled = true;
    } finally {
      _isInitialized = true;
    }
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

  static final SettingsNotifier instance = SettingsNotifier._();

  Future<void> _persist() async {
    try {
      final file = await _settingsFile;
      await file.parent.create(recursive: true);
      await file.writeAsString(jsonEncode(<String, dynamic>{
        'themeMode': _themeMode.name,
        'notificationsEnabled': _notificationsEnabled,
      }));
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
      _ => ThemeMode.system,
    };
  }
}
