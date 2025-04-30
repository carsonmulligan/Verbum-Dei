import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = BibleViewModel()
    
    var body: some View {
        NavigationView {
            if !viewModel.books.isEmpty {
                List(viewModel.books) { book in
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
                    .navigationTitle("Loading...")
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
                    HStack(alignment: .top, spacing: 8) {
                        Text("\(verse.number)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .frame(width: 30, alignment: .trailing)
                        Text(verse.text)
                            .fixedSize(horizontal: false, vertical: true)
                    }
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