import SwiftUI

struct LatinOnlyVerseView: View {
    let number: Int
    let text: String
    let isBookmarked: Bool
    let onDeleteBookmark: (() -> Void)?
    let onCreateBookmark: () -> Void
    @Environment(\.colorScheme) private var colorScheme
    @State private var offset: CGFloat = 0
    @State private var showingBookmarkIndicator = false
    
    var body: some View {
        ZStack {
            // Bookmark indicator background
            HStack {
                Spacer()
                Image(systemName: "bookmark.fill")
                    .foregroundColor(.white)
                    .frame(width: 50)
                    .opacity(showingBookmarkIndicator ? 1 : 0)
            }
            .background(Color.deepPurple)
            
            // Main content
            HStack(alignment: .top, spacing: 8) {
                Text("\(number)")
                    .font(.footnote)
                    .foregroundColor(colorScheme == .dark ? .nightSecondary : .secondary)
                    .frame(width: 30, alignment: .trailing)
                Text(text)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(8)
                    .background(isBookmarked ? (colorScheme == .dark ? Color.white.opacity(0.1) : Color.secondary.opacity(0.15)) : Color.clear)
                    .cornerRadius(8)
                    .foregroundColor(colorScheme == .dark ? .nightText : Color(.displayP3, red: 0.1, green: 0.1, blue: 0.1, opacity: 1))
            }
            .padding(.vertical, 4)
            .background(colorScheme == .dark ? Color.nightBackground : Color.paperWhite)
            .offset(x: offset)
            .gesture(
                DragGesture()
                    .onChanged { gesture in
                        if !isBookmarked {
                            let translation = gesture.translation.width
                            offset = max(-100, min(0, translation))
                            showingBookmarkIndicator = offset < -50
                        }
                    }
                    .onEnded { gesture in
                        if offset < -50 && !isBookmarked {
                            onCreateBookmark()
                        }
                        withAnimation {
                            offset = 0
                            showingBookmarkIndicator = false
                        }
                    }
            )
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
    let onCreateBookmark: () -> Void
    @Environment(\.colorScheme) private var colorScheme
    @State private var offset: CGFloat = 0
    @State private var showingBookmarkIndicator = false
    
    var body: some View {
        ZStack {
            // Bookmark indicator background
            HStack {
                Spacer()
                Image(systemName: "bookmark.fill")
                    .foregroundColor(.white)
                    .frame(width: 50)
                    .opacity(showingBookmarkIndicator ? 1 : 0)
            }
            .background(Color.deepPurple)
            
            // Main content
            HStack(alignment: .top, spacing: 8) {
                Text("\(number)")
                    .font(.footnote)
                    .foregroundColor(colorScheme == .dark ? .nightSecondary : .secondary)
                    .frame(width: 30, alignment: .trailing)
                Text(text)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(8)
                    .background(isBookmarked ? (colorScheme == .dark ? Color.white.opacity(0.1) : Color.secondary.opacity(0.15)) : Color.clear)
                    .cornerRadius(8)
                    .foregroundColor(colorScheme == .dark ? .nightText : Color(.displayP3, red: 0.1, green: 0.1, blue: 0.1, opacity: 1))
            }
            .padding(.vertical, 4)
            .background(colorScheme == .dark ? Color.nightBackground : Color.paperWhite)
            .offset(x: offset)
            .gesture(
                DragGesture()
                    .onChanged { gesture in
                        if !isBookmarked {
                            let translation = gesture.translation.width
                            offset = max(-100, min(0, translation))
                            showingBookmarkIndicator = offset < -50
                        }
                    }
                    .onEnded { gesture in
                        if offset < -50 && !isBookmarked {
                            onCreateBookmark()
                        }
                        withAnimation {
                            offset = 0
                            showingBookmarkIndicator = false
                        }
                    }
            )
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
    let onCreateBookmark: () -> Void
    @Environment(\.colorScheme) private var colorScheme
    @State private var offset: CGFloat = 0
    @State private var showingBookmarkIndicator = false
    
    var body: some View {
        ZStack {
            // Bookmark indicator background
            HStack {
                Spacer()
                Image(systemName: "bookmark.fill")
                    .foregroundColor(.white)
                    .frame(width: 50)
                    .opacity(showingBookmarkIndicator ? 1 : 0)
            }
            .background(Color.deepPurple)
            
            // Main content
            HStack(alignment: .top, spacing: 8) {
                Text("\(number)")
                    .font(.footnote)
                    .foregroundColor(colorScheme == .dark ? .nightSecondary : .secondary)
                    .frame(width: 30, alignment: .trailing)
                VStack(alignment: .leading, spacing: 4) {
                    Text(latinText)
                        .fixedSize(horizontal: false, vertical: true)
                        .foregroundColor(colorScheme == .dark ? .nightText : Color(.displayP3, red: 0.1, green: 0.1, blue: 0.1, opacity: 1))
                    Text(englishText)
                        .italic()
                        .foregroundColor(colorScheme == .dark ? .nightSecondary : Color(.displayP3, red: 0.3, green: 0.3, blue: 0.3, opacity: 1))
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(8)
                .background(isBookmarked ? (colorScheme == .dark ? Color.white.opacity(0.1) : Color.secondary.opacity(0.15)) : Color.clear)
                .cornerRadius(8)
            }
            .padding(.vertical, 4)
            .background(colorScheme == .dark ? Color.nightBackground : Color.paperWhite)
            .offset(x: offset)
            .gesture(
                DragGesture()
                    .onChanged { gesture in
                        if !isBookmarked {
                            let translation = gesture.translation.width
                            offset = max(-100, min(0, translation))
                            showingBookmarkIndicator = offset < -50
                        }
                    }
                    .onEnded { gesture in
                        if offset < -50 && !isBookmarked {
                            onCreateBookmark()
                        }
                        withAnimation {
                            offset = 0
                            showingBookmarkIndicator = false
                        }
                    }
            )
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
    @EnvironmentObject private var viewModel: BibleViewModel
    
    var body: some View {
        Group {
            if displayMode == .latinOnly {
                LatinOnlyVerseView(
                    number: verse.number,
                    text: verse.latinText,
                    isBookmarked: isBookmarked,
                    onDeleteBookmark: deleteBookmark,
                    onCreateBookmark: { showingBookmarkSheet = true }
                )
            } else if displayMode == .englishOnly {
                EnglishOnlyVerseView(
                    number: verse.number,
                    text: verse.englishText,
                    isBookmarked: isBookmarked,
                    onDeleteBookmark: deleteBookmark,
                    onCreateBookmark: { showingBookmarkSheet = true }
                )
            } else {
                BilingualVerseView(
                    number: verse.number,
                    latinText: verse.latinText,
                    englishText: verse.englishText,
                    isBookmarked: isBookmarked,
                    onDeleteBookmark: deleteBookmark,
                    onCreateBookmark: { showingBookmarkSheet = true }
                )
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