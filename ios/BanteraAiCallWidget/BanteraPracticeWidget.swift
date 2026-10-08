import SwiftUI
import WidgetKit

struct BanteraPracticeEntry: TimelineEntry {
  let date: Date
  let snapshot: BanteraPracticeSnapshot
}

struct BanteraPracticeProvider: TimelineProvider {
  func placeholder(in context: Context) -> BanteraPracticeEntry {
    .init(date: Date(), snapshot: .init(dateKey: BanteraPracticeSnapshot.dayKey(Date()),
      signedIn: true, spoken: 128, listened: 640, locale: Locale.current.identifier, labels: [:]))
  }
  func getSnapshot(in context: Context, completion: @escaping (BanteraPracticeEntry) -> Void) {
    if context.isPreview { completion(placeholder(in: context)) }
    else { completion(.init(date: Date(), snapshot: .read().forDate(Date()))) }
  }
  func getTimeline(in context: Context, completion: @escaping (Timeline<BanteraPracticeEntry>) -> Void) {
    let now = Date()
    let snapshot = BanteraPracticeSnapshot.read()
    let midnight = Calendar.current.date(byAdding: .day, value: 1, to: Calendar.current.startOfDay(for: now))!
    // Schedule the zero-count entry in advance; a suspended app need not run at midnight.
    completion(Timeline(entries: [
      .init(date: now, snapshot: snapshot.forDate(now)),
      .init(date: midnight, snapshot: snapshot.forDate(midnight))
    ], policy: .after(midnight.addingTimeInterval(60))))
  }
}

struct BanteraPracticeWidget: Widget {
  var body: some WidgetConfiguration {
    StaticConfiguration(kind: BanteraPracticeSnapshot.kind, provider: BanteraPracticeProvider()) { entry in
      BanteraPracticeEntryView(snapshot: entry.snapshot)
        .containerBackground(for: .widget) { Color(uiColor: .systemBackground) }
        .widgetURL(BanteraPracticeSnapshot.chatURL)
    }
    .configurationDisplayName("practice.widget.title")
    .description("practice.widget.description")
    .supportedFamilies([.systemSmall, .systemMedium])
  }
}

struct BanteraPracticeEntryView: View {
  @Environment(\.widgetFamily) private var family
  let snapshot: BanteraPracticeSnapshot
  var body: some View { BanteraPracticeWidgetView(snapshot: snapshot, family: family) }
}

struct BanteraPracticeWidgetView: View {
  let family: WidgetFamily
  init(snapshot: BanteraPracticeSnapshot, family: WidgetFamily) {
    self.snapshot = snapshot
    self.family = family
  }
  @Environment(\.colorScheme) private var colorScheme
  let snapshot: BanteraPracticeSnapshot
  private var compact: Bool { family == .systemSmall }
  private var purple: Color { colorScheme == .dark ? Color(red: 0.66, green: 0.55, blue: 1) : Color(red: 0.36, green: 0.23, blue: 0.77) }
  private var mint: Color { colorScheme == .dark ? Color(red: 0.20, green: 0.90, blue: 0.72) : Color(red: 0.02, green: 0.43, blue: 0.34) }

  private func label(_ key: String) -> String {
    snapshot.labels[key] ?? NSLocalizedString("practice.widget.\(key)", comment: "Practice widget")
  }
  private func number(_ count: Int) -> String {
    count.formatted(.number.locale(Locale(identifier: snapshot.locale)))
  }
  var body: some View {
    VStack(alignment: .leading, spacing: compact ? 5 : 10) {
      HStack(spacing: 6) {
        Image("BanteraLogo").resizable().scaledToFit().frame(width: compact ? 18 : 23, height: compact ? 18 : 23).clipShape(RoundedRectangle(cornerRadius: 6))
        Text(label("today") + " · " + label("words")).font(.caption.weight(.semibold)).foregroundStyle(.secondary)
          .lineLimit(1).minimumScaleFactor(0.75)
        Spacer(minLength: 0)
        if !compact { Text("Bantera").font(.caption.weight(.semibold)).foregroundStyle(.secondary) }
      }
      if compact {
        metric(snapshot.spoken, key: "spoken", icon: "mic.fill", tint: purple)
        metric(snapshot.listened, key: "listened", icon: "headphones", tint: mint)
      } else {
        HStack(spacing: 18) {
          metric(snapshot.spoken, key: "spoken", icon: "mic.fill", tint: purple)
          Rectangle().fill(Color.primary.opacity(0.1)).frame(width: 1)
          metric(snapshot.listened, key: "listened", icon: "headphones", tint: mint)
        }.frame(maxHeight: .infinity)
      }
      HStack(spacing: 5) {
        Image(systemName: "waveform")
        Text(label(snapshot.signedIn ? "chat" : "signIn"))
          .lineLimit(1).minimumScaleFactor(0.65)
        Spacer(minLength: 0)
        Image(systemName: "arrow.up.right").font(.caption2.weight(.bold))
      }
      .font(.caption.weight(.semibold))
      .foregroundStyle(purple)
      .padding(.horizontal, compact ? 8 : 12).padding(.vertical, compact ? 4 : 8)
      .background(purple.opacity(0.10), in: Capsule())
    }
    .accessibilityElement(children: .combine)
    .accessibilityHint(Text(label("chat")))
  }

  @ViewBuilder private func metric(_ count: Int, key: String, icon: String, tint: Color) -> some View {
    if compact {
      HStack(spacing: 8) {
        Image(systemName: icon).font(.subheadline).foregroundStyle(tint).frame(width: 18)
        VStack(alignment: .leading, spacing: 0) {
          Text(number(count)).font(.system(size: 22, weight: .bold, design: .rounded))
            .monospacedDigit().lineLimit(1).minimumScaleFactor(0.55)
          Text(label(key)).font(.system(size: 10, weight: .medium)).foregroundStyle(.secondary).lineLimit(1).minimumScaleFactor(0.7)
        }
        Spacer(minLength: 0)
      }
    } else {
      VStack(alignment: .leading, spacing: 3) {
        Label(label(key), systemImage: icon).font(.caption.weight(.medium)).foregroundStyle(tint)
          .lineLimit(1).minimumScaleFactor(0.65)
        Text(number(count)).font(.system(size: 33, weight: .bold, design: .rounded))
          .monospacedDigit().lineLimit(1).minimumScaleFactor(0.5)
      }.frame(maxWidth: .infinity, alignment: .leading)
    }
  }
}
