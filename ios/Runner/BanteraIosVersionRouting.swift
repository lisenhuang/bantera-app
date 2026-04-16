import Flutter
import Foundation

/// Dev mock major version synced from Flutter (`SettingsNotifier.devMockIosMajorVersion`).
/// Routing uses effective OS; real OS still gates API availability.
enum BanteraIosVersionRouting {
  private static let userDefaultsKey = "devMockIosMajorVersion"

  static var devMockIosMajorVersion: Int? {
    get {
      guard UserDefaults.standard.object(forKey: userDefaultsKey) != nil else {
        return nil
      }
      return UserDefaults.standard.integer(forKey: userDefaultsKey)
    }
    set {
      if let newValue {
        UserDefaults.standard.set(newValue, forKey: userDefaultsKey)
      } else {
        UserDefaults.standard.removeObject(forKey: userDefaultsKey)
      }
    }
  }

  static var realIosMajorVersion: Int {
    ProcessInfo.processInfo.operatingSystemVersion.majorVersion
  }

  static var effectiveIosMajorVersion: Int {
    devMockIosMajorVersion ?? realIosMajorVersion
  }

  /// `BanteraVideoPreparationService` / SpeechTranscriber path (iOS 26+ product behavior).
  static var useSpeechTranscriberRoutingPath: Bool {
    effectiveIosMajorVersion >= 26 && realIosMajorVersion >= 26
  }

  /// Translation.framework cue translation (iOS 18+).
  static var useTranslationFrameworkRoutingPath: Bool {
    effectiveIosMajorVersion >= 18 && realIosMajorVersion >= 18
  }
}

final class BanteraIosVersionBridge {
  init(binaryMessenger: FlutterBinaryMessenger) {
    let channel = FlutterMethodChannel(
      name: "bantera/ios_version",
      binaryMessenger: binaryMessenger
    )
    channel.setMethodCallHandler { call, result in
      guard call.method == "setDevMockIosMajorVersion" else {
        result(FlutterMethodNotImplemented)
        return
      }
      switch call.arguments {
      case nil, is NSNull:
        BanteraIosVersionRouting.devMockIosMajorVersion = nil
      case let value as Int:
        BanteraIosVersionRouting.devMockIosMajorVersion = value
      case let value as NSNumber:
        BanteraIosVersionRouting.devMockIosMajorVersion = value.intValue
      default:
        result(
          FlutterError(
            code: "invalid_arguments",
            message: "setDevMockIosMajorVersion expects int or null",
            details: nil
          )
        )
        return
      }
      result(nil)
    }
  }
}
