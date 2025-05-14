import Foundation

// MARK: - Prayer Models
struct Prayer: Identifiable, Codable {
    var id: String {
        // Create a normalized ID from the title by removing spaces and special characters
        let normalized = title
            .lowercased()
            .replacingOccurrences(of: " ", with: "_")
            .replacingOccurrences(of: ",", with: "")
            .replacingOccurrences(of: ".", with: "")
            .replacingOccurrences(of: "'", with: "")
            .replacingOccurrences(of: "\"", with: "")
            .replacingOccurrences(of: "(", with: "")
            .replacingOccurrences(of: ")", with: "")
        return normalized
    }
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

struct RosaryMystery: Codable, Identifiable {
    var id: Int { number }
    let number: Int
    let latin: String
    let english: String
}

struct TemplateObject: Codable, Hashable {
    let count: Int
    let intentions: [String]?
    
    init(count: Int, intentions: [String]? = nil) {
        self.count = count
        self.intentions = intentions
    }
}

struct PrayerIntention: Codable {
    let count: Int
    let intentions: [String]
}

struct RosaryTemplate: Codable {
    let opening: [OrderItem]
    let decade: [OrderItem]
    let closing: [String]
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        print("Starting to decode RosaryTemplate...")
        
        // Decode opening array
        var openingItems: [OrderItem] = []
        var openingArrayContainer = try container.nestedUnkeyedContainer(forKey: .opening)
        print("Decoding opening prayers...")
        
        while !openingArrayContainer.isAtEnd {
            do {
                let item = try openingArrayContainer.decode(OrderItem.self)
                openingItems.append(item)
            } catch {
                print("❌ Error decoding opening prayer item: \(error)")
                throw error
            }
        }
        opening = openingItems
        print("Successfully decoded \(openingItems.count) opening prayers")
        
        // Decode decade array
        var decadeItems: [OrderItem] = []
        var decadeArrayContainer = try container.nestedUnkeyedContainer(forKey: .decade)
        print("Decoding decade prayers...")
        
        while !decadeArrayContainer.isAtEnd {
            do {
                let item = try decadeArrayContainer.decode(OrderItem.self)
                decadeItems.append(item)
            } catch {
                print("❌ Error decoding decade prayer item: \(error)")
                throw error
            }
        }
        decade = decadeItems
        print("Successfully decoded \(decadeItems.count) decade prayers")
        
        closing = try container.decode([String].self, forKey: .closing)
        print("Successfully decoded \(closing.count) closing prayers")
        
        print("✅ Completed decoding RosaryTemplate")
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(opening, forKey: .opening)
        try container.encode(decade, forKey: .decade)
        try container.encode(closing, forKey: .closing)
    }
    
    private enum CodingKeys: String, CodingKey {
        case opening, decade, closing
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

enum OrderItem: Codable, Hashable {
    case string(String)
    case array([String])
    case dictionary([String: [String]])
    case templateObject([String: TemplateObject])
    case prayerCount(String, Int)
    case prayerWithIntentions(String, Int, [String])
    case object(PrayerObject)
    
    private struct IntentionWrapper: Codable {
        let count: Int
        let intentions: [String]
    }
    
    var id: String? {
        switch self {
        case .string(let id):
            return id
        case .prayerCount(let id, _):
            return id
        case .prayerWithIntentions(let id, _, _):
            return id
        case .object(let obj):
            return obj.id
        default:
            return nil
        }
    }
    
    // Helper function to convert to PrayerObject
    var asPrayerObject: PrayerObject? {
        switch self {
        case .string(let id):
            return PrayerObject(id: id, count: 1, intentions: nil)
        case .prayerCount(let id, let count):
            return PrayerObject(id: id, count: count, intentions: nil)
        case .prayerWithIntentions(let id, let count, let intentions):
            return PrayerObject(id: id, count: count, intentions: intentions)
        case .object(let obj):
            return obj
        default:
            return nil
        }
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        print("Decoding OrderItem...")
        
        // Try decoding as String first
        if let str = try? container.decode(String.self) {
            print("Decoded as string: \(str)")
            self = .string(str)
            return
        }
        
        // Try decoding as String array
        if let arr = try? container.decode([String].self) {
            print("Decoded as string array: \(arr)")
            self = .array(arr)
            return
        }
        
        // Try decoding as dictionary with string array values
        if let dict = try? container.decode([String: [String]].self) {
            print("Decoded as dictionary with string array: \(dict)")
            self = .dictionary(dict)
            return
        }
        
        // Try decoding as template object
        if let dict = try? container.decode([String: TemplateObject].self) {
            print("Decoded as template object: \(dict)")
            self = .templateObject(dict)
            return
        }
        
        // Try decoding as simple prayer count
        if let dict = try? container.decode([String: Int].self),
           let (key, count) = dict.first {
            print("Decoded as prayer count: \(key) (\(count)x)")
            self = .prayerCount(key, count)
            return
        }
        
        // Try decoding as prayer with intentions
        if let dict = try? container.decode([String: IntentionWrapper].self),
           let (key, wrapper) = dict.first {
            print("Decoded as prayer with intentions: \(key) (\(wrapper.count)x, intentions: \(wrapper.intentions))")
            self = .prayerWithIntentions(key, wrapper.count, wrapper.intentions)
            return
        }
        
        // Try decoding as prayer with count and intentions in nested structure
        if let dict = try? container.decode([String: [String: String]].self),
           let (key, details) = dict.first,
           let countStr = details["count"],
           let count = Int(countStr),
           let intentionsStr = details["intentions"],
           let intentions = try? JSONDecoder().decode([String].self, from: intentionsStr.data(using: .utf8) ?? Data()) {
            print("Decoded as prayer with nested count and intentions: \(key) (\(count)x, intentions: \(intentions))")
            self = .prayerWithIntentions(key, count, intentions)
            return
        }
        
        throw DecodingError.dataCorruptedError(
            in: container,
            debugDescription: "Cannot decode OrderItem: data doesn't match any expected format"
        )
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .string(let str):
            try container.encode(str)
        case .array(let arr):
            try container.encode(arr)
        case .dictionary(let dict):
            try container.encode(dict)
        case .templateObject(let dict):
            try container.encode(dict)
        case .prayerCount(let prayer, let count):
            try container.encode([prayer: count])
        case .prayerWithIntentions(let prayer, let count, let intentions):
            let wrapper = IntentionWrapper(count: count, intentions: intentions)
            try container.encode([prayer: wrapper])
        case .object(let obj):
            try container.encode(obj)
        }
    }
    
    func hash(into hasher: inout Hasher) {
        switch self {
        case .string(let str):
            hasher.combine(0)
            hasher.combine(str)
        case .array(let arr):
            hasher.combine(1)
            hasher.combine(arr)
        case .dictionary(let dict):
            hasher.combine(2)
            hasher.combine(dict)
        case .templateObject(let dict):
            hasher.combine(3)
            hasher.combine(dict)
        case .prayerCount(let prayer, let count):
            hasher.combine(4)
            hasher.combine(prayer)
            hasher.combine(count)
        case .prayerWithIntentions(let prayer, let count, let intentions):
            hasher.combine(5)
            hasher.combine(prayer)
            hasher.combine(count)
            hasher.combine(intentions)
        case .object(let obj):
            hasher.combine(6)
            hasher.combine(obj)
        }
    }
    
    static func == (lhs: OrderItem, rhs: OrderItem) -> Bool {
        switch (lhs, rhs) {
        case (.string(let lhs), .string(let rhs)):
            return lhs == rhs
        case (.array(let lhs), .array(let rhs)):
            return lhs == rhs
        case (.dictionary(let lhs), .dictionary(let rhs)):
            return lhs == rhs
        case (.templateObject(let lhs), .templateObject(let rhs)):
            return lhs == rhs
        case (.prayerCount(let lhsPrayer, let lhsCount), .prayerCount(let rhsPrayer, let rhsCount)):
            return lhsPrayer == rhsPrayer && lhsCount == rhsCount
        case (.prayerWithIntentions(let lhsPrayer, let lhsCount, let lhsIntentions),
              .prayerWithIntentions(let rhsPrayer, let rhsCount, let rhsIntentions)):
            return lhsPrayer == rhsPrayer && lhsCount == rhsCount && lhsIntentions == rhsIntentions
        case (.object(let lhs), .object(let rhs)):
            return lhs == rhs
        default:
            return false
        }
    }
}

// New struct to represent a prayer with count and optional intentions
struct PrayerObject: Codable, Hashable {
    let id: String
    let count: Int
    let intentions: [String]?
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
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        print("Starting to decode DivineMercyTemplate...")
        
        opening = try container.decode([String].self, forKey: .opening)
        print("Successfully decoded \(opening.count) opening prayers")
        
        // Decode decade array
        var decadeItems: [OrderItem] = []
        var decadeArrayContainer = try container.nestedUnkeyedContainer(forKey: .decade)
        print("Decoding decade prayers...")
        
        while !decadeArrayContainer.isAtEnd {
            do {
                let item = try decadeArrayContainer.decode(OrderItem.self)
                decadeItems.append(item)
            } catch {
                print("❌ Error decoding decade prayer item: \(error)")
                throw error
            }
        }
        decade = decadeItems
        print("Successfully decoded \(decadeItems.count) decade prayers")
        
        // Decode closing array
        var closingItems: [OrderItem] = []
        var closingArrayContainer = try container.nestedUnkeyedContainer(forKey: .closing)
        print("Decoding closing prayers...")
        
        while !closingArrayContainer.isAtEnd {
            do {
                let item = try closingArrayContainer.decode(OrderItem.self)
                closingItems.append(item)
            } catch {
                print("❌ Error decoding closing prayer item: \(error)")
                throw error
            }
        }
        closing = closingItems
        print("Successfully decoded \(closingItems.count) closing prayers")
        
        structure = try container.decode(DivineMercyStructure.self, forKey: .structure)
        print("Successfully decoded structure")
        
        print("✅ Completed decoding DivineMercyTemplate")
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(opening, forKey: .opening)
        try container.encode(decade, forKey: .decade)
        try container.encode(closing, forKey: .closing)
        try container.encode(structure, forKey: .structure)
    }
    
    private enum CodingKeys: String, CodingKey {
        case opening, decade, closing, structure
    }
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
    
    func loadPrayers() {
        print("Starting to load prayers...")
        let prayerFiles = [
            ("prayers.json", PrayerCategory.basic),
            ("rosary_prayers.json", PrayerCategory.rosary),
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
                    case "rosary_prayers.json":
                        print("Decoding rosary prayers...")
                        let container = try JSONDecoder().decode(RosaryPrayersContainer.self, from: data)
                        print("Successfully decoded rosary prayers. Mysteries count: \(container.mysteries.count)")
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