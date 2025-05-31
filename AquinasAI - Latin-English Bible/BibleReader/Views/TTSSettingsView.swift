import SwiftUI

struct TTSSettingsView: View {
    @EnvironmentObject private var ttsManager: TTSManager
    @EnvironmentObject private var audioSettings: AudioSettings
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            Form {
                // Engine Selection Section
                Section(header: Text("Text-to-Speech Engine")) {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Image(systemName: ttsManager.preferKokoro ? "checkmark.circle.fill" : "circle")
                                .foregroundColor(ttsManager.preferKokoro ? .green : .secondary)
                            
                            VStack(alignment: .leading) {
                                Text("Kokoro TTS (Premium)")
                                    .font(.headline)
                                Text("High-quality neural voice synthesis")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            if ttsManager.kokoroLoadingProgress > 0 && ttsManager.kokoroLoadingProgress < 1 {
                                ProgressView(value: ttsManager.kokoroLoadingProgress)
                                    .frame(width: 50)
                            }
                        }
                        .onTapGesture {
                            ttsManager.preferKokoro = true
                            ttsManager.loadKokoroModelIfNeeded()
                        }
                        
                        HStack {
                            Image(systemName: !ttsManager.preferKokoro ? "checkmark.circle.fill" : "circle")
                                .foregroundColor(!ttsManager.preferKokoro ? .green : .secondary)
                            
                            VStack(alignment: .leading) {
                                Text("iOS TTS (Standard)")
                                    .font(.headline)
                                Text("Built-in system voices")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                        }
                        .onTapGesture {
                            ttsManager.preferKokoro = false
                        }
                    }
                    
                    // Current engine status
                    HStack {
                        Text("Current Engine:")
                            .foregroundColor(.secondary)
                        Spacer()
                        Text(ttsManager.currentEngine)
                            .fontWeight(.medium)
                    }
                    
                    // Error display
                    if let error = ttsManager.ttsError {
                        Text(error)
                            .foregroundColor(.red)
                            .font(.caption)
                    }
                }
                
                // Kokoro Voice Selection (only show if using Kokoro)
                if ttsManager.preferKokoro {
                    Section(header: Text("Kokoro Voice Selection")) {
                        ForEach(Voice.italianVoices) { voice in
                            VStack(alignment: .leading) {
                                HStack {
                                    Image(systemName: ttsManager.selectedKokoroVoice.id == voice.id ? "checkmark.circle.fill" : "circle")
                                        .foregroundColor(ttsManager.selectedKokoroVoice.id == voice.id ? .deepPurple : .secondary)
                                    
                                    VStack(alignment: .leading) {
                                        HStack {
                                            Text(voice.name)
                                                .font(.headline)
                                            
                                            Text("(\(voice.gender.displayName))")
                                                .font(.caption)
                                                .foregroundColor(.secondary)
                                        }
                                        
                                        Text(voice.description)
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                    
                                    Spacer()
                                    
                                    Button("Test") {
                                        ttsManager.selectKokoroVoice(voice)
                                        ttsManager.speakLatin("Ave Maria, gratia plena")
                                    }
                                    .buttonStyle(.bordered)
                                    .controlSize(.small)
                                }
                            }
                            .onTapGesture {
                                ttsManager.selectKokoroVoice(voice)
                            }
                        }
                    }
                }
                
                // Playback Settings
                Section(header: Text("Playback Settings")) {
                    VStack(alignment: .leading) {
                        HStack {
                            Text("Speech Rate")
                            Spacer()
                            Text("\(Int(audioSettings.speechRate * 100))%")
                                .foregroundColor(.secondary)
                        }
                        
                        Slider(value: $audioSettings.speechRate, in: 0.2...1.0, step: 0.1) {
                            Text("Speech Rate")
                        }
                        .onChange(of: audioSettings.speechRate) {
                            audioSettings.saveSettings()
                        }
                    }
                    
                    VStack(alignment: .leading) {
                        HStack {
                            Text("Volume")
                            Spacer()
                            Text("\(Int(audioSettings.volume * 100))%")
                                .foregroundColor(.secondary)
                        }
                        
                        Slider(value: $audioSettings.volume, in: 0.0...1.0, step: 0.1) {
                            Text("Volume")
                        }
                        .onChange(of: audioSettings.volume) {
                            audioSettings.saveSettings()
                        }
                    }
                }
                
                // Latin Pronunciation Settings
                Section(header: Text("Latin Pronunciation"), 
                       footer: Text("Italian pronunciation is closest to ecclesiastical Latin. Kokoro provides the most natural pronunciation.")) {
                    
                    Toggle("Use Italian Voice for Latin", isOn: $audioSettings.useItalianForLatin)
                        .onChange(of: audioSettings.useItalianForLatin) {
                            audioSettings.saveSettings()
                        }
                    
                    HStack {
                        Text("Current Latin Voice:")
                            .foregroundColor(.secondary)
                        Spacer()
                        Text(ttsManager.getVoiceInfo(for: "it-IT"))
                            .font(.caption)
                            .multilineTextAlignment(.trailing)
                    }
                }
                
                // Model Management (if using Kokoro)
                if ttsManager.preferKokoro {
                    Section(header: Text("Model Management")) {
                        Button("Reload Kokoro Model") {
                            ttsManager.unloadKokoroModel()
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                ttsManager.loadKokoroModelIfNeeded()
                            }
                        }
                        .foregroundColor(.deepPurple)
                        
                        Button("Unload Model (Free Memory)") {
                            ttsManager.unloadKokoroModel()
                        }
                        .foregroundColor(.orange)
                        
                        Text("Kokoro model uses ~200MB of memory when loaded")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                // Test Section
                Section(header: Text("Test Voices")) {
                    VStack(spacing: 12) {
                        Button("Test Latin: \"Ave Maria, gratia plena\"") {
                            ttsManager.speakLatin("Ave Maria, gratia plena")
                        }
                        .frame(maxWidth: .infinity)
                        .buttonStyle(.bordered)
                        
                        Button("Test Latin: \"Pater noster qui es in caelis\"") {
                            ttsManager.speakLatin("Pater noster qui es in caelis")
                        }
                        .frame(maxWidth: .infinity)
                        .buttonStyle(.bordered)
                        
                        if ttsManager.isPlaying {
                            Button("Stop Playback") {
                                ttsManager.stop()
                            }
                            .frame(maxWidth: .infinity)
                            .buttonStyle(.borderedProminent)
                            .tint(.red)
                        }
                    }
                }
            }
            .navigationTitle("Audio Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
} 