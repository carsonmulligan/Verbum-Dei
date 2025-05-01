import Foundation

class BookmarkStore: ObservableObject {
    @Published private(set) var bookmarks: [Bookmark] = []
    private let saveKey = "SavedBookmarks"
    
    init() {
        loadBookmarks()
    }
    
    func addBookmark(_ bookmark: Bookmark) {
        bookmarks.append(bookmark)
        saveBookmarks()
    }
    
    func removeBookmark(withId id: UUID) {
        bookmarks.removeAll { $0.id == id }
        saveBookmarks()
    }
    
    func updateBookmark(_ bookmark: Bookmark) {
        if let index = bookmarks.firstIndex(where: { $0.id == bookmark.id }) {
            bookmarks[index] = bookmark
            saveBookmarks()
        }
    }
    
    func isVerseBookmarked(bookName: String, chapterNumber: Int, verseNumber: Int) -> Bool {
        bookmarks.contains { bookmark in
            bookmark.bookName == bookName &&
            bookmark.chapterNumber == chapterNumber &&
            bookmark.verseNumber == verseNumber
        }
    }
    
    func getBookmark(bookName: String, chapterNumber: Int, verseNumber: Int) -> Bookmark? {
        bookmarks.first { bookmark in
            bookmark.bookName == bookName &&
            bookmark.chapterNumber == chapterNumber &&
            bookmark.verseNumber == verseNumber
        }
    }
    
    private func loadBookmarks() {
        guard let data = UserDefaults.standard.data(forKey: saveKey) else { return }
        
        do {
            bookmarks = try JSONDecoder().decode([Bookmark].self, from: data)
        } catch {
            print("Error loading bookmarks: \(error)")
        }
    }
    
    private func saveBookmarks() {
        do {
            let data = try JSONEncoder().encode(bookmarks)
            UserDefaults.standard.set(data, forKey: saveKey)
        } catch {
            print("Error saving bookmarks: \(error)")
        }
    }
} 