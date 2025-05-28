import Foundation

struct BookNameMappings: Codable {
    let description: String
    let vulgate_to_english: [String: String]
    let vulgate_to_spanish: [String: String]
    let english_to_vulgate: [String: String]
    let spanish_to_vulgate: [String: String]
    let english_to_spanish: [String: String]
    let spanish_to_english: [String: String]
    let missing_books: MissingBooks?
    let notes: [String: String]?
    
    struct MissingBooks: Codable {
        let spanish_only: [String]
        let latin_only: [String]
        let english_only: [String]
    }
}

class BibleViewModel: ObservableObject {
    @Published var books: [Book] = []
    @Published var errorMessage: String?
    @Published var displayMode: DisplayMode = .latinEnglish
    
    private var bookNameMappings: BookNameMappings?
    
    init() {
        loadBookNameMappings()
        loadBibleContent()
    }
    
    // MARK: - Public Methods
    
    // Get book name for specific language
    func getBookName(for latinName: String, in language: Language) -> String {
        guard let mappings = bookNameMappings else { return latinName }
        
        switch language {
        case .latin:
            return latinName
        case .english:
            return mappings.vulgate_to_english[latinName] ?? latinName
        case .spanish:
            return mappings.vulgate_to_spanish[latinName] ?? latinName
        }
    }
    
    // Get English name (for backwards compatibility)
    func getEnglishName(for latinName: String) -> String {
        return getBookName(for: latinName, in: .english)
    }
    
    // Check if book is available in specific language
    func isBookAvailable(_ latinName: String, in language: Language) -> Bool {
        switch language {
        case .latin, .english:
            return true
        case .spanish:
            let missingBooks = bookNameMappings?.missing_books?.latin_only ?? []
            return !missingBooks.contains(latinName)
        }
    }
    
    // MARK: - Private Methods
    
    private func loadBookNameMappings() {
        guard let url = Bundle.main.url(forResource: "mappings_three_languages", withExtension: "json", subdirectory: "Bible") else {
            print("Warning: Could not find mappings_three_languages.json in Bible directory")
            // Fallback to old mappings
            loadLegacyMappings()
            return
        }
        
        do {
            let data = try Data(contentsOf: url)
            bookNameMappings = try JSONDecoder().decode(BookNameMappings.self, from: data)
            print("Successfully loaded three-language book name mappings")
        } catch {
            print("Error loading mappings_three_languages.json: \(error)")
            // Fallback to old mappings
            loadLegacyMappings()
        }
    }
    
    private func loadLegacyMappings() {
        guard let url = Bundle.main.url(forResource: "mappings", withExtension: "json") else {
            print("Error: Could not find any mappings file")
            return
        }
        
        do {
            let data = try Data(contentsOf: url)
            let legacyMappings = try JSONDecoder().decode(LegacyBookNameMappings.self, from: data)
            
            // Convert to new format
            bookNameMappings = BookNameMappings(
                description: legacyMappings.description,
                vulgate_to_english: legacyMappings.vulgate_to_english,
                vulgate_to_spanish: [:], // Empty for legacy
                english_to_vulgate: legacyMappings.english_to_vulgate,
                spanish_to_vulgate: [:], // Empty for legacy
                english_to_spanish: [:], // Empty for legacy
                spanish_to_english: [:], // Empty for legacy
                missing_books: nil,
                notes: nil
            )
            print("Loaded legacy mappings as fallback")
        } catch {
            print("Error loading legacy mappings.json: \(error)")
        }
    }
    
    private func loadBibleContent() {
        print("Bundle path: \(Bundle.main.bundlePath)")
        
        // List all resources in the bundle for debugging
        let resourcePaths = Bundle.main.paths(forResourcesOfType: "json", inDirectory: nil)
        print("Found JSON files in bundle: \(resourcePaths)")
        
        guard let latinUrl = Bundle.main.url(forResource: "vulgate_latin", withExtension: "json", subdirectory: "Bible"),
              let englishUrl = Bundle.main.url(forResource: "vulgate_english", withExtension: "json", subdirectory: "Bible") else {
            errorMessage = "Could not find required Bible content files in bundle."
            return
        }
        
        // Spanish is optional for now
        let spanishUrl = Bundle.main.url(forResource: "vulgate_spanish_RV", withExtension: "json", subdirectory: "Bible")
        
        do {
            let latinData = try Data(contentsOf: latinUrl)
            let englishData = try Data(contentsOf: englishUrl)
            
            let latinContent = try JSONDecoder().decode(BibleContent.self, from: latinData)
            let englishContent = try JSONDecoder().decode(BibleContent.self, from: englishData)
            
            var spanishContent: BibleContent?
            if let spanishUrl = spanishUrl {
                do {
                    let spanishData = try Data(contentsOf: spanishUrl)
                    spanishContent = try JSONDecoder().decode(BibleContent.self, from: spanishData)
                    print("Successfully loaded Spanish content")
                } catch {
                    print("Warning: Could not load Spanish content: \(error)")
                }
            }
            
            // Perform three-way merge
            let mergedBooks = mergeThreeLanguages(
                latin: latinContent.books,
                english: englishContent.books,
                spanish: spanishContent?.books ?? []
            )
            
            self.books = mergedBooks
            
            if books.isEmpty {
                errorMessage = "No matching content found between language texts."
            } else {
                print("Successfully loaded and merged Bible content: \(books.count) books")
                if spanishContent != nil {
                    print("Spanish support enabled")
                } else {
                    print("Spanish support disabled (file not found)")
                }
            }
        } catch {
            print("Error loading content: \(error)")
            errorMessage = "Error loading Bible content: \(error.localizedDescription)"
        }
    }
    
    private func mergeThreeLanguages(latin: [Book], english: [Book], spanish: [Book]) -> [Book] {
        // Create dictionaries for faster lookup
        var englishBooksDictionary: [String: Book] = [:]
        for englishBook in english {
            if let latinName = bookNameMappings?.english_to_vulgate[englishBook.name] {
                englishBooksDictionary[latinName] = englishBook
            }
        }
        
        var spanishBooksDictionary: [String: Book] = [:]
        for spanishBook in spanish {
            if let latinName = bookNameMappings?.spanish_to_vulgate[spanishBook.name] {
                spanishBooksDictionary[latinName] = spanishBook
            }
        }
        
        var mergedBooks: [Book] = []
        
        for latinBook in latin {
            guard let englishBook = englishBooksDictionary[latinBook.name] else {
                print("Warning: No matching English book found for \(latinBook.name)")
                continue
            }
            
            // Spanish book is optional
            let spanishBook = spanishBooksDictionary[latinBook.name]
            if spanishBook == nil {
                print("Info: No Spanish version available for \(latinBook.name)")
            }
            
            // Merge chapters
            let mergedChapters = mergeChapters(
                latinChapters: latinBook.chapters,
                englishChapters: englishBook.chapters,
                spanishChapters: spanishBook?.chapters ?? [],
                bookName: latinBook.name
            )
            
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
        
        return mergedBooks
    }
    
    private func mergeChapters(latinChapters: [Chapter], englishChapters: [Chapter], spanishChapters: [Chapter], bookName: String) -> [Chapter] {
        // Create dictionaries for faster lookup
        let englishChaptersDictionary = Dictionary(
            uniqueKeysWithValues: englishChapters.map { ("\($0.number)", $0) }
        )
        
        let spanishChaptersDictionary = Dictionary(
            uniqueKeysWithValues: spanishChapters.map { ("\($0.number)", $0) }
        )
        
        var mergedChapters: [Chapter] = []
        
        for latinChapter in latinChapters {
            guard let englishChapter = englishChaptersDictionary["\(latinChapter.number)"] else {
                print("Warning: No matching English chapter found for \(bookName) chapter \(latinChapter.number)")
                continue
            }
            
            // Spanish chapter is optional
            let spanishChapter = spanishChaptersDictionary["\(latinChapter.number)"]
            
            let mergedVerses = mergeVerses(
                latinVerses: latinChapter.verses,
                englishVerses: englishChapter.verses,
                spanishVerses: spanishChapter?.verses ?? [],
                bookName: bookName,
                chapterNumber: latinChapter.number
            )
            
            if !mergedVerses.isEmpty {
                let chapter = Chapter(
                    id: latinChapter.id,
                    number: latinChapter.number,
                    verses: mergedVerses
                )
                mergedChapters.append(chapter)
            }
        }
        
        return mergedChapters
    }
    
    private func mergeVerses(latinVerses: [Verse], englishVerses: [Verse], spanishVerses: [Verse], bookName: String, chapterNumber: Int) -> [Verse] {
        // Create dictionaries for faster lookup
        let englishVersesDictionary = Dictionary(
            uniqueKeysWithValues: englishVerses.map { ("\($0.number)", $0) }
        )
        
        let spanishVersesDictionary = Dictionary(
            uniqueKeysWithValues: spanishVerses.map { ("\($0.number)", $0) }
        )
        
        let mergedVerses = latinVerses.compactMap { latinVerse -> Verse? in
            guard let englishVerse = englishVersesDictionary["\(latinVerse.number)"] else {
                print("Warning: No matching English verse found for \(bookName) \(chapterNumber):\(latinVerse.number)")
                return nil
            }
            
            // Spanish verse is optional
            let spanishVerse = spanishVersesDictionary["\(latinVerse.number)"]
            let spanishText = spanishVerse?.latinText ?? "" // Use latinText field from Spanish JSON
            
            return Verse(
                id: latinVerse.id,
                number: latinVerse.number,
                latinText: latinVerse.latinText,
                englishText: englishVerse.latinText, // Use latinText field from English JSON
                spanishText: spanishText
            )
        }
        
        return mergedVerses
    }
}

// Legacy mappings structure for backwards compatibility
private struct LegacyBookNameMappings: Codable {
    let description: String
    let vulgate_to_english: [String: String]
    let english_to_vulgate: [String: String]
} 