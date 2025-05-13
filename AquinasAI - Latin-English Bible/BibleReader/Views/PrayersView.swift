import SwiftUI

enum PrayerCategory: String, CaseIterable {
    case basic = "Basic Prayers"
    case mass = "Mass Prayers"
    case rosary = "Rosary"
    case divine = "Divine Mercy"
    case other = "Other Prayers"
}

struct PrayersView: View {
    @EnvironmentObject var prayerStore: PrayerStore
    @Environment(\.dismiss) var dismiss
    @State private var searchText = ""
    @State private var selectedCategory: PrayerCategory = .basic
    @State private var selectedLanguage: PrayerLanguage = .bilingual
    
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
                                NavigationLink(destination: RosaryView()) {
                                    Text(category.displayName)
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 8)
                                        .background(
                                            Capsule()
                                                .fill(selectedCategory == category ? Color.purple : Color.clear)
                                                .overlay(
                                                    Capsule()
                                                        .strokeBorder(Color.purple, lineWidth: 1)
                                                )
                                        )
                                        .foregroundColor(selectedCategory == category ? .white : .purple)
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
                                                .fill(selectedCategory == category ? Color.purple : Color.clear)
                                                .overlay(
                                                    Capsule()
                                                        .strokeBorder(Color.purple, lineWidth: 1)
                                                )
                                        )
                                        .foregroundColor(selectedCategory == category ? .white : .purple)
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
                        ScrollView {
                            LazyVStack(spacing: 16) {
                                ForEach(filteredPrayers) { prayer in
                                    PrayerCard(prayer: prayer, language: selectedLanguage)
                                        .padding(.horizontal)
                                }
                            }
                            .padding(.vertical)
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

private struct PrayerCard: View {
    let prayer: Prayer
    let language: PrayerLanguage
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                if language == .latinOnly || language == .bilingual {
                    Text(prayer.displayTitleLatin)
                        .font(.headline)
                        .foregroundColor(colorScheme == .dark ? .nightText : .primary)
                }
                
                if language == .englishOnly || language == .bilingual {
                    if language == .bilingual {
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
            
            if language == .latinOnly || language == .bilingual {
                Text(prayer.latin)
                    .font(.body)
                    .foregroundColor(colorScheme == .dark ? .nightText : .primary)
            }
            
            if language == .englishOnly || language == .bilingual {
                Text(prayer.english)
                    .font(.body)
                    .foregroundColor(language == .bilingual ? .secondary : (colorScheme == .dark ? .nightText : .primary))
                    .italic(language == .bilingual)
            }
        }
        .padding()
        .background(colorScheme == .dark ? Color.white.opacity(0.05) : Color.white)
        .cornerRadius(12)
        .shadow(color: colorScheme == .dark ? .clear : Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
} 