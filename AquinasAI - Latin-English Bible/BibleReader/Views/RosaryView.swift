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
            if let template = template, let commonPrayers = commonPrayers {
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        // Mystery type title and description
                        if !mysteryTitle.isEmpty {
                            VStack(alignment: .leading, spacing: 8) {
                                Text(mysteryTitle)
                                    .font(.title)
                                    .fontWeight(.bold)
                                    .foregroundColor(.purple)
                                
                                Text(mysteryDescription)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                    .padding(.bottom, 8)
                            }
                            .padding(.horizontal)
                        }
                        
                        // Opening prayers
                        Section(header: 
                            Text("Opening Prayers")
                                .font(.headline)
                                .foregroundColor(.purple)
                                .padding(.bottom, 4)
                        ) {
                            ForEach(Array(template.opening.enumerated()), id: \.offset) { index, item in
                                if case .string(let prayerKey) = item,
                                   let prayer = commonPrayers[prayerKey] {
                                    PrayerCard(prayer: prayer.asPrayer, language: selectedLanguage)
                                }
                            }
                        }
                        .padding(.horizontal)
                        
                        // Mysteries
                        if let mysteries = mysteries {
                            ForEach(mysteries, id: \.number) { mystery in
                                VStack(alignment: .leading, spacing: 8) {
                                    HStack {
                                        Text("Mystery \(mystery.number)")
                                            .font(.headline)
                                            .foregroundColor(.purple)
                                        
                                        Spacer()
                                        
                                        Image(systemName: "rosette")
                                            .foregroundColor(.purple)
                                    }
                                    .padding(.bottom, 4)
                                    
                                    if selectedLanguage != .english {
                                        Text(mystery.latin)
                                            .font(.body)
                                            .italic()
                                    }
                                    
                                    if selectedLanguage != .latin {
                                        Text(mystery.english)
                                            .font(.body)
                                    }
                                    
                                    // Decade prayers
                                    ForEach(Array(template.decade.enumerated()), id: \.offset) { index, item in
                                        if case .string(let prayerKey) = item,
                                           let prayer = commonPrayers[prayerKey] {
                                            PrayerCard(prayer: prayer.asPrayer, language: selectedLanguage)
                                                .padding(.leading)
                                        }
                                    }
                                }
                                .padding()
                                .background(Color(.systemGray6))
                                .cornerRadius(12)
                                .padding(.horizontal)
                            }
                        }
                        
                        // Closing prayers
                        Section(header: 
                            Text("Closing Prayers")
                                .font(.headline)
                                .foregroundColor(.purple)
                                .padding(.bottom, 4)
                        ) {
                            ForEach(template.closing, id: \.self) { prayerKey in
                                if let prayer = commonPrayers[prayerKey] {
                                    PrayerCard(prayer: prayer.asPrayer, language: selectedLanguage)
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                    .padding(.vertical)
                }
            } else {
                VStack(spacing: 16) {
                    if prayerStore.rosaryPrayers == nil {
                        ProgressView()
                            .scaleEffect(1.5)
                        Text("Loading prayers...")
                            .foregroundColor(.secondary)
                    } else {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.system(size: 40))
                            .foregroundColor(.orange)
                        Text("Unable to load prayers")
                            .foregroundColor(.secondary)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .navigationTitle("Rosary")
    }
}

#Preview {
    NavigationView {
        RosaryView()
            .environmentObject(PrayerStore())
    }
} 