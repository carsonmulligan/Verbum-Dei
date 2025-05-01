import SwiftUI

struct SearchView: View {
    @StateObject private var searchViewModel: SearchViewModel
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.dismiss) private var dismiss
    @State private var navigationPath = NavigationPath()
    
    init(bibleViewModel: BibleViewModel) {
        _searchViewModel = StateObject(wrappedValue: SearchViewModel(bibleViewModel: bibleViewModel))
    }
    
    var body: some View {
        NavigationStack(path: $navigationPath) {
            SearchContentView(
                searchViewModel: searchViewModel,
                navigationPath: $navigationPath
            )
            .navigationTitle("Search")
            .navigationBarTitleDisplayMode(.inline)
            .navigationDestination(for: BookNavigation.self) { navigation in
                BookView(
                    book: navigation.book,
                    viewModel: searchViewModel.bibleViewModel,
                    initialChapter: navigation.chapterNumber,
                    scrollToVerse: navigation.verseNumber
                )
            }
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

struct SearchContentView: View {
    @ObservedObject var searchViewModel: SearchViewModel
    @Binding var navigationPath: NavigationPath
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        VStack(spacing: 0) {
            SearchBar(searchText: $searchViewModel.searchQuery)
                .padding()
            
            if searchViewModel.isSearching {
                ProgressView()
                    .padding()
            } else if searchViewModel.searchResults.isEmpty && !searchViewModel.searchQuery.isEmpty {
                EmptySearchView()
            } else {
                SearchResultsList(
                    results: searchViewModel.searchResults,
                    navigationPath: $navigationPath
                )
            }
        }
        .background(colorScheme == .dark ? Color.nightBackground : Color.paperWhite)
    }
}

private struct SearchBar: View {
    @Binding var searchText: String
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)
            
            TextField("Enter verse (e.g. john 3:16) or search text...", text: $searchText)
                .textFieldStyle(PlainTextFieldStyle())
                .autocapitalization(.none)
                .disableAutocorrection(true)
                .onChange(of: searchText) { oldValue, newValue in
                    // The actual search is handled by the view model's property observer
                }
            
            if !searchText.isEmpty {
                Button(action: {
                    searchText = ""
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

private struct EmptySearchView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 40))
                .foregroundColor(.gray)
            Text("No results found")
                .foregroundColor(.gray)
        }
        .padding(.top, 40)
    }
}

private struct SearchResultsList: View {
    let results: [SearchResult]
    @Binding var navigationPath: NavigationPath
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                ForEach(results) { result in
                    SearchResultRow(result: result, navigationPath: $navigationPath)
                    
                    if result != results.last {
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

private struct SearchResultRow: View {
    let result: SearchResult
    @Binding var navigationPath: NavigationPath
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        Group {
            switch result {
            case .verse(let book, let englishName, let chapter, let verse):
                Button {
                    navigationPath.append(
                        BookNavigation(
                            book: book,
                            chapterNumber: chapter.number,
                            verseNumber: verse.number
                        )
                    )
                } {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("\(englishName) \(chapter.number):\(verse.number)")
                                .font(.headline)
                                .foregroundColor(colorScheme == .dark ? .nightText : .primary)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(.gray)
                        }
                        
                        Text(verse.englishText)
                            .font(.body)
                            .foregroundColor(colorScheme == .dark ? .nightSecondary : .secondary)
                            .multilineTextAlignment(.leading)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .padding()
                    .background(colorScheme == .dark ? Color.black.opacity(0.3) : Color.white)
                    .cornerRadius(10)
                }
                .padding(.horizontal)
                .padding(.vertical, 4)
                
            case .book(let book, let englishName):
                Button {
                    navigationPath.append(
                        BookNavigation(
                            book: book,
                            chapterNumber: nil,
                            verseNumber: nil
                        )
                    )
                } {
                    HStack {
                        Text(englishName)
                            .font(.headline)
                            .foregroundColor(colorScheme == .dark ? .nightText : .primary)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundColor(.gray)
                    }
                    .padding()
                }
            }
        }
    }
} 