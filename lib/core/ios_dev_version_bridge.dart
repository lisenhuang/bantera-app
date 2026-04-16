import 'dart:io';

import 'package:flutter/services.dart';

/// Syncs [SettingsNotifier.devMockIosMajorVersion] to native iOS so Swift routing
/// matches Dart (`#available` alone cannot see the mock).
class IosDevVersionBridge {
  IosDevVersionBridge._();

  static const MethodChannel _channel = MethodChannel('bantera/ios_version');

  static Future<void> syncDevMockIosMajorVersionToNative(int? value) async {
    if (!Platform.isIOS) return;
    try {
      await _channel.invokeMethod<void>(
        'setDevMockIosMajorVersion',
        value,
      );
    } on MissingPluginException {
      // Tests / non-iOS embedders.
    }
  }
}
