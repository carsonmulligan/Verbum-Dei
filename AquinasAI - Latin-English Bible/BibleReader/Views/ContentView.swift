import SwiftUI

// Custom deep purple color
extension Color {
    static let deepPurple = Color(red: 76/255, green: 40/255, blue: 90/255)
}

struct ContentView: View {
    @StateObject private var viewModel = BibleViewModel()
    @AppStorage("isDarkMode") private var isDarkMode = false
    
    var body: some View {
        NavigationView {
            if !viewModel.books.isEmpty {
                BookList(books: viewModel.books, viewModel: viewModel, isDarkMode: $isDarkMode)
            } else if let error = viewModel.errorMessage {
                ErrorView(message: error)
            } else {
                LoadingView()
            }
        }
        .preferredColorScheme(isDarkMode ? .dark : .light)
    }
}

struct BookList: View {
    let books: [Book]
    @ObservedObject var viewModel: BibleViewModel
    @Binding var isDarkMode: Bool
    @State private var selectedTestament: Testament = .old
    
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
        VStack(spacing: 0) {
            // Custom Title
            Text(navigationTitle)
                .font(.custom("Times New Roman", size: 32))
                .padding(.top, 20)
                .padding(.bottom, 10)
            
            // Testament and Dark Mode Selectors
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
                
                // Dark Mode Toggle
                TestamentPillButton(
                    title: isDarkMode ? "Light Mode" : "Dark Mode",
                    isSelected: isDarkMode,
                    action: { isDarkMode.toggle() }
                )
            }
            .padding()
            .background(Color(UIColor.systemBackground))
            
            // Book List
            List(filteredBooks) { book in
                NavigationLink(destination: BookView(book: book, viewModel: viewModel)) {
                    Text(getDisplayName(for: book))
                        .font(.custom("Times New Roman", size: 17))
                }
            }
            .listStyle(PlainListStyle())
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Picker("Display Mode", selection: $viewModel.displayMode) {
                    Text("Latin").tag(DisplayMode.latinOnly)
                    Text("English").tag(DisplayMode.englishOnly)
                    Text("Bilingual").tag(DisplayMode.bilingual)
                }
                .pickerStyle(.menu)
                .font(.custom("Times New Roman", size: 17))
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

struct TestamentPillButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.custom("Times New Roman", size: 15))
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
                                .font(.custom("Times New Roman", size: 17))
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
            .background(Color(UIColor.systemBackground))
            
            // Chapter Content
            ScrollViewReader { proxy in
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        ForEach(book.chapters.indices, id: \.self) { index in
                            ChapterView(chapter: book.chapters[index], displayMode: viewModel.displayMode)
                                .id(index)
                        }
                    }
                    .padding(.vertical)
                }
                .onChange(of: selectedChapterIndex) { newIndex in
                    withAnimation {
                        proxy.scrollTo(newIndex, anchor: .top)
                    }
                }
            }
        }
        .navigationTitle(book.name)
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct ChapterView: View {
    let chapter: Chapter
    let displayMode: DisplayMode
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Chapter \(chapter.number)")
                .font(.custom("Times New Roman", size: 24))
                .fontWeight(.bold)
                .padding(.horizontal)
            
            ForEach(chapter.verses) { verse in
                VerseView(verse: verse, displayMode: displayMode)
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