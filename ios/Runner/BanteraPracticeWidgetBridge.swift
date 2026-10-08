import Flutter
import Foundation
import WidgetKit

final class BanteraPracticeWidgetBridge {
  private let channel: FlutterMethodChannel
  private var pendingOpen = false
  private var lastData: Data?

  init(messenger: FlutterBinaryMessenger) {
    channel = FlutterMethodChannel(name: "bantera/practice_widget", binaryMessenger: messenger)
    channel.setMethodCallHandler { [weak self] call, result in
      guard let self else { result(nil); return }
      switch call.method {
      case "takePendingOpen":
        let pending = self.pendingOpen
        self.pendingOpen = false
        result(pending)
      case "update":
        do {
          guard let args = call.arguments as? [String: Any],
                JSONSerialization.isValidJSONObject(args),
                let url = BanteraPracticeSnapshot.fileURL else {
            result(FlutterError(code: "widget_unavailable", message: "Shared widget container unavailable", details: nil))
            return
          }
          let raw = try JSONSerialization.data(withJSONObject: args)
          let snapshot = try JSONDecoder().decode(BanteraPracticeSnapshot.self, from: raw)
          let encoder = JSONEncoder()
          encoder.outputFormatting = .sortedKeys
          let data = try encoder.encode(snapshot)
          if data != self.lastData {
            try data.write(to: url, options: [.atomic, .completeFileProtectionUntilFirstUserAuthentication])
            self.lastData = data
            WidgetCenter.shared.reloadTimelines(ofKind: BanteraPracticeSnapshot.kind)
          }
          result(nil)
        } catch {
          result(FlutterError(code: "widget_update_failed", message: "Unable to update practice widget", details: nil))
        }
      default: result(FlutterMethodNotImplemented)
      }
    }
  }

  @discardableResult func open(_ url: URL) -> Bool {
    guard BanteraPracticeSnapshot.isChatURL(url) else { return false }
    pendingOpen = true
    channel.invokeMethod("openChat", arguments: nil)
    return true
  }
}
