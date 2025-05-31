import Foundation

class AudioSettings: ObservableObject {
    @Published var speechRate: Float = 0.4
    @Published var volume: Float = 1.0
    @Published var pitch: Float = 1.0
    
    // Voice preferences for each language
    @Published var useItalianForLatin: Bool = true
    @Published var autoPlayContinuous: Bool = false
    @Published var highlightCurrentText: Bool = true
    
    // Voice selection preferences
    @Published var preferredItalianVoice: String = "it-IT"
    @Published var preferredEnglishVoice: String = "en-US"
    @Published var preferredSpanishVoice: String = "es-ES"
    
    private let userDefaults = UserDefaults.standard
    
    init() {
        loadSettings()
    }
    
    // MARK: - Settings Persistence
    
    private func loadSettings() {
        speechRate = userDefaults.object(forKey: "AudioSettings.speechRate") as? Float ?? 0.4
        volume = userDefaults.object(forKey: "AudioSettings.volume") as? Float ?? 1.0
        pitch = userDefaults.object(forKey: "AudioSettings.pitch") as? Float ?? 1.0
        useItalianForLatin = userDefaults.object(forKey: "AudioSettings.useItalianForLatin") as? Bool ?? true
        autoPlayContinuous = userDefaults.object(forKey: "AudioSettings.autoPlayContinuous") as? Bool ?? false
        highlightCurrentText = userDefaults.object(forKey: "AudioSettings.highlightCurrentText") as? Bool ?? true
        preferredItalianVoice = userDefaults.string(forKey: "AudioSettings.preferredItalianVoice") ?? "it-IT"
        preferredEnglishVoice = userDefaults.string(forKey: "AudioSettings.preferredEnglishVoice") ?? "en-US"
        preferredSpanishVoice = userDefaults.string(forKey: "AudioSettings.preferredSpanishVoice") ?? "es-ES"
    }
    
    func saveSettings() {
        userDefaults.set(speechRate, forKey: "AudioSettings.speechRate")
        userDefaults.set(volume, forKey: "AudioSettings.volume")
        userDefaults.set(pitch, forKey: "AudioSettings.pitch")
        userDefaults.set(useItalianForLatin, forKey: "AudioSettings.useItalianForLatin")
        userDefaults.set(autoPlayContinuous, forKey: "AudioSettings.autoPlayContinuous")
        userDefaults.set(highlightCurrentText, forKey: "AudioSettings.highlightCurrentText")
        userDefaults.set(preferredItalianVoice, forKey: "AudioSettings.preferredItalianVoice")
        userDefaults.set(preferredEnglishVoice, forKey: "AudioSettings.preferredEnglishVoice")
        userDefaults.set(preferredSpanishVoice, forKey: "AudioSettings.preferredSpanishVoice")
    }
    
    // MARK: - Convenience Methods
    
    func getVoiceLanguage(for language: Language) -> String {
        switch language {
        case .latin:
            return useItalianForLatin ? preferredItalianVoice : preferredEnglishVoice
        case .english:
            return preferredEnglishVoice
        case .spanish:
            return preferredSpanishVoice
        }
    }
    
    func resetToDefaults() {
        speechRate = 0.4
        volume = 1.0
        pitch = 1.0
        useItalianForLatin = true
        autoPlayContinuous = false
        highlightCurrentText = true
        preferredItalianVoice = "it-IT"
        preferredEnglishVoice = "en-US"
        preferredSpanishVoice = "es-ES"
        saveSettings()
    }
} 