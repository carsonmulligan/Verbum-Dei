import Foundation

struct Voice: Codable, Identifiable, Equatable {
    let id: String
    let name: String
    let language: String
    let gender: Gender
    let style: Style
    let description: String
    
    // Voice embedding data
    let embedding: [Float]
    
    enum Gender: String, Codable, CaseIterable {
        case male = "male"
        case female = "female"
        
        var displayName: String {
            switch self {
            case .male: return "Male"
            case .female: return "Female"
            }
        }
    }
    
    enum Style: String, Codable, CaseIterable {
        case clear = "clear"
        case warm = "warm"
        case deep = "deep"
        case soft = "soft"
        
        var displayName: String {
            switch self {
            case .clear: return "Clear"
            case .warm: return "Warm"
            case .deep: return "Deep"
            case .soft: return "Soft"
            }
        }
    }
    
    // Predefined Italian voices for Latin
    static let italianVoices: [Voice] = [
        Voice(
            id: "if_sara",
            name: "Sara",
            language: "it-IT",
            gender: .female,
            style: .clear,
            description: "Clear female voice, ideal for liturgical texts",
            embedding: [] // Will be loaded from JSON file
        ),
        Voice(
            id: "im_nicola",
            name: "Nicola",
            language: "it-IT",
            gender: .male,
            style: .deep,
            description: "Deep male voice, good for scholarly reading",
            embedding: [] // Will be loaded from JSON file
        )
    ]
    
    // Default voice for Latin
    static let defaultLatinVoice = italianVoices[0] // Sara
    
    static func == (lhs: Voice, rhs: Voice) -> Bool {
        lhs.id == rhs.id
    }
}

// Voice loading utility
class VoiceLoader {
    static func loadVoice(id: String) throws -> [Float] {
        guard let url = Bundle.main.url(forResource: id, withExtension: "json", subdirectory: "TTS/Voices") else {
            throw VoiceError.fileNotFound(id)
        }
        
        let data = try Data(contentsOf: url)
        let voiceData = try JSONDecoder().decode(VoiceData.self, from: data)
        return voiceData.embedding
    }
}

struct VoiceData: Codable {
    let embedding: [Float]
}

enum VoiceError: Error, LocalizedError {
    case fileNotFound(String)
    case invalidFormat(String)
    case loadingFailed(String)
    
    var errorDescription: String? {
        switch self {
        case .fileNotFound(let id):
            return "Voice file not found: \(id)"
        case .invalidFormat(let id):
            return "Invalid voice file format: \(id)"
        case .loadingFailed(let id):
            return "Failed to load voice: \(id)"
        }
    }
} 