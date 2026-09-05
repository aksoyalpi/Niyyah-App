import Foundation
import FamilyControls
import ManagedSettings

enum NiyyahStore {
  static let appGroupId = "group.com.example.niyyahApp"
  static let selectionKey = "blocklist.selection"
  static let statsKey = "stats.daily"
  static let sessionMinutesKey = "settings.session_minutes"
  static let displayModeKey = "settings.display_mode"
  static let contentStyleKey = "settings.content_style"
  static let shieldShownKey = "shield.shown_at"
  static let sessionEndsKey = "session.ends_at"
  static let defaultSessionMinutes = 15
  static let readingCapSeconds = 300

  static var group: UserDefaults? {
    UserDefaults(suiteName: appGroupId)
  }

  static var isAuthorized: Bool {
    AuthorizationCenter.shared.authorizationStatus == .approved
  }

  static func saveSelection(_ selection: FamilyActivitySelection) {
    guard let data = try? JSONEncoder().encode(selection), let group else { return }
    group.set(data, forKey: selectionKey)
    applyShield()
  }

  static func loadSelection() -> FamilyActivitySelection {
    guard let data = group?.data(forKey: selectionKey),
          let selection = try? JSONDecoder().decode(FamilyActivitySelection.self, from: data)
    else { return FamilyActivitySelection() }
    return selection
  }

  static var selectionCount: Int {
    let selection = loadSelection()
    return selection.applicationTokens.count
      + selection.categoryTokens.count
      + selection.webDomainTokens.count
  }

  static func applyShield() {
    guard isAuthorized else { return }
    let selection = loadSelection()
    let store = ManagedSettingsStore()
    store.shield.applications = selection.applicationTokens.isEmpty ? nil : selection.applicationTokens
    store.shield.applicationCategories = selection.categoryTokens.isEmpty ? nil : selection.categoryTokens
  }

  static func clearShield() {
    let store = ManagedSettingsStore()
    store.shield.applications = nil
    store.shield.applicationCategories = nil
  }

  static func syncSettings() {
    guard let group else { return }
    let std = UserDefaults.standard
    if let minutes = std.object(forKey: "flutter.session_minutes") as? Int, minutes > 0 {
      group.set(minutes, forKey: sessionMinutesKey)
    }
    if let mode = std.string(forKey: "flutter.display_mode") {
      group.set(mode, forKey: displayModeKey)
    }
    if let style = std.string(forKey: "flutter.content_style") {
      group.set(style, forKey: contentStyleKey)
    }
  }

  static var sessionMinutes: Int {
    let minutes = group?.integer(forKey: sessionMinutesKey) ?? 0
    return minutes > 0 ? minutes : defaultSessionMinutes
  }

  static func recordShieldShown() {
    group?.set(Date(), forKey: shieldShownKey)
  }

  static func readingSecondsSinceShown() -> Int? {
    guard let shown = group?.object(forKey: shieldShownKey) as? Date else { return nil }
    let seconds = Int(Date().timeIntervalSince(shown))
    return min(max(seconds, 0), readingCapSeconds)
  }

  static func startSession() {
    group?.set(Date().addingTimeInterval(TimeInterval(sessionMinutes * 60)), forKey: sessionEndsKey)
    clearShield()
  }

  static func endSession() {
    group?.removeObject(forKey: sessionEndsKey)
  }

  static var sessionEndDate: Date? {
    group?.object(forKey: sessionEndsKey) as? Date
  }

  static func addReading(seconds: Int) {
    let day = dateKey()
    var stats = loadStats()
    var stat = stats[day] ?? DayStat(minutes: 0, items: 0)
    stat.minutes += seconds / 60
    stat.items += 1
    stats[day] = stat
    if let data = try? JSONEncoder().encode(stats) {
      group?.set(data, forKey: statsKey)
    }
  }

  struct DayStat: Codable {
    var minutes: Int
    var items: Int
  }

  static func loadStats() -> [String: DayStat] {
    guard let data = group?.data(forKey: statsKey),
          let stats = try? JSONDecoder().decode([String: DayStat].self, from: data)
    else { return [:] }
    return stats
  }

  static func daysPayload() -> [[String: Any]] {
    let calendar = Calendar.current
    var days: [[String: Any]] = []
    let stats = loadStats()
    for offset in stride(from: 6, through: 0, by: -1) {
      let date = calendar.date(byAdding: .day, value: -offset, to: Date()) ?? Date()
      let key = dateKey(date)
      let stat = stats[key] ?? DayStat(minutes: 0, items: 0)
      days.append(["date": key, "minutes": stat.minutes, "items": stat.items])
    }
    return days
  }

  static func dateKey(_ date: Date = Date()) -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd"
    formatter.locale = Locale(identifier: "en_US_POSIX")
    return formatter.string(from: date)
  }
}
