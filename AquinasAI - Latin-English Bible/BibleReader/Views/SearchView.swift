import SwiftUI

struct SearchView: View {
    @StateObject private var searchViewModel: SearchViewModel
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.dismiss) private var dismiss
    
    init(bibleViewModel: BibleViewModel) {
        _searchViewModel = StateObject(wrappedValue: SearchViewModel(bibleViewModel: bibleViewModel))
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Search bar
                searchBar
                    .padding()
                
                if searchViewModel.isSearching {
                    ProgressView()
                        .padding()
                } else if searchViewModel.searchResults.isEmpty && !searchViewModel.searchQuery.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 40))
                            .foregroundColor(.gray)
                        Text("No results found")
                            .foregroundColor(.gray)
                    }
                    .padding(.top, 40)
                } else {
                    // Search results
                    ScrollView {
                        LazyVStack(spacing: 0) {
                            ForEach(searchViewModel.searchResults) { result in
                                SearchResultRow(result: result)
                                    .padding(.horizontal)
                                    .padding(.vertical, 12)
                                
                                if result != searchViewModel.searchResults.last {
                                    Divider()
                                        .background(colorScheme == .dark ? Color.white.opacity(0.1) : Color.separatorLight)
                                }
                            }
                        }
                        .padding(.vertical, 8)
                    }
                    .background(colorScheme == .dark ? Color.nightBackground : Color.paperWhite)
                }
            }
            .background(colorScheme == .dark ? Color.nightBackground : Color.paperWhite)
            .navigationTitle("Search")
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
    
    private var searchBar: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)
            
            TextField("Search books and verses...", text: $searchViewModel.searchQuery)
                .textFieldStyle(PlainTextFieldStyle())
                .autocapitalization(.none)
                .disableAutocorrection(true)
                .onChange(of: searchViewModel.searchQuery) { query in
                    searchViewModel.performSearch(query: query)
                }
            
            if !searchViewModel.searchQuery.isEmpty {
                Button(action: {
                    searchViewModel.searchQuery = ""
                }) {
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

struct SearchResultRow: View {
    let result: SearchResult
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        NavigationLink(value: result) {
            VStack(alignment: .leading, spacing: 4) {
                switch result {
                case .book(let book):
                    Text(book.name)
                        .font(.headline)
                        .foregroundColor(colorScheme == .dark ? .nightText : .primary)
                    
                case .verse(let book, let chapter, let verse):
                    HStack {
                        Text("\(book.name) \(chapter.number):\(verse.number)")
                            .font(.headline)
                            .foregroundColor(colorScheme == .dark ? .nightText : .primary)
                        Spacer()
                        Image(systemName: "text.quote")
                            .foregroundColor(.gray)
                    }
                    
                    Text(verse.latinText)
                        .font(.subheadline)
                        .foregroundColor(colorScheme == .dark ? .nightSecondary : .secondary)
                        .lineLimit(2)
                    
                    Text(verse.englishText)
                        .font(.subheadline)
                        .italic()
                        .foregroundColor(colorScheme == .dark ? .nightSecondary : .secondary)
                        .lineLimit(2)
                }
            }
        }
    }
} 