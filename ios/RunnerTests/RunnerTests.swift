import AVFoundation
import CallKit
import Flutter
import UIKit
import XCTest
import SwiftUI
import WidgetKit
@testable import Runner

class RunnerTests: XCTestCase {
  func testCallKitRegionPolicyRejectsMainlandChinaAndUnknownRegion() {
    XCTAssertFalse(BanteraCallKitRegionPolicy.allows(storefront: "CHN", deviceRegion: "NZ"))
    XCTAssertFalse(BanteraCallKitRegionPolicy.allows(storefront: "NZL", deviceRegion: "CN"))
    XCTAssertFalse(BanteraCallKitRegionPolicy.allows(storefront: " cn ", deviceRegion: nil))
    XCTAssertFalse(BanteraCallKitRegionPolicy.allows(storefront: nil, deviceRegion: nil))
    XCTAssertFalse(BanteraCallKitRegionPolicy.allows(storefront: "", deviceRegion: " "))
    XCTAssertTrue(BanteraCallKitRegionPolicy.allows(storefront: "NZL", deviceRegion: "NZ"))
    XCTAssertTrue(BanteraCallKitRegionPolicy.allows(storefront: nil, deviceRegion: "NZ"))
    for (store, region) in [("HKG", "HK"), ("MAC", "MO"), ("TWN", "TW")] {
      XCTAssertTrue(BanteraCallKitRegionPolicy.allows(storefront: store, deviceRegion: region))
    }
  }

  @MainActor
  func testChinaPolicyPreventsProvidersAndVoipRegistrationAndHandlesRegionChanges() {
    let bridge = BanteraCallKitBridge(monitorRegions: false)
    XCTAssertFalse(bridge.regionalPolicyResolved)
    XCTAssertFalse(bridge.hasSystemCallProviders)
    XCTAssertFalse(bridge.hasVoipRegistration)
    bridge.applyRegion(storefront: "CHN", deviceRegion: "NZ")
    XCTAssertFalse(bridge.systemCallsAllowed)
    XCTAssertFalse(bridge.hasSystemCallProviders)
    XCTAssertFalse(bridge.hasVoipRegistration)
    bridge.applyRegion(storefront: "NZL", deviceRegion: "NZ")
    XCTAssertTrue(bridge.systemCallsAllowed)
    XCTAssertTrue(bridge.hasSystemCallProviders)
    XCTAssertTrue(bridge.hasVoipRegistration)
    bridge.applyRegion(storefront: "NZL", deviceRegion: "CN")
    XCTAssertFalse(bridge.systemCallsAllowed)
    XCTAssertFalse(bridge.hasSystemCallProviders)
    XCTAssertFalse(bridge.hasVoipRegistration)
  }

  @MainActor
  func testChinaPolicyQueuesStoredTokenForBackendRemoval() {
    let defaults = UserDefaults.standard
    let savedToken = defaults.object(forKey: "callkit.voipToken")
    let savedRevocations = defaults.object(forKey: "callkit.revokedTokens")
    defer {
      defaults.set(savedToken, forKey: "callkit.voipToken")
      defaults.set(savedRevocations, forKey: "callkit.revokedTokens")
    }
    let token = String(repeating: "ab", count: 32)
    defaults.set(token, forKey: "callkit.voipToken")
    defaults.removeObject(forKey: "callkit.revokedTokens")
    let bridge = BanteraCallKitBridge(monitorRegions: false)
    bridge.applyRegion(storefront: "CHN", deviceRegion: "NZ")
    XCTAssertNil(defaults.string(forKey: "callkit.voipToken"))
    XCTAssertEqual(defaults.stringArray(forKey: "callkit.revokedTokens"), [token])
    bridge.applyRegion(storefront: "CHN", deviceRegion: "NZ")
    XCTAssertEqual(defaults.stringArray(forKey: "callkit.revokedTokens"), [token])
  }

  @MainActor
  func testCuePlaybackRestoresMediaCategoryAndModeAfterCall() throws {
    let app = try XCTUnwrap(UIApplication.shared.delegate as? AppDelegate)
    let session = AVAudioSession.sharedInstance()
    for _ in 0..<2 {
      try session.setCategory(.playAndRecord, mode: .voiceChat, options: [.allowBluetoothHFP])
      try app.prepareMediaPlayback()
      XCTAssertEqual(session.category, .playback)
      XCTAssertEqual(session.mode, .default)
      XCTAssertFalse(session.currentRoute.outputs.contains { $0.portType == .builtInReceiver })
    }
  }

  @MainActor
  func testCuePlaybackCannotStealActiveAiCallAudio() throws {
    let app = try XCTUnwrap(UIApplication.shared.delegate as? AppDelegate)
    let audio = try XCTUnwrap(app.aiAudioBridge)
    audio.reserveCallKitAudio()
    defer { audio.stopCallKitAudio() }
    XCTAssertThrowsError(try app.prepareMediaPlayback())
  }

  @MainActor
  func testCallKitReservationSurvivesListenerReplacementAndRejectsPlayback() throws {
    let app = try XCTUnwrap(UIApplication.shared.delegate as? AppDelegate)
    let audio = try XCTUnwrap(app.aiAudioBridge)
    audio.reserveCallKitAudio()
    defer { audio.stopCallKitAudio() }
    XCTAssertThrowsError(try audio.startPlayback())
    _ = audio.onListen(withArguments: nil) { _ in }
    _ = audio.onCancel(withArguments: nil)
    XCTAssertThrowsError(try audio.startPlayback())
  }

  func testAiCallKitIsAudioOnlyAndHumanCallsRetainVideo() {
    XCTAssertFalse(BanteraCallKitBridge.configuration(ai: true).supportsVideo)
    XCTAssertTrue(BanteraCallKitBridge.configuration(ai: false).supportsVideo)
    let ai = BanteraCallKitBridge.callUpdate(for: [
      "callerUserId": "BA07E2A0-A100-4000-8000-000000000001",
      "callerName": "Bantera AI", "mediaKind": "video"
    ])
    XCTAssertFalse(ai.hasVideo)
    XCTAssertEqual(ai.localizedCallerName, "Bantera AI")
    XCTAssertFalse(ai.supportsHolding)
    XCTAssertTrue(BanteraCallKitBridge.callUpdate(for: [
      "callerUserId": "human", "mediaKind": "video"
    ]).hasVideo)
  }
  // Opt-in acoustic check: reports energy only, never stores microphone PCM.
  // Copy a synthetic mono 24 kHz Int16 fixture to Documents/bantera-echo-speech.pcm.
  @MainActor
  func testSpeakerSpeechLeakage() async throws {
    guard ProcessInfo.processInfo.environment["BANTERA_TEST_AUDIO_HARDWARE"] == "1" else {
      throw XCTSkip("Explicit physical-device acoustic test only.")
    }
    let fixture = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
      .appendingPathComponent("bantera-echo-speech.pcm")
    let speech = try Data(contentsOf: fixture)
    let app = try XCTUnwrap(UIApplication.shared.delegate as? AppDelegate)
    let audio = try XCTUnwrap(app.aiAudioBridge)
    var energy = 0.0, samples = 0, peak = 0, loudFrames = 0
    var bins: [Int: Double] = [:]
    var phaseStart = ProcessInfo.processInfo.systemUptime
    var errors: [String] = []
    _ = audio.onListen(withArguments: nil) { event in
      if let error = event as? FlutterError { errors.append(error.code) }
      guard let bytes = event as? FlutterStandardTypedData else { return }
      var framePeak = 0
      var frameEnergy = 0.0
      bytes.data.withUnsafeBytes { raw in
        for offset in stride(from: 0, to: raw.count, by: 2) {
          let value = Int(raw.loadUnaligned(fromByteOffset: offset, as: Int16.self))
          energy += Double(value * value); frameEnergy += Double(value * value); samples += 1
          framePeak = max(framePeak, abs(value))
        }
      }
      let bin = Int((ProcessInfo.processInfo.systemUptime - phaseStart) * 4)
      bins[bin] = max(bins[bin] ?? 0, sqrt(frameEnergy / Double(max(1, bytes.data.count / 2))))
      peak = max(peak, framePeak)
      if framePeak > 900 { loudFrames += 1 }
    }
    defer { _ = audio.onCancel(withArguments: nil) }
    try await Task.sleep(nanoseconds: 1_000_000_000)
    try audio.start()
    for phase in ["quiet", "firstReply", "secondReply", "routeSwitch", "midReplySwitch", "pausedReply", "laterReply"] {
      if phase == "pausedReply" { try await Task.sleep(nanoseconds: 10_000_000_000) }
      if phase == "laterReply" { try await Task.sleep(nanoseconds: 60_000_000_000) }
      if phase == "routeSwitch" {
        XCTAssertFalse(try audio.setSpeaker(false))
        try await Task.sleep(nanoseconds: 500_000_000)
        XCTAssertEqual(AVAudioSession.sharedInstance().currentRoute.outputs.first?.portType, .builtInReceiver)
        XCTAssertTrue(try audio.setSpeaker(true))
        XCTAssertEqual(AVAudioSession.sharedInstance().currentRoute.outputs.first?.portType, .builtInSpeaker)
      }
      energy = 0; samples = 0; peak = 0; loudFrames = 0; bins = [:]; phaseStart = ProcessInfo.processInfo.systemUptime
      if phase != "quiet" { try audio.feed(speech) }
      if phase == "midReplySwitch" {
        try await Task.sleep(nanoseconds: 1_000_000_000)
        XCTAssertFalse(try audio.setSpeaker(false))
        try await Task.sleep(nanoseconds: 250_000_000)
        XCTAssertTrue(try audio.setSpeaker(true))
      }
      let seconds = phase == "quiet" ? 1.0 : Double(speech.count) / 48000 + 0.6
      try await Task.sleep(nanoseconds: UInt64(seconds * 1_000_000_000))
      print("ACOUSTIC \(phase) rms=\(sqrt(energy / Double(max(1, samples)))) peak=\(peak) loudFrames=\(loudFrames) \(audio.diagnostics)")
      print("ACOUSTIC BINS \(phase) \(bins.sorted { $0.key < $1.key })")
      XCTAssertGreaterThan(samples, 10000)
      XCTAssertEqual(AVAudioSession.sharedInstance().currentRoute.outputs.first?.portType, .builtInSpeaker,
        "Route must remain on speaker throughout \(phase): \(audio.diagnostics)")
      XCTAssertTrue(errors.isEmpty, errors.joined(separator: ","))
      if ProcessInfo.processInfo.environment["BANTERA_ASSERT_QUIET_ROOM"] == "1" {
        XCTAssertLessThanOrEqual(loudFrames, 5, "Speaker leakage in \(phase): \(audio.diagnostics)")
      }
    }
  }

  @MainActor
  func testAiAudioCapturesAndPlaysAfterSpeakerSwitch() async throws {
    guard ProcessInfo.processInfo.environment["BANTERA_TEST_AUDIO_HARDWARE"] == "1" else {
      throw XCTSkip("Requires an unlocked physical iPhone with microphone permission and BANTERA_TEST_AUDIO_HARDWARE=1.")
    }
    let app = try XCTUnwrap(UIApplication.shared.delegate as? AppDelegate)
    let audio = try XCTUnwrap(app.aiAudioBridge)
    var frames = 0
    var errors: [String] = []
    _ = audio.onListen(withArguments: nil) { event in
      if let bytes = event as? FlutterStandardTypedData { frames += bytes.data.count / 2 }
      if let error = event as? FlutterError { errors.append(error.code) }
    }
    defer { _ = audio.onCancel(withArguments: nil) }
    // Wait for the test host to be active before requesting duplex audio.
    try await Task.sleep(nanoseconds: 2_000_000_000)
    try audio.start()
    try await Task.sleep(nanoseconds: 2_000_000_000)
    XCTAssertGreaterThan(frames, 16000, audio.diagnostics)
    var tone = Data()
    for i in 0..<24000 {
      var sample = Int16(sin(Double(i) * 2 * Double.pi * 440 / 24000) * 2000).littleEndian
      withUnsafeBytes(of: &sample) { tone.append(contentsOf: $0) }
    }
    try audio.feed(tone)
    try await Task.sleep(nanoseconds: 2_000_000_000)
    XCTAssertTrue(audio.diagnostics.contains("playedFrames=24000"), audio.diagnostics)
    XCTAssertTrue(audio.diagnostics.contains("echoCancellation=true"), audio.diagnostics)
    audio.clear()
    let previous = frames
    try AVAudioSession.sharedInstance().overrideOutputAudioPort(.none)
    try await Task.sleep(nanoseconds: 1_000_000_000)
    try AVAudioSession.sharedInstance().overrideOutputAudioPort(.speaker)
    try await Task.sleep(nanoseconds: 2_000_000_000)
    XCTAssertGreaterThan(frames - previous, 16000, audio.diagnostics)
    XCTAssertTrue(errors.isEmpty, "\(errors) \(audio.diagnostics)")
  }
}


// These tests resample in-memory PCM only. They never start an audio unit,
// activate an audio session, or require microphone permission.
final class AiAudioRateTests: XCTestCase {
  let rates = [8000.0, 16000.0, 24000.0, 44100.0, 48000.0]
  func pcm(_ frames: Int, rate: Double, start: Int = 0) -> Data {
    var samples = [Int16](repeating: 0, count: frames)
    for index in samples.indices { samples[index] = Int16(sin(Double(start + index) * 2 * .pi * 440 / rate) * 5000) }
    return samples.withUnsafeBytes { Data($0) }
  }
  func testFragmentedPlaybackConvertsEveryFrame() throws {
    for rate in rates {
      let converter = try BanteraPhoneAudio.PcmConverter(from: 24000, to: rate)
      var input = 0, output = 0
      for n in [101,777,240,137,400,733,1024,380,2000,10000,8208] {
        output += try converter.convert(pcm(n, rate: 24000, start: input)).count / 2
        input += n
      }
      XCTAssertEqual(input, 24000)
      XCTAssertEqual(output, Int(rate), "rate \(rate)")
    }
  }
  func testOneLargePacketDoesNotTruncate() throws {
    for rate in rates {
      let converter = try BanteraPhoneAudio.PcmConverter(from: 24000, to: rate)
      XCTAssertEqual(try converter.convert(pcm(24000 * 6, rate: 24000)).count / 2, Int(rate * 6))
    }
  }
  func testCaptureStaysAt16kAcrossHardwareRates() throws {
    for rate in rates {
      let converter = try BanteraPhoneAudio.PcmConverter(from: rate, to: 16000)
      var input = 0, output = 0
      while input < Int(rate) {
        let n = min(127, Int(rate) - input)
        output += try converter.convert(pcm(n, rate: rate, start: input)).count / 2
        input += n
      }
      XCTAssertEqual(output, 16000, "rate \(rate)")
    }
  }
  func testAccountingPreservesSourceFramesAcrossRateChange() throws {
    var progress = BanteraPhoneAudio.PlaybackProgress()
    progress.enqueue(24000)
    progress.render(24000, sampleRate: 48000, drained: false)
    XCTAssertEqual(progress.frames, 12000)
    let queued = pcm(24000, rate: 48000)
    let newRoute = try BanteraPhoneAudio.PcmConverter(from: 48000, to: 16000).convert(queued)
    XCTAssertEqual(newRoute.count / 2, 8000)
    progress.render(4000, sampleRate: 16000, drained: false)
    XCTAssertEqual(progress.frames, 18000)
    progress.render(4000, sampleRate: 16000, drained: true)
    XCTAssertEqual(progress.frames, 24000)
  }
  func testInterruptionDiscardsOnlyUnplayedFrames() {
    var progress = BanteraPhoneAudio.PlaybackProgress()
    progress.enqueue(24000)
    progress.render(4800, sampleRate: 48000, drained: false)
    progress.clear()
    progress.enqueue(24000)
    progress.render(16000, sampleRate: 16000, drained: true)
    XCTAssertEqual(progress.frames, 26400)
  }
  func testFractionalAccountingAndConverterReset() throws {
    var progress = BanteraPhoneAudio.PlaybackProgress()
    progress.enqueue(24000)
    for _ in 0..<440 { progress.render(100, sampleRate: 44100, drained: false) }
    progress.render(100, sampleRate: 44100, drained: true)
    XCTAssertEqual(progress.frames, 24000)
    let converter = try BanteraPhoneAudio.PcmConverter(from: 24000, to: 48000)
    _ = try converter.convert(pcm(24000, rate: 24000))
    converter.reset()
    let silence = try converter.convert(Data(count: 480))
    XCTAssertEqual(silence, Data(count: 960))
    XCTAssertTrue(try converter.convert(Data()).isEmpty)
  }
}

class PracticeWidgetTests: XCTestCase {
  func testMidnightAndSignOutNeverShowOldCounts() {
    var calendar = Calendar(identifier: .gregorian)
    calendar.timeZone = TimeZone(identifier: "Pacific/Auckland")!
    let today = calendar.date(from: DateComponents(year: 2026, month: 10, day: 8, hour: 23, minute: 59))!
    let tomorrow = calendar.date(byAdding: .minute, value: 2, to: today)!
    var snapshot = BanteraPracticeSnapshot(dateKey: "2026-10-08", signedIn: true,
      spoken: 128, listened: 640, locale: "en", labels: [:])
    XCTAssertEqual(snapshot.forDate(today, calendar: calendar).spoken, 128)
    var buddhist = Calendar(identifier: .buddhist)
    buddhist.timeZone = calendar.timeZone
    XCTAssertEqual(snapshot.forDate(today, calendar: buddhist).spoken, 128)
    XCTAssertEqual(snapshot.forDate(tomorrow, calendar: calendar).spoken, 0)
    XCTAssertEqual(snapshot.forDate(tomorrow, calendar: calendar).listened, 0)
    snapshot.signedIn = false
    XCTAssertEqual(snapshot.forDate(today, calendar: calendar).spoken, 0)
  }

  func testWidgetDeepLinkOnlyAcceptsChatDestination() {
    XCTAssertTrue(BanteraPracticeSnapshot.isChatURL(URL(string: "bantera://ai-chat")!))
    for raw in ["https://ai-chat", "bantera://other", "bantera://ai-chat/call", "bantera://ai-chat?call=true", "bantera://user@ai-chat"] {
      XCTAssertFalse(BanteraPracticeSnapshot.isChatURL(URL(string: raw)!))
    }
  }

  @MainActor
  func testRenderSmallAndMediumPracticeWidgets() throws {
    let snapshot = BanteraPracticeSnapshot(dateKey: BanteraPracticeSnapshot.dayKey(Date()),
      signedIn: true, spoken: 1278, listened: 3257, locale: "en", labels: [
        "today": "Today", "words": "Words", "spoken": "Speaking", "listened": "Listening", "chat": "Bantera AI"
      ])
    for (name, family, size) in [
      ("small", WidgetFamily.systemSmall, CGSize(width: 170, height: 170)),
      ("medium", WidgetFamily.systemMedium, CGSize(width: 364, height: 170))
    ] {
      for dark in [false, true] {
        let view = BanteraPracticeWidgetView(snapshot: snapshot, family: family)
          .environment(\.colorScheme, dark ? .dark : .light)
          .padding(16)
          .frame(width: size.width, height: size.height)
          .background(dark ? Color.black : Color.white)
        let renderer = ImageRenderer(content: view)
        renderer.scale = 3
        let image = try XCTUnwrap(renderer.uiImage)
        XCTAssertEqual(image.size.width, size.width)
        let attachment = XCTAttachment(image: image)
        attachment.name = "practice-widget-\(name)-\(dark ? "dark" : "light")"
        attachment.lifetime = .keepAlways
        add(attachment)
        let directory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        try image.pngData()!.write(to: directory.appendingPathComponent("\(attachment.name!).png"))
      }
    }
  }
}

// Pure signal tests: no audio session, microphone, speaker or device access.
final class BanteraEchoGuardTests: XCTestCase {
  private func source(_ frame: Int) -> Int16 {
    let t = Double(frame) / 48000
    let envelope = 0.65 + 0.3 * sin(t * 17)
    return Int16(envelope * (5000 * sin(t * 2 * .pi * 187) + 3300 * sin(t * 2 * .pi * 613) + 1700 * sin(t * 2 * .pi * 1091)))
  }
  private func run(speaker: Bool = true, delay: Int = 3840, echo: Double = 0.3,
                   voice: Double = 0, chunks: Int = 60, highFrequency: Double? = nil) -> (suppressed: Int, original: Int) {
    let guarder = BanteraEchoGuard(startupProtectionMilliseconds: 0)
    var suppressed = 0, original = 0
    for chunk in 0..<chunks {
      let render = (0..<960).map { source(chunk * 960 + $0) }
      render.withUnsafeBufferPointer { guarder.appendRender($0, sampleRate: 48000) }
      let microphone: [Int16] = (0..<320).map { offset in
        let frame = chunk * 960 + offset * 3 - delay
        let rendered = frame < 0 ? 0 : (0..<3).reduce(0.0) { $0 + Double(source(frame + $1)) } / 3
        let time = Double(chunk * 320 + offset) / 16000
        let user = highFrequency.map { voice * sin(time * 2 * .pi * $0) } ??
          voice * (sin(time * 2 * .pi * 283) + 0.5 * sin(time * 2 * .pi * 853))
        return Int16(rendered * echo + user)
      }
      let input = microphone.withUnsafeBytes { Data($0) }
      let output = guarder.processCapture(input, speaker: speaker)
      if input.contains(where: { $0 != 0 }) && !output.contains(where: { $0 != 0 }) { suppressed += 1 }
      if output == input { original += 1 }
    }
    return (suppressed, original)
  }
  func testDelayedScaledOwnOutputIsSuppressed() {
    for delay in [960, 3840, 9600, 14400] {
      XCTAssertGreaterThan(run(delay: delay).suppressed, 35, "delay=\(delay)")
    }
  }
  func testIndependentSpeechIncludingQuietSpeechPasses() {
    for amplitude in [35.0, 200.0, 2000.0] {
      XCTAssertEqual(run(echo: 0, voice: amplitude).original, 60)
    }
  }
  func testDoubleTalkIsPreserved() {
    for amplitude in [80.0, 300.0, 2000.0] {
      XCTAssertEqual(run(voice: amplitude).original, 60)
    }
  }
  func testReceiverAndHeadphonesNeverUseGuard() {
    XCTAssertEqual(run(speaker: false).original, 60)
  }
  func testResetDiscardsOldRouteReferenceAndSilencePasses() {
    let guarder = BanteraEchoGuard(startupProtectionMilliseconds: 0)
    let render = (0..<24000).map(source)
    render.withUnsafeBufferPointer { guarder.appendRender($0, sampleRate: 48000) }
    guarder.reset()
    let input = render.suffix(1280).withUnsafeBytes { Data($0) }
    XCTAssertEqual(guarder.processCapture(input, speaker: true), input)
    let silence = Data(count: 640)
    XCTAssertEqual(guarder.processCapture(silence, speaker: true), silence)
  }
  func testNewUserSyllableIsNotErasedByPreviousEchoWindow() {
    let guarder = BanteraEchoGuard(startupProtectionMilliseconds: 0)
    for chunk in 0..<30 {
      let rendered = (0..<960).map { source(chunk * 960 + $0) }
      rendered.withUnsafeBufferPointer { guarder.appendRender($0, sampleRate: 48000) }
      let microphone: [Int16] = (0..<320).map { offset in
        let frame = chunk * 960 + offset * 3 - 3840
        let echo = frame < 0 ? 0 : (0..<3).reduce(0.0) { $0 + Double(source(frame + $1)) } / 10
        let user = chunk == 29 ? 120 * sin(Double(offset) * 2 * .pi * 283 / 16000) : 0
        return Int16(echo + user)
      }
      let input = microphone.withUnsafeBytes { Data($0) }
      let output = guarder.processCapture(input, speaker: true)
      if chunk == 29 { XCTAssertEqual(output, input) }
    }
  }

  func testStartupProtectionIsBoundedAndDoesNotRestartForReplies() {
    let guarder = BanteraEchoGuard()
    let microphone = (0..<320).map { Int16(500 * sin(Double($0) * 2 * .pi * 283 / 16000)) }
    let input = microphone.withUnsafeBytes { Data($0) }
    func render(_ chunk: Int, silent: Bool = false) {
      let samples = (0..<960).map { silent ? Int16(0) : source(chunk * 960 + $0) }
      samples.withUnsafeBufferPointer { guarder.appendRender($0, sampleRate: 48000) }
    }
    // Silent route warmup does not consume the first audible-output protection.
    for chunk in 0..<20 { render(chunk, silent: true) }
    XCTAssertEqual(guarder.processCapture(input, speaker: true), input)
    render(20)
    XCTAssertEqual(guarder.processCapture(input, speaker: true), Data(count: input.count))
    // Rendering ahead cannot consume protection before capture catches up.
    for chunk in 21..<51 { render(chunk, silent: true) }
    for _ in 1..<25 {
      XCTAssertEqual(guarder.processCapture(input, speaker: true), Data(count: input.count))
    }
    XCTAssertEqual(guarder.processCapture(input, speaker: true), input)
    render(31)
    XCTAssertEqual(guarder.processCapture(input, speaker: true), input)
    guarder.reset()
    render(32)
    XCTAssertEqual(guarder.processCapture(input, speaker: true), Data(count: input.count))
    XCTAssertEqual(guarder.processCapture(input, speaker: false), input)
  }

  func testStartupGuardHasAHardBoundAndLeavesLaterSpeechIntact() {
    let guarder = BanteraEchoGuard(startupProtectionMilliseconds: 2500)
    let rendered = [Int16](repeating: 2000, count: 48000)
    rendered.withUnsafeBufferPointer { guarder.appendRender($0, sampleRate: 48000) }
    let input = (0..<43200).map { Int16(1000 * sin(Double($0) * 0.17)) }.withUnsafeBytes { Data($0) }
    let output = guarder.processCapture(input, speaker: true)
    XCTAssertEqual(output.prefix(80000), Data(count: 80000))
    XCTAssertEqual(output.suffix(6400), input.suffix(6400))
    XCTAssertEqual(guarder.processCapture(input, speaker: true), input)
  }

  func testIdleRearmsOnlyOnSpeakerAudioAndKeepsIdleMicrophoneOpen() {
    let guarder = BanteraEchoGuard(startupProtectionMilliseconds: 2500)
    func render(_ value: Int16, seconds: Int) {
      let samples = [Int16](repeating: value, count: 4000 * seconds)
      samples.withUnsafeBufferPointer { guarder.appendRender($0, sampleRate: 4000) }
    }
    let input = (0..<40000).map { Int16(500 * sin(Double($0) * 0.17)) }.withUnsafeBytes { Data($0) }
    render(1000, seconds: 1)
    XCTAssertEqual(guarder.processCapture(input, speaker: true), Data(count: input.count))
    render(0, seconds: 1)
    render(1000, seconds: 1)
    XCTAssertEqual(guarder.processCapture(input, speaker: true), input)
    render(0, seconds: 2)
    XCTAssertEqual(guarder.processCapture(input, speaker: true), input)
    render(1000, seconds: 1)
    XCTAssertEqual(guarder.processCapture(input, speaker: true), Data(count: input.count))
    XCTAssertEqual(guarder.processCapture(input, speaker: true), input)
  }

  func testStartupProtectsOnlyBoundedCaptureSamplesEvenForLargeChunks() {
    let guarder = BanteraEchoGuard()
    let render = [Int16](repeating: 1000, count: 48000)
    render.withUnsafeBufferPointer { guarder.appendRender($0, sampleRate: 48000) }
    let input = [Int16](repeating: 500, count: 16000).withUnsafeBytes { Data($0) }
    let output = guarder.processCapture(input, speaker: true)
    XCTAssertEqual(output.prefix(16000), Data(count: 16000))
    XCTAssertEqual(output.suffix(16000), input.suffix(16000))
    XCTAssertTrue(guarder.diagnostics.contains("startupGuardFrames=8000"))
  }

  // Deterministic, amplitude-modulated broadband audio with syllable gaps. Unlike
  // the periodic-tone fixtures above, each window contains fresh random energy.
  private func broadbandSignal() -> [Int16] {
    var seed: UInt64 = 42
    var filtered = 0.0
    return (0..<(16000 * 3)).map { index in
      seed = seed &* 6364136223846793005 &+ 1
      let random = Double(Int32(bitPattern: UInt32(truncatingIfNeeded: seed >> 32))) / Double(Int32.max)
      filtered = 0.55 * filtered + 0.45 * random
      let syllable = index % 4800
      let envelope = syllable < 4000 ? 0.45 + 0.5 * sin(Double(syllable) * .pi / 4000) : 0.1
      return Int16(filtered * envelope * 17000)
    }
  }

  private func runFiltered(voice: Double = 0, newSyllable: Bool = false, frequency: Double? = nil, captureFrames: Int = 320) -> (suppressed: Int, original: Int, last: Bool) {
    let guarder = BanteraEchoGuard(startupProtectionMilliseconds: 0)
    let signal = broadbandSignal()
    var suppressed = 0, original = 0, last = false
    func sample(_ index: Int) -> Double { index >= 0 && index < signal.count ? Double(signal[index]) : 0 }
    for chunk in 0..<100 {
      let rendered = (0..<(captureFrames * 3)).map { signal[chunk * captureFrames + $0 / 3] }
      rendered.withUnsafeBufferPointer { guarder.appendRender($0, sampleRate: 48000) }
      let microphone = (0..<captureFrames).map { offset -> Int16 in
        let frame = chunk * captureFrames + offset - 1280
        // A changed direct spectrum plus two early reflections. Scalar gain or
        // one relaxed correlation threshold cannot identify this as exact echo.
        let echo = 0.28 * sample(frame) + 0.12 * sample(frame - 16) - 0.08 * sample(frame - 28)
        let t = Double(chunk * captureFrames + offset) / 16000
        let talking = !newSyllable || chunk == 99
        let human: Double
        if !talking { human = 0 }
        else if let frequency {
          human = frequency == 0 ? voice * sample(frame + 10000) / 3000 : voice * sin(t * 2 * .pi * frequency)
        } else { human = voice * (sin(t * 2 * .pi * 283) + 0.5 * sin(t * 2 * .pi * 853)) }
        return Int16(echo + human)
      }
      let input = microphone.withUnsafeBytes { Data($0) }
      let output = guarder.processCapture(input, speaker: true)
      if input.contains(where: { $0 != 0 }) && !output.contains(where: { $0 != 0 }) { suppressed += 1 }
      if output == input { original += 1 }
      if chunk == 99 { last = output == input }
    }
    return (suppressed, original, last)
  }

  func testFrequencyColouredBroadbandEchoIsSuppressed() {
    for frames in [160, 320] {
      XCTAssertGreaterThan(runFiltered(captureFrames: frames).suppressed, 75, "frames=\(frames)")
    }
  }
  func testFilteredEchoDoesNotSuppressQuietDoubleTalk() {
    for frames in [160, 320] {
      for amplitude in [35.0, 80.0, 300.0, 2000.0] {
        XCTAssertEqual(runFiltered(voice: amplitude, captureFrames: frames).original, 100,
          "voice=\(amplitude) frames=\(frames)")
      }
    }
  }
  func testFilteredEchoCannotFitAwayFirstNewUserSyllable() {
    for frames in [160, 320] {
      XCTAssertTrue(runFiltered(voice: 120, newSyllable: true, captureFrames: frames).last)
    }
  }

  func testFullBandIndependentSpeechCannotBeHiddenByAnalysisDownsampling() {
    for frequency in [3900.0, 4000.0, 4100.0, 6000.0] {
      XCTAssertEqual(run(voice: 120, highFrequency: frequency).original, 60, "scalar frequency=\(frequency)")
      for frames in [160, 320] {
        XCTAssertTrue(runFiltered(voice: 120, newSyllable: true, frequency: frequency, captureFrames: frames).last,
          "filtered frequency=\(frequency) frames=\(frames)")
      }
    }
    XCTAssertTrue(runFiltered(voice: 35, newSyllable: true, frequency: 0).last,
      "quiet independent broadband speech")
  }

}

final class BanteraAudioReadinessTests: XCTestCase {
  func testFirstBufferOrElapsedTimeAloneCannotStartCall() {
    var gate = BanteraAudioReadiness()
    gate.reset(now: 10)
    gate.capture(frames: 320, now: 10.02, echoEnabled: true, rendered: true)
    XCTAssertFalse(gate.ready)
    gate.capture(frames: 320, now: 11, echoEnabled: true, rendered: true)
    XCTAssertFalse(gate.ready)
    gate.capture(frames: 5760, now: 11.1, echoEnabled: true, rendered: false)
    XCTAssertFalse(gate.ready)
    gate.capture(frames: 320, now: 11.12, echoEnabled: true, rendered: true)
    XCTAssertTrue(gate.ready)
  }
  func testRouteOrDisabledProcessingRequiresNewStableCapture() {
    var gate = BanteraAudioReadiness()
    gate.reset(now: 10)
    gate.capture(frames: 6400, now: 10.4, echoEnabled: true, rendered: true)
    XCTAssertTrue(gate.ready)
    gate.capture(frames: 320, now: 10.5, echoEnabled: false, rendered: true)
    XCTAssertFalse(gate.ready)
    gate.capture(frames: 6400, now: 10.9, echoEnabled: true, rendered: true)
    XCTAssertTrue(gate.ready)
    gate.reset(now: 11)
    XCTAssertFalse(gate.ready)
    XCTAssertFalse(gate.timedOut(now: 12))
    XCTAssertTrue(gate.timedOut(now: 17))
  }
}
