import SwiftUI

struct DictionaryEntryView: View {
    let entry: DictionaryEntry
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // Word and Basic Info
                VStack(alignment: .leading, spacing: 8) {
                    HStack(alignment: .firstTextBaseline) {
                        Text(entry.titleOrthography ?? entry.key)
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(colorScheme == .dark ? .nightText : .primary)
                        
                        if let genitive = entry.titleGenitive {
                            Text(", " + genitive)
                                .font(.title3)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    // Part of Speech and Grammar Info
                    HStack {
                        if let pos = entry.partOfSpeech {
                            Text(pos)
                                .italic()
                        }
                        if let gender = entry.gender {
                            Text("• " + gender)
                        }
                        if let declension = entry.declension {
                            Text("• \(declension)th declension")
                        }
                    }
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    
                    // Alternative Forms
                    if let alternatives = entry.alternativeOrthography, !alternatives.isEmpty {
                        Text("Also: " + alternatives.joined(separator: ", "))
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    // Main Notes if present
                    if let notes = entry.mainNotes, !notes.isEmpty {
                        Text(notes)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .padding(.top, 4)
                    }
                }
                .padding(.bottom, 8)
                
                // Definitions
                ForEach(entry.senses.indices, id: \.self) { index in
                    VStack(alignment: .leading, spacing: 8) {
                        Text("\(index + 1).")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        
                        Text(entry.senses[index])
                            .font(.body)
                            .foregroundColor(colorScheme == .dark ? .nightText : .primary)
                    }
                    
                    if index != entry.senses.count - 1 {
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
    
    var body: some View {
        NavigationView {
            Group {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                } else if let error = error {
                    VStack {
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
                    VStack {
                        Image(systemName: "book.closed")
                            .font(.largeTitle)
                            .foregroundColor(.secondary)
                        Text("No definition found")
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
            .navigationTitle("Dictionary")
            .navigationBarTitleDisplayMode(.inline)
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