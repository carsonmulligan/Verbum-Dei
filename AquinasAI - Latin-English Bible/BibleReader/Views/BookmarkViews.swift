import SwiftUI

struct BookmarkCreationView: View {
    let verse: Verse
    let bookName: String
    let chapterNumber: Int
    @State private var note: String = ""
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var bookmarkStore: BookmarkStore
    @EnvironmentObject private var viewModel: BibleViewModel
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Verse")) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(verse.englishText)
                            .foregroundColor(.primary)
                        Text(verse.latinText)
                            .italic()
                            .foregroundColor(.secondary)
                    }
                }
                
                Section(header: Text("Notes")) {
                    TextEditor(text: $note)
                        .frame(minHeight: 100)
                }
            }
            .navigationTitle("Add Bookmark")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        let bookmark = Bookmark(
                            bookName: bookName,
                            chapterNumber: chapterNumber,
                            verseNumber: verse.number,
                            note: note,
                            verseText: verse.englishText,
                            latinText: verse.latinText
                        )
                        bookmarkStore.addBookmark(bookmark)
                        dismiss()
                    }
                }
            }
        }
    }
}

struct BookmarkEditView: View {
    let bookmark: Bookmark
    @State private var note: String
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var bookmarkStore: BookmarkStore
    @EnvironmentObject private var viewModel: BibleViewModel
    
    init(bookmark: Bookmark) {
        self.bookmark = bookmark
        _note = State(initialValue: bookmark.note)
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Verse")) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(bookmark.verseText ?? "")
                            .foregroundColor(.primary)
                        if let latinText = bookmark.latinText {
                            Text(latinText)
                                .italic()
                                .foregroundColor(.secondary)
                        }
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
            .navigationTitle("Edit Bookmark")
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

struct EmptyBookmarksView: View {
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "bookmark.circle")
                .font(.system(size: 50))
                .foregroundColor(.gray)
            
            Text("No Bookmarks Yet")
                .font(.headline)
                .foregroundColor(.gray)
            
            Text("Press and hold any verse to create a bookmark")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(colorScheme == .dark ? Color.nightBackground : Color.paperWhite)
    }
}

struct BookmarksListView: View {
    @EnvironmentObject private var bookmarkStore: BookmarkStore
    @EnvironmentObject private var viewModel: BibleViewModel
    @EnvironmentObject private var prayerStore: PrayerStore
    @Environment(\.dismiss) private var dismiss
    @State private var editingBookmark: Bookmark?
    @State private var showingPrayers = false
    @State private var selectedPrayerId: String?
    @State private var selectedPrayerCategory: PrayerCategory?
    var onBookmarkSelected: (Bookmark) -> Void
    
    var sortedBookmarks: [Bookmark] {
        bookmarkStore.bookmarks.sorted(by: { $0.timestamp > $1.timestamp })
    }
    
    var body: some View {
        NavigationView {
            Group {
                if sortedBookmarks.isEmpty {
                    EmptyBookmarksView()
                } else {
                    List {
                        ForEach(sortedBookmarks) { bookmark in
                            if bookmark.type == .verse {
                                BookmarkRow(
                                    bookmark: bookmark,
                                    viewModel: viewModel,
                                    onSelect: {
                                        onBookmarkSelected(bookmark)
                                        dismiss()
                                    },
                                    onEdit: {
                                        editingBookmark = bookmark
                                    }
                                )
                            } else {
                                PrayerBookmarkRow(
                                    bookmark: bookmark,
                                    onSelect: {
                                        // Store the prayer ID and show prayers view
                                        if let prayerId = bookmark.prayerId {
                                            print("Selected prayer bookmark with ID: '\(prayerId)', title: '\(bookmark.prayerTitle ?? "unknown")'")
                                            selectedPrayerId = prayerId
                                            
                                            // Convert prayerCategory string to PrayerCategory enum
                                            if let categoryStr = bookmark.prayerCategory {
                                                switch categoryStr {
                                                case PrayerCategory.basic.rawValue:
                                                    selectedPrayerCategory = .basic
                                                case PrayerCategory.mass.rawValue:
                                                    selectedPrayerCategory = .mass
                                                case PrayerCategory.rosary.rawValue:
                                                    selectedPrayerCategory = .rosary
                                                case PrayerCategory.divine.rawValue:
                                                    selectedPrayerCategory = .divine
                                                case PrayerCategory.other.rawValue:
                                                    selectedPrayerCategory = .other
                                                default:
                                                    selectedPrayerCategory = nil
                                                }
                                                print("Setting prayer category to: \(selectedPrayerCategory?.rawValue ?? "nil")")
                                            }
                                            
                                            showingPrayers = true
                                            // Don't dismiss here - let prayer view stay on screen
                                        } else {
                                            print("⚠️ Prayer bookmark has no prayerId!")
                                        }
                                    },
                                    onEdit: {
                                        editingBookmark = bookmark
                                    }
                                )
                            }
                        }
                        .onDelete { indexSet in
                            for index in indexSet {
                                let bookmark = sortedBookmarks[index]
                                bookmarkStore.removeBookmark(withId: bookmark.id)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Bookmarks")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .sheet(item: $editingBookmark) { bookmark in
                if bookmark.type == .verse {
                    BookmarkEditView(bookmark: bookmark)
                } else {
                    PrayerBookmarkEditView(bookmark: bookmark)
                }
            }
            .sheet(isPresented: $showingPrayers, onDismiss: {
                // Dismiss bookmarks view after prayer view is dismissed
                dismiss()
            }) {
                PrayersView(initialPrayerId: selectedPrayerId, initialCategory: selectedPrayerCategory)
                    .environmentObject(prayerStore)
            }
        }
    }
}

private struct BookmarkRow: View {
    let bookmark: Bookmark
    let viewModel: BibleViewModel
    let onSelect: () -> Void
    let onEdit: () -> Void
    @Environment(\.colorScheme) private var colorScheme
    @EnvironmentObject private var bookmarkStore: BookmarkStore
    
    var body: some View {
        Button(action: onSelect) {
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text("\(viewModel.getEnglishName(for: bookmark.bookName ?? "")) \(bookmark.chapterNumber ?? 0):\(bookmark.verseNumber ?? 0)")
                        .font(.headline)
                        .foregroundColor(.primary)
                    Spacer()
                    Image(systemName: "bookmark.fill")
                        .foregroundColor(.deepPurple)
                }
                
                Text(bookmark.verseText ?? "")
                    .font(.subheadline)
                    .foregroundColor(.primary)
                    .lineLimit(2)
                
                if let latinText = bookmark.latinText {
                    Text(latinText)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .italic()
                        .lineLimit(2)
                }
                
                if !bookmark.note.isEmpty {
                    Text(bookmark.note)
                        .font(.footnote)
                        .foregroundColor(.gray)
                        .lineLimit(1)
                        .padding(.top, 2)
                }
            }
            .contentShape(Rectangle())
        }
        .swipeActions(edge: .trailing) {
            Button(role: .destructive) {
                withAnimation {
                    bookmarkStore.removeBookmark(withId: bookmark.id)
                }
            } label: {
                Label("Delete", systemImage: "trash")
            }
            
            Button {
                onEdit()
            } label: {
                Label("Edit", systemImage: "pencil")
            }
            .tint(.blue)
        }
    }
}

private struct PrayerBookmarkRow: View {
    let bookmark: Bookmark
    let onSelect: () -> Void
    let onEdit: () -> Void
    @EnvironmentObject private var bookmarkStore: BookmarkStore
    
    var body: some View {
        Button(action: onSelect) {
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(bookmark.prayerTitleEnglish ?? bookmark.prayerTitle ?? "Prayer")
                        .font(.headline)
                        .foregroundColor(.primary)
                    Spacer()
                    Image(systemName: "bookmark.fill")
                        .foregroundColor(.deepPurple)
                }
                
                if let prayerTitleLatin = bookmark.prayerTitleLatin {
                    Text(prayerTitleLatin)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .italic()
                }
                
                if let prayerCategory = bookmark.prayerCategory, !prayerCategory.isEmpty {
                    Text(prayerCategory)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.top, 1)
                }
                
                if let prayerEnglish = bookmark.prayerEnglish {
                    Text(prayerEnglish)
                        .font(.subheadline)
                        .foregroundColor(.primary)
                        .lineLimit(2)
                }
                
                if !bookmark.note.isEmpty {
                    Text(bookmark.note)
                        .font(.footnote)
                        .foregroundColor(.gray)
                        .lineLimit(1)
                        .padding(.top, 2)
                }
            }
            .contentShape(Rectangle())
        }
        .swipeActions(edge: .trailing) {
            Button(role: .destructive) {
                withAnimation {
                    bookmarkStore.removeBookmark(withId: bookmark.id)
                }
            } label: {
                Label("Delete", systemImage: "trash")
            }
            
            Button {
                onEdit()
            } label: {
                Label("Edit", systemImage: "pencil")
            }
            .tint(.blue)
        }
    }
} 