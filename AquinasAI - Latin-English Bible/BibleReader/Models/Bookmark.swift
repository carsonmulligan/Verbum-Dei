import Foundation

struct Bookmark: Identifiable, Codable {
    let id: UUID
    let bookName: String
    let chapterNumber: Int
    let verseNumber: Int
    var note: String
    let timestamp: Date
    let verseText: String
    
    init(bookName: String, chapterNumber: Int, verseNumber: Int, note: String = "", verseText: String) {
        self.id = UUID()
        self.bookName = bookName
        self.chapterNumber = chapterNumber
        self.verseNumber = verseNumber
        self.note = note
        self.timestamp = Date()
        self.verseText = verseText
    }
} 