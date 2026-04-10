import 'dart:io';

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
  final major = _majorVersionFromPlatformString(Platform.operatingSystemVersion);
  if (major == null) {
    return false;
  }
  return major < 26;
}
