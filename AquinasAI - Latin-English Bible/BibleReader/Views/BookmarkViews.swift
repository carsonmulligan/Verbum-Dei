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
                    Text(verse.englishText)
                        .foregroundColor(.primary)
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
                            verseText: verse.englishText
                        )
                        bookmarkStore.addBookmark(bookmark)
                        dismiss()
                    }
                }
            }
        }
    }
}

struct BookmarksListView: View {
    @EnvironmentObject private var bookmarkStore: BookmarkStore
    @EnvironmentObject private var viewModel: BibleViewModel
    @Environment(\.dismiss) private var dismiss
    var onBookmarkSelected: (Bookmark) -> Void
    
    var body: some View {
        NavigationView {
            List {
                ForEach(bookmarkStore.bookmarks.sorted(by: { $0.timestamp > $1.timestamp })) { bookmark in
                    Button(action: {
                        onBookmarkSelected(bookmark)
                        dismiss()
                    }) {
                        VStack(alignment: .leading, spacing: 4) {
                            HStack {
                                Text("\(viewModel.getEnglishName(for: bookmark.bookName)) \(bookmark.chapterNumber):\(bookmark.verseNumber)")
                                    .font(.headline)
                                    .foregroundColor(.primary)
                                Spacer()
                                Image(systemName: "bookmark.fill")
                                    .foregroundColor(.deepPurple)
                            }
                            
                            Text(bookmark.verseText)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .lineLimit(2)
                            
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
                }
                .onDelete { indexSet in
                    for index in indexSet {
                        let bookmark = bookmarkStore.bookmarks.sorted(by: { $0.timestamp > $1.timestamp })[index]
                        bookmarkStore.removeBookmark(withId: bookmark.id)
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
        }
    }
} 