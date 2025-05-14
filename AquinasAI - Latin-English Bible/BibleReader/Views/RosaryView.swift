import SwiftUI

struct RosaryView: View {
    @EnvironmentObject var prayerStore: PrayerStore
    @Environment(\.dismiss) var dismiss
    @State private var selectedDay: String = getCurrentDay()
    @State private var selectedLanguage: PrayerLanguage = .bilingual
    @State private var scrollToId: String?
    
    // Add parameter for initial prayer ID
    let initialPrayerId: String?
    
    init(initialPrayerId: String? = nil) {
        self.initialPrayerId = initialPrayerId
        self._scrollToId = State(initialValue: initialPrayerId)
    }
    
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
                    selectedLanguage: selectedLanguage,
                    scrollToId: scrollToId
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
    let scrollToId: String?
    
    @State private var viewHasAppeared = false
    
    var body: some View {
        ScrollViewReader { scrollProxy in
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    if !mysteryTitle.isEmpty {
                        MysteryHeaderView(title: mysteryTitle, description: mysteryDescription)
                    }
                    
                    PrayerSectionView(
                        title: "Opening Prayers",
                        prayers: template.opening,
                        commonPrayers: commonPrayers,
                        selectedLanguage: selectedLanguage,
                        scrollToId: scrollToId
                    )
                    
                    if let mysteries = mysteries {
                        MysteriesView(
                            mysteries: mysteries,
                            template: template,
                            commonPrayers: commonPrayers,
                            selectedLanguage: selectedLanguage,
                            scrollToId: scrollToId
                        )
                    }
                    
                    PrayerSectionView(
                        title: "Closing Prayers",
                        prayers: template.closing.map { OrderItem.string($0) },
                        commonPrayers: commonPrayers,
                        selectedLanguage: selectedLanguage,
                        scrollToId: scrollToId
                    )
                }
                .padding(.vertical)
                .id("rosary-content")
                .onAppear {
                    if !viewHasAppeared {
                        viewHasAppeared = true
                        
                        // Attempt to find and scroll to the prayer if an ID is provided
                        if let prayerId = scrollToId {
                            // Give time for the view to fully render
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                scrollToPrayer(id: prayerId, proxy: scrollProxy)
                            }
                        }
                    }
                }
            }
        }
    }
    
    private func scrollToPrayer(id: String, proxy: ScrollViewProxy) {
        withAnimation {
            proxy.scrollTo(id, anchor: .top)
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
    let scrollToId: String?
    
    var body: some View {
        Section(header:
            Text(title)
                .font(.headline)
                .foregroundColor(.deepPurple)
                .padding(.bottom, 4)
        ) {
            VStack(spacing: 12) {
                ForEach(prayers, id: \.self) { item in
                    switch item {
                    case .string(let prayerId):
                        if let prayer = commonPrayers[prayerId] {
                            PrayerCardView(
                                prayer: prayer.asPrayer,
                                selectedLanguage: selectedLanguage,
                                shouldHighlight: scrollToId == prayer.asPrayer.id
                            )
                            .id(prayer.asPrayer.id)
                        }
                    case .prayerCount(let prayerId, let count):
                        if let prayer = commonPrayers[prayerId] {
                            RepeatedPrayerView(
                                prayer: prayer.asPrayer,
                                count: count,
                                intentions: nil,
                                selectedLanguage: selectedLanguage,
                                shouldHighlight: scrollToId == prayer.asPrayer.id
                            )
                            .id(prayer.asPrayer.id)
                        }
                    case .prayerWithIntentions(let prayerId, let count, let intentions):
                        if let prayer = commonPrayers[prayerId] {
                            RepeatedPrayerView(
                                prayer: prayer.asPrayer,
                                count: count,
                                intentions: intentions,
                                selectedLanguage: selectedLanguage,
                                shouldHighlight: scrollToId == prayer.asPrayer.id
                            )
                            .id(prayer.asPrayer.id)
                        }
                    case .object(let obj):
                        if let prayer = commonPrayers[obj.id] {
                            RepeatedPrayerView(
                                prayer: prayer.asPrayer,
                                count: obj.count,
                                intentions: obj.intentions,
                                selectedLanguage: selectedLanguage,
                                shouldHighlight: scrollToId == prayer.asPrayer.id
                            )
                            .id(prayer.asPrayer.id)
                        }
                    case .array, .dictionary, .templateObject:
                        // Handle other cases if needed
                        EmptyView()
                    }
                }
            }
            .padding(.horizontal)
        }
    }
}

// Helper view for prayers in the rosary
private struct PrayerCardView: View {
    let prayer: Prayer
    let selectedLanguage: PrayerLanguage
    let shouldHighlight: Bool
    
    var body: some View {
        PrayerCard(prayer: prayer, language: selectedLanguage)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(shouldHighlight ? Color.deepPurple : Color.clear, lineWidth: shouldHighlight ? 2 : 0)
            )
    }
}

// Modified RepeatedPrayerView to handle scrolling
private struct RepeatedPrayerView: View {
    let prayer: Prayer
    let count: Int
    let intentions: [String]?
    let selectedLanguage: PrayerLanguage
    let shouldHighlight: Bool
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("\(prayer.displayTitleEnglish) (\(count)x)")
                .font(.headline)
                .foregroundColor(.deepPurple)
                .padding(.bottom, 2)
            
            if let intentions = intentions {
                Text("For: \(intentions.joined(separator: ", "))")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .padding(.bottom, 4)
            }
            
            if selectedLanguage == .latinOnly || selectedLanguage == .bilingual {
                Text(prayer.latin)
                    .font(.body)
                    .foregroundColor(colorScheme == .dark ? .white : .primary)
                    .padding(.top, 4)
            }
            
            if selectedLanguage == .englishOnly || selectedLanguage == .bilingual {
                Text(prayer.english)
                    .font(.body)
                    .foregroundColor(selectedLanguage == .bilingual ? 
                                    (colorScheme == .dark ? .gray : .secondary) : 
                                    (colorScheme == .dark ? .white : .primary))
                    .italic(selectedLanguage == .bilingual)
                    .padding(.top, selectedLanguage == .bilingual ? 2 : 4)
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
                .strokeBorder(shouldHighlight ? Color.deepPurple : Color.deepPurple.opacity(0.2), lineWidth: shouldHighlight ? 2 : 1)
        )
    }
}

private struct MysteriesView: View {
    let mysteries: [RosaryMystery]
    let template: RosaryTemplate
    let commonPrayers: [String: RosaryPrayer]
    let selectedLanguage: PrayerLanguage
    let scrollToId: String?
    
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
                    
                    if let description = mystery.description {
                        Text(description)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .padding(.vertical, 4)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    
                    ForEach(template.decade, id: \.self) { item in
                        switch item {
                        case .string(let prayerId):
                            if let prayer = commonPrayers[prayerId] {
                                PrayerCardView(
                                    prayer: prayer.asPrayer,
                                    selectedLanguage: selectedLanguage,
                                    shouldHighlight: scrollToId == prayer.asPrayer.id
                                )
                                .id(prayer.asPrayer.id)
                                .padding(.leading)
                            }
                        case .prayerCount(let prayerId, let count):
                            if let prayer = commonPrayers[prayerId] {
                                RepeatedPrayerView(
                                    prayer: prayer.asPrayer,
                                    count: count,
                                    intentions: nil,
                                    selectedLanguage: selectedLanguage,
                                    shouldHighlight: scrollToId == prayer.asPrayer.id
                                )
                                .id(prayer.asPrayer.id)
                                .padding(.leading)
                            }
                        case .prayerWithIntentions(let prayerId, let count, let intentions):
                            if let prayer = commonPrayers[prayerId] {
                                RepeatedPrayerView(
                                    prayer: prayer.asPrayer,
                                    count: count,
                                    intentions: intentions,
                                    selectedLanguage: selectedLanguage,
                                    shouldHighlight: scrollToId == prayer.asPrayer.id
                                )
                                .id(prayer.asPrayer.id)
                                .padding(.leading)
                            }
                        case .object(let obj):
                            if let prayer = commonPrayers[obj.id] {
                                RepeatedPrayerView(
                                    prayer: prayer.asPrayer,
                                    count: obj.count,
                                    intentions: obj.intentions,
                                    selectedLanguage: selectedLanguage,
                                    shouldHighlight: scrollToId == prayer.asPrayer.id
                                )
                                .id(prayer.asPrayer.id)
                                .padding(.leading)
                            }
                        case .array, .dictionary, .templateObject:
                            // Handle other cases if needed
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