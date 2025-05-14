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
    
    // Add optional initial prayer ID and category
    var initialPrayerId: String?
    var initialCategory: PrayerCategory?
    
    init(initialPrayerId: String? = nil, initialCategory: PrayerCategory? = nil) {
        self.initialPrayerId = initialPrayerId
        self.initialCategory = initialCategory
        self._scrollToId = State(initialValue: initialPrayerId)
        if let category = initialCategory {
            self._selectedCategory = State(initialValue: category)
        }
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
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                        findAndScrollToPrayer(id: id, in: newValue, using: scrollProxy)
                                    }
                                }
                            }
                            .onAppear {
                                // When view appears, find the prayer and its category
                                if let id = initialPrayerId {
                                    scrollToId = id
                                    print("Looking for prayer with ID: \(id)")
                                    
                                    // If we already know the category, use it
                                    if let category = initialCategory, category != .rosary {
                                        selectedCategory = category
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                            findAndScrollToPrayer(id: id, in: category, using: scrollProxy)
                                        }
                                    } else {
                                        // Otherwise search through all categories
                                        findPrayerCategory(for: id) { foundCategory in
                                            if let category = foundCategory, category != .rosary {
                                                selectedCategory = category
                                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                                    findAndScrollToPrayer(id: id, in: category, using: scrollProxy)
                                                }
                                            }
                                        }
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
    
    // Helper function to find and scroll to a prayer by ID
    private func findAndScrollToPrayer(id: String, in category: PrayerCategory, using scrollProxy: ScrollViewProxy) {
        let prayers = prayerStore.getPrayers(for: category)
        print("Looking for prayer \(id) in \(prayers.count) prayers in category \(category.rawValue)")
        
        // Try exact match first
        if let prayer = prayers.first(where: { $0.id == id }) {
            print("Found exact prayer match: \(prayer.title) in category: \(category.rawValue)")
            // Use multiple scroll attempts with different delays to improve reliability
            scrollWithMultipleAttempts(to: id, proxy: scrollProxy, prayer: prayer)
            return
        }
        
        // Try normalized ID match
        let normalizedId = id.lowercased()
            .replacingOccurrences(of: " ", with: "_")
            .replacingOccurrences(of: ",", with: "")
            .replacingOccurrences(of: ".", with: "")
            .replacingOccurrences(of: "'", with: "")
            .replacingOccurrences(of: "\"", with: "")
            .replacingOccurrences(of: "(", with: "")
            .replacingOccurrences(of: ")", with: "")
        
        if let prayer = prayers.first(where: { $0.id == normalizedId }) {
            print("Found prayer match with normalized ID: \(prayer.title) in category: \(category.rawValue)")
            scrollWithMultipleAttempts(to: prayer.id, proxy: scrollProxy, prayer: prayer)
            return
        }
        
        // Try case-insensitive or partial match
        for prayer in prayers {
            // Check if prayer title contains the ID or vice versa
            if prayer.title.lowercased().contains(id.lowercased()) || 
               id.lowercased().contains(prayer.title.lowercased()) {
                print("Found partial match: \(prayer.title) for ID: \(id)")
                scrollWithMultipleAttempts(to: prayer.id, proxy: scrollProxy, prayer: prayer)
                return
            }
            
            // Also check English and Latin titles
            if let englishTitle = prayer.title_english, 
               (englishTitle.lowercased().contains(id.lowercased()) || 
                id.lowercased().contains(englishTitle.lowercased())) {
                print("Found partial match in English title: \(englishTitle) for ID: \(id)")
                scrollWithMultipleAttempts(to: prayer.id, proxy: scrollProxy, prayer: prayer)
                return
            }
            
            if let latinTitle = prayer.title_latin,
               (latinTitle.lowercased().contains(id.lowercased()) || 
                id.lowercased().contains(latinTitle.lowercased())) {
                print("Found partial match in Latin title: \(latinTitle) for ID: \(id)")
                scrollWithMultipleAttempts(to: prayer.id, proxy: scrollProxy, prayer: prayer)
                return
            }
        }
        
        print("⚠️ Could not find prayer with ID: \(id) in category \(category.rawValue)")
    }
    
    // Try multiple scroll attempts to improve reliability
    private func scrollWithMultipleAttempts(to id: String, proxy: ScrollViewProxy, prayer: Prayer) {
        let title = prayer.title
        print("Attempting to scroll to: \(title) with ID: \(id)")
        
        // Immediate attempt
        withAnimation {
            proxy.scrollTo(id, anchor: .top)
        }
        
        // Follow-up attempts with delays
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            print("First delayed scroll attempt to: \(title)")
            withAnimation {
                proxy.scrollTo(id, anchor: .top)
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            print("Second delayed scroll attempt to: \(title)")
            withAnimation {
                proxy.scrollTo(id, anchor: .top)
            }
        }
    }
    
    // Find the category containing a prayer with the given ID
    private func findPrayerCategory(for id: String, completion: @escaping (PrayerCategory?) -> Void) {
        for category in PrayerCategory.allCases {
            if category == .rosary {
                continue // Skip rosary as it's handled separately
            }
            
            let prayers = prayerStore.getPrayers(for: category)
            
            // Try exact match
            if prayers.contains(where: { $0.id == id }) {
                completion(category)
                return
            }
            
            // Try partial matches on title and ID
            for prayer in prayers {
                if prayer.title.lowercased().contains(id.lowercased()) || 
                   id.lowercased().contains(prayer.title.lowercased()) ||
                   (prayer.title_english != nil && prayer.title_english!.lowercased().contains(id.lowercased())) ||
                   (prayer.title_latin != nil && prayer.title_latin!.lowercased().contains(id.lowercased())) {
                    completion(category)
                    return
                }
            }
        }
        
        // No match found
        completion(nil)
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