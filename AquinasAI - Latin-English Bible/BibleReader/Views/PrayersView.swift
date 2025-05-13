import SwiftUI

struct PrayersView: View {
    @StateObject private var prayerStore = PrayerStore()
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    @EnvironmentObject private var viewModel: BibleViewModel
    @State private var searchText = ""
    
    var filteredPrayers: [Prayer] {
        if searchText.isEmpty {
            return prayerStore.prayers
        }
        return prayerStore.prayers.filter { prayer in
            prayer.title_english.localizedCaseInsensitiveContains(searchText) ||
            prayer.title_latin.localizedCaseInsensitiveContains(searchText) ||
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
                    SearchBar(searchText: $searchText)
                        .padding()
                    
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
                    Text(prayer.title_latin)
                        .font(.headline)
                        .foregroundColor(colorScheme == .dark ? .nightText : .primary)
                }
                
                if displayMode == .englishOnly || displayMode == .bilingual {
                    if displayMode == .bilingual {
                        Text(prayer.title_english)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .italic()
                    } else {
                        Text(prayer.title_english)
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