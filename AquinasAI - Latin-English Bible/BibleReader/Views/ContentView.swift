import SwiftUI

// Custom colors
extension Color {
    static let deepPurple = Color(red: 137/255, green: 84/255, blue: 160/255) // Brighter purple for better visibility
    static let paperWhite = Color(red: 242/255, green: 238/255, blue: 228/255) // Slightly darker, warm paper-like color
    static let nightBackground = Color(red: 28/255, green: 28/255, blue: 30/255) // Soft black for dark mode
    static let nightText = Color.white.opacity(0.92) // Slightly softened white for dark mode
    static let nightSecondary = Color.white.opacity(0.65) // Secondary text for dark mode
    static let separatorLight = Color(red: 0/255, green: 0/255, blue: 0/255, opacity: 0.05) // Subtle separator for light mode
}

struct ContentView: View {
    @StateObject private var viewModel = BibleViewModel()
    @StateObject private var bookmarkStore = BookmarkStore()
    @StateObject private var prayerStore = PrayerStore()
    @AppStorage("isDarkMode") private var isDarkMode = true
    @State private var showingBookmarks = false
    @State private var showingSearch = false
    @State private var showingPrayers = false
    
    var body: some View {
        NavigationView {
            if !viewModel.books.isEmpty {
                BookList(
                    books: viewModel.books,
                    viewModel: viewModel,
                    prayerStore: prayerStore,
                    isDarkMode: $isDarkMode,
                    showingBookmarks: $showingBookmarks,
                    showingPrayers: $showingPrayers
                )
            } else if let error = viewModel.errorMessage {
                ErrorView(message: error)
            } else {
                LoadingView()
            }
        }
        .preferredColorScheme(isDarkMode ? .dark : .light)
        .environmentObject(bookmarkStore)
        .environmentObject(viewModel)
        .environmentObject(prayerStore)
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
    @Binding var showingPrayers: Bool
    @Binding var showingSpeedReader: Bool

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

                TestamentPillButton(
                    title: "Prayers",
                    isSelected: false,
                    action: { showingPrayers = true }
                )
            }

            // Speed Reader button
            TestamentPillButton(
                title: "Speed Reader",
                isSelected: false,
                action: { showingSpeedReader = true }
            )
        }
        .padding()
    }
}

// MARK: - Book List View
struct BookList: View {
    let books: [Book]
    @ObservedObject var viewModel: BibleViewModel
    let prayerStore: PrayerStore
    @Binding var isDarkMode: Bool
    @Binding var showingBookmarks: Bool
    @Binding var showingPrayers: Bool
    @State private var selectedTestament: Testament = .old
    @State private var showingSearch = false
    @State private var showingSpeedReader = false
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
        return viewModel.displayMode.navigationTitle
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
                        showingSearch: $showingSearch,
                        showingPrayers: $showingPrayers,
                        showingSpeedReader: $showingSpeedReader
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
                    Menu {
                        // Single Language Options
                        Section("Single Language") {
                            Button("Latin") {
                                viewModel.displayMode = .latinOnly
                            }
                            Button("English") {
                                viewModel.displayMode = .englishOnly
                            }
                            Button("Español") {
                                viewModel.displayMode = .spanishOnly
                            }
                        }
                        
                        // Bilingual Options
                        Section("Bilingual") {
                            Button("Latin-English") {
                                viewModel.displayMode = .latinEnglish
                            }
                            Button("Latin-Español") {
                                viewModel.displayMode = .latinSpanish
                            }
                            Button("English-Español") {
                                viewModel.displayMode = .englishSpanish
                            }
                        }
                    } label: {
                        HStack {
                            Text(viewModel.displayMode.description)
                                .font(.caption)
                            Image(systemName: "chevron.down")
                                .font(.caption2)
                        }
                        .foregroundColor(isDarkMode ? .white : Color.deepPurple)
                    }
                }
            }
            .sheet(isPresented: $showingSearch) {
                SearchView(bibleViewModel: viewModel)
            }
            .sheet(isPresented: $showingBookmarks) {
                BookmarksListView { bookmark in
                    if bookmark.type == .verse,
                       let bookName = bookmark.bookName,
                       let chapterNumber = bookmark.chapterNumber,
                       let verseNumber = bookmark.verseNumber,
                       let book = books.first(where: { $0.name == bookName }) {
                        navigationPath.append(BookNavigation(
                            book: book,
                            chapterNumber: chapterNumber,
                            verseNumber: verseNumber
                        ))
                    }
                    showingBookmarks = false
                }
            }
            .sheet(isPresented: $showingPrayers) {
                PrayersView(initialPrayerId: nil)
                    .environmentObject(prayerStore)
            }
            .sheet(isPresented: $showingSpeedReader) {
                SpeedReaderHubView()
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
        let primaryLanguage = viewModel.displayMode.primaryLanguage
        return viewModel.getBookName(for: book.name, in: primaryLanguage)
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
    @State private var showingSpeedReader: Bool = false
    let initialChapter: Int?
    let scrollToVerse: Int?
    @Environment(\.colorScheme) private var colorScheme

    private var currentChapter: Chapter {
        book.chapters[selectedChapterIndex]
    }
    
    private var navigationTitle: String {
        let primaryLanguage = viewModel.displayMode.primaryLanguage
        return viewModel.getBookName(for: book.name, in: primaryLanguage)
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
            .background(colorScheme == .dark ? Color.nightBackground : Color.paperWhite)
            
            // Chapter Content
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 20) {
                        Text("Chapter \(currentChapter.number)")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(colorScheme == .dark ? .nightText : .black)
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
                .background(colorScheme == .dark ? Color.nightBackground : Color.paperWhite)
                .onChange(of: selectedChapterIndex) { oldValue, newValue in
                    withAnimation {
                        proxy.scrollTo("chapter_header", anchor: .top)
                    }
                }
                .onAppear {
                    if let chapter = initialChapter,
                       let index = book.chapters.firstIndex(where: { $0.number == chapter }) {
                        selectedChapterIndex = index
                        if let verse = scrollToVerse {
                            // Add a slight delay to ensure the view is fully loaded
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                withAnimation {
                                    proxy.scrollTo("verse_\(verse)", anchor: .top)
                                }
                            }
                        }
                    }
                }
            }
        }
        .background(colorScheme == .dark ? Color.nightBackground : Color.paperWhite)
        .navigationTitle(navigationTitle)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    print("📱 SpeedReader button tapped!")
                    print("📱 Book: \(book.name)")
                    print("📱 Chapter: \(currentChapter.number)")
                    print("📱 Setting showingSpeedReader = true")
                    showingSpeedReader = true
                } label: {
                    Image(systemName: "text.viewfinder")
                        .foregroundColor(.deepPurple)
                }
            }
        }
        .fullScreenCover(isPresented: $showingSpeedReader) {
            let _ = print("🎬 fullScreenCover content being created")
            let _ = print("🎬 Book: \(book.name)")
            let _ = print("🎬 Chapter: \(currentChapter.number)")

            // Test: Simple view to verify fullScreenCover works
            VStack(spacing: 20) {
                Text("TEST - FullScreenCover Works!")
                    .font(.largeTitle)
                    .foregroundColor(.primary)

                Text("Book: \(book.name)")
                    .foregroundColor(.secondary)

                Text("Chapter: \(currentChapter.number)")
                    .foregroundColor(.secondary)

                Text("Verses: \(currentChapter.verses.count)")
                    .foregroundColor(.secondary)

                Button("Close") {
                    showingSpeedReader = false
                }
                .font(.title2)
                .foregroundColor(.blue)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(UIColor.systemBackground))
            .onAppear {
                print("🎬 Test view onAppear!")
            }
        }
        .onChange(of: showingSpeedReader) { oldValue, newValue in
            print("📱 showingSpeedReader changed: \(oldValue) -> \(newValue)")
        }
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