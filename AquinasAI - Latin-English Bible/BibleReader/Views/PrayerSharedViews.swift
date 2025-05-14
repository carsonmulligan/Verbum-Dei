import SwiftUI

enum PrayerLanguage: String, CaseIterable {
    case latinOnly = "latin"
    case englishOnly = "english"
    case bilingual = "bilingual"
}

struct PrayerCard: View {
    let prayer: Prayer
    let language: PrayerLanguage
    @Environment(\.colorScheme) private var colorScheme
    @EnvironmentObject private var bookmarkStore: BookmarkStore
    @State private var showingBookmarkSheet = false
    @State private var showingEditBookmarkSheet = false
    
    // Optional speech service parameter - if not provided, speech controls won't appear
    var speechService: SpeechService?
    
    var isBookmarked: Bool {
        bookmarkStore.isPrayerBookmarked(prayerId: prayer.id)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    if language == .latinOnly || language == .bilingual {
                        Text(prayer.displayTitleLatin)
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.deepPurple)
                    }
                    
                    if language == .englishOnly || language == .bilingual {
                        if language == .bilingual {
                            Text(prayer.displayTitleEnglish)
                                .font(.subheadline)
                                .foregroundColor(colorScheme == .dark ? Color.white.opacity(0.8) : Color.primary.opacity(0.8))
                                .italic()
                        } else {
                            Text(prayer.displayTitleEnglish)
                                .font(.headline)
                                .fontWeight(.semibold)
                                .foregroundColor(.deepPurple)
                        }
                    }
                }
                
                Spacer()
                
                Button(action: {
                    if isBookmarked {
                        showingEditBookmarkSheet = true
                    } else {
                        print("Bookmarking prayer: '\(prayer.title)' with ID: '\(prayer.id)'")
                        showingBookmarkSheet = true
                    }
                }) {
                    Image(systemName: isBookmarked ? "bookmark.fill" : "bookmark")
                        .foregroundColor(.deepPurple)
                        .font(.system(size: 18))
                }
            }
            
            if language == .latinOnly || language == .bilingual {
                Text(prayer.latin)
                    .font(.body)
                    .foregroundColor(colorScheme == .dark ? .white : .primary)
                    .padding(.top, 4)
            }
            
            if language == .englishOnly || language == .bilingual {
                Text(prayer.english)
                    .font(.body)
                    .foregroundColor(language == .bilingual ? .secondary : (colorScheme == .dark ? .white : .primary))
                    .italic(language == .bilingual)
                    .padding(.top, language == .bilingual ? 2 : 4)
            }
            
            // Speech controls if speech service is provided
            if let speechService = speechService {
                HStack {
                    if language != .englishOnly {
                        SpeechControlButton(
                            speechService: speechService,
                            text: prayer.latin,
                            language: "latin"
                        )
                    }
                    
                    if language != .latinOnly {
                        SpeechControlButton(
                            speechService: speechService,
                            text: prayer.english,
                            language: "english"
                        )
                    }
                    
                    Spacer()
                    
                    if speechService.isSpeaking {
                        Button(action: {
                            speechService.stopSpeaking()
                        }) {
                            Image(systemName: "stop.circle")
                                .foregroundColor(.red)
                                .imageScale(.large)
                        }
                    }
                }
                .padding(.top, 8)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(colorScheme == .dark ? Color.black.opacity(0.3) : Color.white)
                .shadow(color: colorScheme == .dark ? .clear : Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .strokeBorder(Color.deepPurple.opacity(0.2), lineWidth: 1)
        )
        .contextMenu {
            if isBookmarked {
                Button {
                    if let bookmark = bookmarkStore.getPrayerBookmark(prayerId: prayer.id) {
                        bookmarkStore.removeBookmark(withId: bookmark.id)
                    }
                } label: {
                    Label("Remove Bookmark", systemImage: "bookmark.slash")
                }
                
                Button {
                    showingEditBookmarkSheet = true
                } label: {
                    Label("Edit Bookmark", systemImage: "pencil")
                }
            } else {
                Button {
                    showingBookmarkSheet = true
                } label: {
                    Label("Add Bookmark", systemImage: "bookmark")
                }
            }
        }
        .sheet(isPresented: $showingBookmarkSheet) {
            PrayerBookmarkCreationView(prayer: prayer)
        }
        .sheet(isPresented: $showingEditBookmarkSheet) {
            if let bookmark = bookmarkStore.getPrayerBookmark(prayerId: prayer.id) {
                PrayerBookmarkEditView(bookmark: bookmark)
            }
        }
    }
}

struct PrayerBookmarkCreationView: View {
    let prayer: Prayer
    @State private var note: String = ""
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var bookmarkStore: BookmarkStore
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Prayer")) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(prayer.displayTitleEnglish)
                            .font(.headline)
                            .foregroundColor(.primary)
                        Text(prayer.displayTitleLatin)
                            .italic()
                            .foregroundColor(.secondary)
                    }
                }
                
                Section(header: Text("Notes")) {
                    TextEditor(text: $note)
                        .frame(minHeight: 100)
                }
            }
            .navigationTitle("Add Prayer Bookmark")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        print("Creating bookmark for prayer: '\(prayer.title)' with ID: '\(prayer.id)'")
                        let bookmark = Bookmark(prayer: prayer, note: note)
                        bookmarkStore.addBookmark(bookmark)
                        dismiss()
                    }
                }
            }
        }
    }
}

struct PrayerBookmarkEditView: View {
    let bookmark: Bookmark
    @State private var note: String
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var bookmarkStore: BookmarkStore
    
    init(bookmark: Bookmark) {
        self.bookmark = bookmark
        _note = State(initialValue: bookmark.note)
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Prayer")) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(bookmark.prayerTitleEnglish ?? bookmark.prayerTitle ?? "")
                            .font(.headline)
                            .foregroundColor(.primary)
                        Text(bookmark.prayerTitleLatin ?? "")
                            .italic()
                            .foregroundColor(.secondary)
                    }
                }
                
                Section(header: Text("Notes")) {
                    TextEditor(text: $note)
                        .frame(minHeight: 100)
                }
                
                Section {
                    Button(role: .destructive) {
                        bookmarkStore.removeBookmark(withId: bookmark.id)
                        dismiss()
                    } label: {
                        HStack {
                            Image(systemName: "bookmark.slash")
                            Text("Remove Bookmark")
                        }
                    }
                }
            }
            .navigationTitle("Edit Prayer Bookmark")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        var updatedBookmark = bookmark
                        updatedBookmark.note = note
                        bookmarkStore.updateBookmark(updatedBookmark)
                        dismiss()
                    }
                }
            }
        }
    }
} 