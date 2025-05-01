import SwiftUI

struct LatinOnlyVerseView: View {
    let number: Int
    let text: String
    let isBookmarked: Bool
    
    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Text("\(number)")
                .font(.custom("Times New Roman", size: 14))
                .foregroundColor(.secondary)
                .frame(width: 30, alignment: .trailing)
            Text(text)
                .font(.custom("Times New Roman", size: 17))
                .fixedSize(horizontal: false, vertical: true)
                .padding(isBookmarked ? 8 : 0)
                .background(isBookmarked ? Color.deepPurple.opacity(0.1) : Color.clear)
                .cornerRadius(8)
        }
    }
}

struct EnglishOnlyVerseView: View {
    let number: Int
    let text: String
    let isBookmarked: Bool
    
    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Text("\(number)")
                .font(.custom("Times New Roman", size: 14))
                .foregroundColor(.secondary)
                .frame(width: 30, alignment: .trailing)
            Text(text)
                .font(.custom("Times New Roman", size: 17))
                .fixedSize(horizontal: false, vertical: true)
                .padding(isBookmarked ? 8 : 0)
                .background(isBookmarked ? Color.deepPurple.opacity(0.1) : Color.clear)
                .cornerRadius(8)
        }
    }
}

struct BilingualVerseView: View {
    let number: Int
    let latinText: String
    let englishText: String
    let isBookmarked: Bool
    
    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Text("\(number)")
                .font(.custom("Times New Roman", size: 14))
                .foregroundColor(.secondary)
                .frame(width: 30, alignment: .trailing)
            VStack(alignment: .leading, spacing: 4) {
                Text(latinText)
                    .font(.custom("Times New Roman", size: 17))
                    .fixedSize(horizontal: false, vertical: true)
                Text(englishText)
                    .font(.custom("Times New Roman", size: 17))
                    .italic()
                    .foregroundColor(.gray)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(isBookmarked ? 8 : 0)
            .background(isBookmarked ? Color.deepPurple.opacity(0.1) : Color.clear)
            .cornerRadius(8)
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
                    isBookmarked: isBookmarked
                )
            } else if displayMode == .englishOnly {
                EnglishOnlyVerseView(
                    number: verse.number,
                    text: verse.englishText,
                    isBookmarked: isBookmarked
                )
            } else {
                BilingualVerseView(
                    number: verse.number,
                    latinText: verse.latinText,
                    englishText: verse.englishText,
                    isBookmarked: isBookmarked
                )
            }
        }
        .onLongPressGesture {
            showingBookmarkSheet = true
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
} 