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
    @State private var viewHasAppeared = false
    @State private var scrollAttempts = 0
    
    // Add optional initial prayer ID and category
    var initialPrayerId: String?
    var initialCategory: PrayerCategory?
    
    init(initialPrayerId: String? = nil, initialCategory: PrayerCategory? = nil) {
        print("⭐️ PRAYERS VIEW INIT - Prayer ID: \(initialPrayerId ?? "nil"), Category: \(initialCategory?.rawValue ?? "nil")")
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
                                // Force view uniqueness to ensure refresh when category changes
                                LazyVStack(spacing: 16) {
                                    ForEach(filteredPrayers) { prayer in
                                        PrayerCard(prayer: prayer, language: selectedLanguage)
                                            .padding(.horizontal)
                                            .id(prayer.id)
                                            .background(
                                                // Debug highlight for the target prayer
                                                scrollToId == prayer.id ? Color.yellow.opacity(0.3) : Color.clear
                                            )
                                            .overlay(
                                                // Add a visual border for debugging
                                                ZStack {
                                                    if scrollToId == prayer.id {
                                                        RoundedRectangle(cornerRadius: 12)
                                                            .stroke(Color.red, lineWidth: 2)
                                                            .padding(.horizontal, -2)
                                                    }
                                                }
                                            )
                                            .onAppear {
                                                if scrollToId == prayer.id {
                                                    print("⭐️ TARGET PRAYER APPEARED IN VIEW: \(prayer.title)")
                                                }
                                            }
                                    }
                                }
                                .padding(.vertical)
                                .id("\(selectedCategory)-\(viewHasAppeared)-\(scrollAttempts)")
                            }
                            .onChange(of: selectedCategory) { oldValue, newValue in
                                if let id = scrollToId {
                                    print("📋 Category changed from \(oldValue) to \(newValue), scrollToId: \(id)")
                                    self.scrollAttempts += 1
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                        findAndScrollToPrayer(id: id, in: newValue, using: scrollProxy)
                                    }
                                }
                            }
                            .onAppear {
                                // Extra logging to diagnose initialPrayerId issues
                                print("⭐️ PRAYERS VIEW APPEARED - Prayer ID: \(initialPrayerId ?? "nil"), Category: \(initialCategory?.rawValue ?? "nil"), scrollToId: \(scrollToId ?? "nil")")
                                
                                if !viewHasAppeared {
                                    viewHasAppeared = true
                                    
                                    // When view appears, find the prayer and its category
                                    if let id = initialPrayerId {
                                        scrollToId = id
                                        print("⭐️ Attempting to locate prayer with ID: \(id)")
                                        
                                        // List all prayers in the selected category to debug
                                        let prayers = prayerStore.getPrayers(for: selectedCategory)
                                        print("📋 Available prayers in \(selectedCategory.rawValue) category:")
                                        for prayer in prayers {
                                            print("📋   - \(prayer.title) (ID: \(prayer.id))")
                                        }
                                        
                                        // If we already know the category, use it
                                        if let category = initialCategory, category != .rosary {
                                            print("📋 Using provided category: \(category.rawValue)")
                                            selectedCategory = category
                                            
                                            // Force a staggered approach to scrolling
                                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                                // Reset scroll attempts to force view refresh
                                                self.scrollAttempts += 1
                                                
                                                // First attempt to scroll
                                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                                    print("⭐️ First scroll attempt...")
                                                    findAndScrollToPrayer(id: id, in: category, using: scrollProxy, isInitial: true)
                                                    
                                                    // Second attempt to scroll with a delay
                                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                                        print("⭐️ Second scroll attempt...")
                                                        self.scrollAttempts += 1
                                                        findAndScrollToPrayer(id: id, in: category, using: scrollProxy, isInitial: true)
                                                        
                                                        // Third attempt after another delay
                                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
                                                            print("⭐️ Third scroll attempt...")
                                                            self.scrollAttempts += 1
                                                            findAndScrollToPrayer(id: id, in: category, using: scrollProxy, isInitial: true)
                                                        }
                                                    }
                                                }
                                            }
                                        } else {
                                            // Otherwise search through all categories
                                            print("📋 No category provided, searching all categories")
                                            findPrayerCategory(for: id) { foundCategory in
                                                if let category = foundCategory, category != .rosary {
                                                    print("📋 Found prayer in category: \(category.rawValue)")
                                                    selectedCategory = category
                                                    
                                                    // Force a staggered approach to scrolling
                                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                                        // Reset scroll attempts to force view refresh
                                                        self.scrollAttempts += 1
                                                        
                                                        // First attempt to scroll
                                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                                            print("⭐️ First scroll attempt...")
                                                            findAndScrollToPrayer(id: id, in: category, using: scrollProxy, isInitial: true)
                                                            
                                                            // Second attempt after a delay
                                                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                                                print("⭐️ Second scroll attempt...")
                                                                self.scrollAttempts += 1
                                                                findAndScrollToPrayer(id: id, in: category, using: scrollProxy, isInitial: true)
                                                                
                                                                // Third attempt after another delay
                                                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
                                                                    print("⭐️ Third scroll attempt...")
                                                                    self.scrollAttempts += 1
                                                                    findAndScrollToPrayer(id: id, in: category, using: scrollProxy, isInitial: true)
                                                                }
                                                            }
                                                        }
                                                    }
                                                } else {
                                                    print("❌ Could not find prayer in any category")
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
    private func findAndScrollToPrayer(id: String, in category: PrayerCategory, using scrollProxy: ScrollViewProxy, isInitial: Bool = false) {
        let prayers = prayerStore.getPrayers(for: category)
        print("📋 Looking for prayer \(id) in \(prayers.count) prayers in category \(category.rawValue)")
        
        // Print all prayer IDs for debugging
        let prayerIds = prayers.map { $0.id }
        print("📋 Available prayer IDs: \(prayerIds.joined(separator: ", "))")
        
        // Special case for "oratio_fatimae" prayer
        if id == "oratio_fatimae" || id.lowercased().contains("fatima") || id.lowercased().contains("fatimae") {
            print("⭐️ Special case for Fatima Prayer")
            if let prayer = prayers.first(where: { prayer in
                prayer.title.lowercased().contains("fatima") ||
                (prayer.title_latin != nil && prayer.title_latin!.lowercased().contains("fatima")) ||
                prayer.id.lowercased().contains("fatima") ||
                prayer.title.lowercased().contains("fatimae") ||
                prayer.id.lowercased().contains("fatimae")
            }) {
                print("✅ Special case: Found Fatima Prayer: \(prayer.title) (ID: \(prayer.id))")
                scrollToId = prayer.id // Update scrollToId to match the actual prayer ID
                scrollWithMultipleAttempts(to: prayer.id, proxy: scrollProxy, prayer: prayer, isInitial: isInitial)
                return
            }
        }
        
        // Try exact match first
        if let prayer = prayers.first(where: { $0.id == id }) {
            print("✅ Found exact prayer match: \(prayer.title) (ID: \(prayer.id)) in category: \(category.rawValue)")
            // Use multiple scroll attempts with different delays to improve reliability
            scrollWithMultipleAttempts(to: id, proxy: scrollProxy, prayer: prayer, isInitial: isInitial)
            return
        }
        
        // Try normalized ID match (how the ID should be)
        let normalizedId = id.lowercased()
            .replacingOccurrences(of: " ", with: "_")
            .replacingOccurrences(of: ",", with: "")
            .replacingOccurrences(of: ".", with: "")
            .replacingOccurrences(of: "'", with: "")
            .replacingOccurrences(of: "\"", with: "")
            .replacingOccurrences(of: "(", with: "")
            .replacingOccurrences(of: ")", with: "")
        
        print("📋 Normalized ID for matching: \(normalizedId)")
        
        if let prayer = prayers.first(where: { $0.id == normalizedId }) {
            print("✅ Found prayer match with normalized ID: \(prayer.title) (ID: \(prayer.id)) in category: \(category.rawValue)")
            scrollToId = prayer.id // Update scrollToId to match the actual prayer ID
            scrollWithMultipleAttempts(to: prayer.id, proxy: scrollProxy, prayer: prayer, isInitial: isInitial)
            return
        }
        
        // Special case for "anima_christi" which seems problematic
        if id == "anima_christi" || normalizedId == "anima_christi" {
            print("⭐️ Special case for Anima Christi prayer")
            if let prayer = prayers.first(where: { prayer in 
                prayer.title.lowercased().contains("anima") && 
                prayer.title.lowercased().contains("christi")
            }) {
                print("✅ Special case: Found Anima Christi prayer: \(prayer.title) (ID: \(prayer.id))")
                scrollToId = prayer.id // Update scrollToId to match the actual prayer ID
                scrollWithMultipleAttempts(to: prayer.id, proxy: scrollProxy, prayer: prayer, isInitial: isInitial)
                return
            }
            
            // Try with just part of the name
            if let prayer = prayers.first(where: { prayer in prayer.title.lowercased().contains("anima") }) {
                print("✅ Special case: Found partial match for Anima Christi: \(prayer.title) (ID: \(prayer.id))")
                scrollToId = prayer.id // Update scrollToId to match the actual prayer ID
                scrollWithMultipleAttempts(to: prayer.id, proxy: scrollProxy, prayer: prayer, isInitial: isInitial)
                return
            }
            
            // Last resort - search all prayers regardless of category
            print("⭐️ Searching all prayers for Anima Christi")
            for searchCategory in PrayerCategory.allCases where searchCategory != .rosary {
                let allPrayers = prayerStore.getPrayers(for: searchCategory)
                if let prayer = allPrayers.first(where: { prayer in 
                    prayer.title.lowercased().contains("anima") || 
                    (prayer.title_latin != nil && prayer.title_latin!.lowercased().contains("anima"))
                }) {
                    print("✅ Found Anima Christi in category: \(searchCategory.rawValue)")
                    scrollToId = prayer.id // Update scrollToId to match the actual prayer ID
                    if searchCategory != category {
                        selectedCategory = searchCategory
                        // Wait for category change to take effect
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            scrollWithMultipleAttempts(to: prayer.id, proxy: scrollProxy, prayer: prayer, isInitial: true)
                        }
                    } else {
                        scrollWithMultipleAttempts(to: prayer.id, proxy: scrollProxy, prayer: prayer, isInitial: isInitial)
                    }
                    return
                }
            }
        }
        
        // Special case for "actus_spei" which seems problematic
        if id == "actus_spei" || normalizedId == "actus_spei" {
            if let prayer = prayers.first(where: { 
                $0.title.lowercased().contains("actus") && 
                $0.title.lowercased().contains("spei") 
            }) {
                print("✅ Special case: Found Actus Spei prayer: \(prayer.title) (ID: \(prayer.id))")
                scrollToId = prayer.id // Update scrollToId to match the actual prayer ID
                scrollWithMultipleAttempts(to: prayer.id, proxy: scrollProxy, prayer: prayer, isInitial: isInitial)
                return
            }
            
            // Try all basic prayers with part of the name
            for prayer in prayers {
                if prayer.title.lowercased().contains("actus") || 
                   prayer.title.lowercased().contains("spei") ||
                   (prayer.title_latin != nil && prayer.title_latin!.lowercased().contains("spei")) {
                    print("✅ Partial match for Actus Spei: \(prayer.title) (ID: \(prayer.id))")
                    scrollToId = prayer.id // Update scrollToId to match the actual prayer ID
                    scrollWithMultipleAttempts(to: prayer.id, proxy: scrollProxy, prayer: prayer, isInitial: isInitial)
                    return
                }
            }
        }
        
        // Try case-insensitive or partial match
        for prayer in prayers {
            // Check if prayer title contains the ID or vice versa
            if prayer.title.lowercased().contains(id.lowercased()) || 
               id.lowercased().contains(prayer.title.lowercased()) {
                print("✅ Found partial match: \(prayer.title) (ID: \(prayer.id)) for ID: \(id)")
                scrollToId = prayer.id // Update scrollToId to match the actual prayer ID
                scrollWithMultipleAttempts(to: prayer.id, proxy: scrollProxy, prayer: prayer, isInitial: isInitial)
                return
            }
            
            // Also check English and Latin titles
            if let englishTitle = prayer.title_english, 
               (englishTitle.lowercased().contains(id.lowercased()) || 
                id.lowercased().contains(englishTitle.lowercased())) {
                print("✅ Found partial match in English title: \(englishTitle) (ID: \(prayer.id)) for ID: \(id)")
                scrollToId = prayer.id // Update scrollToId to match the actual prayer ID
                scrollWithMultipleAttempts(to: prayer.id, proxy: scrollProxy, prayer: prayer, isInitial: isInitial)
                return
            }
            
            if let latinTitle = prayer.title_latin,
               (latinTitle.lowercased().contains(id.lowercased()) || 
                id.lowercased().contains(latinTitle.lowercased())) {
                print("✅ Found partial match in Latin title: \(latinTitle) (ID: \(prayer.id)) for ID: \(id)")
                scrollToId = prayer.id // Update scrollToId to match the actual prayer ID
                scrollWithMultipleAttempts(to: prayer.id, proxy: scrollProxy, prayer: prayer, isInitial: isInitial)
                return
            }
        }
        
        print("❌ Could not find prayer with ID: \(id) in category \(category.rawValue)")
    }
    
    // Try multiple scroll attempts to improve reliability
    private func scrollWithMultipleAttempts(to id: String, proxy: ScrollViewProxy, prayer: Prayer, isInitial: Bool = false) {
        let title = prayer.title
        print("📋 Attempting to scroll to: \(title) with ID: \(id)")
        
        // Force immediate scroll
        withAnimation {
            print("📋 Immediate scroll attempt to: \(title)")
            proxy.scrollTo(id, anchor: .top)
        }
        
        // Schedule multiple attempts with increasing delays
        [0.2, 0.4, 0.7, 1.0, 1.5].forEach { delay in
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                withAnimation {
                    print("📋 Delayed scroll attempt after \(delay)s to: \(title)")
                    proxy.scrollTo(id, anchor: .top)
                }
            }
        }
        
        // Final attempt with center alignment
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.8) {
            print("📋 Final scroll attempt with center alignment to: \(title)")
            withAnimation {
                proxy.scrollTo(id, anchor: .center)
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
            
            // Special case for Fatima Prayer
            if id == "oratio_fatimae" || id.lowercased().contains("fatima") {
                if prayers.contains(where: { 
                    $0.title.lowercased().contains("fatima") || 
                    ($0.title_latin != nil && $0.title_latin!.lowercased().contains("fatima")) || 
                    $0.id.lowercased().contains("fatima") ||
                    $0.title.lowercased().contains("fatimae") ||
                    $0.id.lowercased().contains("fatimae")
                }) {
                    completion(category)
                    return
                }
            }
            
            // Special case for Anima Christi
            if id == "anima_christi" {
                if prayers.contains(where: { 
                    $0.title.lowercased().contains("anima") && 
                    $0.title.lowercased().contains("christi") 
                }) {
                    completion(category)
                    return
                }
            }
            
            // Special case for Actus Spei
            if id == "actus_spei" {
                if prayers.contains(where: { 
                    $0.title.lowercased().contains("actus") && 
                    $0.title.lowercased().contains("spei") 
                }) {
                    completion(category)
                    return
                }
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