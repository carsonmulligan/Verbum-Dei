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
                        .foregroundColor(colorScheme == .dark ? .nightText : .primary)
                }
                
                if language == .englishOnly || language == .bilingual {
                    if language == .bilingual {
                        Text(prayer.displayTitleEnglish)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .italic()
                    } else {
                        Text(prayer.displayTitleEnglish)
                            .font(.headline)
                            .foregroundColor(colorScheme == .dark ? .nightText : .primary)
                    }
                }
            }
            
            if language == .latinOnly || language == .bilingual {
                Text(prayer.latin)
                    .font(.body)
                    .foregroundColor(colorScheme == .dark ? .nightText : .primary)
            }
            
            if language == .englishOnly || language == .bilingual {
                Text(prayer.english)
                    .font(.body)
                    .foregroundColor(language == .bilingual ? .secondary : (colorScheme == .dark ? .nightText : .primary))
                    .italic(language == .bilingual)
            }
        }
        .padding()
        .background(colorScheme == .dark ? Color.white.opacity(0.05) : Color.white)
        .cornerRadius(12)
        .shadow(color: colorScheme == .dark ? .clear : Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
} 