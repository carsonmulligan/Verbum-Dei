import Foundation
import SwiftUI

class SearchViewModel: ObservableObject {
    @Published var searchQuery = "" {
        didSet {
            performSearch(query: searchQuery)
        }
    }
    @Published var searchResults: [SearchResult] = []
    @Published var isSearching = false
    
    let bibleViewModel: BibleViewModel
    private var searchTask: Task<Void, Never>?
    
    init(bibleViewModel: BibleViewModel) {
        self.bibleViewModel = bibleViewModel
    }
    
    private func parseVerseReference(_ query: String) -> (bookName: String, chapter: Int, verse: Int)? {
        // Match patterns like "john 3:16", "John 3:16", "JOHN 3:16"
        let components = query.lowercased().trimmingCharacters(in: .whitespaces).components(separatedBy: " ")
        guard components.count == 2 else { return nil }
        
        let bookName = components[0]
        let chapterVerse = components[1].components(separatedBy: ":")
        guard chapterVerse.count == 2,
              let chapter = Int(chapterVerse[0]),
              let verse = Int(chapterVerse[1]) else {
            return nil
        }
        
        return (bookName: bookName, chapter: chapter, verse: verse)
    }
    
    private func searchForVerseReference(_ reference: (bookName: String, chapter: Int, verse: Int)) async -> [SearchResult] {
        // Find matching book
        guard let book = bibleViewModel.books.first(where: {
            bibleViewModel.getEnglishName(for: $0.name).lowercased().starts(with: reference.bookName)
        }) else { return [] }
        
        // Find matching chapter and verse
        guard let chapter = book.chapters.first(where: { $0.number == reference.chapter }),
              let verse = chapter.verses.first(where: { $0.number == reference.verse }) else { return [] }
        
        return [.verse(
            book: book,
            englishName: bibleViewModel.getEnglishName(for: book.name),
            chapter: chapter,
            verse: verse
        )]
    }
    
    private func searchContent(_ query: String) async -> [SearchResult] {
        var results: [SearchResult] = []
        let lowercaseQuery = query.lowercased()
        
        for book in bibleViewModel.books {
            if Task.isCancelled { return [] }
            
            let englishName = bibleViewModel.getEnglishName(for: book.name).lowercased()
            
            if englishName.contains(lowercaseQuery) {
                results.append(.book(
                    book: book,
                    englishName: bibleViewModel.getEnglishName(for: book.name)
                ))
            }
            
            for chapter in book.chapters {
                if Task.isCancelled { return [] }
                
                for verse in chapter.verses {
                    if Task.isCancelled { return [] }
                    
                    let englishText = verse.englishText.lowercased()
                    
                    if englishText.contains(lowercaseQuery) {
                        results.append(.verse(
                            book: book,
                            englishName: bibleViewModel.getEnglishName(for: book.name),
                            chapter: chapter,
                            verse: verse
                        ))
                    }
                }
            }
        }
        
        return results
    }
    
    private func performSearch(query: String) {
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
            
            let results: [SearchResult]
            
            // First try to parse as a verse reference
            if let reference = parseVerseReference(query) {
                results = await searchForVerseReference(reference)
            } else {
                // If no verse reference found or it didn't match, perform content search
                results = await searchContent(query)
            }
            
            // Update the published property on the main thread
            await MainActor.run {
                self.searchResults = results
                self.isSearching = false
            }
        }
    }
}

enum SearchResult: Identifiable, Hashable {
    case book(book: Book, englishName: String)
    case verse(book: Book, englishName: String, chapter: Chapter, verse: Verse)
    
    var id: String {
        switch self {
        case .book(let book, _):
            return "book-\(book.name)"
        case .verse(let book, _, let chapter, let verse):
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