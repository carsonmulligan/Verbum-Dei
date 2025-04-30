import SwiftUI

struct LatinOnlyVerseView: View {
    let number: Int
    let text: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Text("\(number)")
                .font(.caption)
                .foregroundColor(.secondary)
                .frame(width: 30, alignment: .trailing)
            Text(text)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

struct EnglishOnlyVerseView: View {
    let number: Int
    let text: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Text("\(number)")
                .font(.caption)
                .foregroundColor(.secondary)
                .frame(width: 30, alignment: .trailing)
            Text(text)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

struct BilingualVerseView: View {
    let number: Int
    let latinText: String
    let englishText: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Text("\(number)")
                .font(.caption)
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
        }
    }
}

struct VerseView: View {
    let verse: Verse
    let displayMode: DisplayMode
    
    var body: some View {
        Group {
            if displayMode == .latinOnly {
                LatinOnlyVerseView(number: verse.number, text: verse.latinText)
            } else if displayMode == .englishOnly {
                EnglishOnlyVerseView(number: verse.number, text: verse.englishText)
            } else {
                BilingualVerseView(
                    number: verse.number,
                    latinText: verse.latinText,
                    englishText: verse.englishText
                )
            }
        }
    }
} 