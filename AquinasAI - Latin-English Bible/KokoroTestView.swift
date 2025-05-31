import SwiftUI
import AVFoundation

struct KokoroTestView: View {
    @StateObject private var kokoroTest = KokoroTTSTest()
    @StateObject private var iosTTSManager = TTSManager()
    
    @State private var selectedTestIndex = 0
    @State private var showingReport = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                headerSection
                testSelectionSection
                comparisonSection
                resultsSection
                
                Spacer()
            }
            .padding()
            .navigationTitle("TTS Comparison Test")
            .sheet(isPresented: $showingReport) {
                reportView
            }
        }
    }
    
    // MARK: - UI Sections
    
    private var headerSection: some View {
        VStack(spacing: 8) {
            Text("Audio Quality Comparison")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Compare iOS built-in TTS vs Kokoro neural TTS for Latin pronunciation")
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
    }
    
    private var testSelectionSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Test Sample")
                .font(.headline)
            
            Picker("Test Text", selection: $selectedTestIndex) {
                ForEach(0..<kokoroTest.testTexts.count, id: \.self) { index in
                    Text(kokoroTest.testTexts[index].description)
                        .tag(index)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            
            if selectedTestIndex < kokoroTest.testTexts.count {
                let testText = kokoroTest.testTexts[selectedTestIndex]
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Latin:")
                        .font(.caption)
                        .fontWeight(.medium)
                    Text(testText.latin)
                        .font(.body)
                        .padding(8)
                        .background(Color.secondary.opacity(0.1))
                        .cornerRadius(8)
                    
                    Text("English:")
                        .font(.caption)
                        .fontWeight(.medium)
                        .padding(.top, 4)
                    Text(testText.english)
                        .font(.caption)
                        .italic()
                        .foregroundColor(.secondary)
                }
            }
        }
    }
    
    private var comparisonSection: some View {
        VStack(spacing: 16) {
            Text("Audio Comparison")
                .font(.headline)
            
            HStack(spacing: 20) {
                // iOS TTS Test
                VStack(spacing: 8) {
                    Text("iOS TTS")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    Button(action: {
                        testIOSTTS()
                    }) {
                        VStack {
                            Image(systemName: iosTTSManager.isPlaying ? "speaker.wave.2.fill" : "speaker.wave.2")
                                .font(.title2)
                            Text("Play Italian Voice")
                                .font(.caption)
                        }
                        .foregroundColor(.blue)
                        .padding()
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(12)
                    }
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("• Size: 0MB (built-in)")
                        Text("• Setup: Already done")
                        Text("• Quality: Good")
                    }
                    .font(.caption)
                    .foregroundColor(.secondary)
                }
                
                // Kokoro TTS Test
                VStack(spacing: 8) {
                    Text("Kokoro TTS")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    Button(action: {
                        testKokoroTTS()
                    }) {
                        VStack {
                            Image(systemName: kokoroTest.isTestingAvailable ? "speaker.wave.3" : "speaker.slash")
                                .font(.title2)
                            Text(kokoroTest.isTestingAvailable ? "Play Neural Voice" : "Not Available")
                                .font(.caption)
                        }
                        .foregroundColor(kokoroTest.isTestingAvailable ? .purple : .gray)
                        .padding()
                        .background(kokoroTest.isTestingAvailable ? Color.purple.opacity(0.1) : Color.gray.opacity(0.1))
                        .cornerRadius(12)
                    }
                    .disabled(!kokoroTest.isTestingAvailable)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("• Size: +102MB")
                        Text("• Setup: 1 week dev")
                        Text("• Quality: Excellent")
                    }
                    .font(.caption)
                    .foregroundColor(.secondary)
                }
            }
        }
    }
    
    private var resultsSection: some View {
        VStack(spacing: 12) {
            HStack {
                Text("Test Results")
                    .font(.headline)
                
                Spacer()
                
                Button("View Full Report") {
                    showingReport = true
                }
                .font(.caption)
                .foregroundColor(.blue)
            }
            
            if !kokoroTest.testResults.isEmpty {
                let avgScore = kokoroTest.testSummary?.averageIOSScore ?? 0
                
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("iOS TTS Average Score:")
                        Spacer()
                        Text("\(Int(avgScore * 100))%")
                            .fontWeight(.medium)
                            .foregroundColor(scoreColor(avgScore))
                    }
                    
                    ProgressView(value: avgScore)
                        .progressViewStyle(LinearProgressViewStyle(tint: scoreColor(avgScore)))
                    
                    if let summary = kokoroTest.testSummary {
                        Text("Implementation Complexity: \(summary.implementationComplexity.description)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .padding()
                .background(Color.secondary.opacity(0.05))
                .cornerRadius(12)
            } else {
                Text("Run tests to see results")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding()
                    .background(Color.secondary.opacity(0.05))
                    .cornerRadius(12)
            }
        }
    }
    
    private var reportView: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text(kokoroTest.generateDetailedReport())
                        .font(.system(.body, design: .monospaced))
                        .padding()
                }
            }
            .navigationTitle("TTS Evaluation Report")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        showingReport = false
                    }
                }
            }
        }
    }
    
    // MARK: - Actions
    
    private func testIOSTTS() {
        guard selectedTestIndex < kokoroTest.testTexts.count else { return }
        let testText = kokoroTest.testTexts[selectedTestIndex]
        
        // Play using iOS TTS with Italian voice for Latin
        iosTTSManager.speakLatin(testText.latin)
        
        // Run the comparison test to update results
        kokoroTest.runComparisonTest()
    }
    
    private func testKokoroTTS() {
        // Placeholder for when Kokoro is implemented
        // For now, show what would happen
        print("Kokoro TTS would play here with superior quality")
        print("Estimated 2-3 second loading time for first use")
        print("Then 0.1-0.5 second generation time per verse")
    }
    
    private func scoreColor(_ score: Double) -> Color {
        switch score {
        case 0.8...: return .green
        case 0.6..<0.8: return .orange
        default: return .red
        }
    }
}

// MARK: - KokoroTTSTest Extension for UI

extension KokoroTTSTest {
    var testTexts: [TestText] {
        return [
            TestText(
                latin: "Ave Maria, gratia plena, Dominus tecum.",
                english: "Hail Mary, full of grace, the Lord is with thee.",
                description: "Ave Maria"
            ),
            TestText(
                latin: "Pater noster, qui es in caelis, sanctificetur nomen tuum.",
                english: "Our Father, who art in heaven, hallowed be thy name.",
                description: "Pater Noster"
            ),
            TestText(
                latin: "Gloria in excelsis Deo et in terra pax hominibus bonae voluntatis.",
                english: "Glory to God in the highest, and on earth peace to people of good will.",
                description: "Gloria"
            ),
            TestText(
                latin: "Veni Creator Spiritus, mentes tuorum visita.",
                english: "Come, Creator Spirit, visit the minds of your people.",
                description: "Veni Creator"
            )
        ]
    }
}

// MARK: - Preview

struct KokoroTestView_Previews: PreviewProvider {
    static var previews: some View {
        KokoroTestView()
    }
}

// MARK: - Integration Instructions

/**
 * TO USE THIS TEST VIEW IN YOUR APP:
 * 
 * 1. Add this view to your ContentView for testing:
 * 
 * ```swift
 * TabView {
 *     // Your existing tabs...
 *     
 *     KokoroTestView()
 *         .tabItem {
 *             Image(systemName: "speaker.wave.2")
 *             Text("TTS Test")
 *         }
 * }
 * ```
 * 
 * 2. Or present it as a sheet from a settings menu:
 * 
 * ```swift
 * Button("Test Audio Quality") {
 *     showingTTSTest = true
 * }
 * .sheet(isPresented: $showingTTSTest) {
 *     KokoroTestView()
 * }
 * ```
 * 
 * 3. To actually implement Kokoro, you would:
 *    - Add MLX Swift package dependency
 *    - Download and integrate required files
 *    - Implement the commented-out Kokoro methods
 *    - Update the `isTestingAvailable` flag to true
 */ 