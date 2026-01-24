//
//  SpeedReaderContent.swift
//  AquinasAI - Latin-English Bible
//
//  Models for multi-content speed reading with Bible and prayer support
//

import Foundation
import SwiftUI

// Local color extension
private extension Color {
    static let deepPurple = Color(red: 137/255, green: 84/255, blue: 160/255)
}

// MARK: - Content Type

/// Types of content that can be speed-read
enum SpeedReaderContentType: String, CaseIterable, Identifiable {
    case bible = "Bible"
    case prayers = "Prayers"
    case rosary = "Rosary"
    case divineMercy = "Divine Mercy"
    case mass = "Order of Mass"
    case angelus = "Angelus"
    case liturgyOfHours = "Liturgy of Hours"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .bible: return "book.fill"
        case .prayers: return "hands.sparkles.fill"
        case .rosary: return "circle.grid.cross.fill"
        case .divineMercy: return "heart.fill"
        case .mass: return "building.columns.fill"
        case .angelus: return "bell.fill"
        case .liturgyOfHours: return "clock.fill"
        }
    }

    var color: Color {
        switch self {
        case .bible: return .deepPurple
        case .prayers: return .blue
        case .rosary: return .green
        case .divineMercy: return .red
        case .mass: return .orange
        case .angelus: return .yellow
        case .liturgyOfHours: return .purple
        }
    }

    var description: String {
        switch self {
        case .bible: return "Sacred Scripture in Latin, English, and Spanish"
        case .prayers: return "Traditional Catholic prayers"
        case .rosary: return "The Holy Rosary"
        case .divineMercy: return "Divine Mercy Chaplet"
        case .mass: return "Order of the Mass"
        case .angelus: return "Angelus Domini"
        case .liturgyOfHours: return "Liturgy of the Hours"
        }
    }
}

// MARK: - Speed Reader Item

/// A single item to display in the speed reader
struct SpeedReaderItem: Identifiable {
    let id = UUID()
    let text: String
    let verseNumber: Int?  // For Bible verses
    let speaker: String?   // For prayers with instructions
    let isInstruction: Bool  // True if this is an instruction, not prayer text

    init(text: String, verseNumber: Int? = nil, speaker: String? = nil, isInstruction: Bool = false) {
        self.text = text
        self.verseNumber = verseNumber
        self.speaker = speaker
        self.isInstruction = isInstruction
    }

    /// Color for the ORP letter based on content type
    var orpColor: Color {
        if isInstruction {
            return .gray
        }
        return .red  // Default for main content
    }
}

// MARK: - Chapter/Verse Marker

/// Marks a chapter's position within the speed reader word array
struct SpeedReaderChapterMarker: Identifiable {
    let id: String
    let number: Int
    let bookName: String
    let startIndex: Int
    let wordCount: Int

    /// Progress position of this chapter (0.0 to 1.0 of total content)
    func progressPosition(totalWords: Int) -> Double {
        guard totalWords > 0 else { return 0 }
        return Double(startIndex) / Double(totalWords)
    }
}

// MARK: - Verse Marker

/// Marks a verse's position within the speed reader word array
struct SpeedReaderVerseMarker: Identifiable {
    let id: String
    let number: Int
    let chapterNumber: Int
    let startIndex: Int
    let wordCount: Int
}

// MARK: - Progress Keys

/// Keys for storing reading progress
struct SpeedReaderProgressKey {
    static func forChapter(book: String, chapter: Int) -> String {
        return "speedReader_bible_\(book)_\(chapter)"
    }

    static func forPrayer(id: String) -> String {
        return "speedReader_prayer_\(id)"
    }
}

// MARK: - Content Extensions

extension Book {
    /// Convert a chapter to SpeedReaderItems for a specific language
    func toSpeedReaderItems(chapter: Chapter, language: Language) -> [SpeedReaderItem] {
        var items: [SpeedReaderItem] = []

        for verse in chapter.verses {
            let verseText = verse.text(for: language)
            let words = verseText.components(separatedBy: .whitespaces).filter { !$0.isEmpty }

            items.append(contentsOf: words.enumerated().map { index, word in
                SpeedReaderItem(
                    text: word,
                    verseNumber: index == 0 ? verse.number : nil  // Only mark first word with verse number
                )
            })
        }

        return items
    }

    /// Get all chapter markers for the book in a specific language
    func getChapterMarkers(language: Language) -> [SpeedReaderChapterMarker] {
        var markers: [SpeedReaderChapterMarker] = []
        var currentIndex = 0

        for chapter in chapters {
            let items = toSpeedReaderItems(chapter: chapter, language: language)
            markers.append(SpeedReaderChapterMarker(
                id: "\(name)_\(chapter.number)",
                number: chapter.number,
                bookName: name,
                startIndex: currentIndex,
                wordCount: items.count
            ))
            currentIndex += items.count
        }

        return markers
    }
}

extension Prayer {
    /// Convert prayer to SpeedReaderItems for a specific language
    func toSpeedReaderItems(language: Language) -> [SpeedReaderItem] {
        var items: [SpeedReaderItem] = []

        // Add instructions if present
        if let instructions = instructions, !instructions.isEmpty {
            let instructionWords = instructions.components(separatedBy: .whitespaces).filter { !$0.isEmpty }
            items.append(contentsOf: instructionWords.map { word in
                SpeedReaderItem(text: word, isInstruction: true)
            })
        }

        // Get text for the specified language
        let text: String
        switch language {
        case .latin:
            text = latin
        case .english:
            text = english
        case .spanish:
            text = spanish ?? english  // Fallback to English if no Spanish
        }

        let words = text.components(separatedBy: .whitespaces).filter { !$0.isEmpty }
        items.append(contentsOf: words.map { word in
            SpeedReaderItem(text: word)
        })

        return items
    }
}

extension Array where Element == Prayer {
    /// Convert array of prayers to SpeedReaderItems
    func toSpeedReaderItems(language: Language) -> [SpeedReaderItem] {
        flatMap { $0.toSpeedReaderItems(language: language) }
    }
}
