import SwiftUI

/// Optional screen surfacing *which Rosary mysteries are prayed today* plus the
/// full Mon–Sun rhythm. Reached from the Today tab. Reuses the shared
/// `RosaryMysterySet` helper and the JSON-loaded schedule/decades from
/// `PrayerStore`, so there is no duplicated scheduling logic.
struct MysteriesThisWeekView: View {
    @EnvironmentObject private var prayerStore: PrayerStore
    @Environment(\.colorScheme) private var colorScheme

    private let orderedDays = ["Monday", "Tuesday", "Wednesday",
                               "Thursday", "Friday", "Saturday", "Sunday"]

    private var schedule: [String: String]? { prayerStore.rosaryPrayers?.schedule }

    private var todayName: String { RosaryMysterySet.weekdayName(for: Date()) }

    private var todaySet: RosaryMysterySet? {
        RosaryMysterySet.set(for: Date(), schedule: schedule)
    }

    private var background: Color {
        colorScheme == .dark ? Color.nightBackground : Color.paperWhite
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                if let set = todaySet {
                    todayCard(set)
                }
                weekSection
            }
            .padding()
        }
        .background(background.ignoresSafeArea())
        .navigationTitle("Mysteries")
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Today hero card (with the five decades)

    private func todayCard(_ set: RosaryMysterySet) -> some View {
        let decades = prayerStore.getRosaryMysteries(type: set.rawValue)
        return VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 10) {
                Image(systemName: set.sfSymbol)
                    .font(.title3)
                Text("TODAY · \(todayName.uppercased())")
                    .font(.caption.weight(.bold))
            }
            .foregroundColor(.white.opacity(0.85))

            VStack(alignment: .leading, spacing: 2) {
                Text(set.title)
                    .font(.title.bold())
                    .foregroundColor(.white)
                Text(set.latinTitle)
                    .font(.headline.italic())
                    .foregroundColor(.white.opacity(0.85))
            }

            if let decades {
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(decades) { mystery in
                        HStack(alignment: .top, spacing: 10) {
                            Text("\(mystery.number).")
                                .font(.subheadline.weight(.bold))
                                .foregroundColor(.white.opacity(0.7))
                            Text(mystery.english)
                                .font(.subheadline)
                                .foregroundColor(.white)
                        }
                    }
                }
                .padding(.top, 4)
            }

            NavigationLink {
                RosaryPlayerView()
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "play.circle.fill")
                    Text("Pray today's Rosary")
                        .fontWeight(.semibold)
                }
                .font(.subheadline)
                .foregroundColor(set.accentColor)
                .padding(.vertical, 10)
                .padding(.horizontal, 16)
                .background(Capsule().fill(Color.white))
            }
            .padding(.top, 4)
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            LinearGradient(
                colors: [set.accentColor, set.accentColor.opacity(0.7)],
                startPoint: .topLeading, endPoint: .bottomTrailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }

    // MARK: - The week at a glance

    private var weekSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("This week")
                .font(.headline)
                .foregroundColor(colorScheme == .dark ? .nightText : .black)
            VStack(spacing: 8) {
                ForEach(orderedDays, id: \.self) { day in
                    weekRow(day)
                }
            }
        }
    }

    private func weekRow(_ day: String) -> some View {
        let raw = schedule?[day] ?? RosaryMysterySet.canonicalSchedule[day]?.rawValue
        let set = raw.flatMap { RosaryMysterySet(rawValue: $0) }
        let isToday = day == todayName
        return HStack(spacing: 12) {
            Image(systemName: set?.sfSymbol ?? "circle")
                .foregroundColor(set?.accentColor ?? .secondary)
                .frame(width: 26)
            VStack(alignment: .leading, spacing: 1) {
                Text(day)
                    .font(.subheadline.weight(isToday ? .bold : .regular))
                    .foregroundColor(colorScheme == .dark ? .nightText : .primary)
                Text(set?.displayName ?? "—")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            Spacer()
            if isToday {
                Text("TODAY")
                    .font(.caption2.weight(.bold))
                    .foregroundColor(.white)
                    .padding(.vertical, 3)
                    .padding(.horizontal, 8)
                    .background(Capsule().fill(set?.accentColor ?? .deepPurple))
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(colorScheme == .dark ? Color.black.opacity(0.25) : Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .strokeBorder(isToday ? (set?.accentColor ?? .deepPurple) : .clear,
                                      lineWidth: 1.5)
                )
        )
    }
}
