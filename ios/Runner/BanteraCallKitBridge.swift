import AVFoundation
import CallKit
import Flutter
import PushKit
import WebRTC
import UIKit
import os

/// Owns system calls independently of a Flutter view, including locked-screen launches.
final class BanteraCallKitBridge: NSObject, PKPushRegistryDelegate, CXProviderDelegate {
  private let provider: CXProvider
  private let aiProvider: CXProvider
  private let controller = CXCallController()
  private var registry: PKPushRegistry!
  private var channel: FlutterMethodChannel?
  private var ready = false
  private var events: [[String: Any]] = []
  private var calls: [UUID: [String: Any]] = [:]
  private var callProviders: [UUID: CXProvider] = [:]
  private var timers: [UUID: Timer] = [:]
  private var answers: [UUID: CXAnswerCallAction] = [:]
  private var outgoing = Set<UUID>()
  private var token: String?
  private var audioActive = false
  var onAiAudioActivated: (() throws -> Void)?
  var onAiAudioStopped: (() -> Void)?
  private var answerTasks: [UUID: UIBackgroundTaskIdentifier] = [:]
  private let logger = Logger(subsystem: "bantera.lisenhuang.com", category: "AiCallback")
  private var routeObserver: NSObjectProtocol?
  private let defaults = UserDefaults.standard

  override init() {
    provider = CXProvider(configuration: Self.configuration(ai: false))
    aiProvider = CXProvider(configuration: Self.configuration(ai: true))
    super.init()
    provider.setDelegate(self, queue: .main)
    aiProvider.setDelegate(self, queue: .main)
    routeObserver = NotificationCenter.default.addObserver(
      forName: AVAudioSession.routeChangeNotification, object: nil, queue: .main
    ) { [weak self] _ in
      guard let self, self.audioActive else { return }
      self.emitAiRoute()
    }
    registry = PKPushRegistry(queue: .main)
    registry.delegate = self
    registry.desiredPushTypes = [.voIP]
  }

  static func configuration(ai: Bool) -> CXProviderConfiguration {
    let config = CXProviderConfiguration()
    config.supportsVideo = !ai
    config.includesCallsInRecents = true
    config.maximumCallGroups = 1
    config.maximumCallsPerCallGroup = 1
    config.supportedHandleTypes = [.generic]
    return config
  }

  private static func isAi(_ data: [String: Any]) -> Bool {
    (data["callerUserId"] as? String)?.lowercased() == "ba07e2a0-a100-4000-8000-000000000001"
  }

  private func provider(for data: [String: Any]) -> CXProvider {
    Self.isAi(data) ? aiProvider : provider
  }

  private func provider(for id: UUID, data: [String: Any]) -> CXProvider {
    callProviders[id] ?? provider(for: data)
  }

  static func callUpdate(for data: [String: Any]) -> CXCallUpdate {
    let update = CXCallUpdate()
    update.remoteHandle = CXHandle(type: .generic, value: data["callerUserId"] as? String ?? "Bantera")
    update.localizedCallerName = data["callerName"] as? String ?? "Bantera"
    // Never advertise a video upgrade for an AI audio callback.
    update.hasVideo = !isAi(data) && data["mediaKind"] as? String == "video"
    update.supportsHolding = false
    update.supportsGrouping = false
    update.supportsUngrouping = false
    update.supportsDTMF = false
    return update
  }

  func attach(messenger: FlutterBinaryMessenger) {
    channel = FlutterMethodChannel(name: "bantera/callkit", binaryMessenger: messenger)
    channel?.setMethodCallHandler { [weak self] call, result in
      guard let self else { return result(nil) }
      let args = call.arguments as? [String: Any] ?? [:]
      let id = (args["callId"] as? String).flatMap(UUID.init(uuidString:))
      switch call.method {
      case "ready":
        self.defaults.set(args["userId"] as? String, forKey: "callkit.userId")
        self.ready = true
        let queued = self.events
        self.events.removeAll()
        result(["token": self.token ?? "", "isSandbox": BanteraPushNotificationsBridge.isApnsSandboxEnvironment(), "deviceId": self.deviceId])
        for event in queued { self.channel?.invokeMethod("event", arguments: event) }
      case "setUser":
        self.defaults.set(args["userId"] as? String, forKey: "callkit.userId")
        if args["userId"] as? String == nil {
          for id in Array(self.calls.keys) { self.finish(id, reason: .remoteEnded) }
        }
        result(nil)
      case "token":
        result(["token": self.token ?? "", "isSandbox": BanteraPushNotificationsBridge.isApnsSandboxEnvironment(), "deviceId": self.deviceId])
      case "incoming":
        self.reportIncoming(args, completion: { error in result(error == nil) })
      case "outgoing":
        guard let id else { return result(false) }
        if self.calls[id] != nil { return result(true) }
        self.calls[id] = args
        self.outgoing.insert(id)
        self.prepareAudio()
        let action = CXStartCallAction(call: id, handle: CXHandle(type: .generic, value: args["callerName"] as? String ?? "Bantera"))
        action.isVideo = !Self.isAi(args) && args["mediaKind"] as? String == "video"
        self.controller.request(CXTransaction(action: action)) { error in
          DispatchQueue.main.async {
            if error != nil { self.finish(id, reason: .failed) }
            result(error == nil)
          }
        }
      case "requestAnswer":
        guard let id else { return result(false) }
        self.controller.request(CXTransaction(action: CXAnswerCallAction(call: id))) { error in
          DispatchQueue.main.async { result(error == nil) }
        }
      case "requestMute":
        guard let id else { return result(false) }
        self.controller.request(CXTransaction(action: CXSetMutedCallAction(call: id, muted: args["muted"] as? Bool == true))) { error in
          DispatchQueue.main.async { result(error == nil) }
        }
      case "answerReady":
        if let id, let data = self.calls[id] {
          self.timers.removeValue(forKey: id)?.invalidate()
          self.answers.removeValue(forKey: id)?.fulfill()
          // Activation can precede Dart readiness on a background wake-up.
          if self.audioActive && Self.isAi(data) { self.emit("audioActivated", data) }
        }
        result(nil)
      case "audioStarted":
        if let id { self.endAnswerTask(id) }
        result(nil)
      case "connected":
        if let id, self.outgoing.contains(id), let data = self.calls[id] { self.provider(for: id, data: data).reportOutgoingCall(with: id, connectedAt: Date()) }
        result(nil)
      case "end":
        if let id { self.finish(id, reason: .remoteEnded) }
        result(nil)
      default: result(FlutterMethodNotImplemented)
      }
    }
  }

  private var deviceId: String {
    if let value = defaults.string(forKey: "callkit.deviceId") { return value }
    let value = UUID().uuidString
    defaults.set(value, forKey: "callkit.deviceId")
    return value
  }

  private func emit(_ type: String, _ payload: [String: Any]) {
    var event = payload
    event["event"] = type
    if ready { channel?.invokeMethod("event", arguments: event) }
    else { events.append(event) }
  }

  func pushRegistry(_ registry: PKPushRegistry, didUpdate pushCredentials: PKPushCredentials, for type: PKPushType) {
    guard type == .voIP else { return }
    token = pushCredentials.token.map { String(format: "%02x", $0) }.joined()
    emit("token", [:])
  }

  func pushRegistry(_ registry: PKPushRegistry, didInvalidatePushTokenFor type: PKPushType) {
    guard type == .voIP else { return }
    let oldToken = token
    token = nil
    emit("tokenInvalidated", ["token": oldToken ?? ""])
  }

  func pushRegistry(_ registry: PKPushRegistry, didReceiveIncomingPushWith payload: PKPushPayload,
                    for type: PKPushType, completion: @escaping () -> Void) {
    guard type == .voIP else { completion(); return }
    var data: [String: Any] = [:]
    for (key, value) in payload.dictionaryPayload { if let key = key as? String { data[key] = value } }
    // Report synchronously from the PushKit callback, before Dart or any network work.
    reportIncoming(data, fromPush: true) { _ in completion() }
  }

  private func reportIncoming(_ data: [String: Any], fromPush: Bool = false, completion: @escaping (Error?) -> Void) {
    let parsedId = (data["callId"] as? String).flatMap(UUID.init(uuidString:))
    let id = parsedId ?? UUID()
    if calls[id] != nil && !fromPush { completion(nil); return }
    let duplicate = calls[id] != nil
    let update = Self.callUpdate(for: data)
    let expires = Double(data["expiresAt"] as? String ?? "") ?? Date().addingTimeInterval(45).timeIntervalSince1970
    if !duplicate {
      calls[id] = data
      // Configure before reporting/answering; CallKit alone activates the session.
      prepareAudio()
    }
    provider(for: data).reportNewIncomingCall(with: id, update: update) { [weak self] error in
      DispatchQueue.main.async {
        guard let self else { completion(error); return }
        if duplicate { completion(error); return }
        guard self.calls[id] != nil else { completion(error); return }
        if let error { self.calls.removeValue(forKey: id); self.emit("ended", data); completion(error); return }
        let recipient = data["recipientUserId"] as? String
        let user = self.defaults.string(forKey: "callkit.userId")
        if parsedId == nil || expires <= Date().timeIntervalSince1970 || (recipient != nil && recipient != user) {
          self.finish(id, reason: .unanswered)
          completion(nil)
          return
        }
        self.prepareAudio()
        self.timers[id] = Timer.scheduledTimer(withTimeInterval: min(45, max(1, expires - Date().timeIntervalSince1970)), repeats: false) { [weak self] _ in
          self?.finish(id, reason: .unanswered)
          self?.emit("ended", data)
        }
        self.emit("incoming", data)
        completion(nil)
      }
    }
  }

  private var hasAiCall: Bool {
    calls.values.contains { ($0["callerUserId"] as? String)?.lowercased() == "ba07e2a0-a100-4000-8000-000000000001" }
  }

  private func emitAiAudio(_ event: String) {
    for data in calls.values where (data["callerUserId"] as? String)?.lowercased() == "ba07e2a0-a100-4000-8000-000000000001" {
      emit(event, data)
    }
  }

  private func emitAiRoute() {
    let speaker = AVAudioSession.sharedInstance().currentRoute.outputs.contains { $0.portType == .builtInSpeaker }
    for var data in calls.values where (data["callerUserId"] as? String)?.lowercased() == "ba07e2a0-a100-4000-8000-000000000001" {
      data["speaker"] = speaker
      emit("audioRoute", data)
    }
  }

  deinit {
    if let routeObserver { NotificationCenter.default.removeObserver(routeObserver) }
  }

  private func prepareAudio() {
    let rtc = RTCAudioSession.sharedInstance()
    rtc.useManualAudio = true
    rtc.isAudioEnabled = audioActive && !hasAiCall
    let session = AVAudioSession.sharedInstance()
    // CallKit callbacks use the telephone voice processor in both directions.
    // The newer default-mode hardware AEC path held this iPhone on Speaker even
    // after clearing its output override. Do not use that path for phone calls.
    if hasAiCall, #available(iOS 18.2, *), session.prefersEchoCancelledInput {
      try? session.setPrefersEchoCancelledInput(false)
    }
    try? session.setCategory(.playAndRecord, mode: .voiceChat, options: [.allowBluetoothHFP])
    if hasAiCall { try? session.overrideOutputAudioPort(.none) }
  }

  private func endAnswerTask(_ id: UUID) {
    if let task = answerTasks.removeValue(forKey: id), task != .invalid {
      UIApplication.shared.endBackgroundTask(task)
    }
  }

  private func finish(_ id: UUID, reason: CXCallEndedReason) {
    endAnswerTask(id)
    guard let data = calls.removeValue(forKey: id) else { return }
    if Self.isAi(data) { onAiAudioStopped?() }
    timers.removeValue(forKey: id)?.invalidate()
    answers.removeValue(forKey: id)?.fail()
    outgoing.remove(id)
    let owner = callProviders.removeValue(forKey: id) ?? provider(for: data)
    owner.reportCall(with: id, endedAt: Date(), reason: reason)
    if calls.isEmpty { RTCAudioSession.sharedInstance().useManualAudio = false }
  }

  func providerDidReset(_ provider: CXProvider) {
    let pending = calls.filter { self.provider(for: $0.key, data: $0.value) === provider }
    for id in Array(pending.keys) { finish(id, reason: .failed) }
    for data in pending.values { emit("ended", data) }
  }

  func provider(_ provider: CXProvider, perform action: CXStartCallAction) {
    guard calls[action.callUUID] != nil else { action.fail(); return }
    // CallKit chooses the provider for outgoing transactions. Retain the actual
    // delegate so activation and completion use that provider as well.
    callProviders[action.callUUID] = provider
    prepareAudio()
    provider.reportOutgoingCall(with: action.callUUID, startedConnectingAt: Date())
    action.fulfill()
  }

  func provider(_ provider: CXProvider, perform action: CXAnswerCallAction) {
    guard let data = calls[action.callUUID] else { action.fail(); return }
    answers[action.callUUID] = action
    if Self.isAi(data) {
      endAnswerTask(action.callUUID)
      answerTasks[action.callUUID] = UIApplication.shared.beginBackgroundTask(withName: "AI callback startup") { [weak self] in
        guard let self else { return }
        self.logger.error("Callback startup background time expired")
        self.emit("audioFailed", data)
        self.finish(action.callUUID, reason: .failed)
      }
    }
    prepareAudio()
    emit("answer", data)
    // Fulfilled only after the backend confirms acceptance; CallKit then activates audio.
  }

  func provider(_ provider: CXProvider, perform action: CXEndCallAction) {
    let data = calls[action.callUUID]
    finish(action.callUUID, reason: .remoteEnded)
    action.fulfill()
    if let data { emit("ended", data) }
  }

  func provider(_ provider: CXProvider, perform action: CXSetMutedCallAction) {
    var data = calls[action.callUUID] ?? [:]
    data["callId"] = action.callUUID.uuidString.lowercased()
    data["muted"] = action.isMuted
    emit("mute", data)
    action.fulfill()
  }

  func provider(_ provider: CXProvider, timedOutPerforming action: CXAction) {
    guard let action = action as? CXCallAction, let data = calls[action.callUUID] else { return }
    finish(action.callUUID, reason: .failed)
    emit("ended", data)
  }

  func provider(_ provider: CXProvider, didActivate audioSession: AVAudioSession) {
    guard calls.contains(where: { self.provider(for: $0.key, data: $0.value) === provider }) else { return }
    audioActive = true
    if hasAiCall {
      RTCAudioSession.sharedInstance().isAudioEnabled = false
      do {
        // Start native duplex I/O before returning to iOS. A Dart round trip
        // here can otherwise leave a locked, background call without audio.
        try onAiAudioActivated?()
        logger.info("CallKit AI audio activated and native I/O started")
      } catch {
        logger.error("CallKit AI audio startup failed: code \((error as NSError).code)")
        emitAiAudio("audioFailed")
        let failed = calls.filter { Self.isAi($0.value) }
        for id in failed.keys { finish(id, reason: .failed) }
        return
      }
      emitAiAudio("audioActivated")
      emitAiRoute()
    } else {
      RTCAudioSession.sharedInstance().audioSessionDidActivate(audioSession)
      RTCAudioSession.sharedInstance().isAudioEnabled = true
    }
  }

  func provider(_ provider: CXProvider, didDeactivate audioSession: AVAudioSession) {
    // An idle provider reset must not deactivate the other provider's call.
    guard calls.isEmpty || calls.contains(where: { self.provider(for: $0.key, data: $0.value) === provider }) else { return }
    audioActive = false
    onAiAudioStopped?()
    emitAiAudio("audioDeactivated")
    RTCAudioSession.sharedInstance().isAudioEnabled = false
    RTCAudioSession.sharedInstance().audioSessionDidDeactivate(audioSession)
    if calls.isEmpty { RTCAudioSession.sharedInstance().useManualAudio = false }
  }
}
