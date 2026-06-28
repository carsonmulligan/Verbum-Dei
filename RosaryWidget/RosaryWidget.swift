import WidgetKit
import SwiftUI

// NOTE: This file is the source for the `RosaryWidget` extension target. It is
// intentionally NOT in the app's synchronized source group so it does not
// compile into the app target. Create the widget target in Xcode (see
// RosaryWidget/README.md) and add:
//   • this file                          → RosaryWidget target
//   • BibleReader/Models/RosarySchedule.swift → RosaryWidget target (Target Membership)
// RosarySchedule.swift is fully self-contained (no PrayerStore / JSON needed),
// so the widget resolves today's mystery from `RosaryMysterySet.canonicalSchedule`.

// MARK: - Timeline

struct RosaryEntry: TimelineEntry {
    let date: Date
    let set: RosaryMysterySet?
    let weekday: String
}

struct RosaryProvider: TimelineProvider {
    func placeholder(in context: Context) -> RosaryEntry {
        entry(for: Date())
    }

    func getSnapshot(in context: Context, completion: @escaping (RosaryEntry) -> Void) {
        completion(entry(for: Date()))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<RosaryEntry>) -> Void) {
        let calendar = Calendar.current
        let startOfToday = calendar.startOfDay(for: Date())

        // One entry per day for the next week so the widget flips automatically
        // at the day boundary without the app having to run.
        var entries: [RosaryEntry] = []
        for offset in 0..<7 {
            if let day = calendar.date(byAdding: .day, value: offset, to: startOfToday) {
                entries.append(entry(for: day))
            }
        }

        let nextMidnight = calendar.date(byAdding: .day, value: 1, to: startOfToday)
            ?? Date().addingTimeInterval(86_400)
        completion(Timeline(entries: entries, policy: .after(nextMidnight)))
    }

    private func entry(for date: Date) -> RosaryEntry {
        RosaryEntry(
            date: date,
            set: RosaryMysterySet.set(for: date),
            weekday: RosaryMysterySet.weekdayName(for: date)
        )
    }
}

// MARK: - Views

struct RosaryWidgetEntryView: View {
    @Environment(\.widgetFamily) private var family
    let entry: RosaryEntry

    var body: some View {
        switch family {
        case .systemMedium:
            mediumView
        case .accessoryRectangular:
            accessoryRectangular
        case .accessoryInline:
            accessoryInline
        default:
            smallView
        }
    }

    private var accent: Color { entry.set?.accentColor ?? .gray }

    // systemSmall — icon, set name, weekday.
    private var smallView: some View {
        VStack(alignment: .leading, spacing: 6) {
            Image(systemName: entry.set?.sfSymbol ?? "circle")
                .font(.title2)
                .foregroundColor(.white)
            Spacer()
            Text(entry.weekday.uppercased())
                .font(.caption2.weight(.bold))
                .foregroundColor(.white.opacity(0.8))
            Text(entry.set?.displayName ?? "Rosary")
                .font(.title3.bold())
                .foregroundColor(.white)
            Text("Mysteries")
                .font(.caption.weight(.semibold))
                .foregroundColor(.white.opacity(0.9))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        .padding(14)
        .background(gradient)
    }

    // systemMedium — adds the short description.
    private var mediumView: some View {
        HStack(spacing: 16) {
            VStack {
                Image(systemName: entry.set?.sfSymbol ?? "circle")
                    .font(.system(size: 40))
                    .foregroundColor(.white)
            }
            VStack(alignment: .leading, spacing: 6) {
                Text("TODAY · \(entry.weekday.uppercased())")
                    .font(.caption2.weight(.bold))
                    .foregroundColor(.white.opacity(0.8))
                Text(entry.set?.title ?? "Today's Rosary")
                    .font(.title2.bold())
                    .foregroundColor(.white)
                Text(entry.set?.shortDescription ?? "")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.9))
                    .lineLimit(2)
            }
            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        .padding(16)
        .background(gradient)
    }

    // Lock-screen rectangular.
    private var accessoryRectangular: some View {
        VStack(alignment: .leading, spacing: 2) {
            Label(entry.weekday, systemImage: entry.set?.sfSymbol ?? "circle")
                .font(.caption2.weight(.bold))
            Text(entry.set?.title ?? "Rosary")
                .font(.headline)
            Text(entry.set?.shortDescription ?? "")
                .font(.caption2)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // Lock-screen inline.
    private var accessoryInline: some View {
        Label("\(entry.set?.displayName ?? "Rosary") Mysteries",
              systemImage: entry.set?.sfSymbol ?? "circle")
    }

    private var gradient: some View {
        LinearGradient(
            colors: [accent, accent.opacity(0.7)],
            startPoint: .topLeading, endPoint: .bottomTrailing
        )
    }
}

// MARK: - Widget

struct RosaryWidget: Widget {
    let kind = "RosaryWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: RosaryProvider()) { entry in
            RosaryWidgetEntryView(entry: entry)
                // Open the app to today's Rosary when tapped. Register the
                // "aquinasai" URL scheme in the app and route in `onOpenURL`.
                .widgetURL(URL(string: "aquinasai://rosary/today"))
        }
        .configurationDisplayName("Today's Mysteries")
        .description("Shows which Rosary mysteries are prayed today.")
        .supportedFamilies(supportedFamilies)
    }

    private var supportedFamilies: [WidgetFamily] {
        var families: [WidgetFamily] = [.systemSmall, .systemMedium]
        if #available(iOSApplicationExtension 16.0, *) {
            families.append(contentsOf: [.accessoryRectangular, .accessoryInline])
        }
        return families
    }
}

@main
struct RosaryWidgetBundle: WidgetBundle {
    var body: some Widget {
        RosaryWidget()
    }
}
