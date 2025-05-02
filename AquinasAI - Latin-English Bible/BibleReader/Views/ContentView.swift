import SwiftUI

// Custom colors
extension Color {
    static let deepPurple = Color(red: 76/255, green: 40/255, blue: 90/255)
    static let paperWhite = Color(red: 249/255, green: 245/255, blue: 235/255) // Slightly darker, warm paper-like color
    static let nightBackground = Color(red: 28/255, green: 28/255, blue: 30/255) // Soft black for dark mode
    static let nightText = Color.white.opacity(0.92) // Slightly softened white for dark mode
    static let nightSecondary = Color.white.opacity(0.65) // Secondary text for dark mode
    static let separatorLight = Color(red: 0/255, green: 0/255, blue: 0/255, opacity: 0.05) // Subtle separator for light mode
}

struct ContentView: View {
    @StateObject private var viewModel = BibleViewModel()
    @StateObject private var bookmarkStore = BookmarkStore()
    @AppStorage("isDarkMode") private var isDarkMode = true
    @State private var showingBookmarks = false
    @State private var showingSearch = false
    
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
        .environmentObject(viewModel)
        .sheet(isPresented: $showingSearch) {
            SearchView(bibleViewModel: viewModel)
        }
    }
}

// MARK: - Book Row View
struct BookRowView: View {
    let book: Book
    let displayName: String
    let isDarkMode: Bool
    
    var body: some View {
        HStack {
            Text(displayName)
                .foregroundColor(isDarkMode ? .nightText : Color(.displayP3, red: 0.1, green: 0.1, blue: 0.1, opacity: 1))
                .padding(.vertical, 12)
            Spacer()
            Image(systemName: "chevron.right")
                .foregroundColor(Color(.systemGray3))
                .font(.system(size: 14))
        }
        .padding(.horizontal)
        .contentShape(Rectangle())
    }
}

// MARK: - Testament Selector View
struct TestamentSelectorView: View {
    @Binding var selectedTestament: Testament
    @Binding var isDarkMode: Bool
    @Binding var showingBookmarks: Bool
    @Binding var showingSearch: Bool
    
    var body: some View {
        VStack(spacing: 12) {
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
            
            HStack(spacing: 16) {
                TestamentPillButton(
                    title: "Search",
                    isSelected: false,
                    action: { showingSearch = true }
                )
                
                TestamentPillButton(
                    title: "Bookmarks",
                    isSelected: false,
                    action: { showingBookmarks = true }
                )
            }
        }
        .padding()
    }
}

// MARK: - Book List View
struct BookList: View {
    let books: [Book]
    @ObservedObject var viewModel: BibleViewModel
    @Binding var isDarkMode: Bool
    @Binding var showingBookmarks: Bool
    @State private var selectedTestament: Testament = .old
    @State private var showingSearch = false
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
            ZStack {
                (isDarkMode ? Color.nightBackground : Color.paperWhite)
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Cross Image
                    Image("app_home_image")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxWidth: .infinity)
                        .padding(.horizontal)
                        .padding(.top, 20)
                    
                    Text(navigationTitle)
                        .font(.largeTitle)
                        .fontWeight(.medium)
                        .foregroundColor(isDarkMode ? .nightText : Color(.displayP3, red: 0.1, green: 0.1, blue: 0.1, opacity: 1))
                        .padding(.top, 20)
                        .padding(.bottom, 10)
                    
                    TestamentSelectorView(
                        selectedTestament: $selectedTestament,
                        isDarkMode: $isDarkMode,
                        showingBookmarks: $showingBookmarks,
                        showingSearch: $showingSearch
                    )
                    
                    bookListContent
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationDestination(for: SearchResult.self) { result in
                switch result {
                case .book(let book, _):
                    BookView(
                        book: book,
                        viewModel: viewModel,
                        initialChapter: nil,
                        scrollToVerse: nil
                    )
                case .verse(let book, _, let chapter, let verse):
                    BookView(
                        book: book,
                        viewModel: viewModel,
                        initialChapter: chapter.number,
                        scrollToVerse: verse.number
                    )
                }
            }
            .navigationDestination(for: BookNavigation.self) { navigation in
                BookView(
                    book: navigation.book,
                    viewModel: viewModel,
                    initialChapter: navigation.chapterNumber,
                    scrollToVerse: navigation.verseNumber
                )
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        isDarkMode.toggle()
                    }) {
                        Image(systemName: isDarkMode ? "moon.fill" : "sun.max.fill")
                            .foregroundColor(isDarkMode ? .white : .deepPurple)
                            .font(.system(size: 20))
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Picker("Display Mode", selection: $viewModel.displayMode) {
                        Text("Latin").tag(DisplayMode.latinOnly)
                        Text("English").tag(DisplayMode.englishOnly)
                        Text("Bilingual").tag(DisplayMode.bilingual)
                    }
                    .pickerStyle(.menu)
                    .tint(isDarkMode ? .white : Color.deepPurple)
                }
            }
            .sheet(isPresented: $showingSearch) {
                SearchView(bibleViewModel: viewModel)
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
    
    private var bookListContent: some View {
        ScrollView {
            LazyVStack(spacing: 0, pinnedViews: []) {
                ForEach(filteredBooks) { book in
                    NavigationLink(value: BookNavigation(book: book)) {
                        BookRowView(
                            book: book,
                            displayName: getDisplayName(for: book),
                            isDarkMode: isDarkMode
                        )
                    }
                    .background(isDarkMode ? Color.nightBackground : Color.paperWhite)
                    
                    if book != filteredBooks.last {
                        Divider()
                            .background(isDarkMode ? Color.white.opacity(0.1) : Color.separatorLight)
                    }
                }
            }
        }
        .background(isDarkMode ? Color.nightBackground : Color.paperWhite)
    }
    
    private func getDisplayName(for book: Book) -> String {
        switch viewModel.displayMode {
        case .latinOnly:
            return book.name
        case .englishOnly:
            return viewModel.getEnglishName(for: book.name)
        case .bilingual:
            return viewModel.getEnglishName(for: book.name)
        }
    }
    
    private func isOldTestament(_ bookName: String) -> Bool {
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
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(isSelected ? Color.deepPurple : Color.clear)
                .foregroundColor(isSelected ? .white : Color.deepPurple)
                .cornerRadius(20)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.deepPurple, lineWidth: colorScheme == .dark ? 1 : 0.75)
                )
                .shadow(color: colorScheme == .dark ? .clear : Color.black.opacity(0.03), radius: 1, x: 0, y: 1)
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
    @State private var scrollOffset: CGFloat = 0
    @State private var previousScrollOffset: CGFloat = 0
    @State private var chapterNavOpacity: CGFloat = 1.0
    @State private var isNavBarVisible = true  // New state for nav bar visibility
    
    private var currentChapter: Chapter {
        book.chapters[selectedChapterIndex]
    }
    
    private var navigationTitle: String {
        switch viewModel.displayMode {
        case .latinOnly:
            return book.name
        case .englishOnly:
            return viewModel.getEnglishName(for: book.name)
        case .bilingual:
            return book.name
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Chapter Navigation
            VStack {
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
            }
            .background(colorScheme == .dark ? Color.nightBackground : Color.paperWhite)
            .opacity(chapterNavOpacity)
            .animation(.easeInOut(duration: 0.3), value: chapterNavOpacity)
            
            // Chapter Content
            ScrollView {
                GeometryReader { geometry in
                    Color.clear.preference(
                        key: ScrollOffsetPreferenceKey.self,
                        value: geometry.frame(in: .named("scroll")).minY
                    )
                }
                .frame(height: 0)
                
                LazyVStack(alignment: .leading, spacing: 20) {
                    Text("Chapter \(currentChapter.number)")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(colorScheme == .dark ? .nightText : .black)
                        .padding(.horizontal)
                        .id("chapter_header")
                        .opacity(chapterNavOpacity) // Also hide chapter title when scrolling
                    
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
            .coordinateSpace(name: "scroll")
            .onPreferenceChange(ScrollOffsetPreferenceKey.self) { value in
                let diff = value - previousScrollOffset
                
                // More gradual opacity change based on scroll direction and speed
                withAnimation {
                    if abs(diff) > 1 {
                        // Scrolling down - fade out
                        if diff < 0 {
                            chapterNavOpacity = max(0, chapterNavOpacity - 0.15)
                            if chapterNavOpacity < 0.1 { // Hide nav bar when almost hidden
                                isNavBarVisible = false
                            }
                        }
                        // Scrolling up - fade in
                        else {
                            chapterNavOpacity = min(1, chapterNavOpacity + 0.15)
                            if chapterNavOpacity > 0.1 { // Show nav bar when starting to show
                                isNavBarVisible = true
                            }
                        }
                    }
                }
                
                previousScrollOffset = value
            }
            .background(colorScheme == .dark ? Color.nightBackground : Color.paperWhite)
        }
        .background(colorScheme == .dark ? Color.nightBackground : Color.paperWhite)
        .navigationTitle(navigationTitle)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                EmptyView() // Remove any existing toolbar items
            }
        }
        // Hide navigation bar based on state
        .navigationBarHidden(!isNavBarVisible)
        // Add a tap gesture to show navigation elements
        .onTapGesture {
            withAnimation(.easeInOut(duration: 0.3)) {
                isNavBarVisible = true
                chapterNavOpacity = 1.0
            }
        }
    }
}

struct ScrollOffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
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