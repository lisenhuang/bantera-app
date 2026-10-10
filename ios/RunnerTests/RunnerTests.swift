import AVFoundation
import CallKit
import Flutter
import UIKit
import XCTest
import SwiftUI
import WidgetKit
@testable import Runner

class RunnerTests: XCTestCase {
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
