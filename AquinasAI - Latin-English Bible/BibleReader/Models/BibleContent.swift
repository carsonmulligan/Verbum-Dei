import Foundation

struct BibleContent: Codable {
    let charset: String
    private let contents: [String: BookContent]
    
    // Computed property to get books in a more usable format
    var books: [Book] {
        contents.map { bookName, content in
            Book(name: bookName, chapters: content.processedChapters)
        }.sorted { $0.name < $1.name }
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
        var tempContents: [String: BookContent] = [:]
        
        for key in dynamicContainer.allKeys {
            if key.stringValue != "charset" {
                tempContents[key.stringValue] = try dynamicContainer.decode(BookContent.self, forKey: key)
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
                     text: text)
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
struct Book: Identifiable {
    let name: String
    let chapters: [Chapter]
    
    var id: String { name }
}

struct Chapter: Identifiable {
    let id: String
    let number: Int
    let verses: [Verse]
}

struct Verse: Identifiable {
    let id: String
    let number: Int
    let text: String
} 