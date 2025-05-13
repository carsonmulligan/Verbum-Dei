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
        switch mysteryType {
        case "joyful":
            return "The Joyful Mysteries focus on the events surrounding Christ's birth and early life."
        case "sorrowful":
            return "The Sorrowful Mysteries meditate on Christ's Passion and death."
        case "glorious":
            return "The Glorious Mysteries contemplate Christ's Resurrection and the glories of Heaven."
        case "luminous":
            return "The Luminous Mysteries reflect on key moments in Christ's public ministry."
        default:
            return ""
        }
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
                            ForEach(template.opening, id: \.self) { item in
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
                                    ForEach(template.decade, id: \.self) { item in
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