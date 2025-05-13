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
    
    var body: some View {
        VStack(spacing: 16) {
            // Day selection
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"], id: \.self) { day in
                        Button(action: {
                            selectedDay = day
                        }) {
                            Text(day)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(
                                    Capsule()
                                        .fill(selectedDay == day ? Color.purple : Color.clear)
                                        .overlay(
                                            Capsule()
                                                .strokeBorder(Color.purple, lineWidth: 1)
                                        )
                                )
                                .foregroundColor(selectedDay == day ? .white : .purple)
                        }
                    }
                }
                .padding(.horizontal)
            }
            
            // Language selection
            Picker("Language", selection: $selectedLanguage) {
                ForEach(PrayerLanguage.allCases, id: \.self) { language in
                    Text(language.rawValue.capitalized).tag(language)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding(.horizontal)
            
            // Rosary content
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Opening prayers
                    if let template = template {
                        Section(header: Text("Opening Prayers").font(.headline).padding(.bottom, 4)) {
                            ForEach(template.opening, id: \.self) { item in
                                if case .string(let prayerKey) = item,
                                   let prayer = commonPrayers?[prayerKey] {
                                    PrayerCard(prayer: prayer.asPrayer, language: selectedLanguage)
                                }
                            }
                        }
                    }
                    
                    // Mysteries
                    if let mysteries = mysteries {
                        Section(header: Text("\(mysteryType?.capitalized ?? "") Mysteries").font(.headline).padding(.bottom, 4)) {
                            ForEach(mysteries, id: \.number) { mystery in
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Mystery \(mystery.number)")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                    
                                    if selectedLanguage != .english {
                                        Text(mystery.latin)
                                            .font(.body)
                                    }
                                    
                                    if selectedLanguage != .latin {
                                        Text(mystery.english)
                                            .font(.body)
                                    }
                                    
                                    // Decade prayers
                                    if let template = template {
                                        ForEach(template.decade, id: \.self) { item in
                                            if case .string(let prayerKey) = item,
                                               let prayer = commonPrayers?[prayerKey] {
                                                PrayerCard(prayer: prayer.asPrayer, language: selectedLanguage)
                                                    .padding(.leading)
                                            }
                                        }
                                    }
                                }
                                .padding()
                                .background(Color(.systemGray6))
                                .cornerRadius(12)
                            }
                        }
                    }
                    
                    // Closing prayers
                    if let template = template {
                        Section(header: Text("Closing Prayers").font(.headline).padding(.bottom, 4)) {
                            ForEach(template.closing, id: \.self) { prayerKey in
                                if let prayer = commonPrayers?[prayerKey] {
                                    PrayerCard(prayer: prayer.asPrayer, language: selectedLanguage)
                                }
                            }
                        }
                    }
                }
                .padding()
            }
        }
        .navigationTitle("Rosary")
    }
}

struct PrayerCard: View {
    let prayer: Prayer
    let language: PrayerLanguage
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(prayer.displayTitleEnglish)
                .font(.headline)
            
            if language != .english {
                Text(prayer.latin)
                    .font(.body)
            }
            
            if language != .latin {
                Text(prayer.english)
                    .font(.body)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

#Preview {
    NavigationView {
        RosaryView()
            .environmentObject(PrayerStore())
    }
} 