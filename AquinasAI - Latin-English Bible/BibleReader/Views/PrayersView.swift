import SwiftUI

enum PrayerCategory: String, CaseIterable {
    case basic = "Basic Prayers"
    case mass = "Mass Prayers"
    case rosary = "Rosary"
    case divine = "Divine Mercy"
    case other = "Other Prayers"
    
    var displayName: String {
        self.rawValue
    }
}

struct PrayersView: View {
    @EnvironmentObject var prayerStore: PrayerStore
    @Environment(\.dismiss) var dismiss
    @State private var searchText = ""
    @State private var selectedCategory: PrayerCategory = .basic
    @State private var selectedLanguage: PrayerLanguage = .bilingual
    @State private var scrollToId: String?
    
    // Add optional initial prayer ID
    var initialPrayerId: String?
    
    init(initialPrayerId: String? = nil) {
        self.initialPrayerId = initialPrayerId
        self._scrollToId = State(initialValue: initialPrayerId)
    }
    
    var filteredPrayers: [Prayer] {
        let prayers = prayerStore.getPrayers(for: selectedCategory)
        if searchText.isEmpty {
            return prayers
        }
        return prayers.filter { prayer in
            prayer.displayTitleEnglish.localizedCaseInsensitiveContains(searchText) ||
            prayer.displayTitleLatin.localizedCaseInsensitiveContains(searchText) ||
            prayer.latin.localizedCaseInsensitiveContains(searchText) ||
            prayer.english.localizedCaseInsensitiveContains(searchText)
        }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 16) {
                // Search bar
                SearchBar(text: $searchText)
                    .padding(.horizontal)
                
                // Category selection
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(PrayerCategory.allCases, id: \.self) { category in
                            if category == .rosary {
                                NavigationLink(destination: RosaryView().environmentObject(prayerStore)) {
                                    Text(category.displayName)
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 8)
                                        .background(
                                            Capsule()
                                                .fill(selectedCategory == category ? Color.deepPurple : Color.clear)
                                                .overlay(
                                                    Capsule()
                                                        .strokeBorder(Color.deepPurple, lineWidth: 1)
                                                )
                                        )
                                        .foregroundColor(selectedCategory == category ? .white : .deepPurple)
                                }
                            } else {
                                Button(action: {
                                    selectedCategory = category
                                }) {
                                    Text(category.displayName)
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 8)
                                        .background(
                                            Capsule()
                                                .fill(selectedCategory == category ? Color.deepPurple : Color.clear)
                                                .overlay(
                                                    Capsule()
                                                        .strokeBorder(Color.deepPurple, lineWidth: 1)
                                                )
                                        )
                                        .foregroundColor(selectedCategory == category ? .white : .deepPurple)
                                }
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
                
                // Prayer list
                if selectedCategory != .rosary {
                    if filteredPrayers.isEmpty {
                        Spacer()
                        VStack {
                            Image(systemName: "book.closed")
                                .font(.system(size: 50))
                                .foregroundColor(.gray)
                            Text("No Prayers Found")
                                .foregroundColor(.gray)
                                .padding(.top)
                        }
                        Spacer()
                    } else {
                        ScrollViewReader { scrollProxy in
                            ScrollView {
                                LazyVStack(spacing: 16) {
                                    ForEach(filteredPrayers) { prayer in
                                        PrayerCard(prayer: prayer, language: selectedLanguage)
                                            .padding(.horizontal)
                                            .id(prayer.id)
                                    }
                                }
                                .padding(.vertical)
                            }
                            .onChange(of: selectedCategory) { oldValue, newValue in
                                if let id = scrollToId {
                                    // If category changes, check if our target prayer is in this category
                                    let prayersInCategory = prayerStore.getPrayers(for: newValue)
                                    if prayersInCategory.contains(where: { $0.id == id }) {
                                        // If yes, scroll to it
                                        withAnimation {
                                            scrollProxy.scrollTo(id, anchor: .top)
                                        }
                                    }
                                }
                            }
                            .onAppear {
                                // When view appears, find the prayer and its category
                                if let id = initialPrayerId {
                                    scrollToId = id
                                    print("Looking for prayer with ID: \(id)")
                                    
                                    // Find the prayer in all categories
                                    var foundPrayer = false
                                    for category in PrayerCategory.allCases {
                                        if category == .rosary {
                                            continue // Skip rosary as it's handled separately
                                        }
                                        let prayers = prayerStore.getPrayers(for: category)
                                        print("Checking \(prayers.count) prayers in category: \(category.rawValue)")
                                        
                                        // Try exact match
                                        if let prayer = prayers.first(where: { $0.id == id }) {
                                            print("Found exact prayer match: \(prayer.title) in category: \(category.rawValue)")
                                            selectedCategory = category
                                            foundPrayer = true
                                            
                                            // Delay scrolling to ensure view is fully loaded
                                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                                                print("Scrolling to prayer: \(prayer.title)")
                                                withAnimation {
                                                    scrollProxy.scrollTo(id, anchor: .top)
                                                }
                                            }
                                            break
                                        }
                                        
                                        // Try case-insensitive or partial match if exact match fails
                                        if !foundPrayer {
                                            for prayer in prayers {
                                                if prayer.title.lowercased().contains(id.lowercased()) || 
                                                   id.lowercased().contains(prayer.title.lowercased()) {
                                                    print("Found partial match: \(prayer.title) for ID: \(id)")
                                                    selectedCategory = category
                                                    foundPrayer = true
                                                    
                                                    // Set the scroll ID to this prayer's ID
                                                    let actualId = prayer.id
                                                    scrollToId = actualId
                                                    
                                                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                                                        print("Scrolling to prayer with partial match: \(prayer.title)")
                                                        withAnimation {
                                                            scrollProxy.scrollTo(actualId, anchor: .top)
                                                        }
                                                    }
                                                    break
                                                }
                                            }
                                        }
                                        
                                        if foundPrayer {
                                            break
                                        }
                                    }
                                    
                                    if !foundPrayer {
                                        print("⚠️ Could not find prayer with ID: \(id)")
                                    }
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Prayers")
            .navigationBarItems(trailing: Button("Done") { dismiss() })
        }
    }
}

private struct SearchBar: View {
    @Binding var text: String
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)
            
            TextField("Search prayers...", text: $text)
                .textFieldStyle(PlainTextFieldStyle())
                .autocapitalization(.none)
                .disableAutocorrection(true)
            
            if !text.isEmpty {
                Button {
                    text = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray)
                }
            }
        }
        .padding(10)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(colorScheme == .dark ? Color.white.opacity(0.1) : Color.black.opacity(0.05))
        )
    }
} 