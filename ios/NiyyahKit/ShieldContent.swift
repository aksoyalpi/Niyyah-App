import Foundation

struct ShieldItem: Decodable {
  let id: String
  let arabic: String
  let translationEn: String
  let source: String
}

enum ShieldContent {
  static func todayItem() -> ShieldItem? {
    let items = filteredItems()
    guard !items.isEmpty else { return nil }
    let index = dayIndex() % items.count
    return items[index]
  }

  static func filteredItems() -> [ShieldItem] {
    let mode = NiyyahStore.group?.string(forKey: NiyyahStore.displayModeKey) ?? "mixed"
    var items: [ShieldItem] = []
    if mode != "hadithOnly" {
      items += parse("quran")
    }
    if mode != "quranOnly" {
      items += parse("hadith")
    }
    return items
  }

  static func style() -> String {
    NiyyahStore.group?.string(forKey: NiyyahStore.contentStyleKey) ?? "arabicWithTranslation"
  }

  static func dayIndex() -> Int {
    let calendar = Calendar.current
    let day = calendar.ordinality(of: .day, in: .year, for: Date()) ?? 0
    let year = calendar.component(.year, from: Date())
    return day + year * 1000
  }

  static func parse(_ name: String) -> [ShieldItem] {
    guard let url = Bundle.main.url(forResource: name, withExtension: "json"),
          let data = try? Data(contentsOf: url),
          let items = try? JSONDecoder().decode([ShieldItem].self, from: data)
    else { return [] }
    return items
  }
}
