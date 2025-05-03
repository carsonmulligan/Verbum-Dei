import Foundation

struct BibleContent: Codable {
    let charset: String
    private let contents: [String: [String: [String: String]]]
    
    // Computed property to get books in a more usable format
    var books: [Book] {
        contents.map { bookName, chapters in
            let processedChapters = chapters.map { chapterNum, verses in
                let processedVerses = verses.map { verseNum, text in
                    Verse(id: "\(chapterNum):\(verseNum)", 
                         number: Int(verseNum) ?? 0,
                         latinText: text,
                         englishText: text)
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
    
    // Custom coding keys to handle dynamic book names
    private enum CodingKeys: String, CodingKey {
        case charset
    }
    
    // Custom decoding to handle the dynamic book structure
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        charset = try container.decode(String.self, forKey: .charset)
        
        // Decode the dynamic book content
        let dynamicContainer = try decoder.container(keyedBy: DynamicCodingKeys.self)
        var tempContents: [String: [String: [String: String]]] = [:]
        
        for key in dynamicContainer.allKeys {
            if key.stringValue != "charset" {
                tempContents[key.stringValue] = try dynamicContainer.decode([String: [String: String]].self, forKey: key)
            }
        }
        contents = tempContents
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
                     englishText: text)
            }.sorted { $0.number < $1.number }
            
            return Chapter(
                id: chapterNum,
                number: Int(chapterNum) ?? 0,
                verses: processedVerses
            )
        }.sorted { $0.number < $1.number }
    }
}

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
    
    static func == (lhs: Verse, rhs: Verse) -> Bool {
        lhs.id == rhs.id && lhs.number == rhs.number
    }
}

enum DisplayMode {
    case latinOnly
    case englishOnly
    case bilingual
    
    var description: String {
        switch self {
        case .latinOnly: return "Latin"
        case .englishOnly: return "English"
        case .bilingual: return "Bilingual"
        }
    }
} 