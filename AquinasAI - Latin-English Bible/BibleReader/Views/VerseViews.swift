import SwiftUI
import UIKit

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
                }
            }
        }
    }
}

struct WordTapModifier: ViewModifier {
    let text: String
    @Binding var selectedWord: String?
    @Binding var showDictionary: Bool
    
    func body(content: Content) -> some View {
        content
            .simultaneousGesture(
                TapGesture(count: 2)
                    .onEnded { _ in
                        // Split text into words while preserving punctuation
                        let words = text.components(separatedBy: .whitespaces)
                            .filter { !$0.isEmpty }
                            .map { word -> String in
                                // Clean the word by removing punctuation but keep diacritics
                                let cleaned = word.trimmingCharacters(in: CharacterSet.punctuationCharacters)
                                return cleaned
                            }
                        
                        // For testing, just use the first non-empty word for now
                        if let firstWord = words.first {
                            selectedWord = firstWord
                            showDictionary = true
                        }
                    }
            )
    }
}

// Helper to get text bounds
private extension String {
    func wordBounds(for range: NSRange, in bounds: CGRect, with attributes: [NSAttributedString.Key: Any]) -> CGRect {
        let attributedString = NSAttributedString(string: self, attributes: attributes)
        let textStorage = NSTextStorage(attributedString: attributedString)
        let layoutManager = NSLayoutManager()
        let textContainer = NSTextContainer(size: bounds.size)
        
        textStorage.addLayoutManager(layoutManager)
        layoutManager.addTextContainer(textContainer)
        
        var result = CGRect.zero
        layoutManager.enumerateEnclosingRects(forGlyphRange: range, withinSelectedGlyphRange: NSRange(location: NSNotFound, length: 0), in: textContainer) { rect, _ in
            result = rect
        }
        
        return result
    }
}

extension View {
    func onWordDoubleTap(text: String, selectedWord: Binding<String?>, showDictionary: Binding<Bool>) -> some View {
        modifier(WordTapModifier(text: text, selectedWord: selectedWord, showDictionary: showDictionary))
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
    @State private var selectedWord: String?
    @State private var showDictionary: Bool = false
    
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
        .onWordDoubleTap(text: verse.latinText, selectedWord: $selectedWord, showDictionary: $showDictionary)
        .sheet(isPresented: $showDictionary) {
            if let word = selectedWord {
                NavigationView {
                    DictionaryPopover(word: word)
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
        if let bookmark = bookmarkStore.bookmarks.first(where: { 
            $0.bookName == bookName &&
            $0.chapterNumber == chapterNumber &&
            $0.verseNumber == verse.number
        }) {
            bookmarkStore.removeBookmark(withId: bookmark.id)
        }
    }
} 