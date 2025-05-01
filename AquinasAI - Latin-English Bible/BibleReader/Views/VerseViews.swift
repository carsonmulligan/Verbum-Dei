import SwiftUI

struct LatinOnlyVerseView: View {
    let number: Int
    let text: String
    let isBookmarked: Bool
    let onDeleteBookmark: (() -> Void)?
    
    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Text("\(number)")
                .font(.footnote)
                .foregroundColor(.secondary)
                .frame(width: 30, alignment: .trailing)
            Text(text)
                .fixedSize(horizontal: false, vertical: true)
                .padding(8)
                .background(isBookmarked ? Color.secondary.opacity(0.15) : Color.clear)
                .cornerRadius(8)
                .contextMenu {
                    if isBookmarked {
                        Button(role: .destructive, action: { onDeleteBookmark?() }) {
                            Label("Remove Bookmark", systemImage: "bookmark.slash")
                        }
                    }
                }
        }
    }
}

struct EnglishOnlyVerseView: View {
    let number: Int
    let text: String
    let isBookmarked: Bool
    let onDeleteBookmark: (() -> Void)?
    
    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Text("\(number)")
                .font(.footnote)
                .foregroundColor(.secondary)
                .frame(width: 30, alignment: .trailing)
            Text(text)
                .fixedSize(horizontal: false, vertical: true)
                .padding(8)
                .background(isBookmarked ? Color.secondary.opacity(0.15) : Color.clear)
                .cornerRadius(8)
                .contextMenu {
                    if isBookmarked {
                        Button(role: .destructive, action: { onDeleteBookmark?() }) {
                            Label("Remove Bookmark", systemImage: "bookmark.slash")
                        }
                    }
                }
        }
    }
}

struct BilingualVerseView: View {
    let number: Int
    let latinText: String
    let englishText: String
    let isBookmarked: Bool
    let onDeleteBookmark: (() -> Void)?
    
    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Text("\(number)")
                .font(.footnote)
                .foregroundColor(.secondary)
                .frame(width: 30, alignment: .trailing)
            VStack(alignment: .leading, spacing: 4) {
                Text(latinText)
                    .fixedSize(horizontal: false, vertical: true)
                Text(englishText)
                    .italic()
                    .foregroundColor(.gray)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(8)
            .background(isBookmarked ? Color.secondary.opacity(0.15) : Color.clear)
            .cornerRadius(8)
            .contextMenu {
                if isBookmarked {
                    Button(role: .destructive, action: { onDeleteBookmark?() }) {
                        Label("Remove Bookmark", systemImage: "bookmark.slash")
                    }
                }
            }
        }
    }
}

struct VerseView: View {
    let verse: Verse
    let displayMode: DisplayMode
    let bookName: String
    let chapterNumber: Int
    @State private var showingBookmarkSheet = false
    @EnvironmentObject private var bookmarkStore: BookmarkStore
    
    var body: some View {
        Group {
            if displayMode == .latinOnly {
                LatinOnlyVerseView(
                    number: verse.number,
                    text: verse.latinText,
                    isBookmarked: isBookmarked,
                    onDeleteBookmark: deleteBookmark
                )
            } else if displayMode == .englishOnly {
                EnglishOnlyVerseView(
                    number: verse.number,
                    text: verse.englishText,
                    isBookmarked: isBookmarked,
                    onDeleteBookmark: deleteBookmark
                )
            } else {
                BilingualVerseView(
                    number: verse.number,
                    latinText: verse.latinText,
                    englishText: verse.englishText,
                    isBookmarked: isBookmarked,
                    onDeleteBookmark: deleteBookmark
                )
            }
        }
        .onLongPressGesture {
            if !isBookmarked {
                showingBookmarkSheet = true
            }
        }
        .sheet(isPresented: $showingBookmarkSheet) {
            BookmarkCreationView(
                verse: verse,
                bookName: bookName,
                chapterNumber: chapterNumber
            )
        }
    }
    
    private var isBookmarked: Bool {
        bookmarkStore.isVerseBookmarked(
            bookName: bookName,
            chapterNumber: chapterNumber,
            verseNumber: verse.number
        )
    }
    
    private func deleteBookmark() {
        if let bookmark = bookmarkStore.bookmarks.first(where: { 
            $0.bookName == bookName &&
            $0.chapterNumber == chapterNumber &&
            $0.verseNumber == verse.number
        }) {
            bookmarkStore.removeBookmark(withId: bookmark.id)
        }
    }
} 