import Flutter
import UIKit

class SceneDelegate: FlutterSceneDelegate {
  override func scene(_ scene: UIScene, willConnectTo session: UISceneSession,
                      options connectionOptions: UIScene.ConnectionOptions) {
    guard let windowScene = scene as? UIWindowScene,
          let app = UIApplication.shared.delegate as? AppDelegate else { return }
    // Reuse the same engine that PushKit can start without a foreground scene.
    let window = UIWindow(windowScene: windowScene)
    window.rootViewController = BanteraAdaptiveViewController(engine: app.callEngine, nibName: nil, bundle: nil)
    self.window = window
    registerSceneLifeCycle(with: app.callEngine)
    super.scene(scene, willConnectTo: session, options: connectionOptions)
    window.makeKeyAndVisible()
    for context in connectionOptions.urlContexts {
      app.practiceWidgetBridge?.open(context.url)
    }
  }
  override func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
    let app = UIApplication.shared.delegate as? AppDelegate
    let remaining = Set(URLContexts.filter { app?.practiceWidgetBridge?.open($0.url) != true })
    if !remaining.isEmpty { super.scene(scene, openURLContexts: remaining) }
  }
}

/// Publishes window-local public UIKit layout signals to Flutter. The engine and
/// route hierarchy are retained when the display, pose or Split View changes.
final class BanteraAdaptiveViewController: FlutterViewController {
  private var layoutChannel: FlutterMethodChannel?
  private var previousLayout: NSDictionary?
  private var hingeStatus = 0
  private var providesHinge = false

  var adaptiveOrientations: UIInterfaceOrientationMask {
    if traitCollection.userInterfaceIdiom == .pad { return .all }
    if #available(iOS 27.1, *), providesHinge || traitCollection.verticalBarEdge != .unspecified {
      return .allButUpsideDown
    }
    return .portrait
  }

  override var supportedInterfaceOrientations: UIInterfaceOrientationMask { adaptiveOrientations }

  override func viewDidLoad() {
    super.viewDidLoad()
    let channel = FlutterMethodChannel(name: "bantera/adaptive_layout", binaryMessenger: binaryMessenger)
    layoutChannel = channel
    channel.setMethodCallHandler { [weak self] call, result in
      guard call.method == "getLayout" else { result(FlutterMethodNotImplemented); return }
      result(self?.layoutSnapshot())
    }
    if #available(iOS 27.1, *) {
      view.addInteraction(UIHingeInteraction { [weak self] _, update in
        self?.providesHinge = update.hinge != nil
        self?.hingeStatus = update.hinge?.status.rawValue ?? 0
        self?.setNeedsUpdateOfSupportedInterfaceOrientations()
        self?.publishLayout()
      })
      registerForTraitChanges(UITraitCollection.systemTraitsAffectingVerticalBarEdge) {
        (controller: BanteraAdaptiveViewController, _: UITraitCollection) in
        controller.publishLayout()
      }
    }
  }

  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    publishLayout()
  }

  override func viewSafeAreaInsetsDidChange() {
    super.viewSafeAreaInsetsDidChange()
    publishLayout()
  }

  private func layoutSnapshot() -> [String: Any] {
    var edge = "horizontal"
    var regions: [[String: Any]] = []
    if #available(iOS 27.1, *) {
      switch traitCollection.verticalBarEdge {
      case .leading: edge = "left"
      case .trailing: edge = "right"
      default: break
      }
      for kind: UIView.ReservedRegion.Kind in [.division, .occlusion] {
        for region in view.reservedRegions(kind: kind) where region.isActive {
          let frame = region.frame
          regions.append(["kind": kind == .division ? "division" : "occlusion",
                          "x": frame.minX, "y": frame.minY,
                          "width": frame.width, "height": frame.height])
        }
      }
    }
    let statusFrame = view.window?.windowScene?.statusBarManager?.statusBarFrame ?? .zero
    let statusBottom = view.convert(statusFrame, from: nil).maxY
    return ["statusBarBottom": max(0, statusBottom), "edge": edge, "width": view.bounds.width, "height": view.bounds.height,
            "hingeStatus": hingeStatus, "regions": regions]
  }

  private func publishLayout() {
    guard isViewLoaded else { return }
    let snapshot = layoutSnapshot()
    let dictionary = snapshot as NSDictionary
    guard previousLayout != dictionary else { return }
    previousLayout = dictionary
    layoutChannel?.invokeMethod("layoutChanged", arguments: snapshot)
  }
}
