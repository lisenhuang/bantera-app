import AppIntents
import Flutter
import Foundation

// App Intents can run before Flutter subscribes during a cold launch.
final class BanteraVoiceShortcut: NSObject, FlutterStreamHandler {
  static let shared = BanteraVoiceShortcut()
  private var sink: FlutterEventSink?
  private var pending: Int64?

  func attach(messenger: FlutterBinaryMessenger) {
    if #available(iOS 16.0, *) {
      BanteraAppShortcuts.updateAppShortcutParameters()
    }
    FlutterEventChannel(name: "bantera/voice_shortcut", binaryMessenger: messenger)
      .setStreamHandler(self)
  }

  func request() {
    let timestamp = Int64(Date().timeIntervalSince1970 * 1000)
    if let sink {
      sink(timestamp)
    } else {
      pending = timestamp
    }
  }

  func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
    sink = events
    if let pending {
      self.pending = nil
      events(pending)
    }
    return nil
  }

  func onCancel(withArguments arguments: Any?) -> FlutterError? {
    sink = nil
    return nil
  }
}

@available(iOS 16.0, *)
struct StartBanteraConversationIntent: AppIntent {
  static var title: LocalizedStringResource = "Talk to Bantera AI"
  static var description = IntentDescription("Start a live voice conversation with Bantera AI.")
  static var openAppWhenRun: Bool { true }
  @available(iOS 26.0, *)
  static var supportedModes: IntentModes { .foreground }
  static var authenticationPolicy: IntentAuthenticationPolicy { .requiresLocalDeviceAuthentication }

  @MainActor
  func perform() async throws -> some IntentResult {
    BanteraVoiceShortcut.shared.request()
    return .result()
  }
}

@available(iOS 16.0, *)
struct BanteraAppShortcuts: AppShortcutsProvider {
  static var appShortcuts: [AppShortcut] {
    AppShortcut(
      intent: StartBanteraConversationIntent(),
      phrases: ["Talk to \(.applicationName) AI"],
      shortTitle: "Talk to Bantera AI",
      systemImageName: "waveform"
    )
  }
}
