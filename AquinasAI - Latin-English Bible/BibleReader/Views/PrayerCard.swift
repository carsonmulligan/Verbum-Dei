import SwiftUI

struct PrayerCard: View {
    let prayer: Prayer
    let language: PrayerLanguage
    var isBookmarked: Bool = false
    var onBookmarkTapped: (() -> Void)?
    
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Prayer Title
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    if language != .englishOnly, let latinTitle = prayer.title_latin {
                        Text(latinTitle)
                            .font(.headline)
                            .foregroundColor(.deepPurple)
                    }
                    
                    if language != .latinOnly, let englishTitle = prayer.title_english {
                        Text(englishTitle)
                            .font(language == .bilingual ? .subheadline : .headline)
                            .foregroundColor(language == .bilingual && language != .latinOnly ? .secondary : .deepPurple)
                    } else {
                        Text(prayer.title)
                            .font(.headline)
                            .foregroundColor(.deepPurple)
                    }
                }
                
                Spacer()
                
                // Bookmark button
                if let onBookmarkTapped = onBookmarkTapped {
                    Button(action: onBookmarkTapped) {
                        Image(systemName: isBookmarked ? "bookmark.fill" : "bookmark")
                            .foregroundColor(.deepPurple)
                    }
                }
            }
            
            // Prayer Instructions (if available)
            if let instructions = prayer.instructions {
                Text(instructions)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .italic()
                    .padding(.bottom, 4)
            }
            
            // Prayer Text - Latin
            if language == .latinOnly || language == .bilingual {
                Text(prayer.latin)
                    .font(.body)
                    .foregroundColor(colorScheme == .dark ? .white : .primary)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.top, 4)
            }
            
            // Prayer Text - English
            if language == .englishOnly || language == .bilingual {
                Text(prayer.english)
                    .font(.body)
                    .foregroundColor(language == .bilingual ? 
                                     (colorScheme == .dark ? .gray : .secondary) : 
                                     (colorScheme == .dark ? .white : .primary))
                    .italic(language == .bilingual)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.top, language == .bilingual ? 2 : 4)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(colorScheme == .dark ? Color.black.opacity(0.3) : Color.white)
                .shadow(color: colorScheme == .dark ? Color.clear : Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .strokeBorder(Color.deepPurple.opacity(0.2), lineWidth: 1)
        )
    }
} 