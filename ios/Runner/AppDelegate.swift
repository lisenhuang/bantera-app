import AVFoundation
import AudioToolbox
import CoreTelephony
import Flutter
import Network
import NaturalLanguage
import Photos
import Speech
@preconcurrency import Translation
import UIKit
import UserNotifications

@main
@objc class AppDelegate: FlutterAppDelegate {
  let callKit = BanteraCallKitBridge()
  lazy var callEngine = FlutterEngine(name: "bantera", project: nil, allowHeadlessExecution: true)
  private var videoProcessingBridge: BanteraVideoProcessingBridge?
  private var translationBridge: BanteraTranslationBridge?
  private var iosVersionBridge: BanteraIosVersionBridge?
  private var pushNotificationsBridge: BanteraPushNotificationsBridge?
  private var pendingNotificationTap: [String: String]?
  private var aiCallActivityBridge: BanteraAiCallActivityBridge?
  var aiAudioBridge: BanteraAiAudioBridge?
  private var photoSaveBridge: BanteraPhotoSaveBridge?

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    UNUserNotificationCenter.current().delegate = self
    if let userInfo = launchOptions?[.remoteNotification] as? [AnyHashable: Any] {
      pendingNotificationTap = Self.notificationPayload(from: userInfo)
    }
    callEngine.run()
    configureEngine()
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  override func userNotificationCenter(
    _ center: UNUserNotificationCenter,
    didReceive response: UNNotificationResponse,
    withCompletionHandler completionHandler: @escaping () -> Void
  ) {
    if response.notification.request.content.userInfo["payload"] as? String == "daily-goal" {
      super.userNotificationCenter(center, didReceive: response, withCompletionHandler: completionHandler)
      return
    }
    let payload = Self.notificationPayload(
      from: response.notification.request.content.userInfo
    )
    if let pushNotificationsBridge {
      pushNotificationsBridge.handleNotificationTap(payload)
    } else {
      pendingNotificationTap = payload
    }
    completionHandler()
  }

  override func userNotificationCenter(
    _ center: UNUserNotificationCenter,
    willPresent notification: UNNotification,
    withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
  ) {
    let payload = Self.notificationPayload(from: notification.request.content.userInfo)
    if payload["threadType"] == "dm" {
      completionHandler([.banner, .list, .sound])
      return
    }
    super.userNotificationCenter(center, willPresent: notification, withCompletionHandler: completionHandler)
  }

  override func application(
    _ application: UIApplication,
    didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
  ) {
    pushNotificationsBridge?.handleRegisteredDeviceToken(deviceToken)
    super.application(application, didRegisterForRemoteNotificationsWithDeviceToken: deviceToken)
  }

  override func application(
    _ application: UIApplication,
    didFailToRegisterForRemoteNotificationsWithError error: Error
  ) {
    pushNotificationsBridge?.handleRegistrationFailure(error)
    super.application(application, didFailToRegisterForRemoteNotificationsWithError: error)
  }

  private func configureEngine() {
    GeneratedPluginRegistrant.register(with: callEngine)
    aiAudioBridge = BanteraAiAudioBridge(messenger: callEngine.binaryMessenger)
    aiCallActivityBridge = BanteraAiCallActivityBridge(messenger: callEngine.binaryMessenger)
    photoSaveBridge = BanteraPhotoSaveBridge(binaryMessenger: callEngine.binaryMessenger)
    callKit.attach(messenger: callEngine.binaryMessenger)
    videoProcessingBridge = BanteraVideoProcessingBridge(
      binaryMessenger: callEngine.binaryMessenger
    )
    translationBridge = BanteraTranslationBridge(
      binaryMessenger: callEngine.binaryMessenger
    )
    iosVersionBridge = BanteraIosVersionBridge(
      binaryMessenger: callEngine.binaryMessenger
    )
    _ = BanteraNetworkReachabilityBridge(
      binaryMessenger: callEngine.binaryMessenger
    )
    pushNotificationsBridge = BanteraPushNotificationsBridge(
      binaryMessenger: callEngine.binaryMessenger,
      initialNotification: pendingNotificationTap
    )
    pendingNotificationTap = nil
  }

  private static func notificationPayload(from userInfo: [AnyHashable: Any]) -> [String: String] {
    var payload: [String: String] = [:]
    for (key, value) in userInfo {
      guard let key = key as? String, key != "aps" else {
        continue
      }
      if let stringValue = value as? String {
        payload[key] = stringValue
      } else {
        payload[key] = "\(value)"
      }
    }
    return payload
  }
}

final class BanteraPhotoSaveBridge {
  private let channel: FlutterMethodChannel

  init(binaryMessenger: FlutterBinaryMessenger) {
    channel = FlutterMethodChannel(name: "bantera/photos", binaryMessenger: binaryMessenger)
    channel.setMethodCallHandler { call, result in
      guard call.method == "saveImage" else {
        result(FlutterMethodNotImplemented)
        return
      }
      guard let args = call.arguments as? [String: Any],
            let bytes = args["bytes"] as? FlutterStandardTypedData,
            bytes.data.count <= 20_000_000,
            UIImage(data: bytes.data) != nil else {
        result(FlutterError(code: "invalid_image", message: "Invalid progress image.", details: nil))
        return
      }
      let data = bytes.data
      let filename = data.count >= 2 && data[0] == 0xff && data[1] == 0xd8 ? "bantera-word-progress.jpg" : "bantera-word-progress.png"
      PHPhotoLibrary.requestAuthorization(for: .addOnly) { status in
        guard status == .authorized || status == .limited else {
          DispatchQueue.main.async {
            result(FlutterError(code: "permission_denied", message: "Allow adding photos in Settings.", details: nil))
          }
          return
        }
        PHPhotoLibrary.shared().performChanges({
          let request = PHAssetCreationRequest.forAsset()
          let options = PHAssetResourceCreationOptions()
          options.originalFilename = filename
          request.addResource(with: .photo, data: data, options: options)
        }) { success, error in
          DispatchQueue.main.async {
            if success { result(nil) }
            else { result(FlutterError(code: "save_failed", message: error?.localizedDescription, details: nil)) }
          }
        }
      }
    }
  }
}

final class BanteraPushNotificationsBridge {
  private let channel: FlutterMethodChannel
  private var cachedToken: String?
  private var pendingResults: [FlutterResult] = []
  private var initialNotification: [String: String]?

  init(
    binaryMessenger: FlutterBinaryMessenger,
    initialNotification: [String: String]?
  ) {
    self.initialNotification = initialNotification
    channel = FlutterMethodChannel(
      name: "bantera/push_notifications",
      binaryMessenger: binaryMessenger
    )
    channel.setMethodCallHandler(handle)
  }

  private func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "getCachedPushToken":
      result(tokenPayload())
    case "registerIfAuthorized":
      registerIfAuthorized(result: result)
    case "takeInitialNotification":
      result(initialNotification)
      initialNotification = nil
    case "requestAuthorizationAndRegister":
      requestAuthorizationAndRegister(result: result)
    default:
      result(FlutterMethodNotImplemented)
    }
  }

  private func registerIfAuthorized(result: @escaping FlutterResult) {
    UNUserNotificationCenter.current().getNotificationSettings { settings in
      DispatchQueue.main.async {
        switch settings.authorizationStatus {
        case .authorized, .provisional, .ephemeral:
          UIApplication.shared.registerForRemoteNotifications()
          if let payload = self.tokenPayload() {
            result(payload)
            return
          }
          self.pendingResults.append(result)
        default:
          result(nil)
        }
      }
    }
  }

  private func requestAuthorizationAndRegister(result: @escaping FlutterResult) {
    UNUserNotificationCenter.current().requestAuthorization(
      options: [.alert, .badge, .sound]
    ) { granted, error in
      DispatchQueue.main.async {
        if let error {
          result(
            FlutterError(
              code: "notification_authorization_failed",
              message: error.localizedDescription,
              details: nil
            )
          )
          return
        }

        guard granted else {
          result(nil)
          return
        }

        UIApplication.shared.registerForRemoteNotifications()
        if let payload = self.tokenPayload() {
          result(payload)
          return
        }

        self.pendingResults.append(result)
      }
    }
  }

  func handleRegisteredDeviceToken(_ deviceToken: Data) {
    cachedToken = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
    let results = pendingResults
    pendingResults.removeAll()
    for result in results {
      result(tokenPayload())
    }
  }

  func handleRegistrationFailure(_ error: Error) {
    let results = pendingResults
    pendingResults.removeAll()
    for result in results {
      result(FlutterError(
        code: "push_registration_failed",
        message: error.localizedDescription,
        details: nil
      ))
    }
  }

  func handleNotificationTap(_ payload: [String: String]) {
    channel.invokeMethod("notificationTapped", arguments: payload)
  }

  private func tokenPayload() -> [String: Any]? {
    guard let cachedToken, !cachedToken.isEmpty else {
      return nil
    }

    return [
      "token": cachedToken,
      "isSandbox": Self.isApnsSandboxEnvironment(),
    ]
  }

  static func isApnsSandboxEnvironment() -> Bool {
    if let environment = embeddedProvisioningApnsEnvironment() {
      return environment == "development"
    }

    #if DEBUG
    return true
    #else
    return false
    #endif
  }

  private static func embeddedProvisioningApnsEnvironment() -> String? {
    guard let url = Bundle.main.url(
      forResource: "embedded",
      withExtension: "mobileprovision"
    ), let data = try? Data(contentsOf: url) else {
      return nil
    }

    let profile = String(data: data, encoding: .isoLatin1)
      ?? String(data: data, encoding: .utf8)
    guard let profile else {
      return nil
    }

    let pattern = #"<key>aps-environment</key>\s*<string>([^<]+)</string>"#
    guard let regex = try? NSRegularExpression(pattern: pattern),
          let match = regex.firstMatch(
            in: profile,
            range: NSRange(profile.startIndex..., in: profile)
          ),
          let range = Range(match.range(at: 1), in: profile) else {
      return nil
    }

    return String(profile[range])
  }
}

/// Per-app cellular policy (`CTCellularData`) + `Network` path snapshot for Dart.
///
/// - `CTCellularData` must be driven on the **main** thread; reading or assigning
///   `cellularDataRestrictionDidUpdateNotifier` from a background queue often
///   leaves `restrictedState` stuck at `.restrictedStateUnknown` on recent iOS
///   (including iOS 26), so the notifier never resolves.
/// - When CT stays unknown, we combine a short main-thread poll with an
///   `NWPathMonitor` snapshot (Apple’s recommended reachability API) as a
///   fallback hint when classifying errors.
private final class BanteraNetworkReachabilityBridge {
  private let channel: FlutterMethodChannel

  private let cellularData = CTCellularData()

  init(binaryMessenger: FlutterBinaryMessenger) {
    channel = FlutterMethodChannel(
      name: "bantera/network_reachability",
      binaryMessenger: binaryMessenger
    )
    channel.setMethodCallHandler(handle)
  }

  private func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "getNetworkHints":
      getNetworkHints(result: result)
    case "getDeviceInfo":
      result(Self.deviceInfo())
    case "getCellularRestrictedState":
      getNetworkHints { payload in
        if let dict = payload as? [String: Any],
           let ct = dict["ctState"] as? String {
          result(ct)
        } else {
          result("unknown")
        }
      }
    default:
      result(FlutterMethodNotImplemented)
    }
  }

  private static func deviceInfo() -> [String: Any] {
    let device = UIDevice.current
    let idiom: String
    switch device.userInterfaceIdiom {
    case .phone:
      idiom = "phone"
    case .pad:
      idiom = "pad"
    case .tv:
      idiom = "tv"
    case .carPlay:
      idiom = "carPlay"
    case .mac:
      idiom = "mac"
    case .unspecified:
      idiom = "unspecified"
    @unknown default:
      idiom = "unknown"
    }

    return [
      "model": device.model,
      "localizedModel": device.localizedModel,
      "userInterfaceIdiom": idiom,
    ]
  }

  /// Full diagnostic payload for Dart (`ctState` + NWPathMonitor booleans).
  private func getNetworkHints(result: @escaping FlutterResult) {
    DispatchQueue.global(qos: .userInitiated).async { [weak self] in
      guard let self = self else {
        DispatchQueue.main.async { result(nil) }
        return
      }

      let nw = Self.snapshotNWPaths()
      BanteraNetworkReachabilityBridge.log(
        "NWPath snapshot: default=\(nw.defaultSatisfied) wifi=\(nw.wifiSatisfied) cellular=\(nw.cellularSatisfied)"
      )

      let sem = DispatchSemaphore(value: 0)
      var ctFinal = "unknown"

      DispatchQueue.main.async {
        self.resolveCTCellularPolicyOnMain { value in
          ctFinal = value
          sem.signal()
        }
      }

      _ = sem.wait(timeout: .now() + 2.8)

      BanteraNetworkReachabilityBridge.log("CTCellular final ctState=\(ctFinal)")

      DispatchQueue.main.async {
        result([
          "ctState": ctFinal,
          "nwDefaultSatisfied": nw.defaultSatisfied,
          "nwWifiSatisfied": nw.wifiSatisfied,
          "nwCellularSatisfied": nw.cellularSatisfied,
        ])
      }
    }
  }

  /// Runs on the main queue only. Polls `restrictedState` after assigning the notifier.
  private func resolveCTCellularPolicyOnMain(completion: @escaping (String) -> Void) {
    assert(Thread.isMainThread, "CTCellularData policy must be resolved on main")

    var finished = false
    let done: (String) -> Void = { value in
      guard !finished else { return }
      finished = true
      completion(value)
    }

    cellularData.cellularDataRestrictionDidUpdateNotifier = { state in
      let mapped = Self.mapRestrictedState(state)
      BanteraNetworkReachabilityBridge.log("cellularDataRestrictionDidUpdateNotifier mapped=\(mapped)")
      if mapped != "unknown" {
        done(mapped)
      }
    }

    let immediate = Self.mapRestrictedState(cellularData.restrictedState)
    BanteraNetworkReachabilityBridge.log("CTCellular immediate restrictedState=\(immediate)")

    if immediate != "unknown" {
      done(immediate)
      return
    }

    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [weak self] in
      guard let self = self, !finished else { return }
      let v = Self.mapRestrictedState(self.cellularData.restrictedState)
      BanteraNetworkReachabilityBridge.log("CTCellular t+0.2s restrictedState=\(v)")
      if v != "unknown" {
        done(v)
      }
    }

    DispatchQueue.main.asyncAfter(deadline: .now() + 1.7) { [weak self] in
      guard let self = self, !finished else { return }
      let v = Self.mapRestrictedState(self.cellularData.restrictedState)
      BanteraNetworkReachabilityBridge.log("CTCellular t+1.7s final restrictedState=\(v)")
      done(v)
    }
  }

  private struct NWSnapshot {
    let defaultSatisfied: Bool
    let wifiSatisfied: Bool
    let cellularSatisfied: Bool
  }

  /// Uses `NWPathMonitor` (Network framework) — Apple’s supported reachability surface on modern iOS.
  private static func snapshotNWPaths() -> NWSnapshot {
    let queue = DispatchQueue(label: "bantera.nw.path.snapshot")
    let defaultMon = NWPathMonitor()
    let wifiMon = NWPathMonitor(requiredInterfaceType: .wifi)
    let cellularMon = NWPathMonitor(requiredInterfaceType: .cellular)

    defaultMon.start(queue: queue)
    wifiMon.start(queue: queue)
    cellularMon.start(queue: queue)

    Thread.sleep(forTimeInterval: 0.04)

    let d = defaultMon.currentPath.status == .satisfied
    let w = wifiMon.currentPath.status == .satisfied
    let c = cellularMon.currentPath.status == .satisfied

    defaultMon.cancel()
    wifiMon.cancel()
    cellularMon.cancel()

    return NWSnapshot(defaultSatisfied: d, wifiSatisfied: w, cellularSatisfied: c)
  }

  private static func mapRestrictedState(_ state: CTCellularDataRestrictedState) -> String {
    switch state {
    case .restricted:
      return "restricted"
    case .notRestricted:
      return "notRestricted"
    case .restrictedStateUnknown:
      return "unknown"
    @unknown default:
      return "unknown"
    }
  }

  private static func log(_ message: String) {
    print("[BanteraNetwork] \(message)")
  }
}

private final class BanteraVideoProcessingBridge {
  private let channel: FlutterMethodChannel

  init(binaryMessenger: FlutterBinaryMessenger) {
    channel = FlutterMethodChannel(
      name: "bantera/video_processing",
      binaryMessenger: binaryMessenger
    )
    channel.setMethodCallHandler(handle)
    BanteraLegacySpeechRecognitionService.logSupportedLocales()
  }

  private func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "getSupportedTranscriptionLocales":
      handleGetSupportedTranscriptionLocales(result: result)
    case "prepareVideoForUpload":
      handlePrepareVideoForUpload(call: call, result: result)
    case "transcribeRecordedAudio":
      handleTranscribeRecordedAudio(call: call, result: result)
    case "transcribeAudioForUpload":
      handleTranscribeAudioForUpload(call: call, result: result)
    case "ensureTranscriptionModelInstalled":
      handleEnsureTranscriptionModelInstalled(call: call, result: result)
    case "ensureRecordedAudioTranscriptionReady":
      handleEnsureRecordedAudioTranscriptionReady(call: call, result: result)
    default:
      result(FlutterMethodNotImplemented)
    }
  }

  private func handleGetSupportedTranscriptionLocales(result: @escaping FlutterResult) {
    if BanteraIosVersionRouting.useSpeechTranscriberRoutingPath {
      guard #available(iOS 26.0, *) else {
        result(BanteraVideoProcessingError.unsupportedIosVersion.flutterError)
        return
      }

      Task {
        let payload = await BanteraVideoPreparationService.supportedLocalePayload()
        print("[SpeechTranscriber, iOS 26+] Supported transcription locales (\(payload.count)):")
        for locale in payload {
          let id = locale["identifier"] as? String ?? "?"
          let name = locale["displayName"] as? String ?? "?"
          print("[SpeechTranscriber, iOS 26+]   \(id) — \(name)")
        }
        await BanteraTranslationService.logAllSupportedLanguages()
        DispatchQueue.main.async {
          result(payload)
        }
      }
    } else {
      let payload = BanteraLegacySpeechRecognitionService.supportedTranscriptionLocalePayload()
      print("[SFSpeechRecognizer] Supported transcription locales (\(payload.count)) (routing)")
      DispatchQueue.main.async {
        result(payload)
      }
    }
  }

  private func handlePrepareVideoForUpload(
    call: FlutterMethodCall,
    result: @escaping FlutterResult
  ) {
    guard BanteraIosVersionRouting.useSpeechTranscriberRoutingPath else {
      result(BanteraVideoProcessingError.unsupportedIosVersion.flutterError)
      return
    }
    guard #available(iOS 26.0, *) else {
      result(BanteraVideoProcessingError.unsupportedIosVersion.flutterError)
      return
    }

    guard
      let args = call.arguments as? [String: Any],
      let inputPath = args["inputPath"] as? String,
      let localeIdentifier = args["localeIdentifier"] as? String,
      !inputPath.isEmpty,
      !localeIdentifier.isEmpty
    else {
      result(BanteraVideoProcessingError.invalidArguments.flutterError)
      return
    }

    Task {
      do {
        let response = try await BanteraVideoPreparationService().prepareVideoForUpload(
          inputURL: URL(fileURLWithPath: inputPath),
          localeIdentifier: localeIdentifier
        )
        DispatchQueue.main.async {
          result(response)
        }
      } catch let error as BanteraVideoProcessingError {
        DispatchQueue.main.async {
          result(error.flutterError)
        }
      } catch {
        DispatchQueue.main.async {
          result(
            FlutterError(
              code: "video_processing_failed",
              message: error.localizedDescription,
              details: nil
            )
          )
        }
      }
    }
  }

  private func handleTranscribeRecordedAudio(
    call: FlutterMethodCall,
    result: @escaping FlutterResult
  ) {
    guard
      let args = call.arguments as? [String: Any],
      let inputPath = args["inputPath"] as? String,
      let localeIdentifier = args["localeIdentifier"] as? String,
      !inputPath.isEmpty,
      !localeIdentifier.isEmpty
    else {
      result(BanteraVideoProcessingError.invalidArguments.flutterError)
      return
    }

    // Default to the normal (auto-corrected) level so an older Flutter bridge that
    // omits the flag still gets a readable transcript; practice opts out explicitly.
    let allowAutoCorrection = (args["allowAutoCorrection"] as? Bool) ?? true

    Task {
      do {
        let inputURL = URL(fileURLWithPath: inputPath)
        let response = try await BanteraLegacySpeechRecognitionService().transcribeRecordedAudio(
          inputURL: inputURL,
          localeIdentifier: localeIdentifier,
          allowAutoCorrection: allowAutoCorrection
        )
        DispatchQueue.main.async {
          result(response)
        }
      } catch let error as BanteraVideoProcessingError {
        DispatchQueue.main.async {
          result(error.flutterError)
        }
      } catch {
        DispatchQueue.main.async {
          result(
            FlutterError(
              code: "video_processing_failed",
              message: error.localizedDescription,
              details: nil
            )
          )
        }
      }
    }
  }

  private func handleEnsureRecordedAudioTranscriptionReady(
    call: FlutterMethodCall,
    result: @escaping FlutterResult
  ) {
    guard
      let args = call.arguments as? [String: Any],
      let localeIdentifier = args["localeIdentifier"] as? String,
      !localeIdentifier.isEmpty
    else {
      result(BanteraVideoProcessingError.invalidArguments.flutterError)
      return
    }

    Task {
      do {
        if BanteraIosVersionRouting.useSpeechTranscriberRoutingPath {
          if #available(iOS 26.0, *) {
            try await BanteraVideoPreparationService().ensureTranscriptionModelInstalled(
              localeIdentifier: localeIdentifier
            )
          } else {
            try await BanteraLegacySpeechRecognitionService().ensureReady(
              localeIdentifier: localeIdentifier
            )
          }
        } else {
          try await BanteraLegacySpeechRecognitionService().ensureReady(
            localeIdentifier: localeIdentifier
          )
        }
        DispatchQueue.main.async {
          result(nil)
        }
      } catch let error as BanteraVideoProcessingError {
        DispatchQueue.main.async {
          result(error.flutterError)
        }
      } catch {
        DispatchQueue.main.async {
          result(
            FlutterError(
              code: "speech_unavailable",
              message: error.localizedDescription,
              details: nil
            )
          )
        }
      }
    }
  }
  private func handleTranscribeAudioForUpload(
    call: FlutterMethodCall,
    result: @escaping FlutterResult
  ) {
    guard BanteraIosVersionRouting.useSpeechTranscriberRoutingPath else {
      result(BanteraVideoProcessingError.unsupportedIosVersion.flutterError)
      return
    }
    guard #available(iOS 26.0, *) else {
      result(BanteraVideoProcessingError.unsupportedIosVersion.flutterError)
      return
    }

    guard
      let args = call.arguments as? [String: Any],
      let inputPath = args["inputPath"] as? String,
      let localeIdentifier = args["localeIdentifier"] as? String,
      !inputPath.isEmpty,
      !localeIdentifier.isEmpty
    else {
      result(BanteraVideoProcessingError.invalidArguments.flutterError)
      return
    }

    Task {
      do {
        let response = try await BanteraVideoPreparationService().transcribeAudioForUpload(
          inputURL: URL(fileURLWithPath: inputPath),
          localeIdentifier: localeIdentifier
        )
        DispatchQueue.main.async {
          result(response)
        }
      } catch let error as BanteraVideoProcessingError {
        DispatchQueue.main.async {
          result(error.flutterError)
        }
      } catch {
        DispatchQueue.main.async {
          result(
            FlutterError(
              code: "transcription_failed",
              message: error.localizedDescription,
              details: nil
            )
          )
        }
      }
    }
  }

  private func handleEnsureTranscriptionModelInstalled(
    call: FlutterMethodCall,
    result: @escaping FlutterResult
  ) {
    guard BanteraIosVersionRouting.useSpeechTranscriberRoutingPath else {
      result(BanteraVideoProcessingError.unsupportedIosVersion.flutterError)
      return
    }
    guard #available(iOS 26.0, *) else {
      result(BanteraVideoProcessingError.unsupportedIosVersion.flutterError)
      return
    }

    guard
      let args = call.arguments as? [String: Any],
      let localeIdentifier = args["localeIdentifier"] as? String,
      !localeIdentifier.isEmpty
    else {
      result(BanteraVideoProcessingError.invalidArguments.flutterError)
      return
    }

    Task {
      do {
        try await BanteraVideoPreparationService().ensureTranscriptionModelInstalled(
          localeIdentifier: localeIdentifier
        )
        DispatchQueue.main.async {
          result(nil)
        }
      } catch let error as BanteraVideoProcessingError {
        DispatchQueue.main.async {
          result(error.flutterError)
        }
      } catch {
        DispatchQueue.main.async {
          result(
            FlutterError(
              code: "speech_model_prepare_failed",
              message: error.localizedDescription,
              details: nil
            )
          )
        }
      }
    }
  }
}

private final class BanteraTranslationBridge {
  private let channel: FlutterMethodChannel

  init(binaryMessenger: FlutterBinaryMessenger) {
    channel = FlutterMethodChannel(
      name: "bantera/translation",
      binaryMessenger: binaryMessenger
    )
    channel.setMethodCallHandler(handle)
  }

  private func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "getSupportedTranslationLocales":
      handleGetSupportedTranslationLocales(call: call, result: result)
    case "getAllSupportedTranslationLocales":
      handleGetAllSupportedTranslationLocales(result: result)
    case "prepareTranslationAssets":
      handlePrepareTranslationAssets(call: call, result: result)
    case "translateTranscriptCues":
      handleTranslateTranscriptCues(call: call, result: result)
    default:
      result(FlutterMethodNotImplemented)
    }
  }

  private func handleGetSupportedTranslationLocales(
    call: FlutterMethodCall,
    result: @escaping FlutterResult
  ) {
    guard BanteraIosVersionRouting.useTranslationFrameworkRoutingPath else {
      result([])
      return
    }
    guard #available(iOS 18.0, *) else {
      result([])
      return
    }

    guard
      let args = call.arguments as? [String: Any],
      let sourceLocaleIdentifier = args["sourceLocaleIdentifier"] as? String,
      !sourceLocaleIdentifier.isEmpty
    else {
      result(BanteraTranslationError.invalidArguments.flutterError)
      return
    }

    let payload = BanteraLegacyTranslationCoordinator.supportedLocalesPayload(
      excluding: sourceLocaleIdentifier
    )
    print("[Translation framework, iOS 18+] Supported translation locales from '\(sourceLocaleIdentifier)' (\(payload.count)):")
    for locale in payload {
      let id = locale["identifier"] as? String ?? "?"
      let name = locale["displayName"] as? String ?? "?"
      print("[Translation framework, iOS 18+]   \(id) — \(name)")
    }
    result(payload)
  }

  private func handleGetAllSupportedTranslationLocales(result: @escaping FlutterResult) {
    guard BanteraIosVersionRouting.useTranslationFrameworkRoutingPath else {
      result([])
      return
    }
    guard #available(iOS 18.0, *) else {
      result([])
      return
    }

    let payload = BanteraLegacyTranslationCoordinator.allLocalesPayload()
    print("[Translation framework, iOS 18+] All supported translation locales (\(payload.count)):")
    for locale in payload {
      let id = locale["identifier"] as? String ?? "?"
      let name = locale["displayName"] as? String ?? "?"
      print("[Translation framework, iOS 18+]   \(id) — \(name)")
    }
    result(payload)

    // Log-only: print Live Translation (LanguageAvailability) language list for comparison.
    // Not used for actual translation.
    if BanteraIosVersionRouting.useSpeechTranscriberRoutingPath {
      if #available(iOS 26.0, *) {
        Task {
          let availability = LanguageAvailability()
          let languages = await availability.supportedLanguages
          let displayLocale = Locale.current
          let sorted = languages
            .map { $0.minimalIdentifier }
            .sorted { $0.localizedCaseInsensitiveCompare($1) == .orderedAscending }
          print("[Live Translation, iOS 26+] Supported languages (\(sorted.count)):")
          for id in sorted {
            let name = displayLocale.localizedString(forIdentifier: id) ?? id
            print("[Live Translation, iOS 26+]   \(id) — \(name)")
          }
        }
      }
    }
  }

  private func handlePrepareTranslationAssets(
    call: FlutterMethodCall,
    result: @escaping FlutterResult
  ) {
    guard BanteraIosVersionRouting.useTranslationFrameworkRoutingPath else {
      result(BanteraTranslationError.unsupportedIosVersion.flutterError)
      return
    }
    guard #available(iOS 18.0, *) else {
      result(BanteraTranslationError.unsupportedIosVersion.flutterError)
      return
    }

    guard
      let args = call.arguments as? [String: Any],
      let sourceLocaleIdentifier = args["sourceLocaleIdentifier"] as? String,
      let targetLocaleIdentifier = args["targetLocaleIdentifier"] as? String,
      !sourceLocaleIdentifier.isEmpty,
      !targetLocaleIdentifier.isEmpty
    else {
      result(BanteraTranslationError.invalidArguments.flutterError)
      return
    }

    // Translation framework (iOS 18+) manages model downloads automatically — no preparation needed.
    result(nil)
  }

  private func handleTranslateTranscriptCues(
    call: FlutterMethodCall,
    result: @escaping FlutterResult
  ) {
    guard BanteraIosVersionRouting.useTranslationFrameworkRoutingPath else {
      result(BanteraTranslationError.unsupportedIosVersion.flutterError)
      return
    }
    guard #available(iOS 18.0, *) else {
      result(BanteraTranslationError.unsupportedIosVersion.flutterError)
      return
    }

    guard
      let args = call.arguments as? [String: Any],
      let sourceLocaleIdentifier = args["sourceLocaleIdentifier"] as? String,
      let targetLocaleIdentifier = args["targetLocaleIdentifier"] as? String,
      let rawCues = args["cues"] as? [[String: Any]],
      !sourceLocaleIdentifier.isEmpty,
      !targetLocaleIdentifier.isEmpty
    else {
      result(BanteraTranslationError.invalidArguments.flutterError)
      return
    }

    let cues = rawCues.compactMap { BanteraLegacyTranslationCoordinator.CueInput(dictionary: $0) }
    BanteraLegacyTranslationCoordinator.translate(
      cues: cues,
      sourceLocaleIdentifier: sourceLocaleIdentifier,
      targetLocaleIdentifier: targetLocaleIdentifier
    ) { legacyResult in
      DispatchQueue.main.async {
        switch legacyResult {
        case .success(let outputs):
          result(outputs.map(\.dictionary))
        case .failure(let error):
          if let bantera = error as? BanteraTranslationError {
            result(bantera.flutterError)
          } else {
            result(
              FlutterError(
                code: "translation_failed",
                message: error.localizedDescription,
                details: nil
              )
            )
          }
        }
      }
    }
  }
}

@available(iOS 26.0, *)
private final class BanteraTranslationService {
  struct TranslationCueInput {
    let id: String
    let text: String

    init?(dictionary: [String: Any]) {
      let id = dictionary["id"] as? String ?? ""
      let text = dictionary["text"] as? String ?? ""
      if id.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
        text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
        return nil
      }

      self.id = id
      self.text = text
    }
  }

  struct TranslationCueOutput {
    let id: String
    let translatedText: String

    var dictionary: [String: Any] {
      [
        "id": id,
        "translatedText": translatedText,
      ]
    }
  }

  private struct CueChunk {
    let cueIDs: [String]
    let sourceText: String
  }

  private let maxCuesPerChunk = 8
  private let maxCharactersPerChunk = 1200

  static func logAllSupportedLanguages() async {
    guard #available(iOS 26.0, *) else { return }
    let availability = LanguageAvailability()
    let languages = await availability.supportedLanguages
    let displayLocale = Locale.current
    let sorted = languages.sorted {
      let l = displayLocale.localizedString(forIdentifier: $0.minimalIdentifier) ?? $0.minimalIdentifier
      let r = displayLocale.localizedString(forIdentifier: $1.minimalIdentifier) ?? $1.minimalIdentifier
      return l.localizedCaseInsensitiveCompare(r) == .orderedAscending
    }
    print("[Translation framework, iOS 18+] iOS built-in translation supported languages (\(sorted.count)):")
    for lang in sorted {
      let id = lang.minimalIdentifier
      let name = displayLocale.localizedString(forIdentifier: id) ?? id
      print("[Translation framework, iOS 18+]   \(id) — \(name)")
    }
  }

  /// Returns all iOS built-in translation locales as a Flutter-ready payload.
  /// Does not require a source locale — suitable for native-language pickers.
  @available(iOS 26.0, *)
  static func allSupportedLanguagePayload() async -> [[String: Any]] {
    let availability = LanguageAvailability()
    let languages = await availability.supportedLanguages
    let displayLocale = Locale.current
    return languages.map { lang in
      let id = lang.minimalIdentifier
      let name = displayLocale.localizedString(forIdentifier: id) ?? id
      return ["identifier": id, "displayName": name, "isInstalled": true] as [String: Any]
    }
  }

  static func supportedTargetLocalePayload(
    sourceLocaleIdentifier: String
  ) async throws -> [[String: Any]] {
    let normalizedSource = Self.normalizeIdentifier(sourceLocaleIdentifier)
    let availability = LanguageAvailability()
    let supportedLanguages = await availability.supportedLanguages
    let sourceLanguage = Locale.Language(identifier: normalizedSource)
    let displayLocale = Locale.current

    var payload: [[String: Any]] = []

    for target in supportedLanguages {
      if target.minimalIdentifier == sourceLanguage.minimalIdentifier {
        continue
      }

      let status = await availability.status(from: sourceLanguage, to: target)
      guard status == .installed || status == .supported else {
        continue
      }

      let identifier = target.minimalIdentifier
      payload.append([
        "identifier": identifier,
        "displayName": displayLocale.localizedString(forIdentifier: identifier) ?? identifier,
        "isInstalled": status == .installed,
      ])
    }

    return payload.sorted {
      let left = ($0["displayName"] as? String) ?? ""
      let right = ($1["displayName"] as? String) ?? ""
      return left.localizedCaseInsensitiveCompare(right) == .orderedAscending
    }
  }

  func translate(
    cues: [TranslationCueInput],
    sourceLocaleIdentifier: String,
    targetLocaleIdentifier: String
  ) async throws -> [TranslationCueOutput] {
    if cues.isEmpty {
      return []
    }

    let normalizedSource = Self.normalizeIdentifier(sourceLocaleIdentifier)
    let normalizedTarget = Self.normalizeIdentifier(targetLocaleIdentifier)
    let sourceLanguage = Locale.Language(identifier: normalizedSource)
    let targetLanguage = Locale.Language(identifier: normalizedTarget)

    if sourceLanguage.minimalIdentifier == targetLanguage.minimalIdentifier {
      return cues.map {
        TranslationCueOutput(id: $0.id, translatedText: Self.cleanText($0.text))
      }
    }

    let availability = LanguageAvailability()
    let status = await availability.status(from: sourceLanguage, to: targetLanguage)
    if status == .installed {
      // Ready to translate.
    } else if status == .supported {
      throw BanteraTranslationError.translationAssetsNotInstalled(
        source: normalizedSource,
        target: normalizedTarget
      )
    } else {
      throw BanteraTranslationError.unsupportedLanguagePair(
        source: normalizedSource,
        target: normalizedTarget
      )
    }

    let session = TranslationSession(installedSource: sourceLanguage, target: targetLanguage)
    return try await translate(cues: cues, session: session)
  }

  private func translate(
    cues: [TranslationCueInput],
    session: TranslationSession
  ) async throws -> [TranslationCueOutput] {
    var translatedByCueID: [String: String] = [:]
    let chunks = makeChunks(from: cues)

    for chunk in chunks {
      do {
        let response = try await session.translate(chunk.sourceText)
        let extracted = extractChunkTranslations(
          translatedText: response.targetText,
          cueIDs: chunk.cueIDs
        )
        for cueID in chunk.cueIDs {
          if let translated = extracted[cueID] {
            translatedByCueID[cueID] = Self.cleanText(translated)
          }
        }
      } catch {
        continue
      }
    }

    for cue in cues {
      if translatedByCueID[cue.id] != nil {
        continue
      }

      do {
        let response = try await session.translate(cue.text)
        translatedByCueID[cue.id] = Self.cleanText(response.targetText)
      } catch {
        throw BanteraTranslationError.translationFailed(
          "Bantera could not translate this cue on your iPhone."
        )
      }
    }

    return cues.map { cue in
      TranslationCueOutput(
        id: cue.id,
        translatedText: translatedByCueID[cue.id] ?? ""
      )
    }
  }

  private func makeChunks(from cues: [TranslationCueInput]) -> [CueChunk] {
    var chunks: [CueChunk] = []
    var currentCues: [TranslationCueInput] = []
    var currentCharacters = 0

    for cue in cues {
      let estimated = cue.text.count + 2 * markerStart(for: cue.id).count + 8
      let wouldExceed = !currentCues.isEmpty && (
        currentCues.count >= maxCuesPerChunk || (currentCharacters + estimated) > maxCharactersPerChunk
      )

      if wouldExceed {
        chunks.append(buildChunk(from: currentCues))
        currentCues = []
        currentCharacters = 0
      }

      currentCues.append(cue)
      currentCharacters += estimated
    }

    if !currentCues.isEmpty {
      chunks.append(buildChunk(from: currentCues))
    }

    return chunks
  }

  private func buildChunk(from cues: [TranslationCueInput]) -> CueChunk {
    let cueIDs = cues.map(\.id)
    let sourceText = cues.map { cue in
      let start = markerStart(for: cue.id)
      let end = markerEnd(for: cue.id)
      return "\(start)\n\(cue.text)\n\(end)"
    }
    .joined(separator: "\n")

    return CueChunk(cueIDs: cueIDs, sourceText: sourceText)
  }

  private func markerStart(for cueID: String) -> String {
    "[[[BANTERA:\(cueID)]]]"
  }

  private func markerEnd(for cueID: String) -> String {
    "[[[/BANTERA:\(cueID)]]]"
  }

  private func extractChunkTranslations(
    translatedText: String,
    cueIDs: [String]
  ) -> [String: String] {
    var output: [String: String] = [:]

    for cueID in cueIDs {
      let startMarker = markerStart(for: cueID)
      let endMarker = markerEnd(for: cueID)
      guard let startRange = translatedText.range(of: startMarker) else {
        continue
      }
      guard
        let endRange = translatedText.range(
          of: endMarker,
          range: startRange.upperBound..<translatedText.endIndex
        )
      else {
        continue
      }

      let between = translatedText[startRange.upperBound..<endRange.lowerBound]
      output[cueID] = String(between).trimmingCharacters(in: .whitespacesAndNewlines)
    }

    return output
  }

  private static func cleanText(_ text: String) -> String {
    text
      .replacingOccurrences(of: "\r\n", with: "\n")
      .replacingOccurrences(of: "\r", with: "\n")
      .split(separator: "\n")
      .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
      .filter { !$0.isEmpty }
      .joined(separator: "\n")
      .trimmingCharacters(in: .whitespacesAndNewlines)
  }

  private static func normalizeIdentifier(_ identifier: String) -> String {
    identifier
      .trimmingCharacters(in: .whitespacesAndNewlines)
      .replacingOccurrences(of: "_", with: "-")
  }
}

private enum BanteraVideoProcessingError: LocalizedError {
  case unsupportedIosVersion
  case invalidArguments
  case speechUnavailable
  case speechAuthorizationDenied
  case speechAuthorizationRestricted
  case unsupportedLocale(String)
  case noAudioTrack
  case transcriptionFailed(String)
  case exportFailed(String)
  case fileAccessFailed(String)

  var errorDescription: String? {
    switch self {
    case .unsupportedIosVersion:
      return "Video transcription requires iOS 26 or later."
    case .invalidArguments:
      return "The selected video could not be prepared."
    case .speechUnavailable:
      return "Speech transcription is not available on this iPhone."
    case .speechAuthorizationDenied:
      return "Speech Recognition access is turned off for Bantera."
    case .speechAuthorizationRestricted:
      return "Speech Recognition is restricted on this iPhone."
    case let .unsupportedLocale(identifier):
      return "The selected language (\(identifier)) is not available for transcription."
    case .noAudioTrack:
      return "The selected video does not contain an audio track."
    case let .transcriptionFailed(message):
      return message
    case let .exportFailed(message):
      return message
    case let .fileAccessFailed(message):
      return message
    }
  }

  var code: String {
    switch self {
    case .unsupportedIosVersion:
      return "unsupported_ios_version"
    case .invalidArguments:
      return "invalid_arguments"
    case .speechUnavailable:
      return "speech_unavailable"
    case .speechAuthorizationDenied:
      return "speech_authorization_denied"
    case .speechAuthorizationRestricted:
      return "speech_authorization_restricted"
    case .unsupportedLocale:
      return "unsupported_locale"
    case .noAudioTrack:
      return "no_audio_track"
    case .transcriptionFailed:
      return "transcription_failed"
    case .exportFailed:
      return "export_failed"
    case .fileAccessFailed:
      return "file_access_failed"
    }
  }

  var flutterError: FlutterError {
    FlutterError(code: code, message: errorDescription, details: nil)
  }
}

private final class BanteraLegacySpeechRecognitionService {
  static func logSupportedLocales() {
    let supported = SFSpeechRecognizer.supportedLocales().sorted {
      localizedName(for: $0) < localizedName(for: $1)
    }

    print("[SFSpeechRecognizer, iOS 10+] Supported locales (\(supported.count)):")
    for locale in supported {
      print("[SFSpeechRecognizer, iOS 10+]   \(bcp47Identifier(for: locale)) — \(localizedName(for: locale))")
    }
  }

  /// Flutter payload aligned with `SpeechTranscriber` locale entries (`identifier`, `displayName`, `isInstalled`).
  static func supportedTranscriptionLocalePayload() -> [[String: Any]] {
    let supported = SFSpeechRecognizer.supportedLocales().sorted {
      localizedName(for: $0) < localizedName(for: $1)
    }
    return supported.map { locale in
      [
        "identifier": bcp47Identifier(for: locale),
        "displayName": localizedName(for: locale),
        "isInstalled": true,
      ]
    }
  }

  func ensureReady(localeIdentifier: String) async throws {
    try await ensureSpeechAuthorization()
    let resolved = try resolveRecognizer(localeIdentifier: localeIdentifier)
    guard resolved.recognizer.isAvailable else {
      throw BanteraVideoProcessingError.speechUnavailable
    }
  }

  /// Per-word recognition output plus the engine path that produced it.
  private struct TranscriptionOutcome {
    let text: String
    let segments: [[String: Any]]
    let onDevice: Bool
  }

  /// - Parameter allowAutoCorrection: `true` (chat DMs / group messages) lets Apple's
  ///   network language model smooth the speaker's wording so the reader can understand
  ///   them — the normal, default transcription level. `false` (practice / cue play) keeps
  ///   an HONEST transcript that preserves the learner's actual pronunciation mistakes.
  func transcribeRecordedAudio(
    inputURL: URL,
    localeIdentifier: String,
    allowAutoCorrection: Bool
  ) async throws -> [String: Any] {
    try await ensureSpeechAuthorization()
    let resolved = try resolveRecognizer(localeIdentifier: localeIdentifier)
    guard resolved.recognizer.isAvailable else {
      throw BanteraVideoProcessingError.speechUnavailable
    }

    let outcome = try await transcribe(
      url: inputURL,
      recognizer: resolved.recognizer,
      allowAutoCorrection: allowAutoCorrection
    )
    let text = outcome.text.trimmingCharacters(in: .whitespacesAndNewlines)
    guard !text.isEmpty else {
      throw BanteraVideoProcessingError.transcriptionFailed(
        "No transcript could be generated. Check that the audio matches the chosen language."
      )
    }

    return [
      "transcriptText": text,
      "transcriptLanguage": Self.bcp47Identifier(for: resolved.locale),
      "transcriptLanguageCode": Self.languageCode(for: resolved.locale),
      // Per-word confidence + which engine produced it, so the comparison layer can
      // flag words the recognizer was unsure about instead of scoring them correct.
      "segments": outcome.segments,
      "recognitionMode": outcome.onDevice ? "onDevice" : "network",
    ]
  }

  private func ensureSpeechAuthorization() async throws {
    let status = await requestSpeechAuthorization()
    switch status {
    case .authorized:
      return
    case .denied:
      throw BanteraVideoProcessingError.speechAuthorizationDenied
    case .restricted:
      throw BanteraVideoProcessingError.speechAuthorizationRestricted
    case .notDetermined:
      throw BanteraVideoProcessingError.speechAuthorizationDenied
    @unknown default:
      throw BanteraVideoProcessingError.speechUnavailable
    }
  }

  private func requestSpeechAuthorization() async -> SFSpeechRecognizerAuthorizationStatus {
    await withCheckedContinuation { continuation in
      SFSpeechRecognizer.requestAuthorization { status in
        continuation.resume(returning: status)
      }
    }
  }

  private func resolveRecognizer(localeIdentifier: String) throws -> (
    locale: Locale,
    recognizer: SFSpeechRecognizer
  ) {
    let normalizedIdentifier = Self.normalizeIdentifier(localeIdentifier)
    let supportedLocales = SFSpeechRecognizer.supportedLocales()

    let locale = supportedLocales.first {
      Self.normalizeIdentifier(Self.bcp47Identifier(for: $0)) == normalizedIdentifier ||
        Self.normalizeIdentifier($0.identifier) == normalizedIdentifier
    } ?? supportedLocales.first {
      Self.languageCode(for: $0) == Self.languageCode(fromIdentifier: localeIdentifier)
    }

    guard let locale, let recognizer = SFSpeechRecognizer(locale: locale) else {
      throw BanteraVideoProcessingError.unsupportedLocale(localeIdentifier)
    }

    return (locale, recognizer)
  }

  /// Auto-correction policy, keyed on the caller's intent:
  ///
  /// - `allowAutoCorrection == true` (chat DMs / group messages): use the default
  ///   recognizer path so Apple's network language model can smooth the speaker's
  ///   wording — readers need to understand what the other person said.
  /// - `allowAutoCorrection == false` (practice / cue play): when the locale has an
  ///   on-device model, transcribe strictly on-device. The network recognizer applies
  ///   heavier language-model "smoothing" that snaps a learner's mistakes back to the
  ///   expected words, so for an honest transcript we deliberately do NOT fall back to
  ///   it when on-device is available.
  ///
  /// Locales without an on-device model always use the network recognizer regardless,
  /// and the result is tagged so the caller can treat it as lower fidelity.
  private func transcribe(
    url: URL,
    recognizer: SFSpeechRecognizer,
    allowAutoCorrection: Bool
  ) async throws -> TranscriptionOutcome {
    let requiresOnDeviceRecognition =
      allowAutoCorrection ? false : recognizer.supportsOnDeviceRecognition
    return try await transcribe(
      url: url,
      recognizer: recognizer,
      requiresOnDeviceRecognition: requiresOnDeviceRecognition
    )
  }

  private func transcribe(
    url: URL,
    recognizer: SFSpeechRecognizer,
    requiresOnDeviceRecognition: Bool
  ) async throws -> TranscriptionOutcome {
    try await withCheckedThrowingContinuation { continuation in
      let request = SFSpeechURLRecognitionRequest(url: url)
      request.shouldReportPartialResults = false
      request.requiresOnDeviceRecognition = requiresOnDeviceRecognition

      let lock = NSLock()
      var didResume = false

      func finish(_ result: Result<TranscriptionOutcome, Error>) {
        lock.lock()
        defer { lock.unlock() }
        guard !didResume else { return }
        didResume = true
        switch result {
        case let .success(outcome):
          continuation.resume(returning: outcome)
        case let .failure(error):
          continuation.resume(throwing: error)
        }
      }

      _ = recognizer.recognitionTask(with: request) { result, error in
        if let error {
          finish(.failure(BanteraVideoProcessingError.transcriptionFailed(error.localizedDescription)))
          return
        }

        guard let result else { return }
        if result.isFinal {
          let best = result.bestTranscription
          let segments = best.segments.map { segment -> [String: Any] in
            [
              "text": segment.substring,
              "confidence": Double(segment.confidence),
            ]
          }
          finish(
            .success(
              TranscriptionOutcome(
                text: best.formattedString,
                segments: segments,
                onDevice: requiresOnDeviceRecognition
              )
            )
          )
        }
      }
    }
  }

  private static func normalizeIdentifier(_ identifier: String) -> String {
    identifier
      .trimmingCharacters(in: .whitespacesAndNewlines)
      .replacingOccurrences(of: "_", with: "-")
      .lowercased()
  }

  private static func bcp47Identifier(for locale: Locale) -> String {
    normalizeIdentifier(locale.identifier)
  }

  private static func languageCode(for locale: Locale) -> String {
    if #available(iOS 16.0, *) {
      return locale.language.languageCode?.identifier.lowercased() ?? "und"
    }

    return locale.languageCode?.lowercased() ?? "und"
  }

  private static func languageCode(fromIdentifier identifier: String) -> String {
    normalizeIdentifier(identifier)
      .split(separator: "-")
      .first
      .map(String.init) ?? "und"
  }

  private static func localizedName(for locale: Locale) -> String {
    Locale.current.localizedString(forIdentifier: bcp47Identifier(for: locale))
      ?? locale.localizedString(forIdentifier: locale.identifier)
      ?? bcp47Identifier(for: locale)
  }
}

@available(iOS 26.0, *)
private final class BanteraVideoPreparationService {
  func transcribeRecordedAudio(
    inputURL: URL,
    localeIdentifier: String
  ) async throws -> [String: Any] {
    let locale = try await resolveLocale(identifier: localeIdentifier)
    let transcript = try await transcribeAudioFile(at: inputURL, locale: locale)

    return [
      "transcriptText": transcript.text,
      "transcriptLanguage": transcript.localeIdentifier,
      "transcriptLanguageCode": transcript.languageCode,
    ]
  }

  func transcribeAudioForUpload(
    inputURL: URL,
    localeIdentifier: String
  ) async throws -> [String: Any] {
    let locale = try await resolveLocale(identifier: localeIdentifier)
    let asset = AVAsset(url: inputURL)
    // Use transcribe(asset:locale:) so the audio is extracted to Linear PCM
    // before being passed to SpeechTranscriber (same path as prepareVideoForUpload).
    let transcript = try await transcribe(asset: asset, locale: locale)

    return [
      "transcriptText": transcript.text,
      "transcriptLanguage": transcript.localeIdentifier,
      "transcriptLanguageCode": transcript.languageCode,
      "transcriptCues": transcript.cues.map(\.dictionary),
    ]
  }

  func prepareVideoForUpload(
    inputURL: URL,
    localeIdentifier: String
  ) async throws -> [String: Any] {
    let inputAsset = AVAsset(url: inputURL)
    let locale = try await resolveLocale(identifier: localeIdentifier)
    let transcript = try await transcribe(asset: inputAsset, locale: locale)
    let preparedOutput = try await exportUploadVideo(from: inputURL, asset: inputAsset)
    let metadata = try videoMetadata(for: AVAsset(url: preparedOutput.url), url: preparedOutput.url)

    return [
      "outputPath": preparedOutput.url.path,
      "fileName": preparedOutput.url.lastPathComponent,
      "transcriptText": transcript.text,
      "transcriptLanguage": transcript.localeIdentifier,
      "transcriptLanguageCode": transcript.languageCode,
      "transcriptCues": transcript.cues.map(\.dictionary),
      "durationMs": metadata.durationMs,
      "fileSizeBytes": metadata.fileSizeBytes,
      "videoWidth": metadata.width as Any,
      "videoHeight": metadata.height as Any,
      "contentType": metadata.contentType,
      "shouldDeleteAfterUse": preparedOutput.shouldDeleteAfterUse,
    ]
  }

  static func supportedLocalePayload() async -> [[String: Any]] {
    let supported = await SpeechTranscriber.supportedLocales.sorted {
      localizedName(for: $0) < localizedName(for: $1)
    }
    let installed = await SpeechTranscriber.installedLocales
    let installedIds = Set(installed.map { $0.identifier(.bcp47) })

    return supported.map { locale in
      [
        "identifier": locale.identifier(.bcp47),
        "displayName": Self.localizedName(for: locale),
        "isInstalled": installedIds.contains(locale.identifier(.bcp47)),
      ]
    }
  }

  /// Downloads and installs the on-device SpeechTranscriber language assets for
  /// [localeIdentifier] when needed, using the same path as transcription. Call
  /// before long-running work (e.g. AI dialogue generation) so transcription
  /// does not stall later waiting for the asset.
  func ensureTranscriptionModelInstalled(localeIdentifier: String) async throws {
    guard SpeechTranscriber.isAvailable else {
      throw BanteraVideoProcessingError.speechUnavailable
    }
    let locale = try await resolveLocale(identifier: localeIdentifier)
    _ = try await ensureTranscriptionAssetsDownloaded(for: locale)
  }

  private struct PreparedOutput {
    let url: URL
    let shouldDeleteAfterUse: Bool
  }

  private struct VideoMetadata {
    let durationMs: Int
    let width: Int?
    let height: Int?
    let fileSizeBytes: Int
    let contentType: String
  }

  private struct TranscriptCuePayload {
    var index: Int
    var startMs: Int
    var endMs: Int
    let text: String

    var dictionary: [String: Any] {
      [
        "index": index,
        "startMs": startMs,
        "endMs": endMs,
        "text": text,
      ]
    }
  }

  private struct PreparedTranscript {
    let text: String
    let localeIdentifier: String
    let languageCode: String
    let cues: [TranscriptCuePayload]
  }

  private func resolveLocale(identifier: String) async throws -> Locale {
    let supported = await SpeechTranscriber.supportedLocales
    if let exact = supported.first(where: {
      $0.identifier(.bcp47).caseInsensitiveCompare(identifier) == .orderedSame
        || $0.identifier.caseInsensitiveCompare(identifier) == .orderedSame
    }) {
      return exact
    }

    let requestedLanguage = identifier
      .replacingOccurrences(of: "_", with: "-")
      .split(separator: "-")
      .first?
      .lowercased()

    if let requestedLanguage,
       let fallback = supported.first(where: {
         $0.language.languageCode?.identifier.lowercased() == requestedLanguage
       }) {
      return fallback
    }

    throw BanteraVideoProcessingError.unsupportedLocale(identifier)
  }

  private func ensureTranscriptionAssetsDownloaded(for locale: Locale) async throws -> SpeechTranscriber {
    let transcriber = SpeechTranscriber(
      locale: locale,
      transcriptionOptions: [],
      reportingOptions: [],
      attributeOptions: [.audioTimeRange]
    )

    let installed = await SpeechTranscriber.installedLocales
    let installedIds = Set(installed.map { $0.identifier(.bcp47) })
    if !installedIds.contains(locale.identifier(.bcp47)) {
      if let installRequest = try await AssetInventory.assetInstallationRequest(supporting: [transcriber]) {
        try await installRequest.downloadAndInstall()
      }
    }
    return transcriber
  }

  private func transcribe(asset: AVAsset, locale: Locale) async throws -> PreparedTranscript {
    let rawAudioURL = try await extractAudioAsLinearPcmFile(from: asset)
    defer { try? FileManager.default.removeItem(at: rawAudioURL) }

    return try await transcribeAudioFile(at: rawAudioURL, locale: locale)
  }

  private func transcribeAudioFile(
    at inputURL: URL,
    locale: Locale
  ) async throws -> PreparedTranscript {
    guard SpeechTranscriber.isAvailable else {
      throw BanteraVideoProcessingError.speechUnavailable
    }

    let transcriber = try await ensureTranscriptionAssetsDownloaded(for: locale)

    let readableInputURL: URL
    var shouldDeleteReadableInput = false
    do {
      _ = try AVAudioFile(forReading: inputURL)
      readableInputURL = inputURL
    } catch {
      do {
        readableInputURL = try await extractAudioAsLinearPcmFile(from: AVAsset(url: inputURL))
        shouldDeleteReadableInput = true
      } catch {
        throw BanteraVideoProcessingError.fileAccessFailed(
          "The recorded audio could not be opened for transcription."
        )
      }
    }
    if shouldDeleteReadableInput {
      defer { try? FileManager.default.removeItem(at: readableInputURL) }
    }

    let inputAudioFile: AVAudioFile
    do {
      inputAudioFile = try AVAudioFile(forReading: readableInputURL)
    } catch {
      throw BanteraVideoProcessingError.fileAccessFailed(
        "The recorded audio could not be opened for transcription."
      )
    }

    let requiredFormat = await SpeechAnalyzer.bestAvailableAudioFormat(
      compatibleWith: [transcriber],
      considering: nil
    )

    let audioURL: URL
    if let requiredFormat,
       !isEquivalentFormat(inputAudioFile.processingFormat, requiredFormat) {
      do {
        audioURL = try await convertAudioFile(from: readableInputURL, to: requiredFormat)
      } catch {
        audioURL = readableInputURL
      }
    } else {
      audioURL = readableInputURL
    }

    if audioURL != readableInputURL {
      defer { try? FileManager.default.removeItem(at: audioURL) }
    }

    let audioFile = try openTranscriptionAudioFile(
      primaryURL: audioURL,
      fallbackURL: readableInputURL
    )

    let analyzer = SpeechAnalyzer(modules: [transcriber])
    try await analyzer.start(inputAudioFile: audioFile, finishAfterFile: true)

    var cues: [TranscriptCuePayload] = []
    var processingError: Error?

    do {
      var resultIndex = 0
      for try await result in transcriber.results {
        let resultText = String(result.text.characters)
        print("[Bantera] result[\(resultIndex)] text='\(resultText)' range=\(result.range.start.seconds)s-\(CMTimeRangeGetEnd(result.range).seconds)s")
        for (runIndex, run) in result.text.runs.enumerated() {
          let runText = String(result.text[run.range].characters)
          print("[Bantera]   run[\(runIndex)] text='\(runText)' attributes=\(run.attributes)")
        }
        resultIndex += 1

        // Try to build per-sentence cues using per-character timing from the
        // Speech.TimeRangeAttribute attribute on each run. This is essential for
        // CJK languages where the whole result is one long string.
        let perCharCues = Self.cuesFromAttributedRuns(result.text)
        if !perCharCues.isEmpty {
          for var cue in perCharCues {
            cue.index = cues.count
            cues.append(cue)
          }
          continue
        }

        // Fallback for results with no per-run timing (alphabetic languages
        // already emit short results so each result becomes one cue).
        let cleaned = Self.cleanTranscriptSegment(String(result.text.characters))
        guard !cleaned.isEmpty else { continue }

        let timeRange = result.range
        guard timeRange.start.seconds.isFinite, timeRange.end.seconds.isFinite else { continue }

        let startMs = max(0, Int((timeRange.start.seconds * 1000).rounded()))
        var endMs = max(startMs + 1, Int((timeRange.end.seconds * 1000).rounded()))
        if endMs <= startMs { endMs = startMs + 1 }

        if let lastIndex = cues.indices.last, cues[lastIndex].text == cleaned {
          cues[lastIndex].endMs = max(cues[lastIndex].endMs, endMs)
          continue
        }

        cues.append(TranscriptCuePayload(index: cues.count, startMs: startMs, endMs: endMs, text: cleaned))
      }
    } catch {
      processingError = error
    }

    let normalizedCues = Self.normalizeTranscriptCues(cues)
    let transcript = normalizedCues
      .map(\.text)
      .joined(separator: "\n")
      .trimmingCharacters(in: .whitespacesAndNewlines)

    guard !transcript.isEmpty, !normalizedCues.isEmpty else {
      if let processingError {
        throw BanteraVideoProcessingError.transcriptionFailed(
          processingError.localizedDescription
        )
      }

      throw BanteraVideoProcessingError.transcriptionFailed(
        "No transcript could be generated. Check that the video audio matches the chosen language."
      )
    }

    return PreparedTranscript(
      text: transcript,
      localeIdentifier: locale.identifier(.bcp47),
      languageCode: Self.languageCode(for: locale),
      cues: normalizedCues
    )
  }

  private func extractAudioAsLinearPcmFile(from asset: AVAsset) async throws -> URL {
    let audioTracks: [AVAssetTrack]
    do {
      audioTracks = try await asset.loadTracks(withMediaType: .audio)
    } catch {
      throw BanteraVideoProcessingError.exportFailed(
        "Bantera could not read the selected video audio."
      )
    }

    guard let audioTrack = audioTracks.first else {
      throw BanteraVideoProcessingError.noAudioTrack
    }

    let outputURL = FileManager.default.temporaryDirectory
      .appendingPathComponent("bantera_audio_\(UUID().uuidString)")
      .appendingPathExtension("caf")

    let reader: AVAssetReader
    do {
      reader = try AVAssetReader(asset: asset)
    } catch {
      throw BanteraVideoProcessingError.exportFailed(
        "Bantera could not read the selected video audio."
      )
    }

    let outputSettings: [String: Any] = [
      AVFormatIDKey: kAudioFormatLinearPCM,
      AVSampleRateKey: 16_000.0,
      AVNumberOfChannelsKey: 1,
      AVLinearPCMBitDepthKey: 16,
      AVLinearPCMIsFloatKey: false,
      AVLinearPCMIsBigEndianKey: false,
      AVLinearPCMIsNonInterleaved: false,
    ]

    let trackOutput = AVAssetReaderTrackOutput(track: audioTrack, outputSettings: outputSettings)
    trackOutput.alwaysCopiesSampleData = false

    guard reader.canAdd(trackOutput) else {
      throw BanteraVideoProcessingError.exportFailed(
        "Bantera could not configure the video audio for transcription."
      )
    }
    reader.add(trackOutput)

    guard reader.startReading() else {
      throw BanteraVideoProcessingError.exportFailed(
        "Bantera could not start reading the video audio."
      )
    }

    let audioFormat = AVAudioFormat(
      commonFormat: .pcmFormatInt16,
      sampleRate: 16_000,
      channels: 1,
      interleaved: true
    )!

    var totalFrames: Int64 = 0
    do {
      let audioFile = try AVAudioFile(
        forWriting: outputURL,
        settings: audioFormat.settings,
        commonFormat: .pcmFormatInt16,
        interleaved: true
      )

      while let sampleBuffer = trackOutput.copyNextSampleBuffer() {
        guard CMSampleBufferDataIsReady(sampleBuffer) else { continue }

        let numSamples = CMSampleBufferGetNumSamples(sampleBuffer)
        guard numSamples > 0, let blockBuffer = CMSampleBufferGetDataBuffer(sampleBuffer) else {
          continue
        }

        var length = 0
        var dataPointer: UnsafeMutablePointer<Int8>?
        let status = CMBlockBufferGetDataPointer(
          blockBuffer,
          atOffset: 0,
          lengthAtOffsetOut: nil,
          totalLengthOut: &length,
          dataPointerOut: &dataPointer
        )

        guard status == kCMBlockBufferNoErr, let pointer = dataPointer else {
          continue
        }

        let frameCount = AVAudioFrameCount(numSamples)
        guard let pcmBuffer = AVAudioPCMBuffer(pcmFormat: audioFormat, frameCapacity: frameCount) else {
          continue
        }

        pcmBuffer.frameLength = frameCount
        if let int16Data = pcmBuffer.int16ChannelData {
          memcpy(int16Data[0], pointer, length)
        }

        do {
          try audioFile.write(from: pcmBuffer)
          totalFrames += Int64(frameCount)
        } catch {
          break
        }
      }
    } catch {
      throw BanteraVideoProcessingError.fileAccessFailed(
        "Bantera could not create a temporary transcription audio file."
      )
    }

    if reader.status == .failed || totalFrames == 0 {
      try? FileManager.default.removeItem(at: outputURL)
      throw BanteraVideoProcessingError.transcriptionFailed(
        "The selected video does not contain usable speech audio."
      )
    }

    return outputURL
  }

  private func convertAudioFile(
    from sourceURL: URL,
    to targetFormat: AVAudioFormat
  ) async throws -> URL {
    let outputURL = FileManager.default.temporaryDirectory
      .appendingPathComponent("bantera_audio_\(UUID().uuidString)")
      .appendingPathExtension("caf")

    let sourceFile: AVAudioFile
    do {
      sourceFile = try AVAudioFile(forReading: sourceURL)
    } catch {
      throw BanteraVideoProcessingError.fileAccessFailed(
        "Bantera could not open the extracted audio for conversion."
      )
    }

    let sourceFormat = sourceFile.processingFormat
    guard let converter = AVAudioConverter(from: sourceFormat, to: targetFormat) else {
      return sourceURL
    }

    let outputFile: AVAudioFile
    do {
      outputFile = try AVAudioFile(
        forWriting: outputURL,
        settings: targetFormat.settings,
        commonFormat: targetFormat.commonFormat,
        interleaved: targetFormat.isInterleaved
      )
    } catch {
      throw BanteraVideoProcessingError.fileAccessFailed(
        "Bantera could not create a compatible transcription audio file."
      )
    }

    let bufferSize: AVAudioFrameCount = 4096
    var totalFrames: Int64 = 0

    while sourceFile.framePosition < sourceFile.length {
      let remainingFrames = AVAudioFrameCount(sourceFile.length - sourceFile.framePosition)
      let framesToRead = min(bufferSize, remainingFrames)
      guard let sourceBuffer = AVAudioPCMBuffer(
        pcmFormat: sourceFormat,
        frameCapacity: framesToRead
      ) else {
        continue
      }

      do {
        try sourceFile.read(into: sourceBuffer, frameCount: framesToRead)
      } catch {
        break
      }

      let ratio = targetFormat.sampleRate / sourceFormat.sampleRate
      let outputCapacity = AVAudioFrameCount(Double(framesToRead) * ratio * 1.2)
      guard let outputBuffer = AVAudioPCMBuffer(
        pcmFormat: targetFormat,
        frameCapacity: outputCapacity
      ) else {
        continue
      }

      do {
        try converter.convert(to: outputBuffer, from: sourceBuffer)
        if outputBuffer.frameLength > 0 {
          try outputFile.write(from: outputBuffer)
          totalFrames += Int64(outputBuffer.frameLength)
        }
      } catch {
        break
      }
    }

    if totalFrames == 0 {
      try? FileManager.default.removeItem(at: outputURL)
      throw BanteraVideoProcessingError.transcriptionFailed(
        "Bantera could not convert the selected video audio for transcription."
      )
    }

    return outputURL
  }

  private func openTranscriptionAudioFile(
    primaryURL: URL,
    fallbackURL: URL
  ) throws -> AVAudioFile {
    do {
      return try AVAudioFile(forReading: primaryURL)
    } catch {
      guard primaryURL != fallbackURL else {
        throw BanteraVideoProcessingError.fileAccessFailed(
          "The extracted audio could not be opened for transcription."
        )
      }

      do {
        return try AVAudioFile(forReading: fallbackURL)
      } catch {
        throw BanteraVideoProcessingError.fileAccessFailed(
          "The extracted audio could not be opened for transcription."
        )
      }
    }
  }

  private func isEquivalentFormat(
    _ lhs: AVAudioFormat,
    _ rhs: AVAudioFormat
  ) -> Bool {
    lhs.sampleRate == rhs.sampleRate &&
      lhs.channelCount == rhs.channelCount &&
      lhs.commonFormat == rhs.commonFormat &&
      lhs.isInterleaved == rhs.isInterleaved
  }

  private func exportUploadVideo(from inputURL: URL, asset: AVAsset) async throws -> PreparedOutput {
    let originalMetadata = try videoMetadata(for: asset, url: inputURL)
    let maxDimension = max(originalMetadata.width ?? 0, originalMetadata.height ?? 0)
    let presetName = preferredExportPreset(for: asset, maxDimension: maxDimension)

    guard let exporter = AVAssetExportSession(asset: asset, presetName: presetName) else {
      throw BanteraVideoProcessingError.exportFailed(
        "Bantera could not create a video export session for this file."
      )
    }

    exporter.shouldOptimizeForNetworkUse = true
    let outputFileType: AVFileType
    if exporter.supportedFileTypes.contains(.mp4) {
      outputFileType = .mp4
    } else if exporter.supportedFileTypes.contains(.mov) {
      outputFileType = .mov
    } else {
      outputFileType = exporter.supportedFileTypes.first ?? .mp4
    }

    let fileExtension = outputFileType == .mov ? "mov" : "mp4"
    let outputURL = FileManager.default.temporaryDirectory
      .appendingPathComponent("bantera_video_\(UUID().uuidString)")
      .appendingPathExtension(fileExtension)

    exporter.outputURL = outputURL
    exporter.outputFileType = outputFileType

    do {
      try await exporter.exportAsync()
    } catch {
      throw BanteraVideoProcessingError.exportFailed(
        "Bantera could not create an upload-ready copy of this video."
      )
    }

    let optimizedMetadata = try videoMetadata(for: AVAsset(url: outputURL), url: outputURL)
    if maxDimension <= 1280 && optimizedMetadata.fileSizeBytes >= originalMetadata.fileSizeBytes {
      try? FileManager.default.removeItem(at: outputURL)
      return PreparedOutput(url: inputURL, shouldDeleteAfterUse: false)
    }

    return PreparedOutput(url: outputURL, shouldDeleteAfterUse: true)
  }

  private func preferredExportPreset(for asset: AVAsset, maxDimension: Int) -> String {
    let presets = AVAssetExportSession.exportPresets(compatibleWith: asset)

    if maxDimension > 1280, presets.contains(AVAssetExportPreset1280x720) {
      return AVAssetExportPreset1280x720
    }
    if presets.contains(AVAssetExportPresetMediumQuality) {
      return AVAssetExportPresetMediumQuality
    }
    if presets.contains(AVAssetExportPreset1280x720) {
      return AVAssetExportPreset1280x720
    }
    if presets.contains(AVAssetExportPreset640x480) {
      return AVAssetExportPreset640x480
    }
    return AVAssetExportPresetHighestQuality
  }

  private func videoMetadata(for asset: AVAsset, url: URL) throws -> VideoMetadata {
    let resourceValues = try url.resourceValues(forKeys: [.fileSizeKey])
    let fileSize = resourceValues.fileSize ?? 0
    let durationMs = Int((max(asset.duration.seconds, 0) * 1000).rounded())

    let track = asset.tracks(withMediaType: .video).first
    let transformed = track?.naturalSize.applying(track?.preferredTransform ?? .identity)
    let width = transformed.map { Int(abs($0.width).rounded()) }
    let height = transformed.map { Int(abs($0.height).rounded()) }

    let contentType: String
    switch url.pathExtension.lowercased() {
    case "mov":
      contentType = "video/quicktime"
    case "m4v":
      contentType = "video/x-m4v"
    default:
      contentType = "video/mp4"
    }

    return VideoMetadata(
      durationMs: durationMs,
      width: width,
      height: height,
      fileSizeBytes: fileSize,
      contentType: contentType
    )
  }

  // Groups per-character runs into sentence-level cues using the accurate
  // Speech.TimeRangeAttribute timestamps on each run.
  // Splits at CJK/standard sentence-ending punctuation so each cue is one
  // complete thought with real start/end times — no proportional estimation.

  private static func cuesFromAttributedRuns(
    _ text: AttributedString
  ) -> [TranscriptCuePayload] {
    let sentenceEnders: Set<Character> = ["。", "！", "？", ".", "!", "?"]

    var cues: [TranscriptCuePayload] = []
    var buffer = ""
    var bufferStartMs: Int? = nil
    var bufferEndMs = 0
    var foundAnyTiming = false

    for run in text.runs {
      guard let timeRange = run[AttributeScopes.SpeechAttributes.TimeRangeAttribute.self] else { continue }
      foundAnyTiming = true

      let segment = String(text[run.range].characters)
      let trimmed = segment.trimmingCharacters(in: .whitespaces)

      buffer += segment

      if !trimmed.isEmpty {
        let startSec = timeRange.start.seconds
        let endSec   = CMTimeRangeGetEnd(timeRange).seconds
        if startSec.isFinite && endSec.isFinite {
          let startMs = max(0, Int((startSec * 1000).rounded()))
          let endMs   = max(startMs, Int((endSec * 1000).rounded()))
          if bufferStartMs == nil { bufferStartMs = startMs }
          bufferEndMs = endMs
        }
      }

      let shouldSplit = trimmed.last.map { sentenceEnders.contains($0) } ?? false
      if shouldSplit {
        let cueText = cleanTranscriptSegment(buffer)
        if !cueText.isEmpty, let startMs = bufferStartMs {
          cues.append(TranscriptCuePayload(
            index: 0,
            startMs: startMs,
            endMs: max(bufferEndMs, startMs + 1),
            text: cueText
          ))
        }
        buffer = ""
        bufferStartMs = nil
        bufferEndMs = 0
      }
    }

    // Flush any trailing text not ended by punctuation.
    let remaining = cleanTranscriptSegment(buffer)
    if !remaining.isEmpty, let startMs = bufferStartMs {
      cues.append(TranscriptCuePayload(
        index: 0,
        startMs: startMs,
        endMs: max(bufferEndMs, startMs + 1),
        text: remaining
      ))
    }

    return foundAnyTiming ? cues : []
  }

  private static func cleanTranscriptSegment(_ text: String) -> String {
    let flattened = text
      .components(separatedBy: .newlines)
      .map { $0.trimmingCharacters(in: .whitespaces) }
      .filter { !$0.isEmpty }
      .joined(separator: " ")

    let collapsed = flattened.replacingOccurrences(
      of: #"\s+"#,
      with: " ",
      options: .regularExpression
    )

    var cleaned = collapsed.trimmingCharacters(in: .whitespacesAndNewlines)
    while cleaned.hasSuffix(".") || cleaned.hasSuffix("。") {
      cleaned.removeLast()
    }

    return cleaned.trimmingCharacters(in: .whitespacesAndNewlines)
  }

  private static func normalizeTranscriptCues(
    _ cues: [TranscriptCuePayload]
  ) -> [TranscriptCuePayload] {
    guard !cues.isEmpty else {
      return []
    }

    var normalized: [TranscriptCuePayload] = []
    for cue in cues {
      let text = cleanTranscriptSegment(cue.text)
      guard !text.isEmpty else {
        continue
      }

      var startMs = max(0, cue.startMs)
      var endMs = max(startMs + 1, cue.endMs)

      if let last = normalized.last {
        startMs = max(startMs, last.endMs)
        endMs = max(endMs, startMs + 1)
      }

      if let lastIndex = normalized.indices.last,
         normalized[lastIndex].text == text {
        normalized[lastIndex].endMs = max(normalized[lastIndex].endMs, endMs)
        continue
      }

      normalized.append(
        TranscriptCuePayload(
          index: normalized.count,
          startMs: startMs,
          endMs: endMs,
          text: text
        )
      )
    }

    return normalized
  }

  private static func languageCode(for locale: Locale) -> String {
    if let languageCode = locale.language.languageCode?.identifier {
      return languageCode.lowercased()
    }

    return locale.identifier(.bcp47)
      .replacingOccurrences(of: "_", with: "-")
      .split(separator: "-")
      .first?
      .lowercased() ?? "und"
  }

  private static func localizedName(for locale: Locale) -> String {
    Locale.current.localizedString(forIdentifier: locale.identifier) ?? locale.identifier(.bcp47)
  }
}

private extension AVAssetExportSession {
  func exportAsync() async throws {
    try await withCheckedThrowingContinuation { continuation in
      exportAsynchronously {
        switch self.status {
        case .completed:
          continuation.resume()
        case .failed:
          continuation.resume(throwing: self.error ?? NSError(domain: "Bantera", code: -1))
        case .cancelled:
          continuation.resume(throwing: NSError(domain: "Bantera", code: -2))
        default:
          continuation.resume(throwing: NSError(domain: "Bantera", code: -3))
        }
      }
    }
  }
}

// Full-duplex PCM for Bantera AI. All player state is confined to the main queue.
final class BanteraAiAudioBridge: NSObject, FlutterStreamHandler {
  private var callKitManaged = false
  private var phoneAudio: BanteraPhoneAudio?
  private var routeObserver: NSObjectProtocol?
  private var engine: AVAudioEngine?
  private var player: AVAudioPlayerNode?
  private var sink: FlutterEventSink?
  private var pending = 0
  private var queued: [(id: UUID, data: Data)] = []
  private var configurationObserver: NSObjectProtocol?
  private var healthTimer: Timer?
  private var lastCapture = Date()
  private var recoveries = 0
  private var recoveryWork: DispatchWorkItem?
  private var usesSpeaker = true
  private var usesVoiceProcessing = true
  private var startResult: FlutterResult?
  private var captureBuffers = 0
  private var capturedFrames = 0
  private var playedFrames = 0
  private var conversionError = ""
  private var echoCancellationEnabled: Bool {
    if let phoneAudio { return phoneAudio.echoCancellationEnabled }
    if usesVoiceProcessing { return engine?.inputNode.isVoiceProcessingEnabled == true }
    if #available(iOS 18.2, *) { return AVAudioSession.sharedInstance().isEchoCancelledInputEnabled }
    return false
  }
  private var speakerNeedsEchoCancellation: Bool {
    AVAudioSession.sharedInstance().currentRoute.outputs.contains { $0.portType == .builtInSpeaker }
  }
  var diagnostics: String {
    "mode=\(AVAudioSession.sharedInstance().mode.rawValue) category=\(AVAudioSession.sharedInstance().category.rawValue) options=\(AVAudioSession.sharedInstance().categoryOptions.rawValue) outputs=\(AVAudioSession.sharedInstance().currentRoute.outputs.map { $0.portType.rawValue }.joined(separator: ",")) echoCancellation=\(echoCancellationEnabled) voiceProcessing=\(usesVoiceProcessing) speaker=\(speakerNeedsEchoCancellation) running=\(phoneAudio?.running ?? (engine?.isRunning == true)) captureBuffers=\(captureBuffers) capturedFrames=\(capturedFrames) playedFrames=\(phoneAudio?.renderedFrames ?? playedFrames) recoveries=\(recoveries) conversion=\(conversionError)"
  }
  private var generation = 0
  private var playbackGeneration = 0
  private var drain: FlutterResult?
  private var interruptionObserver: NSObjectProtocol?
  private let format = AVAudioFormat(commonFormat: .pcmFormatFloat32, sampleRate: 24000, channels: 1, interleaved: false)!

  init(messenger: FlutterBinaryMessenger) {
    super.init()
    FlutterEventChannel(name: "bantera/ai_audio/input", binaryMessenger: messenger).setStreamHandler(self)
    FlutterMethodChannel(name: "bantera/ai_audio", binaryMessenger: messenger).setMethodCallHandler { [weak self] call, result in
      guard let self else { return }
      do {
        switch call.method {
        case "identifyLanguages":
          guard let texts = call.arguments as? [String], texts.count <= 250,
                texts.allSatisfy({ $0.count <= 4000 }) else { result([]); return }
          DispatchQueue.global(qos: .utility).async {
            let evidence: [[String: Any]] = texts.map { text in
              let recognizer = NLLanguageRecognizer()
              recognizer.processString(text)
              let hypotheses = recognizer.languageHypotheses(withMaximum: 3).map {
                ["language": $0.key.rawValue, "confidence": $0.value] as [String: Any]
              }
              let tagger = NLTagger(tagSchemes: [.language])
              tagger.string = text
              var languages = Set<String>()
              tagger.enumerateTags(in: text.startIndex..<text.endIndex, unit: .word,
                                   scheme: .language, options: [.omitWhitespace, .omitPunctuation]) { tag, _ in
                if let tag { languages.insert(tag.rawValue) }
                return true
              }
              return ["hypotheses": hypotheses, "languages": Array(languages)]
            }
            DispatchQueue.main.async { result(evidence) }
          }
        case "storagePath":
          var url = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0].appendingPathComponent("bantera_ai", isDirectory: true)
          try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true, attributes: [.protectionKey: FileProtectionType.completeUntilFirstUserAuthentication])
          var values = URLResourceValues(); values.isExcludedFromBackup = true
          try url.setResourceValues(values)
          result(url.path)
        case "diagnostics": result(self.diagnostics)
        case "start":
          try self.start(callKitManaged: (call.arguments as? [String: Any])?["callKitManaged"] as? Bool == true)
          self.startResult = result
        case "startPlayback": try self.startPlayback(); result(nil)
        case "feed":
          if let bytes = call.arguments as? FlutterStandardTypedData { try self.feed(bytes.data) }
          result(nil)
        case "clear": self.clear(); result(nil)
        case "drain":
          self.drain?(nil); self.drain = nil
          if self.phoneAudio?.hasQueuedAudio == false || (self.phoneAudio == nil && self.pending == 0) { result(nil) } else { self.drain = result }
        case "speaker":
          self.usesSpeaker = (call.arguments as? Bool) == true
          let session = AVAudioSession.sharedInstance()
          let options = self.sessionOptions
          try self.configureSession(options: options)
          try session.overrideOutputAudioPort(self.usesSpeaker ? .speaker : .none)
          result(nil)
        case "stop": self.stop(); result(nil)
        default: result(FlutterMethodNotImplemented)
        }
      } catch { self.stop(); result(FlutterError(code: "audio_unavailable", message: "Audio is unavailable.", details: nil)) }
    }
    interruptionObserver = NotificationCenter.default.addObserver(forName: AVAudioSession.interruptionNotification, object: nil, queue: .main) { [weak self] note in
      guard let self, self.engine != nil || self.phoneAudio != nil,
        (note.userInfo?[AVAudioSessionInterruptionTypeKey] as? UInt) == AVAudioSession.InterruptionType.began.rawValue else { return }
      self.conversionError = "session-interruption"
      self.sink?(FlutterError(code: "interrupted", message: "Audio was interrupted.", details: nil))
      self.stop()
    }
  }
  func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? { sink = events; return nil }
  func onCancel(withArguments arguments: Any?) -> FlutterError? { sink = nil; stop(); return nil }
  func startPlayback() throws {
    stop()
    let session = AVAudioSession.sharedInstance()
    try session.setCategory(.playback, mode: .spokenAudio)
    try session.setActive(true)
    let engine = AVAudioEngine(), player = AVAudioPlayerNode()
    self.engine = engine; self.player = player
    engine.attach(player)
    engine.connect(player, to: engine.mainMixerNode, format: format)
    engine.prepare()
    try engine.start()
    player.play()
  }
  func start(callKitManaged: Bool = false) throws {
    stop()
    self.callKitManaged = callKitManaged
    usesSpeaker = !callKitManaged
    usesVoiceProcessing = true
    captureBuffers = 0; capturedFrames = 0; playedFrames = 0; conversionError = ""
    recoveries = 0
    // Newer iPhones expose built-in echo-cancelled input without VoiceProcessingIO.
    // Query in its required category/mode, then verify the active state below.
    let session = AVAudioSession.sharedInstance()
    if callKitManaged {
      // The system already activated the route selected on the call screen.
      // Never replay an old app speaker preference when starting/recovering it.
      usesSpeaker = speakerNeedsEchoCancellation
    }
    let mode: AVAudioSession.Mode = callKitManaged ? .voiceChat : .default
    if #available(iOS 18.2, *), callKitManaged, session.prefersEchoCancelledInput {
      try session.setPrefersEchoCancelledInput(false)
    }
    if session.category != .playAndRecord || session.mode != mode || session.categoryOptions != sessionOptions {
      try session.setCategory(.playAndRecord, mode: mode, options: sessionOptions)
    }
    if #available(iOS 18.2, *), !callKitManaged, session.isEchoCancelledInputAvailable {
      do {
        if !session.prefersEchoCancelledInput { try session.setPrefersEchoCancelledInput(true) }
        usesVoiceProcessing = false
      } catch { usesVoiceProcessing = true }
    }
    if callKitManaged {
      routeObserver = NotificationCenter.default.addObserver(
        forName: AVAudioSession.routeChangeNotification, object: nil, queue: .main
      ) { [weak self] _ in
        guard let self, self.callKitManaged else { return }
        self.usesSpeaker = self.speakerNeedsEchoCancellation
      }
    }
    if callKitManaged {
      let phone = try BanteraPhoneAudio(onInput: { [weak self] data in
        guard let self, self.phoneAudio != nil else { return }
        self.captureBuffers += 1
        self.capturedFrames += data.count / 2
        self.lastCapture = Date()
        self.startResult?(nil); self.startResult = nil
        self.sink?(FlutterStandardTypedData(bytes: data))
      }, onDrained: { [weak self] in
        guard let self, self.phoneAudio?.hasQueuedAudio == false else { return }
        self.drain?(nil); self.drain = nil
      })
      self.phoneAudio = phone
      try phone.start()
      lastCapture = Date()
      healthTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
        guard let self, self.phoneAudio != nil else { return }
        if Date().timeIntervalSince(self.lastCapture) > 5 { self.failAudio() }
      }
      return
    }
    try buildEngine()
    healthTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
      guard let self, let engine = self.engine else { return }
      if !engine.isRunning || Date().timeIntervalSince(self.lastCapture) > 3 ||
          (self.speakerNeedsEchoCancellation && !self.echoCancellationEnabled) {
        self.recoverAudio()
      }
    }
  }
  private var sessionOptions: AVAudioSession.CategoryOptions {
    // CallKit's receiver/speaker picker owns routing. defaultToSpeaker would
    // make clearing its speaker override fall back to the loudspeaker again.
    callKitManaged || !usesSpeaker ? [.allowBluetoothHFP] : [.defaultToSpeaker, .allowBluetoothHFP]
  }
  private func configureSession(options: AVAudioSession.CategoryOptions) throws {
    let session = AVAudioSession.sharedInstance()
    let mode: AVAudioSession.Mode = usesVoiceProcessing ? .voiceChat : .default
    // Reapplying the category can reset a route the user just selected.
    if session.category != .playAndRecord || session.mode != mode || session.categoryOptions != options {
      try session.setCategory(.playAndRecord, mode: mode, options: options)
    }
    if #available(iOS 18.2, *), !usesVoiceProcessing, !session.prefersEchoCancelledInput {
      try session.setPrefersEchoCancelledInput(true)
    }
  }
  private func buildEngine() throws {
    let session = AVAudioSession.sharedInstance()
    let options = sessionOptions
    try configureSession(options: options)
    if !callKitManaged { try session.setActive(true) }
    if !usesVoiceProcessing && speakerNeedsEchoCancellation && !echoCancellationEnabled {
      // The preference is not a guarantee. Never silently stream uncancelled
      // speaker echo if iOS declines it; use the standard voice processor.
      usesVoiceProcessing = true
      try configureSession(options: options)
    }
    let engine = AVAudioEngine(), player = AVAudioPlayerNode()
    self.engine = engine; self.player = player
    // Both paths provide system echo cancellation while preserving duplex audio.
    if usesVoiceProcessing {
      try engine.inputNode.setVoiceProcessingEnabled(true)
      engine.inputNode.isVoiceProcessingInputMuted = false
    }
    engine.attach(player); engine.connect(player, to: engine.mainMixerNode, format: format)
    let inputFormat = engine.inputNode.outputFormat(forBus: 0)
    guard inputFormat.sampleRate > 0, inputFormat.channelCount > 0 else {
      throw NSError(domain: "Audio", code: 2)
    }
    // Keep the input branch in the render graph even before Gemini sends its
    // first output buffer. The muted mixer prevents microphone monitoring.
    let captureMixer = AVAudioMixerNode()
    engine.attach(captureMixer)
    engine.connect(engine.inputNode, to: captureMixer, format: inputFormat)
    captureMixer.outputVolume = 0
    engine.connect(captureMixer, to: engine.mainMixerNode, fromBus: 0, toBus: 1, format: inputFormat)
    let target = AVAudioFormat(commonFormat: .pcmFormatInt16, sampleRate: 16000, channels: 1, interleaved: false)!
    guard let converter = AVAudioConverter(from: inputFormat, to: target) else { throw NSError(domain: "Audio", code: 1) }
    let captureGeneration = generation
    engine.inputNode.installTap(onBus: 0, bufferSize: 2048, format: inputFormat) { [weak self] buffer, _ in
      let capacity = AVAudioFrameCount(ceil(Double(buffer.frameLength) * 16000 / inputFormat.sampleRate) + 32)
      guard let converted = AVAudioPCMBuffer(pcmFormat: target, frameCapacity: capacity) else { return }
      var supplied = false
      var error: NSError?
      converter.convert(to: converted, error: &error) { _, status in
        if supplied { status.pointee = .noDataNow; return nil }
        supplied = true; status.pointee = .haveData; return buffer
      }
      let frameCount = Int(converted.frameLength)
      let errorCode = error.map { String($0.code) } ?? "none"
      DispatchQueue.main.async { [weak self] in
        self?.captureBuffers += 1
        self?.capturedFrames += frameCount
        self?.conversionError = errorCode
      }
      guard error == nil, converted.frameLength > 0, let samples = converted.int16ChannelData?[0] else { return }
      let data = Data(bytes: samples, count: Int(converted.frameLength) * 2)
      DispatchQueue.main.async { [weak self] in
        guard let self, self.engine != nil, self.generation == captureGeneration else { return }
        self.lastCapture = Date()
        if !self.speakerNeedsEchoCancellation || self.echoCancellationEnabled {
          self.recoveries = 0
        }
        self.startResult?(nil); self.startResult = nil
        self.sink?(FlutterStandardTypedData(bytes: data))
      }
    }
    // iOS can stop both capture and playback when hardware formats change.
    // Rebuild on the main queue after the notification, never inside its callback.
    configurationObserver = NotificationCenter.default.addObserver(
      forName: .AVAudioEngineConfigurationChange, object: engine, queue: nil
    ) { [weak self, weak engine] _ in
      DispatchQueue.main.async {
        guard let self, let engine, self.engine === engine, !engine.isRunning else { return }
        self.recoverAudio()
      }
    }
    lastCapture = Date()
    engine.prepare()
    try engine.start()
    player.play()
  }
  private func recoverAudio() {
    guard engine != nil, recoveryWork == nil else { return }
    // Route changes arrive before iOS has finished negotiating its new input
    // format. Rebuilding immediately can see zero channels and lose both paths.
    let work = DispatchWorkItem { [weak self] in
      guard let self else { return }
      self.recoveryWork = nil
      self.recoveries += 1
      if self.recoveries >= 2 { self.usesVoiceProcessing = true }
      guard self.recoveries <= 3 else { self.failAudio(); return }
      let remaining = self.queued
      self.tearDownEngine()
      do {
        try self.buildEngine()
        for item in remaining { self.schedule(item) }
      } catch {
        self.conversionError = "restart-\((error as NSError).domain)-\((error as NSError).code)"
        if self.engine == nil { self.failAudio() } else { self.recoverAudio() }
      }
    }
    recoveryWork = work
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3, execute: work)
  }
  private func failAudio() {
    sink?(FlutterError(code: "audio_unavailable", message: "Audio is unavailable.", details: nil))
    stop()
  }
  func feed(_ data: Data) throws {
    if let phoneAudio { try phoneAudio.feed(data); return }
    guard let engine else { throw NSError(domain: "Audio", code: 3) }
    if !engine.isRunning { recoverAudio() }
    guard !data.isEmpty, data.count % 2 == 0 else { return }
    let item = (id: UUID(), data: data)
    queued.append(item)
    pending = queued.count
    if engine.isRunning && recoveryWork == nil { schedule(item) }
  }
  private func schedule(_ item: (id: UUID, data: Data)) {
    let data = item.data
    guard let player, data.count > 0, data.count % 2 == 0,
          let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: AVAudioFrameCount(data.count / 2)),
          let floats = buffer.floatChannelData?[0] else { return }
    buffer.frameLength = buffer.frameCapacity
    data.withUnsafeBytes { raw in
      for index in 0..<Int(buffer.frameLength) {
        let value = UInt16(raw[index * 2]) | UInt16(raw[index * 2 + 1]) << 8
        floats[index] = Float(Int16(bitPattern: value)) / 32768
      }
    }
    let version = playbackGeneration
    player.scheduleBuffer(buffer, completionCallbackType: .dataPlayedBack) { [weak self] _ in
      DispatchQueue.main.async {
        guard let self, self.playbackGeneration == version else { return }
        self.playedFrames += item.data.count / 2
        self.queued.removeAll { $0.id == item.id }
        self.pending = self.queued.count
        if self.pending == 0 { self.drain?(nil); self.drain = nil }
      }
    }
  }
  func clear() {
    if let phoneAudio { phoneAudio.clear(); drain?(nil); drain = nil; return }
    // Keep capture generation stable: clearing output must not disable microphone events.
    playbackGeneration += 1
    player?.stop(); queued.removeAll(); pending = 0; drain?(nil); drain = nil
    player?.play()
  }
  private func tearDownEngine() {
    generation += 1; playbackGeneration += 1
    if let observer = configurationObserver {
      NotificationCenter.default.removeObserver(observer)
      configurationObserver = nil
    }
    if let engine { engine.inputNode.removeTap(onBus: 0); engine.stop() }
    player?.stop(); engine = nil; player = nil
  }
  func stop() {
    let ownedSession = engine != nil || phoneAudio != nil
    phoneAudio?.stop(); phoneAudio = nil
    if let routeObserver { NotificationCenter.default.removeObserver(routeObserver) }
    routeObserver = nil
    recoveryWork?.cancel(); recoveryWork = nil
    startResult?(FlutterError(code: "audio_unavailable", message: "Microphone could not start.", details: diagnostics))
    startResult = nil
    healthTimer?.invalidate(); healthTimer = nil
    tearDownEngine()
    queued.removeAll(); pending = 0; drain?(nil); drain = nil
    if ownedSession && !callKitManaged {
      try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
    }
    callKitManaged = false
  }
  deinit {
    healthTimer?.invalidate()
    if let routeObserver { NotificationCenter.default.removeObserver(routeObserver) }
    if let configurationObserver { NotificationCenter.default.removeObserver(configurationObserver) }
    if let interruptionObserver { NotificationCenter.default.removeObserver(interruptionObserver) }
  }
}

// Telephony PCM uses VoiceProcessingIO directly. AVAudioEngine's graph can stop
// before its input tap starts on a CallKit-owned session after a route transition.
// The I/O unit owns both directions and follows CallKit receiver/headset routing.
final class BanteraPhoneAudio {
  private var unit: AudioUnit?
  private(set) var running = false
  private let lock = NSLock()
  private let capacity = 24000 * 90
  private var samples = [Int16](repeating: 0, count: 24000 * 90)
  private var readIndex = 0, writeIndex = 0, count = 0
  private var renderedCount = 0
  private var awaitingOutput = false
  private var playbackGeneration = 0
  private let microphoneBuffer = UnsafeMutablePointer<Int16>.allocate(capacity: 4096)
  private let inputFormat = AVAudioFormat(commonFormat: .pcmFormatInt16, sampleRate: 24000, channels: 1, interleaved: false)!
  private let captureFormat = AVAudioFormat(commonFormat: .pcmFormatInt16, sampleRate: 16000, channels: 1, interleaved: false)!
  private var converter: AVAudioConverter!
  private let onInput: (Data) -> Void
  private let onDrained: () -> Void

  var echoCancellationEnabled: Bool {
    guard let unit else { return false }
    var bypass: UInt32 = 1
    var size: UInt32 = 4
    return AudioUnitGetProperty(unit, kAUVoiceIOProperty_BypassVoiceProcessing,
      kAudioUnitScope_Global, 0, &bypass, &size) == noErr && bypass == 0
  }
  var renderedFrames: Int {
    lock.lock(); defer { lock.unlock() }
    return renderedCount
  }
  var hasQueuedAudio: Bool {
    lock.lock(); defer { lock.unlock() }
    return count > 0 || awaitingOutput
  }

  init(onInput: @escaping (Data) -> Void, onDrained: @escaping () -> Void) throws {
    self.onInput = onInput
    self.onDrained = onDrained
    converter = AVAudioConverter(from: inputFormat, to: captureFormat)
    var description = AudioComponentDescription(componentType: kAudioUnitType_Output,
      componentSubType: kAudioUnitSubType_VoiceProcessingIO, componentManufacturer: kAudioUnitManufacturer_Apple,
      componentFlags: 0, componentFlagsMask: 0)
    guard let component = AudioComponentFindNext(nil, &description) else { throw Self.error(-1) }
    try Self.check(AudioComponentInstanceNew(component, &unit))
    guard let unit else { throw Self.error(-1) }
    do {
      var enabled: UInt32 = 1
      try Self.check(AudioUnitSetProperty(unit, kAudioOutputUnitProperty_EnableIO, kAudioUnitScope_Input, 1, &enabled, 4))
      try Self.check(AudioUnitSetProperty(unit, kAudioOutputUnitProperty_EnableIO, kAudioUnitScope_Output, 0, &enabled, 4))
      var stream = AudioStreamBasicDescription(mSampleRate: 24000, mFormatID: kAudioFormatLinearPCM,
        mFormatFlags: kAudioFormatFlagIsSignedInteger | kAudioFormatFlagIsPacked,
        mBytesPerPacket: 2, mFramesPerPacket: 1, mBytesPerFrame: 2, mChannelsPerFrame: 1, mBitsPerChannel: 16, mReserved: 0)
      let size = UInt32(MemoryLayout<AudioStreamBasicDescription>.size)
      try Self.check(AudioUnitSetProperty(unit, kAudioUnitProperty_StreamFormat, kAudioUnitScope_Input, 0, &stream, size))
      try Self.check(AudioUnitSetProperty(unit, kAudioUnitProperty_StreamFormat, kAudioUnitScope_Output, 1, &stream, size))
      var maximum: UInt32 = 4096
      try Self.check(AudioUnitSetProperty(unit, kAudioUnitProperty_MaximumFramesPerSlice, kAudioUnitScope_Global, 0, &maximum, 4))
      var bypass: UInt32 = 0
      try Self.check(AudioUnitSetProperty(unit, kAUVoiceIOProperty_BypassVoiceProcessing, kAudioUnitScope_Global, 0, &bypass, 4))
      var render = AURenderCallbackStruct(inputProc: Self.render, inputProcRefCon: Unmanaged.passUnretained(self).toOpaque())
      var capture = AURenderCallbackStruct(inputProc: Self.capture, inputProcRefCon: Unmanaged.passUnretained(self).toOpaque())
      try Self.check(AudioUnitSetProperty(unit, kAudioUnitProperty_SetRenderCallback, kAudioUnitScope_Input, 0,
        &render, UInt32(MemoryLayout<AURenderCallbackStruct>.size)))
      try Self.check(AudioUnitSetProperty(unit, kAudioOutputUnitProperty_SetInputCallback, kAudioUnitScope_Global, 0,
        &capture, UInt32(MemoryLayout<AURenderCallbackStruct>.size)))
      try Self.check(AudioUnitInitialize(unit))
    } catch {
      AudioComponentInstanceDispose(unit); self.unit = nil
      throw error
    }
  }

  private static func error(_ code: OSStatus) -> NSError { NSError(domain: "BanteraPhoneAudio", code: Int(code)) }
  private static func check(_ status: OSStatus) throws { if status != noErr { throw error(status) } }
  func start() throws {
    guard let unit else { throw Self.error(-1) }
    try Self.check(AudioOutputUnitStart(unit))
    running = true
  }
  func stop() {
    running = false
    if let unit {
      AudioOutputUnitStop(unit)
      AudioUnitUninitialize(unit)
      AudioComponentInstanceDispose(unit)
      self.unit = nil
    }
    clear()
  }
  deinit { stop(); microphoneBuffer.deallocate() }

  func feed(_ data: Data) throws {
    guard !data.isEmpty, data.count % 2 == 0 else { throw Self.error(-1) }
    lock.lock(); defer { lock.unlock() }
    let incoming = data.count / 2
    guard incoming <= capacity - count else { throw Self.error(-1) }
    data.withUnsafeBytes { bytes in
      for index in 0..<incoming {
        samples[writeIndex] = Int16(littleEndian: bytes.loadUnaligned(fromByteOffset: index * 2, as: Int16.self))
        writeIndex = (writeIndex + 1) % capacity
      }
    }
    count += incoming
    awaitingOutput = true
    playbackGeneration += 1
  }
  func clear() {
    lock.lock(); readIndex = 0; writeIndex = 0; count = 0; awaitingOutput = false; playbackGeneration += 1; lock.unlock()
  }

  private static let render: AURenderCallback = { context, _, _, _, frames, buffers in
    let owner = Unmanaged<BanteraPhoneAudio>.fromOpaque(context).takeUnretainedValue()
    guard let buffers, let data = buffers.pointee.mBuffers.mData else { return noErr }
    let output = data.assumingMemoryBound(to: Int16.self)
    owner.lock.lock()
    let available = min(Int(frames), owner.count)
    for index in 0..<available {
      output[index] = owner.samples[owner.readIndex]
      owner.readIndex = (owner.readIndex + 1) % owner.capacity
    }
    if available < Int(frames) { output.advanced(by: available).update(repeating: 0, count: Int(frames) - available) }
    owner.count -= available
    owner.renderedCount += available
    let version = owner.playbackGeneration
    let drained = available > 0 && owner.count == 0
    owner.lock.unlock()
    buffers.pointee.mBuffers.mDataByteSize = frames * 2
    if drained {
      DispatchQueue.main.async { [weak owner] in
        // Render submits the final buffer before the hardware finishes playing it.
        // Keep the end-of-call drain open through that last output interval.
        let session = AVAudioSession.sharedInstance()
        let delay = session.outputLatency + session.ioBufferDuration
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) { [weak owner] in
          guard let owner, owner.running else { return }
          owner.lock.lock()
          let complete = owner.count == 0 && owner.playbackGeneration == version
          if complete { owner.awaitingOutput = false }
          owner.lock.unlock()
          if complete { owner.onDrained() }
        }
      }
    }
    return noErr
  }

  private static let capture: AURenderCallback = { context, flags, time, _, frames, _ in
    let owner = Unmanaged<BanteraPhoneAudio>.fromOpaque(context).takeUnretainedValue()
    guard frames <= 4096, let unit = owner.unit else { return noErr }
    var buffer = AudioBufferList(mNumberBuffers: 1,
      mBuffers: AudioBuffer(mNumberChannels: 1, mDataByteSize: frames * 2, mData: owner.microphoneBuffer))
    let status = AudioUnitRender(unit, flags, time, 1, frames, &buffer)
    guard status == noErr else { return status }
    let bytes = Data(bytes: owner.microphoneBuffer, count: Int(frames) * 2)
    DispatchQueue.main.async { [weak owner] in owner?.convertCapture(bytes) }
    return noErr
  }

  private func convertCapture(_ data: Data) {
    guard running,
      let input = AVAudioPCMBuffer(pcmFormat: inputFormat, frameCapacity: AVAudioFrameCount(data.count / 2)),
      let output = AVAudioPCMBuffer(pcmFormat: captureFormat, frameCapacity: AVAudioFrameCount(data.count / 3 + 32)),
      let destination = input.int16ChannelData?[0] else { return }
    input.frameLength = AVAudioFrameCount(data.count / 2)
    data.copyBytes(to: UnsafeMutableRawBufferPointer(start: destination, count: data.count))
    var supplied = false
    var error: NSError?
    converter.convert(to: output, error: &error) { _, state in
      if supplied { state.pointee = .noDataNow; return nil }
      supplied = true; state.pointee = .haveData; return input
    }
    guard error == nil, output.frameLength > 0, let samples = output.int16ChannelData?[0] else { return }
    onInput(Data(bytes: samples, count: Int(output.frameLength) * 2))
  }
}
