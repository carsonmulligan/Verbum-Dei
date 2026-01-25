//
//  SpeedReaderView.swift
//  AquinasAI - Latin-English Bible
//
//  RSVP Speed Reading view with ORP (Optimal Recognition Point) highlighting
//  Displays one word at a time with the focus letter highlighted
//

import SwiftUI

struct SpeedReaderView: View {
    @StateObject private var manager = SpeedReaderManager()
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme

    @State private var showControls: Bool = true
    @State private var controlsTimer: Timer?
    @State private var showChapterPicker: Bool = false
    @State private var showWPMInput: Bool = false
    @State private var wpmInputText: String = ""
    @State private var showLanguagePicker: Bool = false

    // Content to load
    let book: Book?
    let chapter: Chapter?
    let prayer: Prayer?
    let text: String?
    let title: String?
    let allBooks: [Book]?
    let rosaryPrayers: [String: Prayer]?
    let mysterySet: String?
    let mysteries: [RosaryMystery]?

    // MARK: - Initializers

    /// Initialize with a Bible chapter
    init(book: Book, chapter: Chapter, allBooks: [Book]? = nil) {
        self.book = book
        self.chapter = chapter
        self.prayer = nil
        self.text = nil
        self.title = nil
        self.allBooks = allBooks
        self.rosaryPrayers = nil
        self.mysterySet = nil
        self.mysteries = nil
    }

    /// Initialize with a prayer
    init(prayer: Prayer) {
        self.book = nil
        self.chapter = nil
        self.prayer = prayer
        self.text = nil
        self.title = nil
        self.allBooks = nil
        self.rosaryPrayers = nil
        self.mysterySet = nil
        self.mysteries = nil
    }

    /// Initialize with plain text
    init(text: String, title: String? = nil) {
        self.book = nil
        self.chapter = nil
        self.prayer = nil
        self.text = text
        self.title = title
        self.allBooks = nil
        self.rosaryPrayers = nil
        self.mysterySet = nil
        self.mysteries = nil
    }

    /// Initialize with Rosary
    init(rosaryPrayers: [String: Prayer], mysterySet: String, mysteries: [RosaryMystery]) {
        self.book = nil
        self.chapter = nil
        self.prayer = nil
        self.text = nil
        self.title = nil
        self.allBooks = nil
        self.rosaryPrayers = rosaryPrayers
        self.mysterySet = mysterySet
        self.mysteries = mysteries
    }

    var body: some View {
        ZStack {
            // Background
            backgroundColor
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // Top bar with title and progress
                topBar

                Spacer()

                // Main word display
                wordDisplayArea
                    .contentShape(Rectangle())
                    .onTapGesture {
                        if !showControls {
                            // Controls hidden - always pause and show controls
                            if manager.isPlaying {
                                manager.pause()
                            }
                            withAnimation(.easeInOut(duration: 0.2)) {
                                showControls = true
                            }
                        } else if !manager.isPlaying {
                            // Controls visible and paused - tap to play
                            manager.play()
                        } else {
                            // Controls visible and playing - tap to pause
                            manager.pause()
                        }
                    }
                    .simultaneousGesture(swipeGesture)

                Spacer()

                // Bottom controls
                if showControls {
                    bottomControls
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }

            // Persistent close button (always visible)
            VStack {
                HStack {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title2)
                            .foregroundColor(.white)
                            .background(
                                Circle()
                                    .fill(Color.black.opacity(0.5))
                                    .frame(width: 32, height: 32)
                            )
                    }
                    .padding(.leading, 16)
                    .padding(.top, 8)

                    Spacer()
                }

                Spacer()
            }
        }
        .onAppear {
            print("SpeedReaderView: onAppear called")
            print("SpeedReaderView: book=\(book?.name ?? "nil"), chapter=\(chapter?.number ?? -1)")
            loadContent()
            print("SpeedReaderView: After loadContent, words=\(manager.words.count)")
        }
        .onDisappear {
            manager.pause()
        }
        .onChange(of: manager.isPlaying) { oldValue, newValue in
            // Auto-hide controls after 3 seconds when playback starts
            if newValue {
                controlsTimer?.invalidate()
                controlsTimer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: false) { _ in
                    withAnimation(.easeInOut(duration: 0.3)) {
                        showControls = false
                    }
                }
            }
        }
        .sheet(isPresented: $showChapterPicker) {
            SpeedReaderChapterPickerSheet(manager: manager) {
                showChapterPicker = false
            }
        }
        .sheet(isPresented: $showLanguagePicker) {
            SpeedReaderLanguagePickerSheet(manager: manager) {
                showLanguagePicker = false
            }
        }
        .alert("Set WPM", isPresented: $showWPMInput) {
            TextField("WPM (10-999)", text: $wpmInputText)
            Button("Cancel", role: .cancel) {}
            Button("Set") {
                if let newWPM = Int(wpmInputText) {
                    manager.setWPM(newWPM)
                }
            }
        } message: {
            Text("Enter reading speed (10-999 words per minute)")
        }
    }

    // MARK: - Content Loading

    private func loadContent() {
        print("SpeedReaderView: loadContent called")
        print("SpeedReaderView: book=\(book?.name ?? "nil"), chapter=\(chapter?.number ?? -1)")
        print("SpeedReaderView: prayer=\(prayer?.title ?? "nil")")
        print("SpeedReaderView: text=\(text ?? "nil")")
        print("SpeedReaderView: rosary mysterySet=\(mysterySet ?? "nil")")

        if let book = book, let chapter = chapter {
            print("SpeedReaderView: Loading Bible chapter...")
            manager.allBooks = allBooks ?? []
            manager.loadBibleChapter(book, chapter: chapter)
            print("SpeedReaderView: After load - words count: \(manager.words.count)")
        } else if let rosaryPrayers = rosaryPrayers, let mysterySet = mysterySet, let mysteries = mysteries {
            print("SpeedReaderView: Loading full Rosary...")
            manager.loadRosary(prayers: rosaryPrayers, mysterySet: mysterySet, mysteries: mysteries)
            print("SpeedReaderView: After load - words count: \(manager.words.count)")
        } else if let prayer = prayer {
            print("SpeedReaderView: Loading prayer...")
            manager.loadPrayer(prayer)
            print("SpeedReaderView: After load - words count: \(manager.words.count)")
        } else if let text = text {
            print("SpeedReaderView: Loading text...")
            manager.loadText(text, title: title)
            print("SpeedReaderView: After load - words count: \(manager.words.count)")
        } else {
            print("SpeedReaderView: No content to load!")
        }
    }

    // MARK: - Background

    private var backgroundColor: Color {
        colorScheme == .dark ? Color.nightBackground : Color.paperWhite
    }

    private var textColor: Color {
        colorScheme == .dark ? Color.nightText : Color.black
    }

    // MARK: - Top Bar

    @ViewBuilder
    private var topBar: some View {
        if showControls {
            VStack(spacing: 8) {
                // Top row: word counter and hide button
                HStack {
                    // Spacer for X button
                    Spacer()
                        .frame(width: 50)

                    // Word counter
                    Text("\(manager.currentWordIndex + 1) / \(manager.totalWords)")
                        .font(.caption.monospacedDigit())
                        .foregroundColor(.secondary)

                    Spacer()

                    // Hide controls button
                    Button {
                        controlsTimer?.invalidate()
                        withAnimation(.easeInOut(duration: 0.3)) {
                            showControls = false
                        }
                    } label: {
                        Image(systemName: "eye.slash.fill")
                            .font(.title2)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.horizontal)
                .padding(.top, 8)

                // Center: Title and chapter/verse/rosary info
                VStack(spacing: 2) {
                    if let title = manager.contentTitle {
                        Text(title)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                    }

                    // Current verse (if Bible mode)
                    if manager.contentType == .bible, let verseNum = manager.currentVerseNumber {
                        Text("Verse \(verseNum)")
                            .font(.caption2)
                            .foregroundColor(.deepPurple)
                            .lineLimit(1)
                    }

                    // Current rosary position (if Rosary mode)
                    if manager.contentType == .rosary, let marker = manager.currentRosaryMarker {
                        if let mysteryName = marker.mysteryName {
                            Text(mysteryName)
                                .font(.caption2)
                                .foregroundColor(.deepPurple)
                                .lineLimit(1)
                        }
                        if let prayerType = marker.prayerType {
                            Text(prayerType)
                                .font(.caption2)
                                .foregroundColor(.secondary)
                                .lineLimit(1)
                        }
                    }
                }

                // Progress bar
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Rectangle()
                            .fill(Color.gray.opacity(0.2))
                            .frame(height: 3)

                        Rectangle()
                            .fill(Color.deepPurple)
                            .frame(width: geo.size.width * manager.progress, height: 3)
                    }
                }
                .frame(height: 3)
                .padding(.horizontal)
            }
            .padding(.bottom, 8)
            .background(backgroundColor.opacity(0.95))
            .transition(.move(edge: .top).combined(with: .opacity))
        }
    }

    // MARK: - Word Display Area

    private var wordDisplayArea: some View {
        VStack(spacing: 8) {
            if manager.words.isEmpty {
                // No content loaded
                VStack(spacing: 12) {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.largeTitle)
                        .foregroundColor(.orange)
                    Text("No content loaded")
                        .font(.headline)
                        .foregroundColor(textColor)
                    Text("Words: \(manager.words.count)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    if let title = manager.contentTitle {
                        Text("Title: \(title)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            } else if let word = manager.currentWord {
                // The word with ORP highlighting (arrows included)
                WordORPDisplay(
                    word: word,
                    textColor: textColor,
                    orpColor: manager.currentItem?.orpColor ?? .deepPurple
                )
                .id(word.id) // Force redraw on word change
            } else {
                Text("Tap to start")
                    .font(.title2)
                    .foregroundColor(textColor)
            }
        }
        .frame(maxWidth: .infinity)
        .contentShape(Rectangle())
    }

    // MARK: - Bottom Controls

    private var bottomControls: some View {
        VStack(spacing: 16) {
            // Chapter navigation (if book mode with chapters)
            if manager.hasChapters {
                HStack(spacing: 20) {
                    // Previous chapter
                    Button {
                        manager.previousChapter()
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "backward.end.fill")
                            Text("Prev Ch.")
                                .font(.caption)
                        }
                        .foregroundColor(manager.currentChapterIndex > 0 ? textColor : .secondary)
                    }
                    .disabled(manager.currentChapterIndex <= 0)

                    Spacer()

                    // Chapter picker button
                    Button {
                        showChapterPicker = true
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "list.bullet")
                            Text("Ch. \(manager.currentChapterIndex + 1)/\(manager.chapters.count)")
                                .font(.caption.monospacedDigit())
                        }
                        .foregroundColor(.deepPurple)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.deepPurple.opacity(0.15))
                        .cornerRadius(8)
                    }

                    Spacer()

                    // Next chapter
                    Button {
                        manager.nextChapter()
                    } label: {
                        HStack(spacing: 4) {
                            Text("Next Ch.")
                                .font(.caption)
                            Image(systemName: "forward.end.fill")
                        }
                        .foregroundColor(manager.currentChapterIndex < manager.chapters.count - 1 ? textColor : .secondary)
                    }
                    .disabled(manager.currentChapterIndex >= manager.chapters.count - 1)
                }
                .padding(.horizontal)
            }

            // Play/Pause and navigation
            HStack(spacing: 20) {
                // Jump to beginning of chapter
                Button {
                    manager.reset()
                } label: {
                    VStack(spacing: 2) {
                        Image(systemName: "backward.end")
                            .font(.title3)
                        Text("Start")
                            .font(.caption2)
                    }
                    .foregroundColor(textColor)
                }
                .disabled(manager.isAtStart)
                .opacity(manager.isAtStart ? 0.3 : 1)

                // Skip backward
                Button {
                    manager.skipBackward()
                } label: {
                    Image(systemName: "gobackward.10")
                        .font(.title2)
                        .foregroundColor(textColor)
                }
                .disabled(manager.isAtStart)
                .opacity(manager.isAtStart ? 0.3 : 1)

                // Previous word
                Button {
                    manager.previousWord()
                } label: {
                    Image(systemName: "backward.fill")
                        .font(.title3)
                        .foregroundColor(textColor)
                }
                .disabled(manager.isAtStart)
                .opacity(manager.isAtStart ? 0.3 : 1)

                // Play/Pause
                Button {
                    manager.togglePlayPause()
                } label: {
                    Image(systemName: manager.isPlaying ? "pause.circle.fill" : "play.circle.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.deepPurple)
                }

                // Next word
                Button {
                    manager.nextWord()
                } label: {
                    Image(systemName: "forward.fill")
                        .font(.title3)
                        .foregroundColor(textColor)
                }
                .disabled(manager.isAtEnd)
                .opacity(manager.isAtEnd ? 0.3 : 1)

                // Skip forward
                Button {
                    manager.skipForward()
                } label: {
                    Image(systemName: "goforward.10")
                        .font(.title2)
                        .foregroundColor(textColor)
                }
                .disabled(manager.isAtEnd)
                .opacity(manager.isAtEnd ? 0.3 : 1)

                // Jump to end of chapter
                Button {
                    manager.jumpToEnd()
                } label: {
                    VStack(spacing: 2) {
                        Image(systemName: "forward.end")
                            .font(.title3)
                        Text("End")
                            .font(.caption2)
                    }
                    .foregroundColor(textColor)
                }
                .disabled(manager.isAtEnd)
                .opacity(manager.isAtEnd ? 0.3 : 1)
            }

            // WPM control
            VStack(spacing: 8) {
                HStack {
                    // Tappable WPM - opens custom input
                    Button {
                        wpmInputText = "\(manager.wpm)"
                        showWPMInput = true
                    } label: {
                        HStack(spacing: 4) {
                            Text("\(manager.wpm)")
                                .font(.headline.monospacedDigit())
                                .foregroundColor(textColor)
                            Text("WPM")
                                .font(.headline)
                                .foregroundColor(textColor)
                            Image(systemName: "pencil.circle.fill")
                                .font(.caption)
                                .foregroundColor(.deepPurple)
                        }
                    }

                    Spacer()

                    // Time remaining
                    Text("\(formatTime(manager.estimatedTimeRemaining)) remaining")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                // WPM Slider (10-999 range)
                Slider(
                    value: Binding(
                        get: { Double(manager.wpm) },
                        set: { manager.setWPM(Int($0)) }
                    ),
                    in: 10...999,
                    step: 10
                )
                .tint(.deepPurple)

                // WPM Presets
                HStack(spacing: 12) {
                    ForEach(SpeedReaderManager.WPMPreset.allCases, id: \.rawValue) { preset in
                        Button {
                            manager.applyPreset(preset)
                        } label: {
                            VStack(spacing: 2) {
                                Image(systemName: preset.icon)
                                    .font(.caption)
                                Text(preset.displayName)
                                    .font(.caption2)
                            }
                            .foregroundColor(manager.wpm == preset.rawValue ? .deepPurple : .secondary)
                            .padding(.vertical, 6)
                            .padding(.horizontal, 12)
                            .background(
                                manager.wpm == preset.rawValue
                                    ? Color.deepPurple.opacity(0.15)
                                    : Color.clear
                            )
                            .cornerRadius(8)
                        }
                    }
                }

                // Language selector
                Divider()
                    .padding(.vertical, 4)

                HStack {
                    Text("Language")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    Spacer()

                    Button {
                        showLanguagePicker = true
                    } label: {
                        HStack(spacing: 4) {
                            Text(manager.currentLanguage.shortCode)
                            Image(systemName: "chevron.down")
                                .font(.caption2)
                        }
                        .font(.caption)
                        .foregroundColor(.deepPurple)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(Color.deepPurple.opacity(0.15))
                        .cornerRadius(8)
                    }
                }
            }
            .padding(.horizontal)
        }
        .padding()
        .padding(.bottom, 8)
        .background(backgroundColor.opacity(0.95))
    }

    // MARK: - Gestures

    private var swipeGesture: some Gesture {
        DragGesture(minimumDistance: 50)
            .onEnded { value in
                let horizontal = value.translation.width
                let vertical = value.translation.height

                if abs(horizontal) > abs(vertical) {
                    // Horizontal swipe
                    if horizontal > 0 {
                        manager.skipBackward(5)
                    } else {
                        manager.skipForward(5)
                    }
                } else {
                    // Vertical swipe - dismiss on swipe down
                    if vertical > 0 {
                        dismiss()
                    }
                }
            }
    }

    // MARK: - Helpers

    private func showControlsTemporarily() {
        withAnimation(.easeInOut(duration: 0.2)) {
            showControls = true
        }

        controlsTimer?.invalidate()
        controlsTimer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: false) { _ in
            if manager.isPlaying {
                withAnimation(.easeInOut(duration: 0.3)) {
                    showControls = false
                }
            }
        }
    }

    private func formatTime(_ seconds: Int) -> String {
        let mins = seconds / 60
        let secs = seconds % 60
        if mins > 0 {
            return "\(mins)m \(secs)s"
        }
        return "\(secs)s"
    }
}

// MARK: - Word ORP Display Component

struct WordORPDisplay: View {
    let word: SpeedReaderWord
    let textColor: Color
    var orpColor: Color = .deepPurple

    /// Calculate uniform font size based on screen width
    private var dynamicFontSize: CGFloat {
        let screenWidth = UIScreen.main.bounds.width
        let horizontalPadding: CGFloat = 32
        let availableWidth = screenWidth - horizontalPadding

        // Monospaced character width is ~60% of font size
        // Target: fit 16 characters comfortably
        let maxCharsToFit: CGFloat = 16
        let charWidthRatio: CGFloat = 0.6

        let calculatedSize = availableWidth / (maxCharsToFit * charWidthRatio)

        // Cap at 52pt for iPads, minimum 32pt for readability
        let maxSize: CGFloat = 52
        let minSize: CGFloat = 32

        return min(maxSize, max(minSize, calculatedSize))
    }

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 0) {
            // Before ORP - right-aligned in left half
            Text(word.beforeORP)
                .font(.system(size: dynamicFontSize, weight: .medium, design: .monospaced))
                .foregroundColor(textColor)
                .fixedSize(horizontal: true, vertical: false)
                .frame(maxWidth: .infinity, alignment: .trailing)

            // ORP letter at center with arrows
            Text(word.orpLetter)
                .font(.system(size: dynamicFontSize, weight: .bold, design: .monospaced))
                .foregroundColor(orpColor)
                .overlay(alignment: .top) {
                    Image(systemName: "arrowtriangle.down.fill")
                        .font(.system(size: 16))
                        .foregroundColor(orpColor)
                        .offset(y: -24)
                }
                .overlay(alignment: .bottom) {
                    Image(systemName: "arrowtriangle.up.fill")
                        .font(.system(size: 16))
                        .foregroundColor(orpColor)
                        .offset(y: 24)
                }

            // After ORP - left-aligned in right half
            Text(word.afterORP)
                .font(.system(size: dynamicFontSize, weight: .medium, design: .monospaced))
                .foregroundColor(textColor)
                .fixedSize(horizontal: true, vertical: false)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(maxWidth: .infinity)
        .minimumScaleFactor(0.7) // Fallback for unusually long words
        .padding(.horizontal, 8)
    }
}

// MARK: - Chapter Picker Sheet

struct SpeedReaderChapterPickerSheet: View {
    @ObservedObject var manager: SpeedReaderManager
    let onSelect: () -> Void

    var body: some View {
        NavigationStack {
            List {
                ForEach(Array(manager.chapters.enumerated()), id: \.element.id) { index, chapter in
                    Button {
                        manager.jumpToChapter(index)
                        onSelect()
                    } label: {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Chapter \(chapter.number)")
                                    .font(.headline)
                                    .foregroundColor(.primary)

                                Text(chapter.bookName)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }

                            Spacer()

                            // Current chapter indicator
                            if index == manager.currentChapterIndex {
                                Image(systemName: "speaker.wave.2.fill")
                                    .foregroundColor(.deepPurple)
                            }

                            // Word count
                            Text("\(chapter.wordCount) words")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
            .navigationTitle("Chapters")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        onSelect()
                    }
                }
            }
        }
    }
}

// MARK: - Language Picker Sheet

struct SpeedReaderLanguagePickerSheet: View {
    @ObservedObject var manager: SpeedReaderManager
    let onSelect: () -> Void

    var body: some View {
        NavigationStack {
            List {
                ForEach(Language.allCases, id: \.self) { language in
                    Button {
                        manager.setLanguage(language)
                        onSelect()
                    } label: {
                        HStack {
                            Text(language.displayName)
                                .foregroundColor(.primary)

                            Spacer()

                            if manager.currentLanguage == language {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.deepPurple)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Language")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        onSelect()
                    }
                }
            }
        }
    }
}

// MARK: - Preview

#Preview {
    SpeedReaderView(
        text: "In principio creavit Deus caelum et terram. Terra autem erat inanis et vacua, et tenebrae erant super faciem abyssi.",
        title: "Genesis 1"
    )
}

#Preview("Dark Mode") {
    SpeedReaderView(
        text: "Pater noster, qui es in caelis, sanctificetur nomen tuum. Adveniat regnum tuum. Fiat voluntas tua, sicut in caelo et in terra.",
        title: "Pater Noster"
    )
    .preferredColorScheme(.dark)
}
