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
        print("🔍 DEBUG: Starting loadBibleContent()")
        print("🔍 DEBUG: Bundle path: \(Bundle.main.bundlePath)")
        print("🔍 DEBUG: Bundle resource path: \(Bundle.main.resourcePath ?? "nil")")
        
        // List all resources in the bundle for debugging
        let allResourcePaths = Bundle.main.paths(forResourcesOfType: nil, inDirectory: nil)
        print("🔍 DEBUG: All resources in bundle (\(allResourcePaths.count) total):")
        for path in allResourcePaths.prefix(20) {
            print("  - \(path)")
        }
        
        let jsonPaths = Bundle.main.paths(forResourcesOfType: "json", inDirectory: nil)
        print("🔍 DEBUG: JSON files in bundle (\(jsonPaths.count) total):")
        for path in jsonPaths {
            print("  - \(path)")
        }
        
        // Check for Bible subdirectory specifically
        let bibleJsonPaths = Bundle.main.paths(forResourcesOfType: "json", inDirectory: "Bible")
        print("🔍 DEBUG: JSON files in Bible subdirectory (\(bibleJsonPaths.count) total):")
        for path in bibleJsonPaths {
            print("  - \(path)")
        }
        
        // Try different approaches to find the files
        print("🔍 DEBUG: Attempting to find Bible files...")
        
        // Method 1: Using subdirectory parameter
        let latinUrl1 = Bundle.main.url(forResource: "vulgate_latin", withExtension: "json", subdirectory: "Bible")
        print("🔍 DEBUG: Method 1 (subdirectory) - Latin URL: \(latinUrl1?.absoluteString ?? "nil")")
        
        let englishUrl1 = Bundle.main.url(forResource: "vulgate_english", withExtension: "json", subdirectory: "Bible")
        print("🔍 DEBUG: Method 1 (subdirectory) - English URL: \(englishUrl1?.absoluteString ?? "nil")")
        
        // Method 2: Using path-based approach
        let latinUrl2 = Bundle.main.url(forResource: "Bible/vulgate_latin", withExtension: "json")
        print("🔍 DEBUG: Method 2 (path-based) - Latin URL: \(latinUrl2?.absoluteString ?? "nil")")
        
        let englishUrl2 = Bundle.main.url(forResource: "Bible/vulgate_english", withExtension: "json")
        print("🔍 DEBUG: Method 2 (path-based) - English URL: \(englishUrl2?.absoluteString ?? "nil")")
        
        // Method 3: Check if files exist in root directory
        let latinUrl3 = Bundle.main.url(forResource: "vulgate_latin", withExtension: "json")
        print("🔍 DEBUG: Method 3 (root) - Latin URL: \(latinUrl3?.absoluteString ?? "nil")")
        
        let englishUrl3 = Bundle.main.url(forResource: "vulgate_english", withExtension: "json")
        print("🔍 DEBUG: Method 3 (root) - English URL: \(englishUrl3?.absoluteString ?? "nil")")
        
        // Check if the files exist in the file system
        if let resourcePath = Bundle.main.resourcePath {
            let bibleDir = "\(resourcePath)/Bible"
            print("🔍 DEBUG: Checking Bible directory: \(bibleDir)")
            
            let fileManager = FileManager.default
            if fileManager.fileExists(atPath: bibleDir) {
                print("🔍 DEBUG: Bible directory exists!")
                do {
                    let contents = try fileManager.contentsOfDirectory(atPath: bibleDir)
                    print("🔍 DEBUG: Bible directory contents: \(contents)")
                } catch {
                    print("🔍 DEBUG: Error reading Bible directory: \(error)")
                }
            } else {
                print("🔍 DEBUG: Bible directory does NOT exist!")
                
                // Check what directories do exist
                do {
                    let rootContents = try fileManager.contentsOfDirectory(atPath: resourcePath)
                    print("🔍 DEBUG: Root resource directory contents: \(rootContents)")
                } catch {
                    print("🔍 DEBUG: Error reading root resource directory: \(error)")
                }
            }
        }
        
        // Use the first successful method
        var latinUrl: URL?
        var englishUrl: URL?
        
        if let url1 = latinUrl1, let url2 = englishUrl1 {
            print("✅ DEBUG: Using Method 1 (subdirectory)")
            latinUrl = url1
            englishUrl = url2
        } else if let url1 = latinUrl2, let url2 = englishUrl2 {
            print("✅ DEBUG: Using Method 2 (path-based)")
            latinUrl = url1
            englishUrl = url2
        } else if let url1 = latinUrl3, let url2 = englishUrl3 {
            print("✅ DEBUG: Using Method 3 (root)")
            latinUrl = url1
            englishUrl = url2
        } else {
            print("❌ DEBUG: No method worked - setting error message")
            errorMessage = "Could not find required Bible content files in bundle."
            return
        }
        
        guard let finalLatinUrl = latinUrl, let finalEnglishUrl = englishUrl else {
            print("❌ DEBUG: Final URLs are nil")
            errorMessage = "Could not find required Bible content files in bundle."
            return
        }
        
        print("✅ DEBUG: Final URLs found:")
        print("  Latin: \(finalLatinUrl.absoluteString)")
        print("  English: \(finalEnglishUrl.absoluteString)")
        
        // Spanish is optional for now - try all methods
        let spanishUrl = Bundle.main.url(forResource: "vulgate_spanish_RV", withExtension: "json", subdirectory: "Bible") ??
                        Bundle.main.url(forResource: "Bible/vulgate_spanish_RV", withExtension: "json") ??
                        Bundle.main.url(forResource: "vulgate_spanish_RV", withExtension: "json")
        
        print("🔍 DEBUG: Spanish URL: \(spanishUrl?.absoluteString ?? "nil")")
        
        do {
            print("🔍 DEBUG: Loading Latin data...")
            let latinData = try Data(contentsOf: finalLatinUrl)
            print("✅ DEBUG: Latin data loaded: \(latinData.count) bytes")
            
            print("🔍 DEBUG: Loading English data...")
            let englishData = try Data(contentsOf: finalEnglishUrl)
            print("✅ DEBUG: English data loaded: \(englishData.count) bytes")
            
            print("🔍 DEBUG: Decoding Latin content...")
            let latinContent = try JSONDecoder().decode(BibleContent.self, from: latinData)
            print("✅ DEBUG: Latin content decoded: \(latinContent.books.count) books")
            
            print("🔍 DEBUG: Decoding English content...")
            let englishContent = try JSONDecoder().decode(BibleContent.self, from: englishData)
            print("✅ DEBUG: English content decoded: \(englishContent.books.count) books")
            
            var spanishContent: BibleContent?
            if let spanishUrl = spanishUrl {
                do {
                    print("🔍 DEBUG: Loading Spanish data...")
                    let spanishData = try Data(contentsOf: spanishUrl)
                    print("✅ DEBUG: Spanish data loaded: \(spanishData.count) bytes")
                    
                    print("🔍 DEBUG: Decoding Spanish content...")
                    spanishContent = try JSONDecoder().decode(BibleContent.self, from: spanishData)
                    print("✅ DEBUG: Spanish content decoded: \(spanishContent?.books.count ?? 0) books")
                } catch {
                    print("⚠️ DEBUG: Could not load Spanish content: \(error)")
                }
            }
            
            print("🔍 DEBUG: Starting three-way merge...")
            // Perform three-way merge
            let mergedBooks = mergeThreeLanguages(
                latin: latinContent.books,
                english: englishContent.books,
                spanish: spanishContent?.books ?? []
            )
            
            print("✅ DEBUG: Merge completed: \(mergedBooks.count) books")
            self.books = mergedBooks
            
            if books.isEmpty {
                print("❌ DEBUG: No books after merge")
                errorMessage = "No matching content found between language texts."
            } else {
                print("✅ DEBUG: Successfully loaded and merged Bible content: \(books.count) books")
                if spanishContent != nil {
                    print("✅ DEBUG: Spanish support enabled")
                } else {
                    print("⚠️ DEBUG: Spanish support disabled (file not found)")
                }
            }
        } catch {
            print("❌ DEBUG: Error during loading/decoding: \(error)")
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