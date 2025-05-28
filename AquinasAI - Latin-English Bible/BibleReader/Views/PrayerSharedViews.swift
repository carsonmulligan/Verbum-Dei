import SwiftUI

enum PrayerLanguage: String, CaseIterable {
    case latinOnly = "latin"
    case englishOnly = "english"
    case spanishOnly = "spanish"
    case latinEnglish = "latin_english"
    case latinSpanish = "latin_spanish"
    case englishSpanish = "english_spanish"
    
    var displayName: String {
        switch self {
        case .latinOnly:
            return "Latin"
        case .englishOnly:
            return "English"
        case .spanishOnly:
            return "Spanish"
        case .latinEnglish:
            return "Latin-English"
        case .latinSpanish:
            return "Latin-Spanish"
        case .englishSpanish:
            return "English-Spanish"
        }
    }
    
    var isBilingual: Bool {
        switch self {
        case .latinOnly, .englishOnly, .spanishOnly:
            return false
        case .latinEnglish, .latinSpanish, .englishSpanish:
            return true
        }
    }
    
    var showsLatin: Bool {
        switch self {
        case .latinOnly, .latinEnglish, .latinSpanish:
            return true
        case .englishOnly, .spanishOnly, .englishSpanish:
            return false
        }
    }
    
    var showsEnglish: Bool {
        switch self {
        case .englishOnly, .latinEnglish, .englishSpanish:
            return true
        case .latinOnly, .spanishOnly, .latinSpanish:
            return false
        }
    }
    
    var showsSpanish: Bool {
        switch self {
        case .spanishOnly, .latinSpanish, .englishSpanish:
            return true
        case .latinOnly, .englishOnly, .latinEnglish:
            return false
        }
    }
}

struct PrayerCard: View {
    let prayer: Prayer
    let language: PrayerLanguage
    @Environment(\.colorScheme) private var colorScheme
    @EnvironmentObject private var bookmarkStore: BookmarkStore
    @State private var showingBookmarkSheet = false
    @State private var showingEditBookmarkSheet = false
    
    var isBookmarked: Bool {
        bookmarkStore.isPrayerBookmarked(prayerId: prayer.id)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    // Title display logic
                    if language.showsLatin {
                        Text(prayer.displayTitleLatin)
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.deepPurple)
                    }
                    
                    if language.showsEnglish {
                        Text(prayer.displayTitleEnglish)
                            .font(language.isBilingual ? .subheadline : .headline)
                            .fontWeight(language.isBilingual ? .medium : .semibold)
                            .foregroundColor(language.isBilingual ? 
                                (colorScheme == .dark ? Color.white.opacity(0.8) : Color.primary.opacity(0.8)) : 
                                .deepPurple)
                            .italic(language.isBilingual)
                    }
                    
                    if language.showsSpanish {
                        Text(prayer.displayTitleSpanish)
                            .font(language.isBilingual ? .subheadline : .headline)
                            .fontWeight(language.isBilingual ? .medium : .semibold)
                            .foregroundColor(language.isBilingual ? 
                                (colorScheme == .dark ? Color.white.opacity(0.8) : Color.primary.opacity(0.8)) : 
                                .deepPurple)
                            .italic(language.isBilingual)
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
            
            // Prayer Instructions (if available)
            if let instructions = prayer.instructions {
                Text(instructions)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .italic()
                    .padding(.bottom, 4)
            }
            
            // Prayer text display logic
            if language.showsLatin {
                Text(prayer.latin)
                    .font(.body)
                    .foregroundColor(colorScheme == .dark ? .white : .primary)
                    .padding(.top, 4)
            }
            
            if language.showsEnglish {
                Text(prayer.english)
                    .font(.body)
                    .foregroundColor(language.isBilingual ? .secondary : (colorScheme == .dark ? .white : .primary))
                    .italic(language.isBilingual)
                    .padding(.top, language.isBilingual ? 2 : 4)
            }
            
            if language.showsSpanish {
                if let spanishText = prayer.spanish {
                    Text(spanishText)
                        .font(.body)
                        .foregroundColor(language.isBilingual ? .secondary : (colorScheme == .dark ? .white : .primary))
                        .italic(language.isBilingual)
                        .padding(.top, language.isBilingual ? 2 : 4)
                } else {
                    // Fallback if Spanish text is not available
                    Text("Spanish translation not available")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .italic()
                        .padding(.top, language.isBilingual ? 2 : 4)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(colorScheme == .dark ? Color.black.opacity(0.3) : Color.paperWhite)
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
            
            // Copy options based on language mode
            if language.isBilingual {
                Button {
                    var copyText = ""
                    if language.showsLatin { copyText += prayer.latin }
                    if language.showsEnglish { 
                        if !copyText.isEmpty { copyText += "\n\n" }
                        copyText += prayer.english 
                    }
                    if language.showsSpanish, let spanish = prayer.spanish { 
                        if !copyText.isEmpty { copyText += "\n\n" }
                        copyText += spanish 
                    }
                    UIPasteboard.general.string = copyText
                } label: {
                    Label("Copy Both", systemImage: "doc.on.doc")
                }
                
                if language.showsLatin {
                    Button {
                        UIPasteboard.general.string = prayer.latin
                    } label: {
                        Label("Copy Latin", systemImage: "doc.on.doc.fill")
                    }
                }
                
                if language.showsEnglish {
                    Button {
                        UIPasteboard.general.string = prayer.english
                    } label: {
                        Label("Copy English", systemImage: "doc.on.clipboard")
                    }
                }
                
                if language.showsSpanish {
                    Button {
                        UIPasteboard.general.string = prayer.spanish ?? ""
                    } label: {
                        Label("Copy Spanish", systemImage: "doc.on.clipboard.fill")
                    }
                }
            } else {
                Button {
                    var copyText = ""
                    if language.showsLatin { copyText = prayer.latin }
                    else if language.showsEnglish { copyText = prayer.english }
                    else if language.showsSpanish { copyText = prayer.spanish ?? "" }
                    UIPasteboard.general.string = copyText
                } label: {
                    Label("Copy", systemImage: "doc.on.doc")
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