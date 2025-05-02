import Foundation

struct DictionaryEntry: Codable, Identifiable {
    let id: String // The key will serve as the ID
    let key: String
    let partOfSpeech: String?
    let senses: [String]
    let entryType: String?
    let declension: Int?
    let gender: String?
    let alternativeOrthography: [String]?
    let titleOrthography: String?
    let titleGenitive: String?
    let mainNotes: String?
    
    enum CodingKeys: String, CodingKey {
        case id = "key"
        case key
        case partOfSpeech = "part_of_speech"
        case senses
        case entryType = "entry_type"
        case declension
        case gender
        case alternativeOrthography = "alternative_orthography"
        case titleOrthography = "title_orthography"
        case titleGenitive = "title_genitive"
        case mainNotes = "main_notes"
    }
}

class LatinDictionaryService: ObservableObject {
    @Published private var dictionaryCache: [String: [DictionaryEntry]] = [:]
    
    // Normalize a Latin word for lookup
    private func normalizeWord(_ word: String) -> String {
        // Remove punctuation and whitespace
        let cleaned = word.trimmingCharacters(in: .punctuationCharacters)
            .trimmingCharacters(in: .whitespaces)
            .lowercased()
        
        // Remove diacritical marks
        return cleaned.folding(options: .diacriticInsensitive, locale: .current)
    }
    
    func lookupWord(_ word: String) async throws -> [DictionaryEntry] {
        // Normalize the input word
        let normalizedWord = normalizeWord(word)
        
        // Get the first letter to determine which file to load
        guard let firstLetter = normalizedWord.first?.uppercased() else {
            return []
        }
        
        // Check cache first
        if let cached = dictionaryCache[firstLetter] {
            return findMatches(normalizedWord, in: cached)
        }
        
        // Load from file if not in cache
        let entries = try await loadDictionaryFile(for: firstLetter)
        dictionaryCache[firstLetter] = entries
        
        return findMatches(normalizedWord, in: entries)
    }
    
    private func findMatches(_ normalizedWord: String, in entries: [DictionaryEntry]) -> [DictionaryEntry] {
        // Check exact matches first
        let exactMatches = entries.filter { normalizeWord($0.key) == normalizedWord }
        if !exactMatches.isEmpty {
            return exactMatches
        }
        
        // Check alternative orthography
        return entries.filter { entry in
            if let alternatives = entry.alternativeOrthography {
                return alternatives.contains { normalizeWord($0) == normalizedWord }
            }
            return false
        }
    }
    
    private func loadDictionaryFile(for letter: String) async throws -> [DictionaryEntry] {
        guard let url = Bundle.main.url(forResource: "ls_\(letter)", withExtension: "json", subdirectory: "latin_dictionary") else {
            throw NSError(domain: "LatinDictionary", code: 404, userInfo: [NSLocalizedDescriptionKey: "Dictionary file not found"])
        }
        
        let data = try Data(contentsOf: url)
        return try JSONDecoder().decode([DictionaryEntry].self, from: data)
    }
} 