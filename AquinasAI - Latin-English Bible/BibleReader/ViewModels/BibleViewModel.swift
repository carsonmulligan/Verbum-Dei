import Foundation

struct BookNameMappings: Codable {
    let description: String
    let vulgate_to_english: [String: String]
    let english_to_vulgate: [String: String]
}

class BibleViewModel: ObservableObject {
    @Published var books: [Book] = []
    @Published var errorMessage: String?
    @Published var displayMode: DisplayMode = .bilingual
    
    private var bookNameMappings: BookNameMappings?
    
    init() {
        loadBookNameMappings()
        loadBibleContent()
    }
    
    private func loadBookNameMappings() {
        guard let url = Bundle.main.url(forResource: "mappings", withExtension: "json") else {
            print("Warning: Could not find mappings.json")
            return
        }
        
        do {
            let data = try Data(contentsOf: url)
            bookNameMappings = try JSONDecoder().decode(BookNameMappings.self, from: data)
            print("Successfully loaded book name mappings")
        } catch {
            print("Error loading mappings.json: \(error)")
        }
    }
    
    private func loadBibleContent() {
        // Print the main bundle path for debugging
        print("Bundle path: \(Bundle.main.bundlePath)")
        
        // List all resources in the bundle for debugging
        let resourcePaths = Bundle.main.paths(forResourcesOfType: "json", inDirectory: nil)
        print("Found JSON files in bundle: \(resourcePaths)")
        
        guard let latinUrl = Bundle.main.url(forResource: "vulgate_latin", withExtension: "json"),
              let englishUrl = Bundle.main.url(forResource: "vulgate_english", withExtension: "json") else {
            errorMessage = "Could not find Bible content files in bundle."
            return
        }
        
        do {
            let latinData = try Data(contentsOf: latinUrl)
            let englishData = try Data(contentsOf: englishUrl)
            
            let latinContent = try JSONDecoder().decode(BibleContent.self, from: latinData)
            let englishContent = try JSONDecoder().decode(BibleContent.self, from: englishData)
            
            // Create a dictionary of English books for faster lookup
            var englishBooksDictionary: [String: Book] = [:]
            for englishBook in englishContent.books {
                if let latinName = bookNameMappings?.english_to_vulgate[englishBook.name] {
                    englishBooksDictionary[latinName] = englishBook
                }
            }
            
            // Merge Latin and English content safely
            var mergedBooks: [Book] = []
            
            for latinBook in latinContent.books {
                guard let englishBook = englishBooksDictionary[latinBook.name] else {
                    print("Warning: No matching English book found for \(latinBook.name)")
                    continue
                }
                
                // Create a dictionary of English chapters for faster lookup
                let englishChaptersDictionary = Dictionary(
                    uniqueKeysWithValues: englishBook.chapters.map { ("\($0.number)", $0) }
                )
                
                var mergedChapters: [Chapter] = []
                
                for latinChapter in latinBook.chapters {
                    guard let englishChapter = englishChaptersDictionary["\(latinChapter.number)"] else {
                        print("Warning: No matching English chapter found for \(latinBook.name) chapter \(latinChapter.number)")
                        continue
                    }
                    
                    // Create a dictionary of English verses for faster lookup
                    let englishVersesDictionary = Dictionary(
                        uniqueKeysWithValues: englishChapter.verses.map { ("\($0.number)", $0) }
                    )
                    
                    let mergedVerses = latinChapter.verses.compactMap { latinVerse -> Verse? in
                        guard let englishVerse = englishVersesDictionary["\(latinVerse.number)"] else {
                            print("Warning: No matching English verse found for \(latinBook.name) \(latinChapter.number):\(latinVerse.number)")
                            return nil
                        }
                        
                        return Verse(
                            id: latinVerse.id,
                            number: latinVerse.number,
                            latinText: latinVerse.latinText,
                            englishText: englishVerse.latinText
                        )
                    }
                    
                    if !mergedVerses.isEmpty {
                        let chapter = Chapter(
                            id: latinChapter.id,
                            number: latinChapter.number,
                            verses: mergedVerses
                        )
                        mergedChapters.append(chapter)
                    } else {
                        print("Warning: No verses found for \(latinBook.name) chapter \(latinChapter.number)")
                    }
                }
                
                if !mergedChapters.isEmpty {
                    let book = Book(
                        name: latinBook.name,
                        chapters: mergedChapters
                    )
                    mergedBooks.append(book)
                } else {
                    print("Warning: No chapters found for \(latinBook.name)")
                }
            }
            
            self.books = mergedBooks
            
            if books.isEmpty {
                errorMessage = "No matching content found between Latin and English texts."
            } else {
                print("Successfully loaded and merged Bible content: \(books.count) books")
            }
        } catch {
            print("Error loading content: \(error)")
            errorMessage = "Error loading Bible content: \(error.localizedDescription)"
        }
    }
} 