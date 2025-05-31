import Foundation
import AVFoundation

class TTSManager: NSObject, ObservableObject {
    private let synthesizer = AVSpeechSynthesizer()
    
    @Published var isPlaying = false
    @Published var isPaused = false
    @Published var currentText: String = ""
    
    // Available voices for different languages
    private var italianVoice: AVSpeechSynthesisVoice? {
        return AVSpeechSynthesisVoice(language: "it-IT")
    }
    
    private var englishVoice: AVSpeechSynthesisVoice? {
        return AVSpeechSynthesisVoice(language: "en-US")
    }
    
    private var spanishVoice: AVSpeechSynthesisVoice? {
        return AVSpeechSynthesisVoice(language: "es-ES")
    }
    
    override init() {
        super.init()
        synthesizer.delegate = self
        
        // Log available voices for debugging
        logAvailableVoices()
    }
    
    private func logAvailableVoices() {
        let voices = AVSpeechSynthesisVoice.speechVoices()
        print("Available voices:")
        for voice in voices {
            if voice.language.hasPrefix("it-") || voice.language.hasPrefix("en-") || voice.language.hasPrefix("es-") {
                print("- \(voice.language): \(voice.name)")
            }
        }
    }
    
    // MARK: - Public Methods
    
    /// Speak Latin text using Italian pronunciation
    func speakLatin(_ text: String) {
        speak(text: text, language: .latin)
    }
    
    /// Speak English text using English voice
    func speakEnglish(_ text: String) {
        speak(text: text, language: .english)
    }
    
    /// Speak Spanish text using Spanish voice
    func speakSpanish(_ text: String) {
        speak(text: text, language: .spanish)
    }
    
    /// Generic speak method that chooses appropriate voice based on language
    func speak(text: String, language: Language) {
        // Stop any current speech
        stop()
        
        let utterance = AVSpeechUtterance(string: text)
        
        // Choose voice based on language
        switch language {
        case .latin:
            // Use Italian voice for Latin (closest pronunciation)
            utterance.voice = italianVoice
            utterance.rate = 0.4 // Slower for Latin reading
        case .english:
            utterance.voice = englishVoice
            utterance.rate = 0.5
        case .spanish:
            utterance.voice = spanishVoice
            utterance.rate = 0.5
        }
        
        // Set speech properties
        utterance.pitchMultiplier = 1.0
        utterance.volume = 1.0
        utterance.preUtteranceDelay = 0.1
        
        currentText = text
        isPlaying = true
        isPaused = false
        
        synthesizer.speak(utterance)
    }
    
    /// Pause current speech
    func pause() {
        if isPlaying && !isPaused {
            synthesizer.pauseSpeaking(at: .immediate)
            isPaused = true
        }
    }
    
    /// Resume paused speech
    func resume() {
        if isPaused {
            synthesizer.continueSpeaking()
            isPaused = false
        }
    }
    
    /// Stop current speech
    func stop() {
        synthesizer.stopSpeaking(at: .immediate)
        isPlaying = false
        isPaused = false
        currentText = ""
    }
    
    /// Check if synthesizer supports a specific language
    func isLanguageSupported(_ languageCode: String) -> Bool {
        return AVSpeechSynthesisVoice(language: languageCode) != nil
    }
    
    /// Get voice info for debugging
    func getVoiceInfo(for language: String) -> String {
        guard let voice = AVSpeechSynthesisVoice(language: language) else {
            return "Voice not available for \(language)"
        }
        return "Voice: \(voice.name) (\(voice.language))"
    }
}

// MARK: - AVSpeechSynthesizerDelegate

extension TTSManager: AVSpeechSynthesizerDelegate {
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didStart utterance: AVSpeechUtterance) {
        DispatchQueue.main.async {
            self.isPlaying = true
            self.isPaused = false
        }
    }
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        DispatchQueue.main.async {
            self.isPlaying = false
            self.isPaused = false
            self.currentText = ""
        }
    }
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didPause utterance: AVSpeechUtterance) {
        DispatchQueue.main.async {
            self.isPaused = true
        }
    }
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didContinue utterance: AVSpeechUtterance) {
        DispatchQueue.main.async {
            self.isPaused = false
        }
    }
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didCancel utterance: AVSpeechUtterance) {
        DispatchQueue.main.async {
            self.isPlaying = false
            self.isPaused = false
            self.currentText = ""
        }
    }
} 