import Foundation

class BibleViewModel: ObservableObject {
    @Published var bibleContent: BibleContent?
    @Published var errorMessage: String?
    
    init() {
        loadBibleContent()
    }
    
    private func loadBibleContent() {
        guard let url = Bundle.main.url(forResource: "vulgate_latin", withExtension: "json") else {
            errorMessage = "Could not find Bible content file"
            return
        }
        
        do {
            let data = try Data(contentsOf: url)
            bibleContent = try JSONDecoder().decode(BibleContent.self, from: data)
        } catch {
            errorMessage = "Error loading Bible content: \(error.localizedDescription)"
        }
    }
} 