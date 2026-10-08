import Foundation

/// Only aggregate counts and UI labels are shared. No credentials or chat history.
struct BanteraPracticeSnapshot: Codable, Equatable {
  static let appGroup = "group.bantera.lisenhuang.com"
  static let kind = "BanteraPracticeWidget"
  static let chatURL = URL(string: "bantera://ai-chat")!
  var dateKey: String
  var signedIn: Bool
  var spoken: Int
  var listened: Int
  var locale: String
  var labels: [String: String]

  static func dayKey(_ date: Date, calendar: Calendar = .current) -> String {
    // Flutter's ledger keys are Gregorian even when the device uses another calendar.
    var gregorian = Calendar(identifier: .gregorian)
    gregorian.timeZone = calendar.timeZone
    let parts = gregorian.dateComponents([.year, .month, .day], from: date)
    return String(format: "%04d-%02d-%02d", parts.year!, parts.month!, parts.day!)
  }

  static var empty: Self {
    .init(dateKey: "", signedIn: false, spoken: 0, listened: 0, locale: Locale.current.identifier, labels: [:])
  }

  func forDate(_ date: Date, calendar: Calendar = .current) -> Self {
    var value = self
    if !signedIn || dateKey != Self.dayKey(date, calendar: calendar) {
      value.spoken = 0
      value.listened = 0
    }
    value.spoken = max(0, value.spoken)
    value.listened = max(0, value.listened)
    return value
  }

  static var fileURL: URL? {
    FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: appGroup)?
      .appendingPathComponent("practice-widget.json")
  }

  static func read() -> Self {
    guard let url = fileURL, let data = try? Data(contentsOf: url),
          let value = try? JSONDecoder().decode(Self.self, from: data) else { return .empty }
    return value
  }

  static func isChatURL(_ url: URL) -> Bool {
    url.scheme == "bantera" && url.host == "ai-chat" &&
      (url.path.isEmpty || url.path == "/") && url.query == nil && url.fragment == nil &&
      url.user == nil && url.password == nil && url.port == nil
  }
}
