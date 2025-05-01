import Foundation
import SwiftUI

class SearchViewModel: ObservableObject {
    @Published var searchQuery = ""
    @Published var searchResults: [SearchResult] = []
    @Published var isSearching = false
    
    private let bibleViewModel: BibleViewModel
    private var searchTask: Task<Void, Never>?
    
    init(bibleViewModel: BibleViewModel) {
        self.bibleViewModel = bibleViewModel
    }
    
    func performSearch(query: String) {
        // Cancel any existing search task
        searchTask?.cancel()
        
        guard !query.isEmpty else {
            searchResults = []
            return
        }
        
        isSearching = true
        
        // Create a new search task
        searchTask = Task { [weak self] in
            guard let self = self else { return }
            
            var results: [SearchResult] = []
            let lowercaseQuery = query.lowercased()
            
            // Search through book names
            for book in self.bibleViewModel.books {
                let latinName = book.name.lowercased()
                let englishName = self.bibleViewModel.getEnglishName(for: book.name).lowercased()
                
                if latinName.contains(lowercaseQuery) || englishName.contains(lowercaseQuery) {
                    results.append(.book(book))
                }
                
                // Search through verses
                for chapter in book.chapters {
                    for verse in chapter.verses {
                        if Task.isCancelled { return }
                        
                        let latinText = verse.latinText.lowercased()
                        let englishText = verse.englishText.lowercased()
                        
                        if latinText.contains(lowercaseQuery) || englishText.contains(lowercaseQuery) {
                            results.append(.verse(
                                book: book,
                                chapter: chapter,
                                verse: verse
                            ))
                        }
                    }
                }
            }
            
            await MainActor.run {
                self.searchResults = results
                self.isSearching = false
            }
        }
    }
}

enum SearchResult: Identifiable, Hashable {
    case book(Book)
    case verse(book: Book, chapter: Chapter, verse: Verse)
    
    var id: String {
        switch self {
        case .book(let book):
            return "book-\(book.name)"
        case .verse(let book, let chapter, let verse):
            return "verse-\(book.name)-\(chapter.number)-\(verse.number)"
        }
    }
    
    static func == (lhs: SearchResult, rhs: SearchResult) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
} 