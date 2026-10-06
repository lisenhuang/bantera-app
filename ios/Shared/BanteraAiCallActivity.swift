import ActivityKit
import AppIntents
import Foundation

struct BanteraAiCallAttributes: ActivityAttributes {
  struct ContentState: Codable, Hashable {
    var endsAt: Date
    var muted: Bool
    var speaker: Bool
    var phase: String
  }
  var callID: String
}

extension Notification.Name {
  static let banteraAiCallControl = Notification.Name("bantera.ai.call.control")
}

struct BanteraAiCallControlIntent: LiveActivityIntent {
  static var title: LocalizedStringResource = "Bantera AI call"
  static var openAppWhenRun = false
  static var isDiscoverable = false
  static var authenticationPolicy: IntentAuthenticationPolicy = .alwaysAllowed

  @Parameter(title: "Call") var callID: String
  @Parameter(title: "Action") var action: String
  init() {}
  init(callID: String, action: String) { self.callID = callID; self.action = action }

  func perform() async throws -> some IntentResult {
    guard ["mute", "speaker", "end"].contains(action),
          let activity = Activity<BanteraAiCallAttributes>.activities.first(where: { $0.attributes.callID == callID }) else { return .result() }
    if action == "end" || activity.content.state.endsAt > Date() {
      await MainActor.run {
        NotificationCenter.default.post(name: .banteraAiCallControl, object: nil,
          userInfo: ["callID": callID, "action": action])
      }
    }
    if action == "end" || activity.content.state.endsAt <= Date() {
      await activity.end(nil, dismissalPolicy: .immediate)
    }
    return .result()
  }
}
