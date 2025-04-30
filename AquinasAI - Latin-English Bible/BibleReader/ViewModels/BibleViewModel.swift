import Foundation

class BibleViewModel: ObservableObject {
    @Published var books: [Book] = []
    @Published var errorMessage: String?
    @Published var displayMode: DisplayMode = .bilingual
    
    init() {
        loadBibleContent()
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
            
            // Merge Latin and English content
            self.books = latinContent.books.enumerated().map { index, latinBook in
                let englishBook = englishContent.books[index]
                
                let mergedChapters = latinBook.chapters.enumerated().map { chapterIndex, latinChapter in
                    let englishChapter = englishBook.chapters[chapterIndex]
                    
                    let mergedVerses = latinChapter.verses.enumerated().map { verseIndex, latinVerse in
                        let englishVerse = englishChapter.verses[verseIndex]
                        return Verse(
                            id: latinVerse.id,
                            number: latinVerse.number,
                            latinText: latinVerse.latinText,
                            englishText: englishVerse.latinText  // Note: In the English JSON, it's still under 'latinText'
                        )
                    }
                    
                    return Chapter(
                        id: latinChapter.id,
                        number: latinChapter.number,
                        verses: mergedVerses
                    )
                }
                
                return Book(
                    name: latinBook.name,
                    chapters: mergedChapters
                )
            }
            
            print("Successfully loaded and merged Bible content")
        } catch {
            print("Error loading content: \(error)")
            errorMessage = "Error loading Bible content: \(error.localizedDescription)"
        }
    }
} 