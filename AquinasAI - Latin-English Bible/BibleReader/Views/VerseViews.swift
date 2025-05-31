import SwiftUI

struct LatinOnlyVerseView: View {
    let number: Int
    let text: String
    let isBookmarked: Bool
    let onDeleteBookmark: (() -> Void)?
    let bookName: String
    let chapterNumber: Int
    @Environment(\.colorScheme) private var colorScheme
    @EnvironmentObject private var viewModel: BibleViewModel
    @EnvironmentObject private var ttsManager: TTSManager
    
    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Text("\(number)")
                .font(.footnote)
                .foregroundColor(colorScheme == .dark ? .nightSecondary : .secondary)
                .frame(width: 30, alignment: .trailing)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(text)
                    .fixedSize(horizontal: false, vertical: true)
                    .foregroundColor(colorScheme == .dark ? .nightText : Color(.displayP3, red: 0.1, green: 0.1, blue: 0.1, opacity: 1))
                
                // TTS controls
                HStack {
                    Button(action: {
                        ttsManager.speakLatin(text)
                    }) {
                        Image(systemName: ttsManager.isPlaying && ttsManager.currentText == text ? "speaker.wave.2.fill" : "speaker.wave.2")
                            .foregroundColor(.deepPurple)
                            .font(.caption)
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    if ttsManager.isPlaying && ttsManager.currentText == text {
                        Button(action: {
                            if ttsManager.isPaused {
                                ttsManager.resume()
                            } else {
                                ttsManager.pause()
                            }
                        }) {
                            Image(systemName: ttsManager.isPaused ? "play.fill" : "pause.fill")
                                .foregroundColor(.deepPurple)
                                .font(.caption)
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        Button(action: {
                            ttsManager.stop()
                        }) {
                            Image(systemName: "stop.fill")
                                .foregroundColor(.deepPurple)
                                .font(.caption)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    
                    Spacer()
                }
                .padding(.top, 2)
            }
            .padding(8)
            .background(isBookmarked ? (colorScheme == .dark ? Color.white.opacity(0.1) : Color.secondary.opacity(0.15)) : Color.clear)
            .cornerRadius(8)
            .contextMenu {
                Button(action: {
                    ttsManager.speakLatin(text)
                }) {
                    Label("Speak Latin", systemImage: "speaker.wave.2")
                }
                
                if isBookmarked {
                    Button(role: .destructive, action: { onDeleteBookmark?() }) {
                        Label("Remove Bookmark", systemImage: "bookmark.slash")
                    }
                } else {
                    Button {
                        NotificationCenter.default.post(
                            name: NSNotification.Name("AddBookmark"), 
                            object: nil, 
                            userInfo: ["verseNumber": number]
                        )
                    } label: {
                        Label("Add Bookmark", systemImage: "bookmark")
                    }
                }
                
                Button {
                    let englishBookName = viewModel.getEnglishName(for: bookName)
                    let sourceInfo = "\(englishBookName) \(chapterNumber):\(number)"
                    UIPasteboard.general.string = "\(sourceInfo)\n\n\(text)"
                } label: {
                    Label("Copy", systemImage: "doc.on.doc")
                }
            }
        }
    }
}

struct EnglishOnlyVerseView: View {
    let number: Int
    let text: String
    let isBookmarked: Bool
    let onDeleteBookmark: (() -> Void)?
    let bookName: String
    let chapterNumber: Int
    @Environment(\.colorScheme) private var colorScheme
    @EnvironmentObject private var viewModel: BibleViewModel
    @EnvironmentObject private var ttsManager: TTSManager
    
    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Text("\(number)")
                .font(.footnote)
                .foregroundColor(colorScheme == .dark ? .nightSecondary : .secondary)
                .frame(width: 30, alignment: .trailing)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(text)
                    .fixedSize(horizontal: false, vertical: true)
                    .foregroundColor(colorScheme == .dark ? .nightText : Color(.displayP3, red: 0.1, green: 0.1, blue: 0.1, opacity: 1))
                
                // TTS controls
                HStack {
                    Button(action: {
                        ttsManager.speakEnglish(text)
                    }) {
                        Image(systemName: ttsManager.isPlaying && ttsManager.currentText == text ? "speaker.wave.2.fill" : "speaker.wave.2")
                            .foregroundColor(.deepPurple)
                            .font(.caption)
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    if ttsManager.isPlaying && ttsManager.currentText == text {
                        Button(action: {
                            if ttsManager.isPaused {
                                ttsManager.resume()
                            } else {
                                ttsManager.pause()
                            }
                        }) {
                            Image(systemName: ttsManager.isPaused ? "play.fill" : "pause.fill")
                                .foregroundColor(.deepPurple)
                                .font(.caption)
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        Button(action: {
                            ttsManager.stop()
                        }) {
                            Image(systemName: "stop.fill")
                                .foregroundColor(.deepPurple)
                                .font(.caption)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    
                    Spacer()
                }
                .padding(.top, 2)
            }
            .padding(8)
            .background(isBookmarked ? (colorScheme == .dark ? Color.white.opacity(0.1) : Color.secondary.opacity(0.15)) : Color.clear)
            .cornerRadius(8)
            .contextMenu {
                Button(action: {
                    ttsManager.speakEnglish(text)
                }) {
                    Label("Speak English", systemImage: "speaker.wave.2")
                }
                
                if isBookmarked {
                    Button(role: .destructive, action: { onDeleteBookmark?() }) {
                        Label("Remove Bookmark", systemImage: "bookmark.slash")
                    }
                } else {
                    Button {
                        NotificationCenter.default.post(
                            name: NSNotification.Name("AddBookmark"), 
                            object: nil, 
                            userInfo: ["verseNumber": number]
                        )
                    } label: {
                        Label("Add Bookmark", systemImage: "bookmark")
                    }
                }
                
                Button {
                    let englishBookName = viewModel.getEnglishName(for: bookName)
                    let sourceInfo = "\(englishBookName) \(chapterNumber):\(number)"
                    UIPasteboard.general.string = "\(sourceInfo)\n\n\(text)"
                } label: {
                    Label("Copy", systemImage: "doc.on.doc")
                }
            }
        }
    }
}

struct SpanishOnlyVerseView: View {
    let number: Int
    let text: String
    let isBookmarked: Bool
    let onDeleteBookmark: (() -> Void)?
    let bookName: String
    let chapterNumber: Int
    @Environment(\.colorScheme) private var colorScheme
    @EnvironmentObject private var viewModel: BibleViewModel
    @EnvironmentObject private var ttsManager: TTSManager
    
    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Text("\(number)")
                .font(.footnote)
                .foregroundColor(colorScheme == .dark ? .nightSecondary : .secondary)
                .frame(width: 30, alignment: .trailing)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(text)
                    .fixedSize(horizontal: false, vertical: true)
                    .foregroundColor(colorScheme == .dark ? .nightText : Color(.displayP3, red: 0.1, green: 0.1, blue: 0.1, opacity: 1))
                
                // TTS controls
                HStack {
                    Button(action: {
                        ttsManager.speakSpanish(text)
                    }) {
                        Image(systemName: ttsManager.isPlaying && ttsManager.currentText == text ? "speaker.wave.2.fill" : "speaker.wave.2")
                            .foregroundColor(.deepPurple)
                            .font(.caption)
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    if ttsManager.isPlaying && ttsManager.currentText == text {
                        Button(action: {
                            if ttsManager.isPaused {
                                ttsManager.resume()
                            } else {
                                ttsManager.pause()
                            }
                        }) {
                            Image(systemName: ttsManager.isPaused ? "play.fill" : "pause.fill")
                                .foregroundColor(.deepPurple)
                                .font(.caption)
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        Button(action: {
                            ttsManager.stop()
                        }) {
                            Image(systemName: "stop.fill")
                                .foregroundColor(.deepPurple)
                                .font(.caption)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    
                    Spacer()
                }
                .padding(.top, 2)
            }
            .padding(8)
            .background(isBookmarked ? (colorScheme == .dark ? Color.white.opacity(0.1) : Color.secondary.opacity(0.15)) : Color.clear)
            .cornerRadius(8)
            .contextMenu {
                Button(action: {
                    ttsManager.speakSpanish(text)
                }) {
                    Label("Speak Spanish", systemImage: "speaker.wave.2")
                }
                
                if isBookmarked {
                    Button(role: .destructive, action: { onDeleteBookmark?() }) {
                        Label("Remove Bookmark", systemImage: "bookmark.slash")
                    }
                } else {
                    Button {
                        NotificationCenter.default.post(
                            name: NSNotification.Name("AddBookmark"), 
                            object: nil, 
                            userInfo: ["verseNumber": number]
                        )
                    } label: {
                        Label("Add Bookmark", systemImage: "bookmark")
                    }
                }
                
                Button {
                    let englishBookName = viewModel.getEnglishName(for: bookName)
                    let sourceInfo = "\(englishBookName) \(chapterNumber):\(number)"
                    UIPasteboard.general.string = "\(sourceInfo)\n\n\(text)"
                } label: {
                    Label("Copy", systemImage: "doc.on.doc")
                }
            }
        }
    }
}

struct BilingualVerseView: View {
    let number: Int
    let primaryText: String
    let secondaryText: String
    let isBookmarked: Bool
    let onDeleteBookmark: (() -> Void)?
    let bookName: String
    let chapterNumber: Int
    let displayMode: DisplayMode
    @Environment(\.colorScheme) private var colorScheme
    @EnvironmentObject private var viewModel: BibleViewModel
    @EnvironmentObject private var ttsManager: TTSManager
    
    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Text("\(number)")
                .font(.footnote)
                .foregroundColor(colorScheme == .dark ? .nightSecondary : .secondary)
                .frame(width: 30, alignment: .trailing)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(primaryText)
                    .fixedSize(horizontal: false, vertical: true)
                    .foregroundColor(colorScheme == .dark ? .nightText : Color(.displayP3, red: 0.1, green: 0.1, blue: 0.1, opacity: 1))
                Text(secondaryText)
                    .italic()
                    .foregroundColor(colorScheme == .dark ? .nightSecondary : Color(.displayP3, red: 0.3, green: 0.3, blue: 0.3, opacity: 1))
                    .fixedSize(horizontal: false, vertical: true)
                
                // TTS controls for bilingual views
                HStack {
                    // Primary text audio button
                    Button(action: {
                        let primaryLanguage = displayMode.primaryLanguage
                        ttsManager.speak(text: primaryText, language: primaryLanguage)
                    }) {
                        Image(systemName: ttsManager.isPlaying && ttsManager.currentText == primaryText ? "speaker.wave.2.fill" : "speaker.wave.2")
                            .foregroundColor(.deepPurple)
                            .font(.caption)
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    // Secondary text audio button
                    if let secondaryLanguage = displayMode.secondaryLanguage {
                        Button(action: {
                            ttsManager.speak(text: secondaryText, language: secondaryLanguage)
                        }) {
                            Image(systemName: ttsManager.isPlaying && ttsManager.currentText == secondaryText ? "speaker.wave.1.fill" : "speaker.wave.1")
                                .foregroundColor(.deepPurple.opacity(0.7))
                                .font(.caption)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    
                    // Playback controls when active
                    if ttsManager.isPlaying && (ttsManager.currentText == primaryText || ttsManager.currentText == secondaryText) {
                        Button(action: {
                            if ttsManager.isPaused {
                                ttsManager.resume()
                            } else {
                                ttsManager.pause()
                            }
                        }) {
                            Image(systemName: ttsManager.isPaused ? "play.fill" : "pause.fill")
                                .foregroundColor(.deepPurple)
                                .font(.caption)
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        Button(action: {
                            ttsManager.stop()
                        }) {
                            Image(systemName: "stop.fill")
                                .foregroundColor(.deepPurple)
                                .font(.caption)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    
                    Spacer()
                }
                .padding(.top, 2)
            }
            .padding(8)
            .background(isBookmarked ? (colorScheme == .dark ? Color.white.opacity(0.1) : Color.secondary.opacity(0.15)) : Color.clear)
            .cornerRadius(8)
            .contextMenu {
                Button(action: {
                    let primaryLanguage = displayMode.primaryLanguage
                    ttsManager.speak(text: primaryText, language: primaryLanguage)
                }) {
                    Label("Speak \(displayMode.primaryLanguage.displayName)", systemImage: "speaker.wave.2")
                }
                
                if let secondaryLanguage = displayMode.secondaryLanguage {
                    Button(action: {
                        ttsManager.speak(text: secondaryText, language: secondaryLanguage)
                    }) {
                        Label("Speak \(secondaryLanguage.displayName)", systemImage: "speaker.wave.1")
                    }
                }
                
                if isBookmarked {
                    Button(role: .destructive, action: { onDeleteBookmark?() }) {
                        Label("Remove Bookmark", systemImage: "bookmark.slash")
                    }
                } else {
                    Button {
                        NotificationCenter.default.post(
                            name: NSNotification.Name("AddBookmark"), 
                            object: nil, 
                            userInfo: ["verseNumber": number]
                        )
                    } label: {
                        Label("Add Bookmark", systemImage: "bookmark")
                    }
                }
                
                Button {
                    let englishBookName = viewModel.getEnglishName(for: bookName)
                    let sourceInfo = "\(englishBookName) \(chapterNumber):\(number)"
                    UIPasteboard.general.string = "\(sourceInfo)\n\n\(primaryText)\n\n\(secondaryText)"
                } label: {
                    Label("Copy", systemImage: "doc.on.doc")
                }
            }
        }
    }
}

struct VerseView: View {
    let verse: Verse
    let displayMode: DisplayMode
    let bookName: String
    let chapterNumber: Int
    @State private var showingBookmarkSheet = false
    @EnvironmentObject private var bookmarkStore: BookmarkStore
    @EnvironmentObject private var viewModel: BibleViewModel
    
    var body: some View {
        Group {
            switch displayMode {
            case .latinOnly:
                LatinOnlyVerseView(
                    number: verse.number,
                    text: verse.latinText,
                    isBookmarked: isBookmarked,
                    onDeleteBookmark: deleteBookmark,
                    bookName: bookName,
                    chapterNumber: chapterNumber
                )
            case .englishOnly:
                EnglishOnlyVerseView(
                    number: verse.number,
                    text: verse.englishText,
                    isBookmarked: isBookmarked,
                    onDeleteBookmark: deleteBookmark,
                    bookName: bookName,
                    chapterNumber: chapterNumber
                )
            case .spanishOnly:
                SpanishOnlyVerseView(
                    number: verse.number,
                    text: verse.spanishText,
                    isBookmarked: isBookmarked,
                    onDeleteBookmark: deleteBookmark,
                    bookName: bookName,
                    chapterNumber: chapterNumber
                )
            case .latinEnglish:
                BilingualVerseView(
                    number: verse.number,
                    primaryText: verse.latinText,
                    secondaryText: verse.englishText,
                    isBookmarked: isBookmarked,
                    onDeleteBookmark: deleteBookmark,
                    bookName: bookName,
                    chapterNumber: chapterNumber,
                    displayMode: displayMode
                )
            case .latinSpanish:
                BilingualVerseView(
                    number: verse.number,
                    primaryText: verse.latinText,
                    secondaryText: verse.spanishText,
                    isBookmarked: isBookmarked,
                    onDeleteBookmark: deleteBookmark,
                    bookName: bookName,
                    chapterNumber: chapterNumber,
                    displayMode: displayMode
                )
            case .englishSpanish:
                BilingualVerseView(
                    number: verse.number,
                    primaryText: verse.englishText,
                    secondaryText: verse.spanishText,
                    isBookmarked: isBookmarked,
                    onDeleteBookmark: deleteBookmark,
                    bookName: bookName,
                    chapterNumber: chapterNumber,
                    displayMode: displayMode
                )
            }
        }
        .onLongPressGesture {
            if !isBookmarked {
                showingBookmarkSheet = true
            }
        }
        .sheet(isPresented: $showingBookmarkSheet) {
            BookmarkCreationView(
                verse: verse,
                bookName: bookName,
                chapterNumber: chapterNumber
            )
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("AddBookmark"))) { notification in
            if !isBookmarked {
                if let userInfo = notification.userInfo,
                   let notificationVerseNumber = userInfo["verseNumber"] as? Int,
                   notificationVerseNumber == verse.number {
                    showingBookmarkSheet = true
                }
            }
        }
    }
    
    private var isBookmarked: Bool {
        bookmarkStore.isVerseBookmarked(
            bookName: bookName,
            chapterNumber: chapterNumber,
            verseNumber: verse.number
        )
    }
    
    private func deleteBookmark() {
        if let bookmark = bookmarkStore.getBookmark(
            bookName: bookName,
            chapterNumber: chapterNumber,
            verseNumber: verse.number
        ) {
            bookmarkStore.removeBookmark(withId: bookmark.id)
        }
    }
} 