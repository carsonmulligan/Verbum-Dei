import SwiftUI

// Custom deep purple color
extension Color {
    static let deepPurple = Color(red: 76/255, green: 40/255, blue: 90/255)
    static let paperWhite = Color(red: 251/255, green: 247/255, blue: 240/255) // Warm, paper-like color
}

struct ContentView: View {
    @StateObject private var viewModel = BibleViewModel()
    @StateObject private var bookmarkStore = BookmarkStore()
    @AppStorage("isDarkMode") private var isDarkMode = false
    @State private var showingBookmarks = false
    
    var body: some View {
        NavigationView {
            if !viewModel.books.isEmpty {
                BookList(books: viewModel.books, viewModel: viewModel, isDarkMode: $isDarkMode, showingBookmarks: $showingBookmarks)
            } else if let error = viewModel.errorMessage {
                ErrorView(message: error)
            } else {
                LoadingView()
            }
        }
        .preferredColorScheme(isDarkMode ? .dark : .light)
        .environmentObject(bookmarkStore)
    }
}

struct BookList: View {
    let books: [Book]
    @ObservedObject var viewModel: BibleViewModel
    @Binding var isDarkMode: Bool
    @Binding var showingBookmarks: Bool
    @State private var selectedTestament: Testament = .old
    @State private var selectedBookmark: Bookmark?
    @State private var navigationPath = NavigationPath()
    
    var filteredBooks: [Book] {
        books.filter { book in
            switch selectedTestament {
            case .old:
                return isOldTestament(book.name)
            case .new:
                return !isOldTestament(book.name)
            }
        }
    }
    
    var navigationTitle: String {
        switch viewModel.displayMode {
        case .latinOnly:
            return "Biblia Sacra"
        case .englishOnly:
            return "Holy Bible"
        case .bilingual:
            return "Biblia Sacra"
        }
    }
    
    var body: some View {
        NavigationStack(path: $navigationPath) {
            VStack(spacing: 0) {
                // Custom Title
                Text(navigationTitle)
                    .font(.largeTitle)
                    .padding(.top, 20)
                    .padding(.bottom, 10)
                
                // Testament and Mode Selectors
                VStack(spacing: 12) {
                    // Testament Selector
                    HStack(spacing: 16) {
                        TestamentPillButton(
                            title: "Old Testament",
                            isSelected: selectedTestament == .old,
                            action: { selectedTestament = .old }
                        )
                        
                        TestamentPillButton(
                            title: "New Testament",
                            isSelected: selectedTestament == .new,
                            action: { selectedTestament = .new }
                        )
                    }
                    
                    // Mode Toggles
                    HStack(spacing: 16) {
                        // Dark Mode Toggle
                        TestamentPillButton(
                            title: isDarkMode ? "Light Mode" : "Dark Mode",
                            isSelected: isDarkMode,
                            action: { isDarkMode.toggle() }
                        )
                        
                        // Bookmarks Toggle
                        TestamentPillButton(
                            title: "Bookmarks",
                            isSelected: false,
                            action: { showingBookmarks = true }
                        )
                    }
                }
                .padding()
                .background(isDarkMode ? Color(UIColor.systemBackground) : Color.paperWhite)
                
                // Book List
                List(filteredBooks) { book in
                    NavigationLink(value: BookNavigation(book: book)) {
                        Text(getDisplayName(for: book))
                    }
                }
                .listStyle(PlainListStyle())
                .scrollContentBackground(isDarkMode ? .visible : .hidden)
                .background(isDarkMode ? Color(UIColor.systemBackground) : Color.paperWhite)
            }
            .background(isDarkMode ? Color(UIColor.systemBackground) : Color.paperWhite)
            .navigationBarTitleDisplayMode(.inline)
            .navigationDestination(for: BookNavigation.self) { navigation in
                BookView(
                    book: navigation.book,
                    viewModel: viewModel,
                    initialChapter: navigation.chapterNumber,
                    scrollToVerse: navigation.verseNumber
                )
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Picker("Display Mode", selection: $viewModel.displayMode) {
                        Text("Latin").tag(DisplayMode.latinOnly)
                        Text("English").tag(DisplayMode.englishOnly)
                        Text("Bilingual").tag(DisplayMode.bilingual)
                    }
                    .pickerStyle(.menu)
                }
            }
            .sheet(isPresented: $showingBookmarks) {
                BookmarksListView { bookmark in
                    if let book = books.first(where: { $0.name == bookmark.bookName }) {
                        navigationPath.append(BookNavigation(
                            book: book,
                            chapterNumber: bookmark.chapterNumber,
                            verseNumber: bookmark.verseNumber
                        ))
                    }
                    showingBookmarks = false
                }
            }
        }
    }
    
    private func getDisplayName(for book: Book) -> String {
        switch viewModel.displayMode {
        case .latinOnly:
            return book.name
        case .englishOnly:
            return viewModel.getEnglishName(for: book.name)
        case .bilingual:
            return book.name
        }
    }
    
    private func isOldTestament(_ bookName: String) -> Bool {
        // Add all New Testament books
        let newTestamentBooks = Set([
            "Matthaeus", "Marcus", "Lucas", "Joannes",
            "Actus Apostolorum",
            "ad Romanos", "ad Corinthios I", "ad Corinthios II",
            "ad Galatas", "ad Ephesios", "ad Philippenses",
            "ad Colossenses", "ad Thessalonicenses I", "ad Thessalonicenses II",
            "ad Timotheum I", "ad Timotheum II", "ad Titum",
            "ad Philemonem", "ad Hebraeos",
            "Jacobi", "Petri I", "Petri II",
            "Joannis I", "Joannis II", "Joannis III",
            "Judae", "Apocalypsis"
        ])
        return !newTestamentBooks.contains(bookName)
    }
}

struct BookNavigation: Hashable {
    let book: Book
    var chapterNumber: Int?
    var verseNumber: Int?
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(book.id)
        hasher.combine(chapterNumber)
        hasher.combine(verseNumber)
    }
    
    static func == (lhs: BookNavigation, rhs: BookNavigation) -> Bool {
        lhs.book.id == rhs.book.id &&
        lhs.chapterNumber == rhs.chapterNumber &&
        lhs.verseNumber == rhs.verseNumber
    }
}

struct TestamentPillButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(isSelected ? Color.deepPurple : Color.clear)
                .foregroundColor(isSelected ? .white : .deepPurple)
                .cornerRadius(20)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.deepPurple, lineWidth: 1)
                )
        }
    }
}

enum Testament {
    case old
    case new
}

struct BookView: View {
    let book: Book
    @ObservedObject var viewModel: BibleViewModel
    @State private var selectedChapterIndex: Int = 0
    let initialChapter: Int?
    let scrollToVerse: Int?
    @Environment(\.colorScheme) private var colorScheme
    
    private var currentChapter: Chapter {
        book.chapters[selectedChapterIndex]
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Chapter Navigation
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(book.chapters.indices, id: \.self) { index in
                        Button(action: {
                            selectedChapterIndex = index
                        }) {
                            Text("\(book.chapters[index].number)")
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(selectedChapterIndex == index ? Color.deepPurple : Color.clear)
                                .foregroundColor(selectedChapterIndex == index ? .white : .deepPurple)
                                .cornerRadius(15)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 15)
                                        .stroke(Color.deepPurple, lineWidth: 1)
                                )
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 8)
            }
            .background(colorScheme == .dark ? Color(UIColor.systemBackground) : Color.paperWhite)
            
            // Chapter Content
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 20) {
                        Text("Chapter \(currentChapter.number)")
                            .font(.title2)
                            .fontWeight(.bold)
                            .padding(.horizontal)
                            .id("chapter_header")
                        
                        ForEach(currentChapter.verses) { verse in
                            VerseView(
                                verse: verse,
                                displayMode: viewModel.displayMode,
                                bookName: book.name,
                                chapterNumber: currentChapter.number
                            )
                            .id("verse_\(verse.number)")
                            .padding(.horizontal)
                        }
                    }
                    .padding(.vertical)
                }
                .background(colorScheme == .dark ? Color(UIColor.systemBackground) : Color.paperWhite)
                .onChange(of: selectedChapterIndex) { _ in
                    withAnimation {
                        proxy.scrollTo("chapter_header", anchor: .top)
                    }
                }
                .onAppear {
                    if let chapter = initialChapter,
                       let index = book.chapters.firstIndex(where: { $0.number == chapter }) {
                        selectedChapterIndex = index
                        if let verse = scrollToVerse {
                            proxy.scrollTo("verse_\(verse)", anchor: .top)
                        }
                    }
                }
            }
        }
        .background(colorScheme == .dark ? Color(UIColor.systemBackground) : Color.paperWhite)
        .navigationTitle(book.name)
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct ChapterView: View {
    let chapter: Chapter
    let displayMode: DisplayMode
    let bookName: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Chapter \(chapter.number)")
                .font(.title2)
                .fontWeight(.bold)
                .padding(.horizontal)
            
            ForEach(chapter.verses) { verse in
                VerseView(
                    verse: verse,
                    displayMode: displayMode,
                    bookName: bookName,
                    chapterNumber: chapter.number
                )
                .padding(.horizontal)
            }
        }
        .padding(.vertical, 10)
    }
}

struct ErrorView: View {
    let message: String
    
    var body: some View {
        Text(message)
            .font(.custom("Times New Roman", size: 17))
            .foregroundColor(.red)
            .padding()
    }
}

struct LoadingView: View {
    var body: some View {
        ProgressView()
            .navigationTitle("Loading...")
    }
}

#Preview {
    ContentView()
} 