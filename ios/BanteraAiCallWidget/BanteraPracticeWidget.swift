import SwiftUI
import WidgetKit

struct BanteraPracticeEntry: TimelineEntry {
  let date: Date
  let snapshot: BanteraPracticeSnapshot
}

struct BanteraPracticeProvider: TimelineProvider {
  func placeholder(in context: Context) -> BanteraPracticeEntry {
    .init(date: Date(), snapshot: .init(dateKey: BanteraPracticeSnapshot.dayKey(Date()),
      signedIn: true, spoken: 128, listened: 640, locale: Locale.current.identifier, labels: [:],
      learningLanguage: "ja-JP", level: "B2", rank: 7))
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
    var utc = Calendar(identifier: .gregorian)
    utc.timeZone = TimeZone(secondsFromGMT: 0)!
    let utcMidnight = utc.date(byAdding: .day, value: 1, to: utc.startOfDay(for: now))!
    let dates = Array(Set([now, midnight, utcMidnight])).sorted()
    completion(Timeline(entries: dates.map { .init(date: $0, snapshot: snapshot.forDate($0)) },
      policy: .after(min(midnight, utcMidnight).addingTimeInterval(60))))
  }
}

struct BanteraPracticeWidget: Widget {
  private var families: [WidgetFamily] {
    var result: [WidgetFamily] = [.systemSmall, .systemMedium, .systemLarge, .systemExtraLarge]
    if #available(iOS 27.0, iOSApplicationExtension 27.0, *) { result.append(.systemExtraLargePortrait) }
    return result
  }
  var body: some WidgetConfiguration {
    StaticConfiguration(kind: BanteraPracticeSnapshot.kind, provider: BanteraPracticeProvider()) { entry in
      if #available(iOS 17.0, iOSApplicationExtension 17.0, *) {
        BanteraPracticeEntryView(snapshot: entry.snapshot)
          .containerBackground(for: .widget) { Color(uiColor: .systemBackground) }
          .widgetURL(BanteraPracticeSnapshot.chatURL)
      } else {
        BanteraPracticeEntryView(snapshot: entry.snapshot)
          .padding(16)
          .background(Color(uiColor: .systemBackground))
          .widgetURL(BanteraPracticeSnapshot.chatURL)
      }
    }
    .configurationDisplayName("practice.widget.title")
    .description("practice.widget.description")
    .supportedFamilies(families)
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
  private var detailed: Bool { family != .systemSmall && family != .systemMedium }
  private var tall: Bool {
    if #available(iOS 27.0, iOSApplicationExtension 27.0, *) { return family == .systemExtraLargePortrait }
    return false
  }
  private var languageName: String {
    guard let code = snapshot.learningLanguage else { return "—" }
    return Locale(identifier: snapshot.locale).localizedString(forIdentifier: code) ?? code
  }
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
        if !compact {
          Image("BanteraLogo").resizable().scaledToFit().frame(width: 23, height: 23).clipShape(RoundedRectangle(cornerRadius: 6))
        }
        Text(compact ? label("today") : label("today") + " · " + label("words")).font(.caption.weight(.semibold)).foregroundStyle(.secondary)
          .lineLimit(1).minimumScaleFactor(0.75)
        Spacer(minLength: 0)
        if compact {
          HStack(spacing: 3) {
            Image(systemName: "trophy.fill")
            Text(snapshot.rank.map { "#" + number($0) } ?? "—").monospacedDigit()
          }
          .font(.system(size: 11, weight: .semibold)).foregroundStyle(purple)
          .lineLimit(1).minimumScaleFactor(0.7)
          .padding(.horizontal, 5).padding(.vertical, 3)
          .background(purple.opacity(0.10), in: Capsule())
          .layoutPriority(1)
          .accessibilityElement(children: .ignore)
          .accessibilityLabel(Text(label("position") + ", " + label("period")))
          .accessibilityValue(Text(snapshot.rank.map { number($0) } ?? "—"))
        } else {
          Text("Bantera").font(.caption.weight(.semibold)).foregroundStyle(.secondary)
        }
      }
      if compact {
        metric(snapshot.spoken, key: "spoken", icon: "mic.fill", tint: purple)
        metric(snapshot.listened, key: "listened", icon: "headphones", tint: mint)
      } else if tall {
        VStack(spacing: 12) {
          tallMetric(snapshot.spoken, key: "spoken", icon: "mic.fill", tint: purple)
          tallMetric(snapshot.listened, key: "listened", icon: "headphones", tint: mint)
        }.frame(maxHeight: .infinity)
      } else {
        HStack(spacing: detailed ? 18 : 10) {
          metric(snapshot.spoken, key: "spoken", icon: "mic.fill", tint: purple)
          Rectangle().fill(Color.primary.opacity(0.1)).frame(width: 1)
          metric(snapshot.listened, key: "listened", icon: "headphones", tint: mint)
          if family == .systemMedium {
            Rectangle().fill(Color.primary.opacity(0.1)).frame(width: 1)
            VStack(alignment: .leading, spacing: 3) {
              Label(label("position"), systemImage: "trophy.fill")
                .font(.caption.weight(.medium)).foregroundStyle(purple)
                .lineLimit(1).minimumScaleFactor(0.65)
              Text(snapshot.rank.map { "#" + number($0) } ?? "—")
                .font(.system(size: 33, weight: .bold, design: .rounded))
                .monospacedDigit().lineLimit(1).minimumScaleFactor(0.5)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(Text(label("position") + ", " + label("period")))
            .accessibilityValue(Text(snapshot.rank.map { number($0) } ?? "—"))
          }
        }.frame(maxHeight: .infinity)
      }
      if detailed {
        VStack(alignment: .leading, spacing: 12) {
          HStack(spacing: 10) {
            Image(systemName: "globe").font(.title3).foregroundStyle(purple)
            VStack(alignment: .leading, spacing: 3) {
              Text(label("language")).font(.caption).foregroundStyle(.secondary)
              Text(languageName).font(.headline).lineLimit(2).minimumScaleFactor(0.7)
            }
            Spacer(minLength: 8)
            VStack(alignment: .trailing, spacing: 3) {
              Text(label("level")).font(.caption).foregroundStyle(.secondary)
              Text(snapshot.level ?? "—").font(.title2.weight(.bold)).foregroundStyle(purple)
            }
          }
          Divider()
          HStack(spacing: 10) {
            Image(systemName: "trophy.fill").font(.title2).foregroundStyle(purple)
            VStack(alignment: .leading, spacing: 3) {
              Text(label("position")).font(.subheadline.weight(.semibold)).lineLimit(2).minimumScaleFactor(0.7)
              Text(label("period")).font(.caption).foregroundStyle(.secondary).lineLimit(1).minimumScaleFactor(0.65)
            }
            Spacer(minLength: 8)
            Text(snapshot.rank.map { "#" + number($0) } ?? "—")
              .font(.system(size: 32, weight: .bold, design: .rounded)).monospacedDigit()
              .lineLimit(1).minimumScaleFactor(0.5).foregroundStyle(purple)
          }
        }.padding(14).background(purple.opacity(0.07), in: RoundedRectangle(cornerRadius: 18))
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

  private func tallMetric(_ count: Int, key: String, icon: String, tint: Color) -> some View {
    VStack(alignment: .leading, spacing: 12) {
      Label(label(key), systemImage: icon).font(.headline).foregroundStyle(tint)
        .lineLimit(1).minimumScaleFactor(0.7)
      Text(number(count)).font(.system(size: 52, weight: .bold, design: .rounded))
        .monospacedDigit().lineLimit(1).minimumScaleFactor(0.45)
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
    .padding(20)
    .background(tint.opacity(0.09), in: RoundedRectangle(cornerRadius: 22))
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
