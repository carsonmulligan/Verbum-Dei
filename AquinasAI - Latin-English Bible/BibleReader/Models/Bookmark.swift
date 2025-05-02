import Foundation

struct Bookmark: Identifiable, Codable, Equatable {
    let id: UUID
    let bookName: String
    let chapterNumber: Int
    let verseNumber: Int
    var note: String
    let timestamp: Date
    let verseText: String
    let latinText: String?
    
    init(bookName: String, chapterNumber: Int, verseNumber: Int, note: String = "", verseText: String, latinText: String? = nil) {
        self.id = UUID()
        self.bookName = bookName
        self.chapterNumber = chapterNumber
        self.verseNumber = verseNumber
        self.note = note
        self.timestamp = Date()
        self.verseText = verseText
        self.latinText = latinText
    }
    
    static func == (lhs: Bookmark, rhs: Bookmark) -> Bool {
        lhs.id == rhs.id
    }
} 