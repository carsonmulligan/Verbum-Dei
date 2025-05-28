import SwiftUI

enum PrayerCategory: String, CaseIterable {
    case basic = "All Prayers"
    case mass = "Order of Mass"
    case rosary = "Rosary"
    case divine = "Divine Mercy"
    case hours = "Liturgy of the Hours"
    case angelus = "Angelus Domini"
    
    var displayName: String {
        self.rawValue
    }
}

struct PrayersView: View {
    @EnvironmentObject var prayerStore: PrayerStore
    @Environment(\.dismiss) var dismiss
    @State private var searchText = ""
    @State private var selectedCategory: PrayerCategory
    @State private var selectedLanguage: PrayerLanguage = .latinEnglish
    @State private var scrollToId: String?
    @State private var viewHasAppeared = false
    
    // Add optional initial prayer ID and category
    let initialPrayerId: String?
    let initialCategory: PrayerCategory?
    
    init(initialPrayerId: String? = nil, initialCategory: PrayerCategory? = nil) {
        // Store parameters as constants
        self.initialPrayerId = initialPrayerId
        self.initialCategory = initialCategory
        
        // Initialize state variables
        self._scrollToId = State(initialValue: initialPrayerId)
        
        // Set the initial category or use a default
        let category = initialCategory ?? .basic
        self._selectedCategory = State(initialValue: category)
    }
    
    var filteredPrayers: [Prayer] {
        let prayers = prayerStore.getPrayers(for: selectedCategory)
        if searchText.isEmpty {
            return prayers
        }
        return prayers.filter { prayer in
            prayer.displayTitleEnglish.localizedCaseInsensitiveContains(searchText) ||
            prayer.displayTitleLatin.localizedCaseInsensitiveContains(searchText) ||
            prayer.displayTitleSpanish.localizedCaseInsensitiveContains(searchText) ||
            prayer.latin.localizedCaseInsensitiveContains(searchText) ||
            prayer.english.localizedCaseInsensitiveContains(searchText) ||
            (prayer.spanish?.localizedCaseInsensitiveContains(searchText) ?? false)
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
                        Text(language.displayName).tag(language)
                    }
                }
                .pickerStyle(MenuPickerStyle())
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
                                .id("\(selectedCategory)-\(viewHasAppeared)")
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
                                if !viewHasAppeared {
                                    viewHasAppeared = true
                                    
                                    if let id = initialPrayerId {
                                        scrollToId = id
                                        
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                            findAndScrollToPrayer(id: id, in: selectedCategory, using: scrollProxy)
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
        
        // Try exact match first
        if let prayer = prayers.first(where: { $0.id == id }) {
            scrollToId = prayer.id // Update scrollToId to match the actual prayer ID
            scrollToPrayer(to: prayer.id, proxy: scrollProxy)
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
            scrollToId = prayer.id // Update scrollToId to match the actual prayer ID
            scrollToPrayer(to: prayer.id, proxy: scrollProxy)
            return
        }
        
        // Special case for "communio_spiritualis" prayer
        if id == "communio_spiritualis" || normalizedId.contains("communio") || normalizedId.contains("spiritual") {
            if let prayer = prayers.first(where: { prayer in
                prayer.title.lowercased().contains("spiritualis") ||
                prayer.title.lowercased().contains("communio") ||
                (prayer.title_english != nil && prayer.title_english!.lowercased().contains("communion")) ||
                prayer.id.lowercased().contains("spiritual")
            }) {
                scrollToId = prayer.id // Update scrollToId to match the actual prayer ID
                scrollToPrayer(to: prayer.id, proxy: scrollProxy)
                return
            }
        }
        
        // Special case for "oratio_fatimae" prayer
        if id == "oratio_fatimae" || id.lowercased().contains("fatima") || id.lowercased().contains("fatimae") {
            if let prayer = prayers.first(where: { prayer in
                prayer.title.lowercased().contains("fatima") ||
                (prayer.title_latin != nil && prayer.title_latin!.lowercased().contains("fatima")) ||
                prayer.id.lowercased().contains("fatima") ||
                prayer.title.lowercased().contains("fatimae") ||
                prayer.id.lowercased().contains("fatimae")
            }) {
                scrollToId = prayer.id // Update scrollToId to match the actual prayer ID
                scrollToPrayer(to: prayer.id, proxy: scrollProxy)
                return
            }
        }
        
        // Special case for "anima_christi" which seems problematic
        if id == "anima_christi" || normalizedId == "anima_christi" {
            if let prayer = prayers.first(where: { prayer in 
                prayer.title.lowercased().contains("anima") && 
                prayer.title.lowercased().contains("christi")
            }) {
                scrollToId = prayer.id // Update scrollToId to match the actual prayer ID
                scrollToPrayer(to: prayer.id, proxy: scrollProxy)
                return
            }
            
            // Try with just part of the name
            if let prayer = prayers.first(where: { prayer in prayer.title.lowercased().contains("anima") }) {
                scrollToId = prayer.id // Update scrollToId to match the actual prayer ID
                scrollToPrayer(to: prayer.id, proxy: scrollProxy)
                return
            }
            
            // Last resort - search all prayers regardless of category
            for searchCategory in PrayerCategory.allCases where searchCategory != .rosary {
                let allPrayers = prayerStore.getPrayers(for: searchCategory)
                if let prayer = allPrayers.first(where: { prayer in 
                    prayer.title.lowercased().contains("anima") || 
                    (prayer.title_latin != nil && prayer.title_latin!.lowercased().contains("anima"))
                }) {
                    scrollToId = prayer.id // Update scrollToId to match the actual prayer ID
                    if searchCategory != category {
                        selectedCategory = searchCategory
                        // Wait for category change to take effect
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            scrollToPrayer(to: prayer.id, proxy: scrollProxy)
                        }
                    } else {
                        scrollToPrayer(to: prayer.id, proxy: scrollProxy)
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
                scrollToId = prayer.id // Update scrollToId to match the actual prayer ID
                scrollToPrayer(to: prayer.id, proxy: scrollProxy)
                return
            }
            
            // Try all basic prayers with part of the name
            for prayer in prayers {
                if prayer.title.lowercased().contains("actus") || 
                   prayer.title.lowercased().contains("spei") ||
                   (prayer.title_latin != nil && prayer.title_latin!.lowercased().contains("spei")) {
                    scrollToId = prayer.id // Update scrollToId to match the actual prayer ID
                    scrollToPrayer(to: prayer.id, proxy: scrollProxy)
                    return
                }
            }
        }
        
        // Try case-insensitive or partial match
        for prayer in prayers {
            // Check if prayer title contains the ID or vice versa
            if prayer.title.lowercased().contains(id.lowercased()) || 
               id.lowercased().contains(prayer.title.lowercased()) {
                scrollToId = prayer.id // Update scrollToId to match the actual prayer ID
                scrollToPrayer(to: prayer.id, proxy: scrollProxy)
                return
            }
            
            // Also check English and Latin titles
            if let englishTitle = prayer.title_english, 
               (englishTitle.lowercased().contains(id.lowercased()) || 
                id.lowercased().contains(englishTitle.lowercased())) {
                scrollToId = prayer.id // Update scrollToId to match the actual prayer ID
                scrollToPrayer(to: prayer.id, proxy: scrollProxy)
                return
            }
            
            if let latinTitle = prayer.title_latin,
               (latinTitle.lowercased().contains(id.lowercased()) || 
                id.lowercased().contains(latinTitle.lowercased())) {
                scrollToId = prayer.id // Update scrollToId to match the actual prayer ID
                scrollToPrayer(to: prayer.id, proxy: scrollProxy)
                return
            }
        }
    }
    
    // Simplified scrolling function
    private func scrollToPrayer(to id: String, proxy: ScrollViewProxy) {
        withAnimation {
            proxy.scrollTo(id, anchor: .top)
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