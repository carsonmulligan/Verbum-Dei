import Foundation

struct BibleContent: Codable {
    let charset: String?
    let lang: String?
    private let contents: [String: [String: [String: String]]]
    
    // Custom coding keys to handle dynamic book names
    private enum CodingKeys: String, CodingKey {
        case charset
        case lang
    }
    
    // Custom decoding to handle the dynamic book structure
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        charset = try? container.decode(String.self, forKey: .charset)
        lang = try? container.decode(String.self, forKey: .lang)
        
        // Decode the dynamic book content
        let dynamicContainer = try decoder.container(keyedBy: DynamicCodingKeys.self)
        var tempContents: [String: [String: [String: String]]] = [:]
        
        for key in dynamicContainer.allKeys {
            if key.stringValue != "charset" && key.stringValue != "lang" {
                tempContents[key.stringValue] = try dynamicContainer.decode([String: [String: String]].self, forKey: key)
            }
        }
        contents = tempContents
    }
    
    // Computed property to get books in a more usable format
    var books: [Book] {
        contents.map { bookName, chapters in
            let processedChapters = chapters.map { chapterNum, verses in
                let processedVerses = verses.map { verseNum, text in
                    Verse(id: "\(chapterNum):\(verseNum)", 
                         number: Int(verseNum) ?? 0,
                         latinText: text,
                         englishText: text,
                         spanishText: text)
                }.sorted { $0.number < $1.number }
                
                return Chapter(
                    id: chapterNum,
                    number: Int(chapterNum) ?? 0,
                    verses: processedVerses
                )
            }.sorted { $0.number < $1.number }
            
            return Book(name: bookName, chapters: processedChapters)
        }.sorted { 
            BibleBookMetadata.getOrder(for: $0.name) < BibleBookMetadata.getOrder(for: $1.name)
        }
    }
}

// Helper struct to handle dynamic keys in JSON
private struct DynamicCodingKeys: CodingKey {
    var stringValue: String
    var intValue: Int?
    
    init?(stringValue: String) {
        self.stringValue = stringValue
        self.intValue = nil
    }
    
    init?(intValue: Int) {
        self.stringValue = String(intValue)
        self.intValue = intValue
    }
}

// Represents the content of a book (chapters)
struct BookContent: Codable {
    let chapters: [String: [String: String]]
    
    // Convert the raw chapter data into our Chapter model
    var processedChapters: [Chapter] {
        chapters.map { chapterNum, verses in
            let processedVerses = verses.map { verseNum, text in
                Verse(id: "\(chapterNum):\(verseNum)", 
                     number: Int(verseNum) ?? 0,
                     latinText: text,
                     englishText: text,
                     spanishText: text)
            }.sorted { $0.number < $1.number }
            
            return Chapter(
                id: chapterNum,
                number: Int(chapterNum) ?? 0,
                verses: processedVerses
            )
        }.sorted { $0.number < $1.number }
    }
}

// MARK: - Language Support

enum Language: String, CaseIterable {
    case latin = "latin"
    case english = "english"
    case spanish = "spanish"
    
    var displayName: String {
        switch self {
        case .latin: return "Latin"
        case .english: return "English"
        case .spanish: return "Español"
        }
    }
    
    var jsonFileName: String {
        switch self {
        case .latin: return "vulgate_latin"
        case .english: return "vulgate_english"
        case .spanish: return "vulgate_spanish_RV"
        }
    }
    
    var shortCode: String {
        switch self {
        case .latin: return "LA"
        case .english: return "EN"
        case .spanish: return "ES"
        }
    }
}

enum DisplayMode: String, CaseIterable {
    case latinOnly = "latinOnly"
    case englishOnly = "englishOnly"
    case spanishOnly = "spanishOnly"
    case latinEnglish = "latinEnglish"
    case latinSpanish = "latinSpanish"
    case englishSpanish = "englishSpanish"
    
    var description: String {
        switch self {
        case .latinOnly: return "Latin"
        case .englishOnly: return "English"
        case .spanishOnly: return "Español"
        case .latinEnglish: return "Latin-English"
        case .latinSpanish: return "Latin-Español"
        case .englishSpanish: return "English-Español"
        }
    }
    
    var languages: [Language] {
        switch self {
        case .latinOnly: return [.latin]
        case .englishOnly: return [.english]
        case .spanishOnly: return [.spanish]
        case .latinEnglish: return [.latin, .english]
        case .latinSpanish: return [.latin, .spanish]
        case .englishSpanish: return [.english, .spanish]
        }
    }
    
    var primaryLanguage: Language {
        return languages.first!
    }
    
    var secondaryLanguage: Language? {
        return languages.count > 1 ? languages[1] : nil
    }
    
    var isBilingual: Bool {
        return languages.count > 1
    }
    
    // Navigation title based on display mode
    var navigationTitle: String {
        switch self {
        case .latinOnly, .latinEnglish, .latinSpanish:
            return "Biblia Sacra"
        case .englishOnly, .englishSpanish:
            return "Holy Bible"
        case .spanishOnly:
            return "Santa Biblia"
        }
    }
}

// MARK: - Core Models

// Models for the view layer
struct Book: Identifiable, Equatable {
    let name: String
    let chapters: [Chapter]
    
    var id: String { name }
    
    var metadata: BibleBookMetadata? {
        BibleBookMetadata.allBooks.first { $0.latin == name }
    }
    
    var displayName: String {
        metadata?.english ?? name
    }
    
    // Get display name for specific language
    func displayName(for language: Language, mappings: BookNameMappings?) -> String {
        guard let mappings = mappings else { return name }
        
        switch language {
        case .latin:
            return name
        case .english:
            return mappings.vulgate_to_english[name] ?? name
        case .spanish:
            return mappings.vulgate_to_spanish[name] ?? name
        }
    }
    
    // Check if book is available in Spanish
    var isAvailableInSpanish: Bool {
        let missingBooks = ["Baruch", "Ecclesiasticus", "Judith", "Machabaeorum I", "Machabaeorum II", "Sapientia", "Tobiae"]
        return !missingBooks.contains(name)
    }
    
    static func == (lhs: Book, rhs: Book) -> Bool {
        lhs.name == rhs.name
    }
}

struct Chapter: Identifiable, Equatable {
    let id: String
    let number: Int
    let verses: [Verse]
    
    static func == (lhs: Chapter, rhs: Chapter) -> Bool {
        lhs.id == rhs.id && lhs.number == rhs.number
    }
}

struct Verse: Identifiable, Equatable {
    let id: String
    let number: Int
    let latinText: String
    let englishText: String
    let spanishText: String
    
    // Get text for specific language
    func text(for language: Language) -> String {
        switch language {
        case .latin: return latinText
        case .english: return englishText
        case .spanish: return spanishText
        }
    }
    
    // Get display text for specific display mode
    func displayText(for mode: DisplayMode) -> String {
        switch mode {
        case .latinOnly:
            return latinText
        case .englishOnly:
            return englishText
        case .spanishOnly:
            return spanishText
        case .latinEnglish:
            return "\(latinText)\n\n\(englishText)"
        case .latinSpanish:
            return "\(latinText)\n\n\(spanishText)"
        case .englishSpanish:
            return "\(englishText)\n\n\(spanishText)"
        }
    }
    
    static func == (lhs: Verse, rhs: Verse) -> Bool {
        lhs.id == rhs.id && lhs.number == rhs.number
    }
} 