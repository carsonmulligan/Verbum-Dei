import Foundation

struct Prayer: Identifiable, Codable {
    var id: String { title }
    let title: String
    let title_latin: String
    let title_english: String
    let latin: String
    let english: String
}

class PrayerStore: ObservableObject {
    @Published var prayers: [Prayer] = []
    
    init() {
        loadPrayers()
    }
    
    private func loadPrayers() {
        if let url = Bundle.main.url(forResource: "prayers", withExtension: "json") {
            do {
                let data = try Data(contentsOf: url)
                let prayersContainer = try JSONDecoder().decode([String: [Prayer]].self, from: data)
                prayers = prayersContainer["prayers"] ?? []
            } catch {
                print("Error loading prayers: \(error)")
            }
        }
    }
} 