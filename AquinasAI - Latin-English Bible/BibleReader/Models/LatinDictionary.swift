import Foundation

struct DictionaryEntry: Codable, Identifiable {
    let id: String // The Latin word itself will serve as the ID
    let word: String
    let definitions: [String]
    let partOfSpeech: String?
    
    enum CodingKeys: String, CodingKey {
        case word
        case id = "word_id"
        case definitions = "def"
        case partOfSpeech = "pos"
    }
}

class LatinDictionaryService: ObservableObject {
    @Published private var dictionaryCache: [String: [DictionaryEntry]] = [:]
    
    func lookupWord(_ word: String) async throws -> [DictionaryEntry] {
        // Convert to lowercase for consistent lookup
        let normalizedWord = word.lowercased()
        
        // Get the first letter to determine which file to load
        guard let firstLetter = normalizedWord.first?.uppercased() else {
            return []
        }
        
        // Check cache first
        if let cached = dictionaryCache[firstLetter] {
            return cached.filter { $0.word.lowercased() == normalizedWord }
        }
        
        // Load from file if not in cache
        let entries = try await loadDictionaryFile(for: firstLetter)
        dictionaryCache[firstLetter] = entries
        
        return entries.filter { $0.word.lowercased() == normalizedWord }
    }
    
    private func loadDictionaryFile(for letter: String) async throws -> [DictionaryEntry] {
        guard let url = Bundle.main.url(forResource: "ls_\(letter)", withExtension: "json", subdirectory: "latin_dictionary") else {
            throw NSError(domain: "LatinDictionary", code: 404, userInfo: [NSLocalizedDescriptionKey: "Dictionary file not found"])
        }
        
        let data = try Data(contentsOf: url)
        return try JSONDecoder().decode([DictionaryEntry].self, from: data)
    }
} 