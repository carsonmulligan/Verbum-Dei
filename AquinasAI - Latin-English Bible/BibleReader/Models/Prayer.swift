import Foundation

// MARK: - Prayer Models
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
    }
}

// MARK: - Container Models for Different JSON Structures
struct RosaryPrayersContainer: Codable {
    let common_prayers: [String: Prayer]
    let mysteries: [String: [RosaryMystery]]
    let schedule: [String: String]
    let template: RosaryTemplate
}

struct RosaryMystery: Codable {
    let number: Int
    let latin: String
    let english: String
}

struct RosaryTemplate: Codable {
    let opening: [String]
    let decade: [String]
    let closing: [String]
}

struct OrderOfMassContainer: Codable {
    let prayers: [Prayer]
    let order_of_mass: OrderOfMass
}

struct OrderOfMass: Codable {
    let introductory_rites: [OrderItem]
    let liturgy_of_the_word: [OrderItem]
    let liturgy_of_the_eucharist: EucharistLiturgy
    let concluding_rites: [String]
}

enum OrderItem: Codable {
    case string(String)
    case array([String])
    case dictionary([String: [String]])
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let str = try? container.decode(String.self) {
            self = .string(str)
        } else if let arr = try? container.decode([String].self) {
            self = .array(arr)
        } else if let dict = try? container.decode([String: [String]].self) {
            self = .dictionary(dict)
        } else {
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Cannot decode OrderItem")
        }
    }
}

struct EucharistLiturgy: Codable {
    let preparation_of_the_gifts: [String]
    let eucharistic_prayer: [OrderItem]
    let communion_rite: [OrderItem]
}

struct AngelusContainer: Codable {
    let angelus: AngelusContent
}

struct AngelusContent: Codable {
    let common_prayers: [String: Prayer]
    let template: AngelusTemplate
}

struct AngelusTemplate: Codable {
    let sequence: [String]
    let structure: AngelusStructure
}

struct AngelusStructure: Codable {
    let times_per_day: Int
    let customary_hours: [String]
}

struct DivineMercyContainer: Codable {
    let divine_mercy_chaplet: DivineMercyContent
}

struct DivineMercyContent: Codable {
    let common_prayers: [String: Prayer]
    let template: DivineMercyTemplate
}

struct DivineMercyTemplate: Codable {
    let opening: [String]
    let decade: [OrderItem]
    let closing: [OrderItem]
    let structure: DivineMercyStructure
}

struct DivineMercyStructure: Codable {
    let decades: Int
}

// MARK: - PrayerStore
class PrayerStore: ObservableObject {
    @Published var prayers: [Prayer] = []
    @Published var rosaryPrayers: RosaryPrayersContainer?
    @Published var massOrder: OrderOfMassContainer?
    @Published var angelusPrayers: AngelusContainer?
    @Published var divineMercyPrayers: DivineMercyContainer?
    
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
                    
                    switch filename {
                    case "rosay_prayers.json":
                        rosaryPrayers = try JSONDecoder().decode(RosaryPrayersContainer.self, from: data)
                        let prayers = rosaryPrayers?.common_prayers.values.map { var prayer = $0; prayer.category = category; return prayer } ?? []
                        allPrayers.append(contentsOf: prayers)
                        
                    case "order_of_mass.json":
                        massOrder = try JSONDecoder().decode(OrderOfMassContainer.self, from: data)
                        let prayers = massOrder?.prayers.map { var prayer = $0; prayer.category = category; return prayer } ?? []
                        allPrayers.append(contentsOf: prayers)
                        
                    case "angelus_domini.json":
                        angelusPrayers = try JSONDecoder().decode(AngelusContainer.self, from: data)
                        let prayers = angelusPrayers?.angelus.common_prayers.values.map { var prayer = $0; prayer.category = category; return prayer } ?? []
                        allPrayers.append(contentsOf: prayers)
                        
                    case "divine_mercy_chaplet.json":
                        divineMercyPrayers = try JSONDecoder().decode(DivineMercyContainer.self, from: data)
                        let prayers = divineMercyPrayers?.divine_mercy_chaplet.common_prayers.values.map { var prayer = $0; prayer.category = category; return prayer } ?? []
                        allPrayers.append(contentsOf: prayers)
                        
                    default:
                        if let prayersContainer = try? JSONDecoder().decode([String: [Prayer]].self, from: data),
                           var categoryPrayers = prayersContainer["prayers"] {
                            for i in categoryPrayers.indices {
                                categoryPrayers[i].category = category
                            }
                            allPrayers.append(contentsOf: categoryPrayers)
                        }
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
    
    // Helper methods to access specific prayer collections
    func getRosaryMysteries(type: String) -> [RosaryMystery]? {
        rosaryPrayers?.mysteries[type]
    }
    
    func getRosarySchedule(day: String) -> String? {
        rosaryPrayers?.schedule[day]
    }
    
    func getMassSection(_ section: String) -> [OrderItem]? {
        switch section {
        case "introductory":
            return massOrder?.order_of_mass.introductory_rites
        case "word":
            return massOrder?.order_of_mass.liturgy_of_the_word
        default:
            return nil
        }
    }
    
    func getAngelusSequence() -> [String]? {
        angelusPrayers?.angelus.template.sequence
    }
    
    func getDivineMercyTemplate() -> DivineMercyTemplate? {
        divineMercyPrayers?.divine_mercy_chaplet.template
    }
} 