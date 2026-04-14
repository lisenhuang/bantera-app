import AVFoundation
import CoreTelephony
import Flutter
import Network
import Speech
@preconcurrency import Translation
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  private var videoProcessingBridge: BanteraVideoProcessingBridge?
  private var translationBridge: BanteraTranslationBridge?

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
    videoProcessingBridge = BanteraVideoProcessingBridge(
      binaryMessenger: engineBridge.applicationRegistrar.messenger()
    )
    translationBridge = BanteraTranslationBridge(
      binaryMessenger: engineBridge.applicationRegistrar.messenger()
    )
    _ = BanteraNetworkReachabilityBridge(
      binaryMessenger: engineBridge.applicationRegistrar.messenger()
    )
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
    case "getSupportedLegacyTranscriptionLocales":
      handleGetSupportedLegacyTranscriptionLocales(result: result)
    case "prepareVideoForUpload":
      handlePrepareVideoForUpload(call: call, result: result)
    case "prepareVideoForLocalPractice":
      handlePrepareVideoForLocalPractice(call: call, result: result)
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
  }

  private func handleGetSupportedLegacyTranscriptionLocales(result: @escaping FlutterResult) {
    result(BanteraLegacySpeechRecognitionService.supportedLocalePayload())
  }

  private func handlePrepareVideoForUpload(
    call: FlutterMethodCall,
    result: @escaping FlutterResult
  ) {
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

  private func handlePrepareVideoForLocalPractice(
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

    Task {
      do {
        let response = try await BanteraLegacySpeechRecognitionService()
          .prepareVideoForLocalPractice(
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

    Task {
      do {
        let inputURL = URL(fileURLWithPath: inputPath)
        let response: [String: Any]
        if #available(iOS 26.0, *) {
          response = try await BanteraVideoPreparationService().transcribeRecordedAudio(
            inputURL: inputURL,
            localeIdentifier: localeIdentifier
          )
        } else {
          response = try await BanteraLegacySpeechRecognitionService().transcribeRecordedAudio(
            inputURL: inputURL,
            localeIdentifier: localeIdentifier
          )
        }
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
        if #available(iOS 26.0, *) {
          try await BanteraVideoPreparationService().ensureTranscriptionModelInstalled(
            localeIdentifier: localeIdentifier
          )
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
    guard #available(iOS 18.0, *) else {
      result(BanteraTranslationError.unsupportedIosVersion.flutterError)
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

  private func handlePrepareTranslationAssets(
    call: FlutterMethodCall,
    result: @escaping FlutterResult
  ) {
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

  static func supportedLocalePayload() -> [[String: Any]] {
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

  static func logSupportedLocales() {
    let supported = SFSpeechRecognizer.supportedLocales().sorted {
      localizedName(for: $0) < localizedName(for: $1)
    }

    print("[SFSpeechRecognizer, iOS 10+] Supported locales (\(supported.count)):")
    for locale in supported {
      print("[SFSpeechRecognizer, iOS 10+]   \(bcp47Identifier(for: locale)) — \(localizedName(for: locale))")
    }
  }

  func ensureReady(localeIdentifier: String) async throws {
    try await ensureSpeechAuthorization()
    let resolved = try resolveRecognizer(localeIdentifier: localeIdentifier)
    guard resolved.recognizer.isAvailable else {
      throw BanteraVideoProcessingError.speechUnavailable
    }
  }

  func transcribeRecordedAudio(
    inputURL: URL,
    localeIdentifier: String
  ) async throws -> [String: Any] {
    try await ensureSpeechAuthorization()
    let resolved = try resolveRecognizer(localeIdentifier: localeIdentifier)
    guard resolved.recognizer.isAvailable else {
      throw BanteraVideoProcessingError.speechUnavailable
    }

    let transcript = try await transcribe(url: inputURL, recognizer: resolved.recognizer)
    let text = transcript.trimmingCharacters(in: .whitespacesAndNewlines)
    guard !text.isEmpty else {
      throw BanteraVideoProcessingError.transcriptionFailed(
        "No transcript could be generated. Check that the audio matches the chosen language."
      )
    }

    return [
      "transcriptText": text,
      "transcriptLanguage": Self.bcp47Identifier(for: resolved.locale),
      "transcriptLanguageCode": Self.languageCode(for: resolved.locale),
    ]
  }

  func prepareVideoForLocalPractice(
    inputURL: URL,
    localeIdentifier: String
  ) async throws -> [String: Any] {
    try await ensureSpeechAuthorization()
    let resolved = try resolveRecognizer(localeIdentifier: localeIdentifier)
    guard resolved.recognizer.isAvailable else {
      throw BanteraVideoProcessingError.speechUnavailable
    }

    let inputAsset = AVAsset(url: inputURL)
    let audioURL = try await extractAudioAsLinearPcmFile(from: inputAsset)
    defer { try? FileManager.default.removeItem(at: audioURL) }

    let transcript = try await transcribePrepared(
      url: audioURL,
      locale: resolved.locale,
      recognizer: resolved.recognizer
    )
    let preparedOutput = try await exportPracticeVideo(from: inputURL, asset: inputAsset)
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

  private func transcribe(url: URL, recognizer: SFSpeechRecognizer) async throws -> String {
    do {
      return try await transcribe(
        url: url,
        recognizer: recognizer,
        requiresOnDeviceRecognition: recognizer.supportsOnDeviceRecognition
      )
    } catch {
      guard recognizer.supportsOnDeviceRecognition else {
        throw error
      }

      return try await transcribe(
        url: url,
        recognizer: recognizer,
        requiresOnDeviceRecognition: false
      )
    }
  }

  private func transcribe(
    url: URL,
    recognizer: SFSpeechRecognizer,
    requiresOnDeviceRecognition: Bool
  ) async throws -> String {
    try await withCheckedThrowingContinuation { continuation in
      let request = SFSpeechURLRecognitionRequest(url: url)
      request.shouldReportPartialResults = false
      request.requiresOnDeviceRecognition = requiresOnDeviceRecognition

      let lock = NSLock()
      var didResume = false

      func finish(_ result: Result<String, Error>) {
        lock.lock()
        defer { lock.unlock() }
        guard !didResume else { return }
        didResume = true
        switch result {
        case let .success(text):
          continuation.resume(returning: text)
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
          finish(.success(result.bestTranscription.formattedString))
        }
      }
    }
  }

  private func transcribePrepared(
    url: URL,
    locale: Locale,
    recognizer: SFSpeechRecognizer
  ) async throws -> PreparedTranscript {
    do {
      return try await transcribePrepared(
        url: url,
        locale: locale,
        recognizer: recognizer,
        requiresOnDeviceRecognition: recognizer.supportsOnDeviceRecognition
      )
    } catch {
      guard recognizer.supportsOnDeviceRecognition else {
        throw error
      }

      return try await transcribePrepared(
        url: url,
        locale: locale,
        recognizer: recognizer,
        requiresOnDeviceRecognition: false
      )
    }
  }

  private func transcribePrepared(
    url: URL,
    locale: Locale,
    recognizer: SFSpeechRecognizer,
    requiresOnDeviceRecognition: Bool
  ) async throws -> PreparedTranscript {
    try await withCheckedThrowingContinuation { continuation in
      let request = SFSpeechURLRecognitionRequest(url: url)
      request.shouldReportPartialResults = false
      request.requiresOnDeviceRecognition = requiresOnDeviceRecognition

      let lock = NSLock()
      var didResume = false

      func finish(_ result: Result<PreparedTranscript, Error>) {
        lock.lock()
        defer { lock.unlock() }
        guard !didResume else { return }
        didResume = true
        switch result {
        case let .success(transcript):
          continuation.resume(returning: transcript)
        case let .failure(error):
          continuation.resume(throwing: error)
        }
      }

      _ = recognizer.recognitionTask(with: request) { result, error in
        if let error {
          finish(.failure(BanteraVideoProcessingError.transcriptionFailed(error.localizedDescription)))
          return
        }

        guard let result, result.isFinal else { return }
        do {
          finish(.success(try Self.preparedTranscript(from: result.bestTranscription, locale: locale)))
        } catch {
          finish(.failure(error))
        }
      }
    }
  }

  private static func preparedTranscript(
    from transcription: SFTranscription,
    locale: Locale
  ) throws -> PreparedTranscript {
    let cues = normalizeTranscriptCues(cuesFromSpeechSegments(transcription.segments))
    let transcriptText = cues
      .map(\.text)
      .joined(separator: "\n")
      .trimmingCharacters(in: .whitespacesAndNewlines)

    if !transcriptText.isEmpty, !cues.isEmpty {
      return PreparedTranscript(
        text: transcriptText,
        localeIdentifier: bcp47Identifier(for: locale),
        languageCode: languageCode(for: locale),
        cues: cues
      )
    }

    let text = cleanTranscriptSegment(transcription.formattedString)
    guard !text.isEmpty else {
      throw BanteraVideoProcessingError.transcriptionFailed(
        "No transcript could be generated. Check that the video audio matches the chosen language."
      )
    }

    return PreparedTranscript(
      text: text,
      localeIdentifier: bcp47Identifier(for: locale),
      languageCode: languageCode(for: locale),
      cues: [
        TranscriptCuePayload(
          index: 0,
          startMs: 0,
          endMs: max(1, estimatedEndMs(from: transcription.segments)),
          text: text
        ),
      ]
    )
  }

  private static func cuesFromSpeechSegments(
    _ segments: [SFTranscriptionSegment]
  ) -> [TranscriptCuePayload] {
    var cues: [TranscriptCuePayload] = []
    var buffer = ""
    var bufferStartMs: Int?
    var bufferEndMs = 0
    var tokenCount = 0
    var previousEndSeconds: TimeInterval?

    func flushBuffer() {
      let text = cleanTranscriptSegment(buffer)
      if !text.isEmpty, let startMs = bufferStartMs {
        cues.append(
          TranscriptCuePayload(
            index: cues.count,
            startMs: startMs,
            endMs: max(bufferEndMs, startMs + 1),
            text: text
          )
        )
      }
      buffer = ""
      bufferStartMs = nil
      bufferEndMs = 0
      tokenCount = 0
    }

    for segment in segments {
      let token = segment.substring.trimmingCharacters(in: .whitespacesAndNewlines)
      guard !token.isEmpty else { continue }

      let startSeconds = max(segment.timestamp, 0)
      let endSeconds = max(segment.timestamp + segment.duration, startSeconds)
      let startMs = max(0, Int((startSeconds * 1000).rounded()))
      let endMs = max(startMs + 1, Int((endSeconds * 1000).rounded()))
      let cueDurationMs = bufferStartMs.map { startMs - $0 } ?? 0
      let gapSeconds = previousEndSeconds.map { startSeconds - $0 } ?? 0

      if !buffer.isEmpty,
         gapSeconds >= 0.85 || tokenCount >= 12 || cueDurationMs >= 8_000 {
        flushBuffer()
      }

      if buffer.isEmpty {
        buffer = token
        bufferStartMs = startMs
        bufferEndMs = endMs
      } else {
        buffer = appendSpeechToken(token, to: buffer)
        bufferEndMs = max(bufferEndMs, endMs)
      }

      tokenCount += 1
      previousEndSeconds = max(previousEndSeconds ?? endSeconds, endSeconds)

      if isSentenceEndingToken(token) {
        flushBuffer()
      }
    }

    flushBuffer()
    return cues
  }

  private static func appendSpeechToken(_ token: String, to text: String) -> String {
    guard !text.isEmpty else { return token }
    guard let first = token.first, let last = text.last else {
      return "\(text) \(token)"
    }

    if attachesToPrevious(first) ||
        attachesToNext(last) ||
        isCjk(first) ||
        isCjk(last) {
      return text + token
    }

    return "\(text) \(token)"
  }

  private static func attachesToPrevious(_ character: Character) -> Bool {
    let characters: Set<Character> = [".", ",", "!", "?", "。", "，", "！", "？", "、", ";", "；", ":", "：", ")", "]", "}"]
    return characters.contains(character)
  }

  private static func attachesToNext(_ character: Character) -> Bool {
    let characters: Set<Character> = ["(", "[", "{", "¿", "¡"]
    return characters.contains(character)
  }

  private static func isSentenceEndingToken(_ token: String) -> Bool {
    guard let last = token.last else { return false }
    let characters: Set<Character> = [".", "!", "?", "。", "！", "？"]
    return characters.contains(last)
  }

  private static func isCjk(_ character: Character) -> Bool {
    for scalar in String(character).unicodeScalars {
      let value = scalar.value
      if (0x4E00...0x9FFF).contains(value) ||
          (0x3040...0x30FF).contains(value) ||
          (0xAC00...0xD7AF).contains(value) {
        return true
      }
    }
    return false
  }

  private static func estimatedEndMs(from segments: [SFTranscriptionSegment]) -> Int {
    let endSeconds = segments.reduce(0.0) { partial, segment in
      max(partial, segment.timestamp + max(segment.duration, 0))
    }
    return max(1, Int((endSeconds * 1000).rounded()))
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

    return collapsed.trimmingCharacters(in: .whitespacesAndNewlines)
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
      .appendingPathComponent("bantera_sfspeech_audio_\(UUID().uuidString)")
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

  private func exportPracticeVideo(from inputURL: URL, asset: AVAsset) async throws -> PreparedOutput {
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
      .appendingPathComponent("bantera_local_practice_video_\(UUID().uuidString)")
      .appendingPathExtension(fileExtension)

    exporter.outputURL = outputURL
    exporter.outputFileType = outputFileType

    do {
      try await exporter.exportAsync()
    } catch {
      throw BanteraVideoProcessingError.exportFailed(
        "Bantera could not create a local practice copy of this video."
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
