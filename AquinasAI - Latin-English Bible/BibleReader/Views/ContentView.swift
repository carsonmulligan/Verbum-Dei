import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = BibleViewModel()
    
    var body: some View {
        NavigationView {
            if !viewModel.books.isEmpty {
                BookList(books: viewModel.books, viewModel: viewModel)
            } else if let error = viewModel.errorMessage {
                ErrorView(message: error)
            } else {
                LoadingView()
            }
        }
    }
}

struct BookList: View {
    let books: [Book]
    @ObservedObject var viewModel: BibleViewModel
    
    var body: some View {
        List(books) { book in
            NavigationLink(destination: BookView(book: book, viewModel: viewModel)) {
                Text(book.name)
            }
        }
        .navigationTitle("Vulgate Bible")
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
    }
}

struct BookView: View {
    let book: Book
    @ObservedObject var viewModel: BibleViewModel
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                ForEach(book.chapters) { chapter in
                    ChapterView(chapter: chapter, displayMode: viewModel.displayMode)
                }
            }
            .padding(.vertical)
        }
        .navigationTitle(book.name)
    }
}

struct ChapterView: View {
    let chapter: Chapter
    let displayMode: DisplayMode
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Chapter \(chapter.number)")
                .font(.title2)
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