import Flutter
import UIKit

class SceneDelegate: FlutterSceneDelegate {
  override func scene(_ scene: UIScene, willConnectTo session: UISceneSession,
                      options connectionOptions: UIScene.ConnectionOptions) {
    guard let windowScene = scene as? UIWindowScene,
          let app = UIApplication.shared.delegate as? AppDelegate else { return }
    // Reuse the same engine that PushKit can start without a foreground scene.
    let window = UIWindow(windowScene: windowScene)
    window.rootViewController = FlutterViewController(engine: app.callEngine, nibName: nil, bundle: nil)
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
