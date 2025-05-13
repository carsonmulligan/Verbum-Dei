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
    
    private enum CodingKeys: String, CodingKey {
        case title
        case title_latin
        case title_english
        case latin
        case english
    }
    
    init(title: String, title_latin: String?, title_english: String?, latin: String, english: String, category: PrayerCategory = .basic) {
        self.title = title
        self.title_latin = title_latin
        self.title_english = title_english
        self.latin = latin
        self.english = english
        self.category = category
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        title = try container.decode(String.self, forKey: .title)
        title_latin = try container.decodeIfPresent(String.self, forKey: .title_latin)
        title_english = try container.decodeIfPresent(String.self, forKey: .title_english)
        latin = try container.decode(String.self, forKey: .latin)
        english = try container.decode(String.self, forKey: .english)
        category = .basic // Default category, will be set after decoding
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(title, forKey: .title)
        try container.encode(title_latin, forKey: .title_latin)
        try container.encode(title_english, forKey: .title_english)
        try container.encode(latin, forKey: .latin)
        try container.encode(english, forKey: .english)
    }
}

// MARK: - Basic Prayers Container
struct BasicPrayersContainer: Codable {
    let prayers: [Prayer]
}

// MARK: - Rosary Container
struct RosaryPrayersContainer: Codable {
    let common_prayers: [String: RosaryPrayer]
    let mysteries: [String: [RosaryMystery]]
    let schedule: [String: String]
    let template: RosaryTemplate
}

struct RosaryPrayer: Codable {
    let title_latin: String?
    let title_english: String?
    let latin: String
    let english: String
    
    var asPrayer: Prayer {
        Prayer(
            title: title_english ?? title_latin ?? "",
            title_latin: title_latin,
            title_english: title_english,
            latin: latin,
            english: english,
            category: .rosary
        )
    }
}

struct RosaryMystery: Codable {
    let number: Int
    let latin: String
    let english: String
}

struct RosaryTemplate: Codable {
    let opening: [TemplateItem]
    let decade: [TemplateItem]
    let closing: [String]
    
    enum TemplateItem: Codable, Hashable {
        case string(String)
        case object([String: TemplateObject])
        
        init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            if let str = try? container.decode(String.self) {
                self = .string(str)
            } else if let obj = try? container.decode([String: TemplateObject].self) {
                self = .object(obj)
            } else {
                throw DecodingError.dataCorruptedError(in: container, debugDescription: "Cannot decode TemplateItem")
            }
        }
        
        func encode(to encoder: Encoder) throws {
            var container = encoder.singleValueContainer()
            switch self {
            case .string(let str):
                try container.encode(str)
            case .object(let obj):
                try container.encode(obj)
            }
        }
        
        func hash(into hasher: inout Hasher) {
            switch self {
            case .string(let str):
                hasher.combine(0) // Discriminator for string case
                hasher.combine(str)
            case .object(let obj):
                hasher.combine(1) // Discriminator for object case
                // Convert dictionary to array of tuples to ensure consistent hashing
                let sortedPairs = obj.sorted(by: { $0.key < $1.key })
                for (key, value) in sortedPairs {
                    hasher.combine(key)
                    hasher.combine(value)
                }
            }
        }
        
        static func == (lhs: TemplateItem, rhs: TemplateItem) -> Bool {
            switch (lhs, rhs) {
            case (.string(let lhs), .string(let rhs)):
                return lhs == rhs
            case (.object(let lhs), .object(let rhs)):
                return lhs == rhs
            default:
                return false
            }
        }
    }
    
    struct TemplateObject: Codable, Hashable {
        let count: Int
        let intentions: [String]?
        
        private enum CodingKeys: CodingKey {
            case count, intentions
        }
        
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            count = try container.decode(Int.self, forKey: .count)
            intentions = try container.decodeIfPresent([String].self, forKey: .intentions)
        }
    }
}

// MARK: - Mass Container
struct OrderOfMassContainer: Codable {
    let prayers: [MassPrayer]
    let order_of_mass: OrderOfMass
}

struct MassPrayer: Codable {
    let title: String
    let title_latin: String?
    let title_english: String?
    let latin: String
    let english: String
    
    var asPrayer: Prayer {
        Prayer(
            title: title,
            title_latin: title_latin,
            title_english: title_english,
            latin: latin,
            english: english,
            category: .mass
        )
    }
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

// MARK: - Angelus Container
struct AngelusContainer: Codable {
    let angelus: AngelusContent
}

struct AngelusContent: Codable {
    let common_prayers: [String: AngelusPrayer]
    let template: AngelusTemplate
}

struct AngelusPrayer: Codable {
    let title_latin: String?
    let title_english: String?
    let latin: String
    let english: String
    
    var asPrayer: Prayer {
        Prayer(
            title: title_english ?? title_latin ?? "",
            title_latin: title_latin,
            title_english: title_english,
            latin: latin,
            english: english,
            category: .other
        )
    }
}

struct AngelusTemplate: Codable {
    let sequence: [String]
    let structure: AngelusStructure
}

struct AngelusStructure: Codable {
    let times_per_day: Int
    let customary_hours: [String]
}

// MARK: - Divine Mercy Container
struct DivineMercyContainer: Codable {
    let divine_mercy_chaplet: DivineMercyContent
}

struct DivineMercyContent: Codable {
    let common_prayers: [String: DivineMercyPrayer]
    let template: DivineMercyTemplate
}

struct DivineMercyPrayer: Codable {
    let title_latin: String?
    let title_english: String?
    let latin: String
    let english: String
    
    var asPrayer: Prayer {
        Prayer(
            title: title_english ?? title_latin ?? "",
            title_latin: title_latin,
            title_english: title_english,
            latin: latin,
            english: english,
            category: .divine
        )
    }
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
        print("Starting to load prayers...")
        let prayerFiles = [
            ("prayers.json", PrayerCategory.basic),
            ("rosay_prayers.json", PrayerCategory.rosary),
            ("divine_mercy_chaplet.json", PrayerCategory.divine),
            ("order_of_mass.json", PrayerCategory.mass),
            ("angelus_domini.json", PrayerCategory.other)
        ]
        
        var allPrayers: [Prayer] = []
        
        for (filename, category) in prayerFiles {
            print("Processing \(filename)...")
            if let url = Bundle.main.url(forResource: filename.replacingOccurrences(of: ".json", with: ""), withExtension: "json") {
                do {
                    let data = try Data(contentsOf: url)
                    print("Successfully loaded data from \(filename)")
                    
                    switch filename {
                    case "rosay_prayers.json":
                        let container = try JSONDecoder().decode(RosaryPrayersContainer.self, from: data)
                        rosaryPrayers = container
                        let prayerArray = container.common_prayers.values.map { $0.asPrayer }
                        print("Loaded \(prayerArray.count) rosary prayers")
                        allPrayers.append(contentsOf: prayerArray)
                        
                    case "order_of_mass.json":
                        let container = try JSONDecoder().decode(OrderOfMassContainer.self, from: data)
                        massOrder = container
                        let prayerArray = container.prayers.map { $0.asPrayer }
                        print("Loaded \(prayerArray.count) mass prayers")
                        allPrayers.append(contentsOf: prayerArray)
                        
                    case "angelus_domini.json":
                        let container = try JSONDecoder().decode(AngelusContainer.self, from: data)
                        angelusPrayers = container
                        let prayerArray = container.angelus.common_prayers.values.map { $0.asPrayer }
                        print("Loaded \(prayerArray.count) angelus prayers")
                        allPrayers.append(contentsOf: prayerArray)
                        
                    case "divine_mercy_chaplet.json":
                        let container = try JSONDecoder().decode(DivineMercyContainer.self, from: data)
                        divineMercyPrayers = container
                        let prayerArray = container.divine_mercy_chaplet.common_prayers.values.map { $0.asPrayer }
                        print("Loaded \(prayerArray.count) divine mercy prayers")
                        allPrayers.append(contentsOf: prayerArray)
                        
                    default:
                        if let prayersContainer = try? JSONDecoder().decode(BasicPrayersContainer.self, from: data) {
                            let mappedPrayers = prayersContainer.prayers.map { prayer -> Prayer in
                                var mutablePrayer = prayer
                                mutablePrayer.category = category
                                return mutablePrayer
                            }
                            print("Loaded \(mappedPrayers.count) basic prayers")
                            allPrayers.append(contentsOf: mappedPrayers)
                        }
                    }
                } catch {
                    print("❌ Error loading prayers from \(filename): \(error)")
                    // Print the data for debugging
                    if let data = try? Data(contentsOf: url),
                       let jsonString = String(data: data, encoding: .utf8) {
                        print("JSON content for \(filename):")
                        print(jsonString.prefix(200)) // Print first 200 characters for debugging
                    }
                }
            } else {
                print("❌ Could not find \(filename) in bundle")
            }
        }
        
        print("Total prayers loaded: \(allPrayers.count)")
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
    
    // Helper method to get mystery type description
    func getMysteryDescription(for type: String) -> String {
        switch type {
        case "joyful":
            return "The Joyful Mysteries focus on the events surrounding Christ's birth and early life."
        case "sorrowful":
            return "The Sorrowful Mysteries meditate on Christ's Passion and death."
        case "glorious":
            return "The Glorious Mysteries contemplate Christ's Resurrection and the glories of Heaven."
        case "luminous":
            return "The Luminous Mysteries reflect on key moments in Christ's public ministry."
        default:
            return ""
        }
    }
} 