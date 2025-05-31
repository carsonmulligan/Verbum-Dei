//___FILEHEADER___

import SwiftUI

@main
struct AquinasAILatinEnglishBibleApp: App {
    @StateObject private var ttsManager = TTSManager()
    @StateObject private var audioSettings = AudioSettings()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(ttsManager)
                .environmentObject(audioSettings)
        }
    }
}
