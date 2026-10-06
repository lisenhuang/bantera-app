import ActivityKit
import AppIntents
import SwiftUI
import WidgetKit

@main
struct BanteraAiCallWidget: Widget {
  var body: some WidgetConfiguration {
    ActivityConfiguration(for: BanteraAiCallAttributes.self) { context in
      VStack(spacing: 12) {
        HStack(spacing: 10) {
          Image("BanteraLogo").resizable().scaledToFit().frame(width: 40, height: 40).clipShape(Circle())
          VStack(alignment: .leading, spacing: 2) {
            Text("Bantera AI").font(.headline)
            Text(status(context)).font(.caption).foregroundStyle(.secondary)
          }
          Spacer()
          countdown(context).font(.title2.weight(.semibold)).monospacedDigit().frame(width: 72)
        }
        controls(context)
      }
      .padding(16)
      .activityBackgroundTint(Color(uiColor: .secondarySystemBackground))
      .activitySystemActionForegroundColor(.primary)
    } dynamicIsland: { context in
      DynamicIsland {
        DynamicIslandExpandedRegion(.leading) { Label("Bantera AI", systemImage: "waveform").font(.headline) }
        DynamicIslandExpandedRegion(.trailing) { countdown(context).monospacedDigit().frame(width: 62) }
        DynamicIslandExpandedRegion(.bottom) { controls(context).padding(.top, 6) }
      } compactLeading: {
        Image(systemName: context.state.muted ? "mic.slash.fill" : "waveform").foregroundStyle(.purple)
      } compactTrailing: {
        countdown(context).monospacedDigit().frame(width: 44)
      } minimal: {
        Image(systemName: context.state.muted ? "mic.slash.fill" : "waveform")
      }
    }
  }

  private func status(_ context: ActivityViewContext<BanteraAiCallAttributes>) -> LocalizedStringKey {
    if context.isStale { return "ai.call.ended" }
    if context.state.phase == "connecting" { return "ai.call.connecting" }
    if context.state.phase == "goodbye" { return "ai.call.goodbye" }
    return "ai.call.audio"
  }

  @ViewBuilder private func countdown(_ context: ActivityViewContext<BanteraAiCallAttributes>) -> some View {
    if context.isStale { Text("0:00") }
    else if context.state.phase == "connecting" { ProgressView() }
    else { Text(timerInterval: Date()...max(Date(), context.state.endsAt), countsDown: true, showsHours: false) }
  }

  private func controls(_ context: ActivityViewContext<BanteraAiCallAttributes>) -> some View {
    HStack(spacing: 10) {
      Button(intent: BanteraAiCallControlIntent(callID: context.attributes.callID, action: "mute")) {
        Label(LocalizedStringKey(context.state.muted ? "ai.call.unmute" : "ai.call.mute"), systemImage: context.state.muted ? "mic.slash.fill" : "mic.fill")
          .frame(maxWidth: .infinity)
      }
      .tint(context.state.muted ? Color(red: 0.42, green: 0.31, blue: 0.90) : Color(white: 0.3))
      .disabled(context.isStale || context.state.phase == "connecting")
      Button(intent: BanteraAiCallControlIntent(callID: context.attributes.callID, action: "speaker")) {
        Label(LocalizedStringKey(context.state.speaker ? "ai.call.speaker" : "ai.call.earpiece"), systemImage: context.state.speaker ? "speaker.wave.2.fill" : "ear.fill")
          .frame(maxWidth: .infinity)
      }
      .tint(context.state.speaker ? Color(red: 0.42, green: 0.31, blue: 0.90) : Color(white: 0.3))
      .disabled(context.isStale || context.state.phase == "connecting")
      Button(intent: BanteraAiCallControlIntent(callID: context.attributes.callID, action: "end")) {
        Label("ai.call.end", systemImage: "phone.down.fill").frame(maxWidth: .infinity)
      }.tint(Color(red: 0.73, green: 0.1, blue: 0.14))
    }
    .font(.caption.weight(.semibold))
    .foregroundStyle(.white)
    .lineLimit(1)
    .minimumScaleFactor(0.7)
    .buttonStyle(.borderedProminent)
    .buttonBorderShape(.capsule)
    .controlSize(.regular)
  }
}
