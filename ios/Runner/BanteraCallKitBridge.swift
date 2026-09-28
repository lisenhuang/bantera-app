import AVFoundation
import CallKit
import Flutter
import PushKit
import WebRTC

/// Owns system calls independently of a Flutter view, including locked-screen launches.
final class BanteraCallKitBridge: NSObject, PKPushRegistryDelegate, CXProviderDelegate {
  private let provider: CXProvider
  private let controller = CXCallController()
  private var registry: PKPushRegistry!
  private var channel: FlutterMethodChannel?
  private var ready = false
  private var events: [[String: Any]] = []
  private var calls: [UUID: [String: Any]] = [:]
  private var timers: [UUID: Timer] = [:]
  private var answers: [UUID: CXAnswerCallAction] = [:]
  private var outgoing = Set<UUID>()
  private var token: String?
  private var audioActive = false
  private let defaults = UserDefaults.standard

  override init() {
    let config = CXProviderConfiguration()
    config.supportsVideo = true
    config.includesCallsInRecents = false
    config.maximumCallGroups = 1
    config.maximumCallsPerCallGroup = 1
    config.supportedHandleTypes = [.generic]
    provider = CXProvider(configuration: config)
    super.init()
    provider.setDelegate(self, queue: .main)
    registry = PKPushRegistry(queue: .main)
    registry.delegate = self
    registry.desiredPushTypes = [.voIP]
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
        action.isVideo = args["mediaKind"] as? String == "video"
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
      case "answerReady":
        if let id { self.timers.removeValue(forKey: id)?.invalidate(); self.answers.removeValue(forKey: id)?.fulfill() }
        result(nil)
      case "connected":
        if let id, self.outgoing.contains(id) { self.provider.reportOutgoingCall(with: id, connectedAt: Date()) }
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
    let update = CXCallUpdate()
    update.remoteHandle = CXHandle(type: .generic, value: data["callerUserId"] as? String ?? "Bantera")
    update.localizedCallerName = data["callerName"] as? String ?? "Bantera"
    update.hasVideo = data["mediaKind"] as? String == "video"
    update.supportsHolding = false
    update.supportsGrouping = false
    update.supportsUngrouping = false
    update.supportsDTMF = false
    let expires = Double(data["expiresAt"] as? String ?? "") ?? Date().addingTimeInterval(45).timeIntervalSince1970
    if !duplicate { calls[id] = data }
    provider.reportNewIncomingCall(with: id, update: update) { [weak self] error in
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

  private func prepareAudio() {
    let rtc = RTCAudioSession.sharedInstance()
    rtc.useManualAudio = true
    rtc.isAudioEnabled = audioActive
    try? AVAudioSession.sharedInstance().setCategory(.playAndRecord, mode: .voiceChat, options: [.allowBluetoothHFP])
  }

  private func finish(_ id: UUID, reason: CXCallEndedReason) {
    guard calls.removeValue(forKey: id) != nil else { return }
    timers.removeValue(forKey: id)?.invalidate()
    answers.removeValue(forKey: id)?.fail()
    outgoing.remove(id)
    provider.reportCall(with: id, endedAt: Date(), reason: reason)
    if calls.isEmpty { RTCAudioSession.sharedInstance().useManualAudio = false }
  }

  func providerDidReset(_ provider: CXProvider) {
    let pending = calls
    for id in Array(calls.keys) { finish(id, reason: .failed) }
    for data in pending.values { emit("ended", data) }
  }

  func provider(_ provider: CXProvider, perform action: CXStartCallAction) {
    guard calls[action.callUUID] != nil else { action.fail(); return }
    prepareAudio()
    provider.reportOutgoingCall(with: action.callUUID, startedConnectingAt: Date())
    action.fulfill()
  }

  func provider(_ provider: CXProvider, perform action: CXAnswerCallAction) {
    guard let data = calls[action.callUUID] else { action.fail(); return }
    answers[action.callUUID] = action
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
    emit("mute", ["callId": action.callUUID.uuidString.lowercased(), "muted": action.isMuted])
    action.fulfill()
  }

  func provider(_ provider: CXProvider, timedOutPerforming action: CXAction) {
    guard let action = action as? CXCallAction, let data = calls[action.callUUID] else { return }
    finish(action.callUUID, reason: .failed)
    emit("ended", data)
  }

  func provider(_ provider: CXProvider, didActivate audioSession: AVAudioSession) {
    audioActive = true
    RTCAudioSession.sharedInstance().audioSessionDidActivate(audioSession)
    RTCAudioSession.sharedInstance().isAudioEnabled = true
  }

  func provider(_ provider: CXProvider, didDeactivate audioSession: AVAudioSession) {
    audioActive = false
    RTCAudioSession.sharedInstance().isAudioEnabled = false
    RTCAudioSession.sharedInstance().audioSessionDidDeactivate(audioSession)
    if calls.isEmpty { RTCAudioSession.sharedInstance().useManualAudio = false }
  }
}
