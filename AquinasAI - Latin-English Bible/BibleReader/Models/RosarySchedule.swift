import SwiftUI

/// The four sets of Rosary mysteries and the traditional weekday on which each
/// is prayed.
///
/// This is the single source of truth for "which mysteries today?" shared by
/// the app **and** the home-screen widget. Keep it free of app-only
/// dependencies (no `PrayerStore`, no JSON required at runtime) so the widget
/// target can include this exact file via target membership and resolve today's
/// mystery without loading any resources.
enum RosaryMysterySet: String, CaseIterable, Identifiable {
    case joyful
    case sorrowful
    case glorious
    case luminous

    var id: String { rawValue }

    /// Canonical traditional schedule. Mirrors `rosary_prayers.json` → `schedule`
    /// and is used as a fallback whenever a JSON-loaded schedule isn't available
    /// (e.g. inside the widget, or if the bundle fails to load).
    static let canonicalSchedule: [String: RosaryMysterySet] = [
        "Monday": .joyful,
        "Tuesday": .sorrowful,
        "Wednesday": .glorious,
        "Thursday": .luminous,
        "Friday": .sorrowful,
        "Saturday": .joyful,
        "Sunday": .glorious
    ]

    /// English weekday name ("Monday"…"Sunday") for a date in the device's
    /// local calendar. Locale is pinned to en_US_POSIX so the key always matches
    /// the schedule dictionaries above regardless of the user's region.
    static func weekdayName(for date: Date, calendar: Calendar = .current) -> String {
        let formatter = DateFormatter()
        formatter.calendar = calendar
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "EEEE"
        return formatter.string(from: date)
    }

    /// The mystery set for a given date. Prefers a caller-supplied schedule
    /// (the app passes the JSON-loaded one); falls back to `canonicalSchedule`.
    static func set(for date: Date,
                    schedule: [String: String]? = nil,
                    calendar: Calendar = .current) -> RosaryMysterySet? {
        let day = weekdayName(for: date, calendar: calendar)
        if let schedule, let raw = schedule[day], let set = RosaryMysterySet(rawValue: raw) {
            return set
        }
        return canonicalSchedule[day]
    }

    /// Capitalized name, e.g. "Joyful".
    var displayName: String {
        rawValue.prefix(1).uppercased() + rawValue.dropFirst()
    }

    /// e.g. "The Joyful Mysteries".
    var title: String { "The \(displayName) Mysteries" }

    var latinTitle: String {
        switch self {
        case .joyful: return "Mysteria Gaudiosa"
        case .sorrowful: return "Mysteria Dolorosa"
        case .glorious: return "Mysteria Gloriosa"
        case .luminous: return "Mysteria Luminosa"
        }
    }

    /// Short one-line gloss, suitable for the medium widget and list rows.
    var shortDescription: String {
        switch self {
        case .joyful: return "Christ's birth and early life"
        case .sorrowful: return "Christ's Passion and death"
        case .glorious: return "The Resurrection and the glory of Heaven"
        case .luminous: return "Christ's public ministry"
        }
    }

    var sfSymbol: String {
        switch self {
        case .joyful: return "sparkles"
        case .sorrowful: return "cross.fill"
        case .glorious: return "crown.fill"
        case .luminous: return "sun.max.fill"
        }
    }

    /// Per-set accent color used by the in-app screen and the widget.
    var accentColor: Color {
        switch self {
        case .joyful: return Color(red: 0.82, green: 0.62, blue: 0.18)    // gold — joy
        case .sorrowful: return Color(red: 0.55, green: 0.18, blue: 0.24) // deep red — passion
        case .glorious: return Color(red: 0.20, green: 0.45, blue: 0.70)  // bright blue — glory
        case .luminous: return Color(red: 0.42, green: 0.50, blue: 0.82)  // luminous indigo
        }
    }
}
