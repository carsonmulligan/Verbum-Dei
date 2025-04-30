import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = BibleViewModel()
    
    var body: some View {
        NavigationView {
            if let content = viewModel.bibleContent {
                List(content.books) { book in
                    NavigationLink(destination: BookView(book: book)) {
                        Text(book.name)
                    }
                }
                .navigationTitle("Vulgate Bible")
            } else if let error = viewModel.errorMessage {
                Text(error)
                    .foregroundColor(.red)
                    .padding()
            } else {
                ProgressView()
            }
        }
    }
}

struct BookView: View {
    let book: Book
    
    var body: some View {
        List(book.chapters) { chapter in
            NavigationLink(destination: ChapterView(chapter: chapter)) {
                Text("Chapter \(chapter.number)")
            }
        }
        .navigationTitle(book.name)
    }
}

struct ChapterView: View {
    let chapter: Chapter
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 10) {
                ForEach(chapter.verses) { verse in
                    Text("\(verse.number). \(verse.text)")
                        .padding(.horizontal)
                }
            }
            .padding(.vertical)
        }
        .navigationTitle("Chapter \(chapter.number)")
    }
}

#Preview {
    ContentView()
} 