import Foundation

class BibleViewModel: ObservableObject {
    @Published var books: [Book] = []
    @Published var errorMessage: String?
    @Published var displayMode: DisplayMode = .bilingual
    
    private var bookNameMapping: [String: String] = [:]
    
    init() {
        loadBookNameMapping()
        loadBibleContent()
    }
    
    private func loadBookNameMapping() {
        guard let url = Bundle.main.url(forResource: "metadata", withExtension: "csv") else {
            print("Warning: Could not find metadata.csv")
            return
        }
        
        do {
            let content = try String(contentsOf: url)
            let rows = content.components(separatedBy: .newlines)
            
            // Skip header row and empty lines
            for row in rows.dropFirst() where !row.isEmpty {
                let columns = row.components(separatedBy: ",")
                if columns.count >= 2 {
                    let english = columns[1].trimmingCharacters(in: .whitespaces)
                    let latin = convertToLatinName(english)
                    bookNameMapping[latin] = english
                }
            }
            print("Loaded book name mapping: \(bookNameMapping.count) entries")
        } catch {
            print("Error loading metadata.csv: \(error)")
        }
    }
    
    private func convertToLatinName(_ english: String) -> String {
        // Convert English names to their Latin equivalents
        switch english {
        case "Genesis": return "Genesis"
        case "Exodus": return "Exodus"
        case "Leviticus": return "Leviticus"
        case "Numbers": return "Numeri"
        case "Deuteronomy": return "Deuteronomium"
        case "Joshua": return "Josue"
        case "Judges": return "Judicum"
        case "Ruth": return "Ruth"
        case "1 Samuel": return "Regum I"
        case "2 Samuel": return "Regum II"
        case "1 Kings": return "Regum III"
        case "2 Kings": return "Regum IV"
        case "1 Chronicles": return "Paralipomenon I"
        case "2 Chronicles": return "Paralipomenon II"
        case "Ezra": return "Esdrae"
        case "Nehemiah": return "Nehemiae"
        case "Tobit": return "Tobiae"
        case "Judith": return "Judith"
        case "Esther": return "Esther"
        case "Job": return "Job"
        case "Psalms": return "Psalmi"
        case "Proverbs": return "Proverbia"
        case "Ecclesiastes": return "Ecclesiastes"
        case "Song of Solomon": return "Canticum Canticorum"
        case "Wisdom": return "Sapientia"
        case "Sirach": return "Ecclesiasticus"
        case "Isaiah": return "Isaias"
        case "Jeremiah": return "Jeremias"
        case "Lamentations": return "Lamentationes"
        case "Baruch": return "Baruch"
        case "Ezekiel": return "Ezechiel"
        case "Daniel": return "Daniel"
        case "Hosea": return "Osee"
        case "Joel": return "Joel"
        case "Amos": return "Amos"
        case "Obadiah": return "Abdias"
        case "Jonah": return "Jonas"
        case "Micah": return "Michaea"
        case "Nahum": return "Nahum"
        case "Habakkuk": return "Habacuc"
        case "Zephaniah": return "Sophonias"
        case "Haggai": return "Aggaeus"
        case "Zechariah": return "Zacharias"
        case "Malachi": return "Malachias"
        case "1 Maccabees": return "Machabaeorum I"
        case "2 Maccabees": return "Machabaeorum II"
        case "Matthew": return "Matthaeus"
        case "Mark": return "Marcus"
        case "Luke": return "Lucas"
        case "John": return "Joannes"
        case "Acts": return "Actus Apostolorum"
        case "Romans": return "ad Romanos"
        case "1 Corinthians": return "ad Corinthios I"
        case "2 Corinthians": return "ad Corinthios II"
        case "Galatians": return "ad Galatas"
        case "Ephesians": return "ad Ephesios"
        case "Philippians": return "ad Philippenses"
        case "Colossians": return "ad Colossenses"
        case "1 Thessalonians": return "ad Thessalonicenses I"
        case "2 Thessalonians": return "ad Thessalonicenses II"
        case "1 Timothy": return "ad Timotheum I"
        case "2 Timothy": return "ad Timotheum II"
        case "Titus": return "ad Titum"
        case "Philemon": return "ad Philemonem"
        case "Hebrews": return "ad Hebraeos"
        case "James": return "Jacobi"
        case "1 Peter": return "Petri I"
        case "2 Peter": return "Petri II"
        case "1 John": return "Joannis I"
        case "2 John": return "Joannis II"
        case "3 John": return "Joannis III"
        case "Jude": return "Judae"
        case "Revelation": return "Apocalypsis"
        default: return english
        }
    }
    
    private func loadBibleContent() {
        // Print the main bundle path for debugging
        print("Bundle path: \(Bundle.main.bundlePath)")
        
        // List all resources in the bundle for debugging
        let resourcePaths = Bundle.main.paths(forResourcesOfType: "json", inDirectory: nil)
        print("Found JSON files in bundle: \(resourcePaths)")
        
        guard let latinUrl = Bundle.main.url(forResource: "vulgate_latin", withExtension: "json"),
              let englishUrl = Bundle.main.url(forResource: "vulgate_english", withExtension: "json") else {
            errorMessage = "Could not find Bible content files in bundle."
            return
        }
        
        do {
            let latinData = try Data(contentsOf: latinUrl)
            let englishData = try Data(contentsOf: englishUrl)
            
            let latinContent = try JSONDecoder().decode(BibleContent.self, from: latinData)
            let englishContent = try JSONDecoder().decode(BibleContent.self, from: englishData)
            
            // Create a dictionary of English books for faster lookup
            var englishBooksDictionary: [String: Book] = [:]
            for englishBook in englishContent.books {
                if let latinName = bookNameMapping.first(where: { $0.value == englishBook.name })?.key {
                    englishBooksDictionary[latinName] = englishBook
                }
            }
            
            // Merge Latin and English content safely
            var mergedBooks: [Book] = []
            
            for latinBook in latinContent.books {
                guard let englishBook = englishBooksDictionary[latinBook.name] else {
                    print("Warning: No matching English book found for \(latinBook.name)")
                    continue
                }
                
                // Create a dictionary of English chapters for faster lookup
                let englishChaptersDictionary = Dictionary(
                    uniqueKeysWithValues: englishBook.chapters.map { ("\($0.number)", $0) }
                )
                
                var mergedChapters: [Chapter] = []
                
                for latinChapter in latinBook.chapters {
                    guard let englishChapter = englishChaptersDictionary["\(latinChapter.number)"] else {
                        print("Warning: No matching English chapter found for \(latinBook.name) chapter \(latinChapter.number)")
                        continue
                    }
                    
                    // Create a dictionary of English verses for faster lookup
                    let englishVersesDictionary = Dictionary(
                        uniqueKeysWithValues: englishChapter.verses.map { ("\($0.number)", $0) }
                    )
                    
                    let mergedVerses = latinChapter.verses.compactMap { latinVerse -> Verse? in
                        guard let englishVerse = englishVersesDictionary["\(latinVerse.number)"] else {
                            print("Warning: No matching English verse found for \(latinBook.name) \(latinChapter.number):\(latinVerse.number)")
                            return nil
                        }
                        
                        return Verse(
                            id: latinVerse.id,
                            number: latinVerse.number,
                            latinText: latinVerse.latinText,
                            englishText: englishVerse.latinText
                        )
                    }
                    
                    if !mergedVerses.isEmpty {
                        let chapter = Chapter(
                            id: latinChapter.id,
                            number: latinChapter.number,
                            verses: mergedVerses
                        )
                        mergedChapters.append(chapter)
                    } else {
                        print("Warning: No verses found for \(latinBook.name) chapter \(latinChapter.number)")
                    }
                }
                
                if !mergedChapters.isEmpty {
                    let book = Book(
                        name: latinBook.name,
                        chapters: mergedChapters
                    )
                    mergedBooks.append(book)
                } else {
                    print("Warning: No chapters found for \(latinBook.name)")
                }
            }
            
            self.books = mergedBooks
            
            if books.isEmpty {
                errorMessage = "No matching content found between Latin and English texts."
            } else {
                print("Successfully loaded and merged Bible content: \(books.count) books")
            }
        } catch {
            print("Error loading content: \(error)")
            errorMessage = "Error loading Bible content: \(error.localizedDescription)"
        }
    }
} 