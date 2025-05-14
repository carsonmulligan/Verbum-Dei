import SwiftUI

enum PrayerLanguage: String, CaseIterable {
    case latinOnly = "latin"
    case englishOnly = "english"
    case bilingual = "bilingual"
}

struct PrayerCard: View {
    let prayer: Prayer
    let language: PrayerLanguage
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                if language == .latinOnly || language == .bilingual {
                    Text(prayer.displayTitleLatin)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.deepPurple)
                }
                
                if language == .englishOnly || language == .bilingual {
                    if language == .bilingual {
                        Text(prayer.displayTitleEnglish)
                            .font(.subheadline)
                            .foregroundColor(colorScheme == .dark ? Color.white.opacity(0.8) : Color.primary.opacity(0.8))
                            .italic()
                    } else {
                        Text(prayer.displayTitleEnglish)
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.deepPurple)
                    }
                }
            }
            
            if language == .latinOnly || language == .bilingual {
                Text(prayer.latin)
                    .font(.body)
                    .foregroundColor(colorScheme == .dark ? .white : .primary)
                    .padding(.top, 4)
            }
            
            if language == .englishOnly || language == .bilingual {
                Text(prayer.english)
                    .font(.body)
                    .foregroundColor(language == .bilingual ? .secondary : (colorScheme == .dark ? .white : .primary))
                    .italic(language == .bilingual)
                    .padding(.top, language == .bilingual ? 2 : 4)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(colorScheme == .dark ? Color.black.opacity(0.3) : Color.white)
                .shadow(color: colorScheme == .dark ? .clear : Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .strokeBorder(Color.deepPurple.opacity(0.2), lineWidth: 1)
        )
    }
} 