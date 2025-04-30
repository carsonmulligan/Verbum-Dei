import Foundation

class BibleViewModel: ObservableObject {
    @Published var books: [Book] = []
    @Published var errorMessage: String?
    
    init() {
        loadBibleContent()
    }
    
    private func loadBibleContent() {
        // Print the main bundle path for debugging
        print("Bundle path: \(Bundle.main.bundlePath)")
        
        // List all resources in the bundle for debugging
        let resourcePaths = Bundle.main.paths(forResourcesOfType: "json", inDirectory: nil)
        print("Found JSON files in bundle: \(resourcePaths)")
        
        guard let url = Bundle.main.url(forResource: "vulgate_latin", withExtension: "json") else {
            errorMessage = "Could not find vulgate_latin.json in bundle. Please ensure the file is added to the Xcode project and included in the target."
            return
        }
        
        do {
            let data = try Data(contentsOf: url)
            print("Successfully loaded JSON data of size: \(data.count) bytes")
            let bibleContent = try JSONDecoder().decode(BibleContent.self, from: data)
            self.books = bibleContent.books
            print("Successfully decoded Bible content")
        } catch {
            print("Error loading content: \(error)")
            errorMessage = "Error loading Bible content: \(error.localizedDescription)"
        }
    }
} 