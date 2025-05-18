import SwiftUI

struct LatinOnlyVerseView: View {
    let number: Int
    let text: String
    let isBookmarked: Bool
    let onDeleteBookmark: (() -> Void)?
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
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
                .contextMenu {
                    if isBookmarked {
                        Button(role: .destructive, action: { onDeleteBookmark?() }) {
                            Label("Remove Bookmark", systemImage: "bookmark.slash")
                        }
                    } else {
                        Button {
                            NotificationCenter.default.post(
                                name: NSNotification.Name("AddBookmark"), 
                                object: nil, 
                                userInfo: ["verseNumber": number]
                            )
                        } label: {
                            Label("Add Bookmark", systemImage: "bookmark")
                        }
                    }
                    
                    Button {
                        UIPasteboard.general.string = text
                    } label: {
                        Label("Copy", systemImage: "doc.on.doc")
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
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
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
                .contextMenu {
                    if isBookmarked {
                        Button(role: .destructive, action: { onDeleteBookmark?() }) {
                            Label("Remove Bookmark", systemImage: "bookmark.slash")
                        }
                    } else {
                        Button {
                            NotificationCenter.default.post(
                                name: NSNotification.Name("AddBookmark"), 
                                object: nil, 
                                userInfo: ["verseNumber": number]
                            )
                        } label: {
                            Label("Add Bookmark", systemImage: "bookmark")
                        }
                    }
                    
                    Button {
                        UIPasteboard.general.string = text
                    } label: {
                        Label("Copy", systemImage: "doc.on.doc")
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
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
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
            .contextMenu {
                if isBookmarked {
                    Button(role: .destructive, action: { onDeleteBookmark?() }) {
                        Label("Remove Bookmark", systemImage: "bookmark.slash")
                    }
                } else {
                    Button {
                        NotificationCenter.default.post(
                            name: NSNotification.Name("AddBookmark"), 
                            object: nil, 
                            userInfo: ["verseNumber": number]
                        )
                    } label: {
                        Label("Add Bookmark", systemImage: "bookmark")
                    }
                }
                
                Button {
                    UIPasteboard.general.string = latinText + "\n\n" + englishText
                } label: {
                    Label("Copy Both", systemImage: "doc.on.doc")
                }
                
                Button {
                    UIPasteboard.general.string = latinText
                } label: {
                    Label("Copy Latin", systemImage: "doc.on.doc.fill")
                }
                
                Button {
                    UIPasteboard.general.string = englishText
                } label: {
                    Label("Copy English", systemImage: "doc.on.clipboard")
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
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("AddBookmark"))) { notification in
            if !isBookmarked {
                if let userInfo = notification.userInfo,
                   let notificationVerseNumber = userInfo["verseNumber"] as? Int,
                   notificationVerseNumber == verse.number {
                    showingBookmarkSheet = true
                }
            }
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
        if let bookmark = bookmarkStore.getBookmark(
            bookName: bookName,
            chapterNumber: chapterNumber,
            verseNumber: verse.number
        ) {
            bookmarkStore.removeBookmark(withId: bookmark.id)
        }
    }
} 