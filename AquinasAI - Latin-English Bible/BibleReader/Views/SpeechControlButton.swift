import SwiftUI

struct SpeechControlButton: View {
    @ObservedObject var speechService: SpeechService
    let text: String
    let language: String
    
    var body: some View {
        Button(action: toggleSpeech) {
            HStack(spacing: 5) {
                Image(systemName: speechButtonIcon)
                    .imageScale(.medium)
                
                Text(speechButtonText)
                    .font(.subheadline)
            }
            .foregroundColor(.white)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Color.deepPurple)
            .cornerRadius(20)
        }
    }
    
    private var speechButtonIcon: String {
        if !speechService.isSpeaking {
            return "play.circle"
        } else if speechService.isPaused {
            return "play.fill"
        } else {
            return "pause.fill"
        }
    }
    
    private var speechButtonText: String {
        if !speechService.isSpeaking {
            return "Read \(language.capitalized)"
        } else if speechService.isPaused {
            return "Continue"
        } else {
            return "Pause"
        }
    }
    
    private func toggleSpeech() {
        if !speechService.isSpeaking {
            speechService.speak(text: text, language: language)
        } else if speechService.isPaused {
            speechService.continueSpeaking()
        } else {
            speechService.pauseSpeaking()
        }
    }
} 