//
//  SpeedReaderHubView.swift
//  AquinasAI - Latin-English Bible
//
//  Hub view for selecting content to speed read
//

import SwiftUI

struct SpeedReaderHubView: View {
    @EnvironmentObject var viewModel: BibleViewModel
    @EnvironmentObject var prayerStore: PrayerStore
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme

    @State private var selectedContentType: SpeedReaderContentType = .bible
    @State private var showingSpeedReader = false
    @State private var selectedBook: Book?
    @State private var selectedChapter: Chapter?
    @State private var selectedPrayer: Prayer?

    var body: some View {
        NavigationStack {
            ZStack {
                // Background
                backgroundColor
                    .ignoresSafeArea()

                // Content
                ScrollView {
                    VStack(spacing: 24) {
                        // Hero header
                        heroHeader

                        // Content type picker
                        contentTypePicker

                        // Content selection based on type
                        contentSelection
                    }
                    .padding()
                }
            }
            .navigationTitle("Speed Reader")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
            .fullScreenCover(isPresented: $showingSpeedReader) {
                if let book = selectedBook, let chapter = selectedChapter {
                    SpeedReaderView(book: book, chapter: chapter)
                } else if let prayer = selectedPrayer {
                    SpeedReaderView(prayer: prayer)
                }
            }
        }
    }

    private var backgroundColor: Color {
        colorScheme == .dark ? Color(red: 28/255, green: 28/255, blue: 30/255) : Color(red: 242/255, green: 238/255, blue: 228/255)
    }

    // MARK: - Hero Header

    private var heroHeader: some View {
        VStack(spacing: 12) {
            Image(systemName: "text.viewfinder")
                .font(.system(size: 50))
                .foregroundColor(.deepPurple)

            Text("RSVP Speed Reader")
                .font(.title2.bold())
                .foregroundColor(colorScheme == .dark ? .nightText : .black)

            Text("Read Scripture and prayers at your own pace using Rapid Serial Visual Presentation. Focus on the highlighted letter to train your reading speed.")
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .padding(.vertical)
    }

    // MARK: - Content Type Picker

    private var contentTypePicker: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(SpeedReaderContentType.allCases) { type in
                    ContentTypeButton(
                        type: type,
                        isSelected: selectedContentType == type,
                        action: { selectedContentType = type }
                    )
                }
            }
            .padding(.horizontal, 4)
        }
    }

    // MARK: - Content Selection

    @ViewBuilder
    private var contentSelection: some View {
        switch selectedContentType {
        case .bible:
            bibleSelection
        case .prayers:
            prayerSelection(category: .basic)
        case .rosary:
            prayerSelection(category: .rosary)
        case .divineMercy:
            prayerSelection(category: .divine)
        case .mass:
            prayerSelection(category: .mass)
        case .angelus:
            prayerSelection(category: .basic)  // Angelus is in the basic prayers
        case .liturgyOfHours:
            prayerSelection(category: .hours)
        }
    }

    // MARK: - Bible Selection

    private var bibleSelection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Select a Book")
                .font(.headline)
                .foregroundColor(colorScheme == .dark ? .nightText : .black)

            LazyVStack(spacing: 8) {
                ForEach(viewModel.books) { book in
                    DisclosureGroup {
                        LazyVStack(spacing: 4) {
                            ForEach(book.chapters) { chapter in
                                Button {
                                    selectedBook = book
                                    selectedChapter = chapter
                                    showingSpeedReader = true
                                } label: {
                                    HStack {
                                        Text("Chapter \(chapter.number)")
                                            .font(.subheadline)
                                            .foregroundColor(.primary)

                                        Spacer()

                                        Text("\(chapter.verses.count) verses")
                                            .font(.caption)
                                            .foregroundColor(.secondary)

                                        Image(systemName: "play.circle.fill")
                                            .foregroundColor(.deepPurple)
                                    }
                                    .padding(.vertical, 8)
                                    .padding(.horizontal, 12)
                                    .background(Color.gray.opacity(0.1))
                                    .cornerRadius(8)
                                }
                            }
                        }
                        .padding(.leading, 8)
                    } label: {
                        HStack {
                            Image(systemName: "book.fill")
                                .foregroundColor(.deepPurple)

                            Text(book.displayName)
                                .font(.headline)
                                .foregroundColor(.primary)

                            Spacer()

                            Text("\(book.chapters.count) chapters")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding(.vertical, 4)
                    }
                    .tint(.deepPurple)
                }
            }
        }
    }

    // MARK: - Prayer Selection

    private func prayerSelection(category: PrayerCategory) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Select a Prayer")
                .font(.headline)
                .foregroundColor(colorScheme == .dark ? .nightText : .black)

            let prayers = prayerStore.getPrayers(for: category)

            if prayers.isEmpty {
                Text("No prayers available in this category.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .padding()
            } else {
                LazyVStack(spacing: 8) {
                    ForEach(prayers, id: \.id) { prayer in
                        Button {
                            selectedPrayer = prayer
                            showingSpeedReader = true
                        } label: {
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(prayer.displayTitleLatin)
                                        .font(.headline)
                                        .foregroundColor(.primary)

                                    Text(prayer.displayTitleEnglish)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }

                                Spacer()

                                Image(systemName: "play.circle.fill")
                                    .font(.title2)
                                    .foregroundColor(.deepPurple)
                            }
                            .padding()
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(12)
                        }
                    }
                }
            }
        }
    }
}

// MARK: - Content Type Button

struct ContentTypeButton: View {
    let type: SpeedReaderContentType
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: type.icon)
                    .font(.title2)

                Text(type.rawValue)
                    .font(.caption)
                    .lineLimit(1)
            }
            .frame(width: 80, height: 70)
            .foregroundColor(isSelected ? .white : type.color)
            .background(isSelected ? type.color : type.color.opacity(0.15))
            .cornerRadius(12)
        }
    }
}

// MARK: - Tips View

struct SpeedReaderTipsView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Tips for Speed Reading")
                .font(.headline)

            TipRow(icon: "eye.fill", text: "Focus on the red letter (ORP)")
            TipRow(icon: "gauge.low", text: "Start slow (150 WPM), increase gradually")
            TipRow(icon: "hand.draw.fill", text: "Swipe to skip, tap to pause")
            TipRow(icon: "globe", text: "Switch languages anytime")
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
    }
}

struct TipRow: View {
    let icon: String
    let text: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(.deepPurple)
                .frame(width: 24)

            Text(text)
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}

// MARK: - Preview

#Preview {
    SpeedReaderHubView()
        .environmentObject(BibleViewModel())
        .environmentObject(PrayerStore())
}
