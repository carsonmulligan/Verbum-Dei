import SwiftUI

struct DictionaryEntryView: View {
    let entry: DictionaryEntry
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // Word and Part of Speech
                HStack {
                    Text(entry.word)
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(colorScheme == .dark ? .nightText : .primary)
                    
                    if let pos = entry.partOfSpeech {
                        Text(pos)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .italic()
                    }
                }
                
                // Definitions
                ForEach(entry.definitions.indices, id: \.self) { index in
                    VStack(alignment: .leading, spacing: 8) {
                        Text("\(index + 1).")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        
                        Text(entry.definitions[index])
                            .font(.body)
                            .foregroundColor(colorScheme == .dark ? .nightText : .primary)
                    }
                    
                    if index != entry.definitions.count - 1 {
                        Divider()
                            .background(colorScheme == .dark ? Color.white.opacity(0.1) : Color.separatorLight)
                    }
                }
            }
            .padding()
        }
        .background(colorScheme == .dark ? Color.nightBackground : Color.paperWhite)
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

struct DictionaryPopover: View {
    let word: String
    @StateObject private var dictionaryService = LatinDictionaryService()
    @State private var entries: [DictionaryEntry] = []
    @State private var isLoading = true
    @State private var error: Error?
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            Group {
                if isLoading {
                    ProgressView("Loading definition...")
                        .progressViewStyle(CircularProgressViewStyle())
                } else if let error = error {
                    VStack(spacing: 12) {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.largeTitle)
                            .foregroundColor(.red)
                        Text("Error loading definition")
                            .font(.headline)
                        Text(error.localizedDescription)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                } else if entries.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "book.closed")
                            .font(.largeTitle)
                            .foregroundColor(.secondary)
                        Text("No definition found for '\(word)'")
                            .font(.headline)
                    }
                } else {
                    ScrollView {
                        VStack(spacing: 20) {
                            ForEach(entries) { entry in
                                DictionaryEntryView(entry: entry)
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("Dictionary: \(word)")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .background(colorScheme == .dark ? Color.nightBackground : Color.paperWhite)
        }
        .task {
            do {
                entries = try await dictionaryService.lookupWord(word)
                isLoading = false
            } catch {
                self.error = error
                isLoading = false
            }
        }
    }
} 