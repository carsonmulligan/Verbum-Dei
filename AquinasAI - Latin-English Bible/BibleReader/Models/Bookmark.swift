import Foundation

enum BookmarkType: String, Codable {
    case verse
    case prayer
}

struct Bookmark: Identifiable, Codable {
    let id: UUID
    let type: BookmarkType
    
    // Bible verse fields
    let bookName: String?
    let chapterNumber: Int?
    let verseNumber: Int?
    let verseText: String?
    let latinText: String?
    
    // Prayer fields
    let prayerId: String?
    let prayerTitle: String?
    let prayerTitleLatin: String?
    let prayerTitleEnglish: String?
    let prayerLatin: String?
    let prayerEnglish: String?
    let prayerCategory: String?
    
    // Common fields
    var note: String
    let timestamp: Date
    
    // Constructor for verse bookmarks
    init(bookName: String, chapterNumber: Int, verseNumber: Int, note: String = "", verseText: String, latinText: String? = nil) {
        self.id = UUID()
        self.type = .verse
        self.bookName = bookName
        self.chapterNumber = chapterNumber
        self.verseNumber = verseNumber
        self.verseText = verseText
        self.latinText = latinText
        self.note = note
        self.timestamp = Date()
        
        // Prayer fields are null
        self.prayerId = nil
        self.prayerTitle = nil
        self.prayerTitleLatin = nil
        self.prayerTitleEnglish = nil
        self.prayerLatin = nil
        self.prayerEnglish = nil
        self.prayerCategory = nil
    }
    
    // Constructor for prayer bookmarks
    init(prayer: Prayer, note: String = "") {
        self.id = UUID()
        self.type = .prayer
        self.prayerId = prayer.id
        self.prayerTitle = prayer.title
        self.prayerTitleLatin = prayer.title_latin
        self.prayerTitleEnglish = prayer.title_english
        self.prayerLatin = prayer.latin
        self.prayerEnglish = prayer.english
        self.prayerCategory = prayer.category.rawValue
        self.note = note
        self.timestamp = Date()
        
        // Verse fields are null
        self.bookName = nil
        self.chapterNumber = nil
        self.verseNumber = nil
        self.verseText = nil
        self.latinText = nil
    }
} 