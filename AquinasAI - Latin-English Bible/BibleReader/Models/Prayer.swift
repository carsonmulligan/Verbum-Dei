import Foundation

struct Prayer: Identifiable, Codable {
    var id: String { title }
    let title: String
    let title_latin: String?
    let title_english: String?
    let latin: String
    let english: String
    var category: PrayerCategory = .basic
    
    var displayTitleLatin: String {
        title_latin ?? title
    }
    
    var displayTitleEnglish: String {
        title_english ?? title
    }
    
    // Custom coding keys to match JSON structure
    private enum CodingKeys: String, CodingKey {
        case title
        case title_latin
        case title_english
        case latin
        case english
    }
    
    // Custom decoder to handle category which isn't in JSON
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        title = try container.decode(String.self, forKey: .title)
        title_latin = try container.decodeIfPresent(String.self, forKey: .title_latin)
        title_english = try container.decodeIfPresent(String.self, forKey: .title_english)
        latin = try container.decode(String.self, forKey: .latin)
        english = try container.decode(String.self, forKey: .english)
        // category is set after decoding by PrayerStore
    }
}

class PrayerStore: ObservableObject {
    @Published var prayers: [Prayer] = []
    
    init() {
        loadPrayers()
    }
    
    private func loadPrayers() {
        let prayerFiles = [
            ("prayers.json", PrayerCategory.basic),
            ("rosay_prayers.json", PrayerCategory.rosary),
            ("divine_mercy_chaplet.json", PrayerCategory.divine),
            ("order_of_mass.json", PrayerCategory.mass),
            ("angelus_domini.json", PrayerCategory.other)
        ]
        
        var allPrayers: [Prayer] = []
        
        for (filename, category) in prayerFiles {
            if let url = Bundle.main.url(forResource: filename.replacingOccurrences(of: ".json", with: ""), withExtension: "json") {
                do {
                    let data = try Data(contentsOf: url)
                    let prayersContainer = try JSONDecoder().decode([String: [Prayer]].self, from: data)
                    // Assign category to each prayer
                    if var categoryPrayers = prayersContainer["prayers"] {
                        for i in categoryPrayers.indices {
                            categoryPrayers[i].category = category
                        }
                        allPrayers.append(contentsOf: categoryPrayers)
                    }
                } catch {
                    print("Error loading prayers from \(filename): \(error)")
                }
            }
        }
        
        prayers = allPrayers
    }
    
    func getPrayers(for category: PrayerCategory) -> [Prayer] {
        prayers.filter { $0.category == category }
    }
} 