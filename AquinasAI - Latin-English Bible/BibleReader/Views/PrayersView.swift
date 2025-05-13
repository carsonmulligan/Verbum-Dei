import SwiftUI

enum PrayerCategory: String, CaseIterable {
    case basic = "Basic Prayers"
    case mass = "Mass Prayers"
    case rosary = "Rosary"
    case divine = "Divine Mercy"
    case other = "Other Prayers"
}

struct PrayersView: View {
    @StateObject private var prayerStore = PrayerStore()
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    @EnvironmentObject private var viewModel: BibleViewModel
    @State private var searchText = ""
    @State private var selectedCategory: PrayerCategory = .basic
    
    var filteredPrayers: [Prayer] {
        let categoryPrayers = prayerStore.getPrayers(for: selectedCategory)
        
        if searchText.isEmpty {
            return categoryPrayers
        }
        
        return categoryPrayers.filter { prayer in
            prayer.displayTitleEnglish.localizedCaseInsensitiveContains(searchText) ||
            prayer.displayTitleLatin.localizedCaseInsensitiveContains(searchText) ||
            prayer.latin.localizedCaseInsensitiveContains(searchText) ||
            prayer.english.localizedCaseInsensitiveContains(searchText)
        }
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                (colorScheme == .dark ? Color.nightBackground : Color.paperWhite)
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Search Bar
                    SearchBar(searchText: $searchText)
                        .padding()
                    
                    // Category Selector
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(PrayerCategory.allCases, id: \.self) { category in
                                TestamentPillButton(
                                    title: category.rawValue,
                                    isSelected: selectedCategory == category,
                                    action: { selectedCategory = category }
                                )
                            }
                        }
                        .padding(.horizontal)
                    }
                    .padding(.vertical, 8)
                    
                    // Prayer List
                    if filteredPrayers.isEmpty {
                        EmptyPrayersView()
                    } else {
                        ScrollView {
                            LazyVStack(spacing: 16) {
                                ForEach(filteredPrayers) { prayer in
                                    PrayerCard(prayer: prayer, displayMode: viewModel.displayMode)
                                        .padding(.horizontal)
                                }
                            }
                            .padding(.vertical)
                        }
                    }
                }
            }
            .navigationTitle("Prayers")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

private struct SearchBar: View {
    @Binding var searchText: String
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)
            
            TextField("Search prayers...", text: $searchText)
                .textFieldStyle(PlainTextFieldStyle())
                .autocapitalization(.none)
                .disableAutocorrection(true)
            
            if !searchText.isEmpty {
                Button {
                    searchText = ""
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

private struct EmptyPrayersView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "book.closed")
                .font(.system(size: 50))
                .foregroundColor(.gray)
            
            Text("No Prayers Found")
                .font(.headline)
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

private struct PrayerCard: View {
    let prayer: Prayer
    let displayMode: DisplayMode
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                if displayMode == .latinOnly || displayMode == .bilingual {
                    Text(prayer.displayTitleLatin)
                        .font(.headline)
                        .foregroundColor(colorScheme == .dark ? .nightText : .primary)
                }
                
                if displayMode == .englishOnly || displayMode == .bilingual {
                    if displayMode == .bilingual {
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
            
            if displayMode == .latinOnly || displayMode == .bilingual {
                Text(prayer.latin)
                    .font(.body)
                    .foregroundColor(colorScheme == .dark ? .nightText : .primary)
            }
            
            if displayMode == .englishOnly || displayMode == .bilingual {
                Text(prayer.english)
                    .font(.body)
                    .foregroundColor(displayMode == .bilingual ? .secondary : (colorScheme == .dark ? .nightText : .primary))
                    .italic(displayMode == .bilingual)
            }
        }
        .padding()
        .background(colorScheme == .dark ? Color.white.opacity(0.05) : Color.white)
        .cornerRadius(12)
        .shadow(color: colorScheme == .dark ? .clear : Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
} 