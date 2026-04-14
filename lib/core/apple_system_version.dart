import 'dart:io';

import 'settings_notifier.dart';

/// First integer in [Platform.operatingSystemVersion], e.g. iOS "18.2.1" -> 18, macOS "15.0" -> 15.
int? _majorVersionFromPlatformString(String version) {
  final match = RegExp(r'(\d+)').firstMatch(version.trim());
  if (match == null) return null;
  return int.tryParse(match.group(1)!);
}

/// iOS / iPadOS ([Platform.isIOS]) or macOS ([Platform.isMacOS]) with OS major below 26.
///
/// Used to hide Create and simplify Practice on older Apple OS releases. Non-Apple
/// platforms are never "legacy" here (full UI).
bool get isLegacyAppleOsPre26 {
  if (!Platform.isIOS && !Platform.isMacOS) {
    return false;
  }
  final major = appleOperatingSystemMajorVersion;
  if (major == null) {
    return false;
  }
  return major < 26;
}

/// Returns the real iOS/macOS major version, ignoring any dev mock override.
/// Use this for checks that must reflect the actual device OS (e.g. Dev screen visibility).
int? get realAppleOperatingSystemMajorVersion {
  if (!Platform.isIOS && !Platform.isMacOS) return null;
  return _majorVersionFromPlatformString(Platform.operatingSystemVersion);
}

/// Returns the iOS/macOS major version, using the dev mock override when set.
int? get appleOperatingSystemMajorVersion {
  if (!Platform.isIOS && !Platform.isMacOS) {
    return null;
  }
  final mock = SettingsNotifier.instance.devMockIosMajorVersion;
  if (mock != null) return mock;
  return _majorVersionFromPlatformString(Platform.operatingSystemVersion);
}

/// True when Apple's Translation framework is available (iOS / iPadOS 18+).
/// Use this to gate translation UI — do not use [isLegacyAppleOsPre26] for translation checks.
bool get supportsBuiltInTranslation {
  if (!Platform.isIOS) return false;
  final major = appleOperatingSystemMajorVersion;
  if (major == null) return false;
  return major >= 18;
}
