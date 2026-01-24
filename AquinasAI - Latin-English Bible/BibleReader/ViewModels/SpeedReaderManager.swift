//
//  SpeedReaderManager.swift
//  AquinasAI - Latin-English Bible
//
//  Manager for controlling speed reading playback with timer-based word display
//

import Foundation
import SwiftUI
import Combine

/// Manages the speed reading session including playback, timing, and word navigation
@MainActor
class SpeedReaderManager: ObservableObject {
    // MARK: - Published Properties

    @Published var currentWordIndex: Int = 0
    @Published var isPlaying: Bool = false
    @Published var words: [SpeedReaderWord] = []
    @Published var items: [SpeedReaderItem] = []

    // MARK: - Content Properties

    @Published var contentTitle: String? = nil
    @Published var contentType: SpeedReaderContentType? = nil
    @Published var currentLanguage: Language = .latin

    // MARK: - Chapter/Book Support

    @Published var chapters: [SpeedReaderChapterMarker] = []
    @Published var verseMarkers: [SpeedReaderVerseMarker] = []
    @Published var currentBook: Book? = nil

    // MARK: - Settings (Persisted)

    @AppStorage("speedReaderWPM") var wpm: Int = 200
    @AppStorage("speedReaderAutoPause") var autoPauseOnPunctuation: Bool = true
    @AppStorage("speedReaderLanguage") private var savedLanguage: String = "latin"

    // MARK: - Private Properties

    private var timer: Timer?
    private var progressKey: String? = nil

    // MARK: - Computed Properties

    /// Current word being displayed
    var currentWord: SpeedReaderWord? {
        guard currentWordIndex >= 0 && currentWordIndex < words.count else { return nil }
        return words[currentWordIndex]
    }

    /// Current item being displayed
    var currentItem: SpeedReaderItem? {
        guard currentWordIndex >= 0 && currentWordIndex < items.count else { return nil }
        return items[currentWordIndex]
    }

    /// Milliseconds per word based on WPM setting
    var msPerWord: Double {
        60000.0 / Double(wpm)
    }

    /// Progress through the text (0.0 to 1.0)
    var progress: Double {
        guard !words.isEmpty else { return 0 }
        return Double(currentWordIndex) / Double(words.count - 1)
    }

    /// Total word count
    var totalWords: Int {
        words.count
    }

    /// Estimated time remaining in seconds
    var estimatedTimeRemaining: Int {
        let remainingWords = words.count - currentWordIndex
        return Int(Double(remainingWords) * msPerWord / 1000)
    }

    /// Check if at the beginning
    var isAtStart: Bool {
        currentWordIndex == 0
    }

    /// Check if at the end
    var isAtEnd: Bool {
        currentWordIndex >= words.count - 1
    }

    /// Current chapter based on word position
    var currentChapter: SpeedReaderChapterMarker? {
        chapters.last { $0.startIndex <= currentWordIndex }
    }

    /// Current chapter index
    var currentChapterIndex: Int {
        guard let chapter = currentChapter else { return 0 }
        return chapters.firstIndex(where: { $0.id == chapter.id }) ?? 0
    }

    /// Progress within current chapter (0.0 to 1.0)
    var chapterProgress: Double {
        guard let chapter = currentChapter else { return 0 }
        let chapterStart = chapter.startIndex
        let chapterEnd = chapters.first(where: { $0.startIndex > chapter.startIndex })?.startIndex ?? words.count
        let chapterLength = chapterEnd - chapterStart
        guard chapterLength > 0 else { return 0 }
        return Double(currentWordIndex - chapterStart) / Double(chapterLength)
    }

    /// Whether we're reading content with chapters
    var hasChapters: Bool {
        chapters.count > 1
    }

    /// Current verse number (if reading Bible)
    var currentVerseNumber: Int? {
        // Find the most recent verse marker
        guard let marker = verseMarkers.last(where: { $0.startIndex <= currentWordIndex }) else {
            return items[safe: currentWordIndex]?.verseNumber
        }
        return marker.number
    }

    // MARK: - Initialization

    init() {
        // Load saved language preference
        if let lang = Language(rawValue: savedLanguage) {
            currentLanguage = lang
        }
    }

    // MARK: - Public Methods

    /// Load text into the speed reader
    func loadText(_ text: String, title: String? = nil, type: SpeedReaderContentType? = nil) {
        words = SpeedReaderWord.parseText(text)
        items = words.map { SpeedReaderItem(text: $0.text) }
        currentWordIndex = 0
        isPlaying = false
        timer?.invalidate()
        contentTitle = title
        contentType = type
        chapters = []
        verseMarkers = []
        progressKey = nil
    }

    /// Load a Bible chapter for speed reading
    func loadBibleChapter(_ book: Book, chapter: Chapter) {
        currentBook = book
        contentTitle = "\(book.displayName) \(chapter.number)"
        contentType = .bible

        let chapterItems = book.toSpeedReaderItems(chapter: chapter, language: currentLanguage)
        items = chapterItems
        words = chapterItems.map { SpeedReaderWord(text: $0.text) }

        // Create verse markers
        var markers: [SpeedReaderVerseMarker] = []
        var currentIndex = 0
        for verse in chapter.verses {
            let verseText = verse.text(for: currentLanguage)
            let wordCount = verseText.components(separatedBy: .whitespaces).filter { !$0.isEmpty }.count
            markers.append(SpeedReaderVerseMarker(
                id: "\(book.name)_\(chapter.number)_\(verse.number)",
                number: verse.number,
                chapterNumber: chapter.number,
                startIndex: currentIndex,
                wordCount: wordCount
            ))
            currentIndex += wordCount
        }
        verseMarkers = markers

        // Create single chapter marker
        chapters = [SpeedReaderChapterMarker(
            id: "\(book.name)_\(chapter.number)",
            number: chapter.number,
            bookName: book.name,
            startIndex: 0,
            wordCount: words.count
        )]

        // Set progress key and restore position
        progressKey = SpeedReaderProgressKey.forChapter(book: book.name, chapter: chapter.number)
        restoreProgress()

        isPlaying = false
        timer?.invalidate()
    }

    /// Load an entire book for continuous reading
    func loadBook(_ book: Book, startingChapter: Int = 1) {
        currentBook = book
        contentTitle = book.displayName
        contentType = .bible

        var allItems: [SpeedReaderItem] = []
        var chapterMarkers: [SpeedReaderChapterMarker] = []
        var allVerseMarkers: [SpeedReaderVerseMarker] = []

        for chapter in book.chapters {
            let chapterStartIndex = allItems.count
            let chapterItems = book.toSpeedReaderItems(chapter: chapter, language: currentLanguage)

            // Create verse markers for this chapter
            var verseStartIndex = chapterStartIndex
            for verse in chapter.verses {
                let verseText = verse.text(for: currentLanguage)
                let wordCount = verseText.components(separatedBy: .whitespaces).filter { !$0.isEmpty }.count
                allVerseMarkers.append(SpeedReaderVerseMarker(
                    id: "\(book.name)_\(chapter.number)_\(verse.number)",
                    number: verse.number,
                    chapterNumber: chapter.number,
                    startIndex: verseStartIndex,
                    wordCount: wordCount
                ))
                verseStartIndex += wordCount
            }

            allItems.append(contentsOf: chapterItems)

            chapterMarkers.append(SpeedReaderChapterMarker(
                id: "\(book.name)_\(chapter.number)",
                number: chapter.number,
                bookName: book.name,
                startIndex: chapterStartIndex,
                wordCount: chapterItems.count
            ))
        }

        items = allItems
        words = allItems.map { SpeedReaderWord(text: $0.text) }
        chapters = chapterMarkers
        verseMarkers = allVerseMarkers

        // Start at the specified chapter
        if startingChapter > 1, let chapterIndex = chapters.firstIndex(where: { $0.number == startingChapter }) {
            currentWordIndex = chapters[chapterIndex].startIndex
        } else {
            currentWordIndex = 0
        }

        isPlaying = false
        timer?.invalidate()
    }

    /// Load a prayer for speed reading
    func loadPrayer(_ prayer: Prayer) {
        contentTitle = prayer.displayTitleLatin
        contentType = .prayers

        let prayerItems = prayer.toSpeedReaderItems(language: currentLanguage)
        items = prayerItems
        words = prayerItems.map { SpeedReaderWord(text: $0.text) }

        chapters = []
        verseMarkers = []

        // Set progress key and restore position
        progressKey = SpeedReaderProgressKey.forPrayer(id: prayer.id)
        restoreProgress()

        isPlaying = false
        timer?.invalidate()
    }

    /// Load multiple prayers for speed reading
    func loadPrayers(_ prayers: [Prayer], title: String, type: SpeedReaderContentType) {
        contentTitle = title
        contentType = type

        let prayerItems = prayers.toSpeedReaderItems(language: currentLanguage)
        items = prayerItems
        words = prayerItems.map { SpeedReaderWord(text: $0.text) }

        chapters = []
        verseMarkers = []
        progressKey = nil

        currentWordIndex = 0
        isPlaying = false
        timer?.invalidate()
    }

    /// Set the reading language
    func setLanguage(_ language: Language) {
        currentLanguage = language
        savedLanguage = language.rawValue

        // Reload current content if any
        if let book = currentBook, let chapter = currentChapter {
            if hasChapters {
                loadBook(book, startingChapter: chapter.number)
            } else if let chapterObj = book.chapters.first(where: { $0.number == chapter.number }) {
                loadBibleChapter(book, chapter: chapterObj)
            }
        }
    }

    /// Jump to a specific chapter
    func jumpToChapter(_ index: Int) {
        guard index >= 0 && index < chapters.count else { return }
        currentWordIndex = chapters[index].startIndex
    }

    /// Jump to next chapter
    func nextChapter() {
        let nextIndex = currentChapterIndex + 1
        if nextIndex < chapters.count {
            jumpToChapter(nextIndex)
        }
    }

    /// Jump to previous chapter
    func previousChapter() {
        // If we're more than 5% into a chapter, go to start of current chapter
        // Otherwise go to previous chapter
        if chapterProgress > 0.05 {
            jumpToChapter(currentChapterIndex)
        } else {
            let prevIndex = currentChapterIndex - 1
            if prevIndex >= 0 {
                jumpToChapter(prevIndex)
            }
        }
    }

    /// Start or resume playback
    func play() {
        guard !words.isEmpty && currentWordIndex < words.count else { return }
        isPlaying = true
        scheduleNextWord()
    }

    /// Pause playback
    func pause() {
        isPlaying = false
        timer?.invalidate()
        timer = nil
        saveProgress()
    }

    /// Toggle between play and pause
    func togglePlayPause() {
        if isPlaying {
            pause()
        } else {
            play()
        }
    }

    /// Go to the next word
    func nextWord() {
        guard currentWordIndex < words.count - 1 else {
            pause()
            return
        }
        currentWordIndex += 1

        if isPlaying {
            scheduleNextWord()
        }
    }

    /// Go to the previous word
    func previousWord() {
        guard currentWordIndex > 0 else { return }
        currentWordIndex -= 1
    }

    /// Skip forward by a number of words
    func skipForward(_ count: Int = 10) {
        currentWordIndex = min(currentWordIndex + count, words.count - 1)
    }

    /// Skip backward by a number of words
    func skipBackward(_ count: Int = 10) {
        currentWordIndex = max(currentWordIndex - count, 0)
    }

    /// Jump to a specific position (0.0 to 1.0)
    func seekTo(progress: Double) {
        let index = Int(Double(words.count - 1) * progress)
        currentWordIndex = max(0, min(index, words.count - 1))
    }

    /// Reset to the beginning
    func reset() {
        pause()
        currentWordIndex = 0
    }

    /// Set WPM with bounds checking
    func setWPM(_ newWPM: Int) {
        wpm = max(10, min(newWPM, 999))

        // If playing, restart timer with new speed
        if isPlaying {
            timer?.invalidate()
            scheduleNextWord()
        }
    }

    // MARK: - Private Methods

    private func scheduleNextWord() {
        timer?.invalidate()

        var delay = msPerWord / 1000.0

        // Add extra pause for punctuation if enabled
        if autoPauseOnPunctuation, let word = currentWord {
            if word.text.hasSuffix(".") || word.text.hasSuffix("!") || word.text.hasSuffix("?") {
                delay *= 2.5 // Longer pause for sentence endings
            } else if word.text.hasSuffix(",") || word.text.hasSuffix(";") || word.text.hasSuffix(":") {
                delay *= 1.5 // Medium pause for commas
            }
        }

        timer = Timer.scheduledTimer(withTimeInterval: delay, repeats: false) { [weak self] _ in
            Task { @MainActor in
                self?.nextWord()
            }
        }
    }

    private func saveProgress() {
        guard let key = progressKey else { return }
        UserDefaults.standard.set(currentWordIndex, forKey: key)
    }

    private func restoreProgress() {
        guard let key = progressKey else { return }
        let savedIndex = UserDefaults.standard.integer(forKey: key)
        if savedIndex > 0 && savedIndex < words.count {
            currentWordIndex = savedIndex
        } else {
            currentWordIndex = 0
        }
    }
}

// MARK: - WPM Presets

extension SpeedReaderManager {
    enum WPMPreset: Int, CaseIterable {
        case slow = 150
        case normal = 250
        case fast = 350
        case turbo = 500

        var displayName: String {
            switch self {
            case .slow: return "Slow"
            case .normal: return "Normal"
            case .fast: return "Fast"
            case .turbo: return "Turbo"
            }
        }

        var icon: String {
            switch self {
            case .slow: return "tortoise.fill"
            case .normal: return "figure.walk"
            case .fast: return "hare.fill"
            case .turbo: return "bolt.fill"
            }
        }
    }

    func applyPreset(_ preset: WPMPreset) {
        setWPM(preset.rawValue)
    }
}

// MARK: - Array Safe Subscript

private extension Array {
    subscript(safe index: Int) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
