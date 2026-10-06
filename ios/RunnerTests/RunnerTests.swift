import AVFoundation
import Flutter
import UIKit
import XCTest
@testable import Runner

class RunnerTests: XCTestCase {
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
