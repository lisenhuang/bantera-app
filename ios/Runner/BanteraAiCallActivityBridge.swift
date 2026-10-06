import ActivityKit
import Flutter
import Foundation

@MainActor
final class BanteraAiCallActivityBridge {
  private let channel: FlutterMethodChannel
  private var activity: Activity<BanteraAiCallAttributes>?
  private var observer: NSObjectProtocol?
  private var generation = 0
  private var updates: Task<Void, Never>?

  init(messenger: FlutterBinaryMessenger) {
    channel = FlutterMethodChannel(name: "bantera/ai_call_activity", binaryMessenger: messenger)
    // A process restart cannot retain an in-memory Gemini call.
    let staleActivities = Activity<BanteraAiCallAttributes>.activities
    Task { for stale in staleActivities { await stale.end(nil, dismissalPolicy: .immediate) } }
    channel.setMethodCallHandler { [weak self] call, result in
      Task { @MainActor in
        guard let self else { result(nil); return }
        switch call.method {
        case "start":
          self.generation += 1
          let revision = self.generation
          let previous = self.activity
          self.activity = nil
          if let previous { await previous.end(nil, dismissalPolicy: .immediate) }
          guard revision == self.generation, ActivityAuthorizationInfo().areActivitiesEnabled,
                let state = self.state(call.arguments) else { result(false); return }
          do {
            self.activity = try Activity.request(attributes: BanteraAiCallAttributes(callID: UUID().uuidString),
              content: ActivityContent(state: state, staleDate: state.endsAt), pushType: nil)
            result(true)
          } catch { result(false) } // Optional UI must never prevent a voice call.
        case "update":
          guard let activity = self.activity, let state = self.state(call.arguments) else { result(nil); return }
          let previous = self.updates
          self.updates = Task {
            await previous?.value
            await activity.update(ActivityContent(state: state, staleDate: state.endsAt))
          }
          await self.updates?.value
          result(nil)
        case "stop":
          self.generation += 1
          let activity = self.activity
          self.activity = nil
          await self.updates?.value
          self.updates = nil
          if let activity { await activity.end(nil, dismissalPolicy: .immediate) }
          result(nil)
        default: result(FlutterMethodNotImplemented)
        }
      }
    }
    observer = NotificationCenter.default.addObserver(forName: .banteraAiCallControl, object: nil, queue: .main) { [weak self] note in
      let callID = note.userInfo?["callID"] as? String
      let action = note.userInfo?["action"] as? String
      Task { @MainActor in
        guard let self, let activity = self.activity, callID == activity.attributes.callID,
              let action else { return }
        self.channel.invokeMethod("control", arguments: action)
      }
    }
  }

  private func state(_ arguments: Any?) -> BanteraAiCallAttributes.ContentState? {
    guard let args = arguments as? [String: Any], let milliseconds = args["endsAt"] as? NSNumber,
          let muted = args["muted"] as? Bool, let speaker = args["speaker"] as? Bool,
          let phase = args["phase"] as? String else { return nil }
    return .init(endsAt: Date(timeIntervalSince1970: milliseconds.doubleValue / 1000), muted: muted, speaker: speaker, phase: phase)
  }

  deinit { if let observer { NotificationCenter.default.removeObserver(observer) } }
}
