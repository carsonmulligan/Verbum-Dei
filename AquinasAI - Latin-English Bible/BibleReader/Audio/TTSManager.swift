import Foundation
import AVFoundation
import Combine

class TTSManager: NSObject, ObservableObject {
    private let synthesizer = AVSpeechSynthesizer()
    private let kokoroTTS = KokoroTTS()
    
    @Published var isPlaying = false
    @Published var isPaused = false
    @Published var currentText: String = ""
    @Published var isUsingKokoro = false
    @Published var kokoroLoadingProgress: Float = 0.0
    @Published var ttsError: String?
    
    // TTS Engine preference
    @Published var preferKokoro = true {
        didSet {
            UserDefaults.standard.set(preferKokoro, forKey: "TTSManager.preferKokoro")
        }
    }
    
    // Voice selection for Kokoro
    @Published var selectedKokoroVoice: Voice = Voice.defaultLatinVoice {
        didSet {
            UserDefaults.standard.set(selectedKokoroVoice.id, forKey: "TTSManager.selectedKokoroVoice")
        }
    }
    
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
        
        // Load user preferences
        loadPreferences()
        
        // Log available voices for debugging
        logAvailableVoices()
        
        // Setup Kokoro observers
        setupKokoroObservers()
        
        // Preload Kokoro if preferred
        if preferKokoro {
            loadKokoroModelIfNeeded()
        }
    }
    
    private func loadPreferences() {
        preferKokoro = UserDefaults.standard.object(forKey: "TTSManager.preferKokoro") as? Bool ?? true
        
        let savedVoiceId = UserDefaults.standard.string(forKey: "TTSManager.selectedKokoroVoice") ?? Voice.defaultLatinVoice.id
        selectedKokoroVoice = Voice.italianVoices.first { $0.id == savedVoiceId } ?? Voice.defaultLatinVoice
    }
    
    private func setupKokoroObservers() {
        // Observe Kokoro loading progress
        kokoroTTS.$loadingProgress
            .receive(on: DispatchQueue.main)
            .assign(to: &$kokoroLoadingProgress)
        
        kokoroTTS.$error
            .receive(on: DispatchQueue.main)
            .map { $0?.localizedDescription }
            .assign(to: &$ttsError)
    }
    
    private func logAvailableVoices() {
        let voices = AVSpeechSynthesisVoice.speechVoices()
        print("Available iOS voices:")
        for voice in voices {
            if voice.language.hasPrefix("it-") || voice.language.hasPrefix("en-") || voice.language.hasPrefix("es-") {
                print("- \(voice.language): \(voice.name)")
            }
        }
        
        print("Available Kokoro voices:")
        for voice in Voice.italianVoices {
            print("- \(voice.id): \(voice.name) (\(voice.description))")
        }
    }
    
    // MARK: - Model Management
    
    func loadKokoroModelIfNeeded() {
        guard preferKokoro && !kokoroTTS.isReady && !kokoroTTS.isLoading else { return }
        
        Task {
            do {
                try await kokoroTTS.loadModel()
                await MainActor.run {
                    print("Kokoro model loaded successfully")
                }
            } catch {
                await MainActor.run {
                    ttsError = "Failed to load Kokoro: \(error.localizedDescription)"
                    print("Kokoro loading failed, will use iOS TTS fallback: \(error)")
                }
            }
        }
    }
    
    func unloadKokoroModel() {
        kokoroTTS.unloadModel()
    }
    
    // MARK: - Public Methods
    
    /// Speak Latin text using best available voice
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
        
        // For Latin, try Kokoro first if available and preferred
        if language == .latin && preferKokoro && kokoroTTS.isReady {
            speakWithKokoro(text: text)
        } else {
            speakWithiOS(text: text, language: language)
        }
    }
    
    private func speakWithKokoro(text: String) {
        currentText = text
        isPlaying = true
        isPaused = false
        isUsingKokoro = true
        
        Task {
            do {
                let audioData = try await kokoroTTS.synthesize(text: text, voice: selectedKokoroVoice)
                await playKokoroAudio(audioData)
            } catch {
                await MainActor.run {
                    ttsError = "Kokoro synthesis failed: \(error.localizedDescription)"
                    print("Kokoro failed, falling back to iOS TTS: \(error)")
                    // Fallback to iOS TTS
                    speakWithiOS(text: text, language: .latin)
                }
            }
        }
    }
    
    private func playKokoroAudio(_ audioData: Data) async {
        // Convert audio data to playable format and play
        // This would use AVAudioPlayer or similar
        // For now, simulate playback
        try? await Task.sleep(nanoseconds: 3_000_000_000) // 3 seconds
        
        await MainActor.run {
            isPlaying = false
            isPaused = false
            currentText = ""
            isUsingKokoro = false
        }
    }
    
    private func speakWithiOS(text: String, language: Language) {
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
        isUsingKokoro = false
        
        synthesizer.speak(utterance)
    }
    
    /// Pause current speech
    func pause() {
        if isUsingKokoro {
            // Kokoro pause would go here
            // For now, just stop
            stop()
        } else {
            if isPlaying && !isPaused {
                synthesizer.pauseSpeaking(at: .immediate)
                isPaused = true
            }
        }
    }
    
    /// Resume paused speech
    func resume() {
        if isUsingKokoro {
            // Kokoro resume would go here
            // For now, not supported
        } else {
            if isPaused {
                synthesizer.continueSpeaking()
                isPaused = false
            }
        }
    }
    
    /// Stop current speech
    func stop() {
        if isUsingKokoro {
            // Stop Kokoro playback
            isUsingKokoro = false
        } else {
            synthesizer.stopSpeaking(at: .immediate)
        }
        
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
        if language.hasPrefix("it-") && preferKokoro && kokoroTTS.isReady {
            return "Kokoro Voice: \(selectedKokoroVoice.name) (\(selectedKokoroVoice.description))"
        }
        
        guard let voice = AVSpeechSynthesisVoice(language: language) else {
            return "Voice not available for \(language)"
        }
        return "iOS Voice: \(voice.name) (\(voice.language))"
    }
    
    // MARK: - Voice Selection
    
    func selectKokoroVoice(_ voice: Voice) {
        selectedKokoroVoice = voice
        // Restart if currently playing
        if isPlaying && isUsingKokoro {
            let currentlyPlayingText = currentText
            stop()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.speakLatin(currentlyPlayingText)
            }
        }
    }
    
    // MARK: - Settings
    
    func toggleTTSEngine() {
        preferKokoro.toggle()
        
        if preferKokoro && !kokoroTTS.isReady {
            loadKokoroModelIfNeeded()
        }
    }
    
    var currentEngine: String {
        if preferKokoro && kokoroTTS.isReady {
            return "Kokoro (Premium)"
        } else if preferKokoro && kokoroTTS.isLoading {
            return "Loading Kokoro..."
        } else {
            return "iOS TTS (Standard)"
        }
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
            self.isUsingKokoro = false
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
            self.isUsingKokoro = false
        }
    }
} 