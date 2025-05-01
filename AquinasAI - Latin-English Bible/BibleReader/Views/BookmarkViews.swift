import SwiftUI

struct BookmarkCreationView: View {
    let verse: Verse
    let bookName: String
    let chapterNumber: Int
    @State private var note: String = ""
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var bookmarkStore: BookmarkStore
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Verse").font(.custom("Times New Roman", size: 14))) {
                    Text(verse.latinText)
                        .font(.custom("Times New Roman", size: 17))
                    if verse.englishText != verse.latinText {
                        Text(verse.englishText)
                            .font(.custom("Times New Roman", size: 17))
                            .italic()
                            .foregroundColor(.gray)
                    }
                }
                
                Section(header: Text("Notes").font(.custom("Times New Roman", size: 14))) {
                    TextEditor(text: $note)
                        .font(.custom("Times New Roman", size: 17))
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
                    .font(.custom("Times New Roman", size: 17))
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        let bookmark = Bookmark(
                            bookName: bookName,
                            chapterNumber: chapterNumber,
                            verseNumber: verse.number,
                            note: note,
                            verseText: verse.latinText
                        )
                        bookmarkStore.addBookmark(bookmark)
                        dismiss()
                    }
                    .font(.custom("Times New Roman", size: 17))
                }
            }
        }
    }
}

struct BookmarksListView: View {
    @EnvironmentObject private var bookmarkStore: BookmarkStore
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
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text("\(bookmark.bookName) \(bookmark.chapterNumber):\(bookmark.verseNumber)")
                                    .font(.custom("Times New Roman", size: 17))
                                    .foregroundColor(.primary)
                                Spacer()
                                Text(bookmark.timestamp.formatted(date: .abbreviated, time: .shortened))
                                    .font(.custom("Times New Roman", size: 14))
                                    .foregroundColor(.secondary)
                            }
                            
                            Text(bookmark.verseText)
                                .font(.custom("Times New Roman", size: 15))
                                .foregroundColor(.secondary)
                                .lineLimit(2)
                            
                            if !bookmark.note.isEmpty {
                                Text(bookmark.note)
                                    .font(.custom("Times New Roman", size: 15))
                                    .foregroundColor(.deepPurple)
                                    .lineLimit(2)
                            }
                        }
                        .padding(.vertical, 4)
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
                    .font(.custom("Times New Roman", size: 17))
                }
            }
        }
    }
} 