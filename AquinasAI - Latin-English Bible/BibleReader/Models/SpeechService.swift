import Foundation
import AVFoundation

class SpeechService: NSObject, ObservableObject, AVSpeechSynthesizerDelegate {
    private let synthesizer = AVSpeechSynthesizer()
    
    @Published var isSpeaking = false
    @Published var isPaused = false
    
    override init() {
        super.init()
        synthesizer.delegate = self
    }
    
    func speak(text: String, language: String) {
        // Stop any ongoing speech
        if synthesizer.isSpeaking {
            synthesizer.stopSpeaking(at: .immediate)
        }
        
        let utterance = AVSpeechUtterance(string: text)
        
        // Configure voice based on language
        utterance.voice = getVoice(for: language)
        
        // Set speech parameters
        utterance.rate = 0.5  // Slower rate for better comprehension
        utterance.pitchMultiplier = 1.0
        utterance.volume = 1.0
        
        synthesizer.speak(utterance)
        isSpeaking = true
        isPaused = false
    }
    
    func stopSpeaking() {
        synthesizer.stopSpeaking(at: .immediate)
        isSpeaking = false
        isPaused = false
    }
    
    func pauseSpeaking() {
        synthesizer.pauseSpeaking(at: .word)
        isPaused = true
    }
    
    func continueSpeaking() {
        synthesizer.continueSpeaking()
        isPaused = false
    }
    
    private func getVoice(for language: String) -> AVSpeechSynthesisVoice? {
        // Match the language to an appropriate voice
        switch language.lowercased() {
        case "latin":
            // Latin doesn't have a dedicated voice, use Italian as closest approximation
            return AVSpeechSynthesisVoice(language: "it-IT")
        case "english":
            return AVSpeechSynthesisVoice(language: "en-US")
        default:
            return AVSpeechSynthesisVoice(language: "en-US")
        }
    }
    
    // MARK: - AVSpeechSynthesizerDelegate
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        isSpeaking = false
        isPaused = false
    }
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didCancel utterance: AVSpeechUtterance) {
        isSpeaking = false
        isPaused = false
    }
} 