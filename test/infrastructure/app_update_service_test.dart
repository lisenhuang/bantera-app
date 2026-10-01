import 'dart:io';

import 'package:app/infrastructure/app_update_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:package_info_plus/package_info_plus.dart';

class _NoHttp extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    throw StateError('Android update checks must not make HTTP requests');
  }
}

void main() {
  final binding = TestWidgetsFlutterBinding.ensureInitialized();
  const channel = MethodChannel('bantera/app_updates');
  var calls = 0;

  setUp(() {
    debugDefaultTargetPlatformOverride = TargetPlatform.android;
    PackageInfo.setMockInitialValues(
      appName: 'Bantera',
      packageName: 'com.lisenhuang.bantera',
      version: '2.0.113',
      buildNumber: '301',
      buildSignature: '',
    );
    calls = 0;
  });

  tearDown(() {
    debugDefaultTargetPlatformOverride = null;
    binding.defaultBinaryMessenger.setMockMethodCallHandler(channel, null);
  });

  for (final available in [true, false]) {
    test(
      'Play availability $available determines the Android update result',
      () async {
        binding.defaultBinaryMessenger.setMockMethodCallHandler(channel, (
          call,
        ) async {
          expect(call.method, 'checkForUpdate');
          calls++;
          return available;
        });
        final result = await HttpOverrides.runWithHttpOverrides(
          AppUpdateService.checkForUpdate,
          _NoHttp(),
        );
        expect(calls, 1);
        expect(result?.needsUpdate, available);
        expect(
          result?.storeUrl,
          'https://play.google.com/store/apps/details?id=com.lisenhuang.bantera',
        );
        expect(result?.currentVersion, '2.0.113');
        expect(result?.storeVersion, isEmpty);
      },
    );
  }

  test('Unknown Play availability is not treated as up to date', () async {
    binding.defaultBinaryMessenger.setMockMethodCallHandler(
      channel,
      (_) async => null,
    );
    expect(await AppUpdateService.checkForUpdate(), isNull);
  });

  test(
    'Play failure on a sideloaded app is caught without an APK fallback',
    () async {
      binding.defaultBinaryMessenger.setMockMethodCallHandler(channel, (
        _,
      ) async {
        calls++;
        throw PlatformException(code: 'play_update_unavailable');
      });
      final result = await HttpOverrides.runWithHttpOverrides(
        AppUpdateService.checkForUpdate,
        _NoHttp(),
      );
      expect(calls, 1);
      expect(result, isNull);
    },
  );

  test(
    'Missing native channel does not escape as an unhandled exception',
    () async {
      expect(await AppUpdateService.checkForUpdate(), isNull);
    },
  );
}
