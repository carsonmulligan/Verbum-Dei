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
    
    private var searchBar: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)
            
            TextField("Enter verse (e.g. john 3:16) or search text...", text: $searchViewModel.searchQuery)
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