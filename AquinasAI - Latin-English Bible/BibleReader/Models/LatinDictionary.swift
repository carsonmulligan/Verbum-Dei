import Foundation

struct DictionaryEntry: Codable, Identifiable {
    var id: String { key } // Computed property using key as id
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
        
        // Remove diacritical marks for matching
        return cleaned.folding(options: .diacriticInsensitive, locale: .current)
    }
    
    func lookupWord(_ word: String) async throws -> [DictionaryEntry] {
        print("Looking up word: \(word)") // Debug print
        
        // Normalize the input word
        let normalizedWord = normalizeWord(word)
        print("Normalized word: \(normalizedWord)") // Debug print
        
        // Get the first letter to determine which file to load
        guard let firstLetter = normalizedWord.first?.uppercased() else {
            print("No first letter found") // Debug print
            return []
        }
        
        // Check cache first
        if let cached = dictionaryCache[firstLetter] {
            print("Found in cache for letter \(firstLetter)") // Debug print
            return findMatches(normalizedWord, in: cached)
        }
        
        // Load from file if not in cache
        print("Loading dictionary file for letter \(firstLetter)") // Debug print
        let entries = try await loadDictionaryFile(for: firstLetter)
        dictionaryCache[firstLetter] = entries
        
        let matches = findMatches(normalizedWord, in: entries)
        print("Found \(matches.count) matches") // Debug print
        return matches
    }
    
    private func findMatches(_ normalizedWord: String, in entries: [DictionaryEntry]) -> [DictionaryEntry] {
        // Check exact matches first
        let exactMatches = entries.filter { normalizeWord($0.key) == normalizedWord }
        if !exactMatches.isEmpty {
            print("Found exact matches: \(exactMatches.map { $0.key })") // Debug print
            return exactMatches
        }
        
        // Check alternative orthography
        let altMatches = entries.filter { entry in
            if let alternatives = entry.alternativeOrthography {
                return alternatives.contains { normalizeWord($0) == normalizedWord }
            }
            return false
        }
        
        if !altMatches.isEmpty {
            print("Found alternative matches: \(altMatches.map { $0.key })") // Debug print
            return altMatches
        }
        
        // If no exact or alternative matches, try finding words that start with our word
        // This helps with conjugated verbs and declined nouns
        let partialMatches = entries.filter { entry in
            let normalizedKey = normalizeWord(entry.key)
            return normalizedKey.hasPrefix(normalizedWord) || normalizedWord.hasPrefix(normalizedKey)
        }
        
        print("Found partial matches: \(partialMatches.map { $0.key })") // Debug print
        return partialMatches
    }
    
    private func loadDictionaryFile(for letter: String) async throws -> [DictionaryEntry] {
        guard let url = Bundle.main.url(forResource: "ls_\(letter)", withExtension: "json", subdirectory: "latin_dictionary") else {
            print("Dictionary file not found for letter \(letter)") // Debug print
            throw NSError(domain: "LatinDictionary", code: 404, userInfo: [NSLocalizedDescriptionKey: "Dictionary file not found"])
        }
        
        let data = try Data(contentsOf: url)
        let entries = try JSONDecoder().decode([DictionaryEntry].self, from: data)
        print("Loaded \(entries.count) entries for letter \(letter)") // Debug print
        return entries
    }
} 