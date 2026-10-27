import Flutter
import Foundation
import WidgetKit
import SwiftUI
import UIKit

final class BanteraPracticeWidgetBridge {
  private let channel: FlutterMethodChannel
  private var pendingOpen = false
  private var lastData: Data?

  init(messenger: FlutterBinaryMessenger) {
    channel = FlutterMethodChannel(name: "bantera/practice_widget", binaryMessenger: messenger)
    channel.setMethodCallHandler { [weak self] call, result in
      guard let self else { result(nil); return }
      switch call.method {
      case "hasConfiguredWidgets":
        Self.recordDiscovery(["phase": "checking"])
        WidgetCenter.shared.getCurrentConfigurations { configurations in
          DispatchQueue.main.async {
            switch configurations {
            case .success(let widgets):
              Self.recordDiscovery(["phase": "completed", "count": widgets.count,
                "kinds": widgets.map(\.kind), "families": widgets.map { String(describing: $0.family) }])
              result(!widgets.isEmpty)
            case .failure(let error):
              let nsError = error as NSError
              Self.recordDiscovery(["phase": "failed", "domain": nsError.domain, "code": nsError.code])
              result(FlutterError(code: "widget_detection_failed", message: "Widget configuration unavailable", details: nil))
            }
          }
        }
      case "isPad":
        result(UIDevice.current.userInterfaceIdiom == .pad)
      case "preview":
        guard let args = call.arguments as? [String: Any] else { result(nil); return }
        DispatchQueue.main.async {
          result(Self.preview(arguments: args).map { FlutterStandardTypedData(bytes: $0) })
        }
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


extension BanteraPracticeWidgetBridge {
  /// Last discovery outcome only, local to the app; no personal data or uploads.
  private static func recordDiscovery(_ details: [String: Any]) {
    guard let directory = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first else { return }
    var record = details
    record["at"] = ISO8601DateFormatter().string(from: Date())
    do {
      try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
      try JSONSerialization.data(withJSONObject: record, options: [.sortedKeys])
        .write(to: directory.appendingPathComponent("widget-discovery-native.json"), options: [.atomic, .completeFileProtectionUntilFirstUserAuthentication])
    } catch { /* Optional diagnostics never affect WidgetKit or app startup. */ }
  }

  /// Renders the very same SwiftUI view as the extension, with example data.
  /// UIHostingController keeps this available on iOS 15 as well as newer iOS.
  @MainActor static func preview(arguments: [String: Any]) -> Data? {
    let name = arguments["size"] as? String ?? "medium"
    let family: WidgetFamily = name == "small" ? .systemSmall : name == "large" ? .systemLarge : name == "extraLarge" ? .systemExtraLarge : .systemMedium
    let size = name == "small" ? CGSize(width: 170, height: 170) : name == "large" ? CGSize(width: 364, height: 382) : name == "extraLarge" ? CGSize(width: 748, height: 382) : CGSize(width: 364, height: 170)
    let dark = arguments["dark"] as? Bool ?? false
    let snapshot = BanteraPracticeSnapshot(dateKey: BanteraPracticeSnapshot.dayKey(Date()),
      signedIn: true, spoken: 128, listened: 640, locale: arguments["locale"] as? String ?? "en",
      labels: arguments["labels"] as? [String: String] ?? [:], learningLanguage: "ja-JP", level: "B2", rank: 7)
    let content = BanteraPracticeWidgetView(snapshot: snapshot, family: family)
      .environment(\.colorScheme, dark ? .dark : .light)
      .padding(16).frame(width: size.width, height: size.height)
      .background(dark ? Color.black : Color.white)
    if #available(iOS 16.0, *) {
      let renderer = ImageRenderer(content: content)
      renderer.scale = 2
      return renderer.uiImage?.pngData()
    }
    let host = UIHostingController(rootView: content)
    host.view.bounds = CGRect(origin: .zero, size: size)
    host.view.backgroundColor = dark ? .black : .white
    host.view.setNeedsLayout()
    host.view.layoutIfNeeded()
    return UIGraphicsImageRenderer(size: size).image { _ in
      host.view.drawHierarchy(in: host.view.bounds, afterScreenUpdates: true)
    }.pngData()
  }
}
