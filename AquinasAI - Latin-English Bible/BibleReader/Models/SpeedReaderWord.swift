//
//  SpeedReaderWord.swift
//  AquinasAI - Latin-English Bible
//
//  Model for a word in the speed reader with ORP (Optimal Recognition Point) calculation
//  Based on the Spritz/RSVP algorithm for rapid serial visual presentation
//

import Foundation

/// Represents a word prepared for speed reading with its ORP position calculated
struct SpeedReaderWord: Identifiable {
    let id = UUID()
    let text: String
    let orpIndex: Int

    /// The ORP letter that should be highlighted
    var orpLetter: String {
        guard orpIndex >= 0 && orpIndex < text.count else { return "" }
        let index = text.index(text.startIndex, offsetBy: orpIndex)
        return String(text[index])
    }

    /// Text before the ORP letter
    var beforeORP: String {
        guard orpIndex > 0 && orpIndex <= text.count else { return "" }
        let index = text.index(text.startIndex, offsetBy: orpIndex)
        return String(text[..<index])
    }

    /// Text after the ORP letter
    var afterORP: String {
        guard orpIndex >= 0 && orpIndex < text.count - 1 else { return "" }
        let index = text.index(text.startIndex, offsetBy: orpIndex + 1)
        return String(text[index...])
    }

    /// Calculate the Optimal Recognition Point for a word using Spritz algorithm
    /// ORP is placed slightly left of center where the eye naturally focuses
    static func calculateORP(for word: String) -> Int {
        let length = word.count

        switch length {
        case 0...1: return 0
        case 2...5: return 1
        case 6...9: return 2
        case 10...13: return 3
        default: return 4  // 14+ chars
        }
    }

    /// Create a SpeedReaderWord from a raw string
    init(text: String) {
        self.text = text
        self.orpIndex = SpeedReaderWord.calculateORP(for: text)
    }

    /// Create with explicit ORP index (for testing)
    init(text: String, orpIndex: Int) {
        self.text = text
        self.orpIndex = orpIndex
    }
}

// MARK: - Text Parsing Extension

extension SpeedReaderWord {
    /// Parse a block of text into an array of SpeedReaderWords
    static func parseText(_ text: String) -> [SpeedReaderWord] {
        let cleanedText = text
            .replacingOccurrences(of: "\n", with: " ")
            .replacingOccurrences(of: "\r", with: " ")

        return cleanedText
            .components(separatedBy: .whitespaces)
            .filter { !$0.isEmpty }
            .map { SpeedReaderWord(text: $0) }
    }
}
