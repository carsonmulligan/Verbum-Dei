import SwiftUI

struct RosaryView: View {
    @EnvironmentObject var prayerStore: PrayerStore
    @State private var selectedDay: String = getCurrentDay()
    @State private var selectedLanguage: PrayerLanguage = .bilingual
    
    private static func getCurrentDay() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE"
        return dateFormatter.string(from: Date())
    }
    
    private var mysteryType: String? {
        prayerStore.rosaryPrayers?.schedule[selectedDay]
    }
    
    private var mysteries: [RosaryMystery]? {
        if let type = mysteryType {
            return prayerStore.rosaryPrayers?.mysteries[type]
        }
        return nil
    }
    
    private var template: RosaryTemplate? {
        prayerStore.rosaryPrayers?.template
    }
    
    private var commonPrayers: [String: RosaryPrayer]? {
        prayerStore.rosaryPrayers?.common_prayers
    }
    
    private var mysteryTitle: String {
        guard let type = mysteryType else { return "" }
        let capitalizedType = type.prefix(1).uppercased() + type.dropFirst()
        return "\(capitalizedType) Mysteries"
    }
    
    private var mysteryDescription: String {
        guard let type = mysteryType else { return "" }
        return prayerStore.getMysteryDescription(for: type)
    }
    
    var body: some View {
        VStack(spacing: 16) {
            DaySelectionView(selectedDay: $selectedDay)
            
            LanguageSelectionView(selectedLanguage: $selectedLanguage)
            
            if let template = template, let commonPrayers = commonPrayers {
                RosaryContentView(
                    template: template,
                    commonPrayers: commonPrayers,
                    mysteries: mysteries,
                    mysteryTitle: mysteryTitle,
                    mysteryDescription: mysteryDescription,
                    selectedLanguage: selectedLanguage
                )
            } else {
                LoadingErrorView(isLoading: prayerStore.rosaryPrayers == nil)
            }
        }
        .navigationTitle("Rosary")
    }
}

// MARK: - Day Selection View
private struct DaySelectionView: View {
    @Binding var selectedDay: String
    private let weekDays = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(weekDays, id: \.self) { day in
                    DayButton(day: day, isSelected: selectedDay == day) {
                        selectedDay = day
                    }
                }
            }
            .padding(.horizontal)
        }
    }
}

private struct DayButton: View {
    let day: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(day)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    Capsule()
                        .fill(isSelected ? Color.deepPurple : Color.clear)
                        .overlay(
                            Capsule()
                                .strokeBorder(Color.deepPurple, lineWidth: 1)
                        )
                )
                .foregroundColor(isSelected ? .white : .deepPurple)
        }
    }
}

// MARK: - Language Selection View
private struct LanguageSelectionView: View {
    @Binding var selectedLanguage: PrayerLanguage
    
    var body: some View {
        Picker("Language", selection: $selectedLanguage) {
            ForEach(PrayerLanguage.allCases, id: \.self) { language in
                Text(language.rawValue.capitalized).tag(language)
            }
        }
        .pickerStyle(SegmentedPickerStyle())
        .padding(.horizontal)
    }
}

// MARK: - Rosary Content View
private struct RosaryContentView: View {
    let template: RosaryTemplate
    let commonPrayers: [String: RosaryPrayer]
    let mysteries: [RosaryMystery]?
    let mysteryTitle: String
    let mysteryDescription: String
    let selectedLanguage: PrayerLanguage
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                if !mysteryTitle.isEmpty {
                    MysteryHeaderView(title: mysteryTitle, description: mysteryDescription)
                }
                
                PrayerSectionView(
                    title: "Opening Prayers",
                    prayers: template.opening,
                    commonPrayers: commonPrayers,
                    selectedLanguage: selectedLanguage
                )
                
                if let mysteries = mysteries {
                    MysteriesView(
                        mysteries: mysteries,
                        template: template,
                        commonPrayers: commonPrayers,
                        selectedLanguage: selectedLanguage
                    )
                }
                
                PrayerSectionView(
                    title: "Closing Prayers",
                    prayers: template.closing.map { OrderItem.string($0) },
                    commonPrayers: commonPrayers,
                    selectedLanguage: selectedLanguage
                )
            }
            .padding(.vertical)
        }
    }
}

private struct MysteryHeaderView: View {
    let title: String
    let description: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.deepPurple)
            
            Text(description)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .padding(.bottom, 8)
        }
        .padding(.horizontal)
    }
}

private struct PrayerSectionView: View {
    let title: String
    let prayers: [OrderItem]
    let commonPrayers: [String: RosaryPrayer]
    let selectedLanguage: PrayerLanguage
    
    var body: some View {
        Section(header:
            Text(title)
                .font(.headline)
                .foregroundColor(.deepPurple)
                .padding(.bottom, 4)
        ) {
            ForEach(Array(prayers.enumerated()), id: \.offset) { index, item in
                switch item {
                case .string(let prayerKey):
                    if let prayer = commonPrayers[prayerKey] {
                        PrayerCard(prayer: prayer.asPrayer, language: selectedLanguage)
                    }
                case .prayerCount(let prayerKey, let count):
                    if let prayer = commonPrayers[prayerKey] {
                        ForEach(0..<count, id: \.self) { _ in
                            PrayerCard(prayer: prayer.asPrayer, language: selectedLanguage)
                        }
                    }
                case .prayerWithIntentions(let prayerKey, let count, let intentions):
                    if let prayer = commonPrayers[prayerKey] {
                        ForEach(0..<count, id: \.self) { index in
                            VStack(alignment: .leading, spacing: 4) {
                                if index < intentions.count {
                                    Text("For \(intentions[index])")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                        .padding(.horizontal)
                                }
                                PrayerCard(prayer: prayer.asPrayer, language: selectedLanguage)
                            }
                        }
                    }
                default:
                    EmptyView()
                }
            }
        }
        .padding(.horizontal)
    }
}

private struct MysteriesView: View {
    let mysteries: [RosaryMystery]
    let template: RosaryTemplate
    let commonPrayers: [String: RosaryPrayer]
    let selectedLanguage: PrayerLanguage
    
    var body: some View {
        VStack(spacing: 16) {
            ForEach(Array(zip(mysteries.indices, mysteries)), id: \.0) { index, mystery in
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Mystery \(mystery.number)")
                            .font(.headline)
                            .foregroundColor(.deepPurple)
                        
                        Spacer()
                        
                        Image(systemName: "rosette")
                            .foregroundColor(.deepPurple)
                    }
                    .padding(.bottom, 4)
                    
                    if selectedLanguage != .englishOnly {
                        Text(mystery.latin)
                            .font(.body)
                            .italic()
                    }
                    
                    if selectedLanguage != .latinOnly {
                        Text(mystery.english)
                            .font(.body)
                    }
                    
                    ForEach(Array(template.decade.enumerated()), id: \.0) { decadeIndex, item in
                        switch item {
                        case .string(let prayerKey):
                            if let prayer = commonPrayers[prayerKey] {
                                PrayerCard(prayer: prayer.asPrayer, language: selectedLanguage)
                                    .padding(.leading)
                            }
                        case .prayerCount(let prayerKey, let count):
                            if let prayer = commonPrayers[prayerKey] {
                                ForEach(0..<count, id: \.self) { _ in
                                    PrayerCard(prayer: prayer.asPrayer, language: selectedLanguage)
                                        .padding(.leading)
                                }
                            }
                        default:
                            EmptyView()
                        }
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
                .padding(.horizontal)
            }
        }
    }
}

private struct LoadingErrorView: View {
    let isLoading: Bool
    @Environment(\.colorScheme) private var colorScheme
    @EnvironmentObject private var prayerStore: PrayerStore
    
    var body: some View {
        VStack(spacing: 20) {
            if isLoading {
                Circle()
                    .trim(from: 0, to: 0.7)
                    .stroke(Color.deepPurple, lineWidth: 4)
                    .frame(width: 50, height: 50)
                    .rotationEffect(Angle(degrees: 360))
                    .animation(Animation.linear(duration: 1).repeatForever(autoreverses: false), value: UUID())
                
                Text("Loading prayers...")
                    .font(.headline)
                    .foregroundColor(.deepPurple)
                
                Text("Preparing your spiritual journey")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            } else {
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 50))
                    .foregroundColor(.orange)
                
                Text("Unable to Load Prayers")
                    .font(.headline)
                    .foregroundColor(colorScheme == .dark ? .white : .primary)
                
                Text("Please check your connection and try again")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                Button {
                    prayerStore.loadPrayers()
                } label: {
                    HStack {
                        Image(systemName: "arrow.clockwise")
                        Text("Retry")
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(Color.deepPurple)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(colorScheme == .dark ? Color.black.opacity(0.6) : Color.white.opacity(0.9))
    }
}

#Preview {
    NavigationView {
        RosaryView()
            .environmentObject(PrayerStore())
    }
} 