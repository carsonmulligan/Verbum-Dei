import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = BibleViewModel()
    
    var body: some View {
        NavigationView {
            if !viewModel.books.isEmpty {
                List(viewModel.books) { book in
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
    @ObservedObject var viewModel: BibleViewModel
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                ForEach(book.chapters) { chapter in
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Chapter \(chapter.number)")
                            .font(.title2)
                            .fontWeight(.bold)
                            .padding(.horizontal)
                        
                        ForEach(chapter.verses) { verse in
                            VerseView(verse: verse, displayMode: viewModel.displayMode)
                                .padding(.horizontal)
                        }
                    }
                    .padding(.vertical, 10)
                    
                    if chapter.number != book.chapters.last?.number {
                        Divider()
                            .padding(.horizontal)
                    }
                }
            }
            .padding(.vertical)
        }
        .navigationTitle(book.name)
    }
}

struct VerseView: View {
    let verse: Verse
    let displayMode: DisplayMode
    
    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            verseNumber
            verseContent
        }
    }
    
    private var verseNumber: some View {
        Text("\(verse.number)")
            .font(.caption)
            .foregroundColor(.secondary)
            .frame(width: 30, alignment: .trailing)
    }
    
    private var verseContent: some View {
        VStack(alignment: .leading, spacing: 4) {
            switch displayMode {
            case .latinOnly:
                latinText
            case .englishOnly:
                englishText
            case .bilingual:
                latinText
                englishText
                    .italic()
                    .foregroundColor(.gray)
            }
        }
    }
    
    private var latinText: some View {
        Text(verse.latinText)
            .fixedSize(horizontal: false, vertical: true)
    }
    
    private var englishText: some View {
        Text(verse.englishText)
            .fixedSize(horizontal: false, vertical: true)
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