import Foundation

struct BibleContent: Codable {
    let books: [Book]
}

struct Book: Codable, Identifiable {
    let id: String
    let name: String
    let chapters: [Chapter]
}

struct Chapter: Codable, Identifiable {
    let id: String
    let number: Int
    let verses: [Verse]
}

struct Verse: Codable, Identifiable {
    let id: String
    let number: Int
    let text: String
} 