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
                    var prayersContainer = try JSONDecoder().decode([String: [Prayer]].self, from: data)
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