import SwiftUI

struct LatinOnlyVerseView: View {
    let number: Int
    let text: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Text("\(number)")
                .font(.custom("Times New Roman", size: 14))
                .foregroundColor(.secondary)
                .frame(width: 30, alignment: .trailing)
            Text(text)
                .font(.custom("Times New Roman", size: 17))
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
                .font(.custom("Times New Roman", size: 14))
                .foregroundColor(.secondary)
                .frame(width: 30, alignment: .trailing)
            Text(text)
                .font(.custom("Times New Roman", size: 17))
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