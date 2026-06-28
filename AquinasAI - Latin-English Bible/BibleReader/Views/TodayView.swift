import SwiftUI

/// The redesigned landing tab: a daily ritual surface centered on the Rosary
/// and audio prayers — the screen TikTok visitors should hit first.
struct TodayView: View {
    @EnvironmentObject private var prayerStore: PrayerStore
    @Environment(\.colorScheme) private var colorScheme
    @Binding var selectedTab: Int

    // Prayers surfaced for one-tap daily audio (must have bundled voiceovers).
    private let dailyPrayerIds = ["signum_crucis", "pater_noster", "ave_maria", "gloria_patri"]

    private var background: Color {
        colorScheme == .dark ? Color.nightBackground : Color.paperWhite
    }

    private var weekday: String {
        let f = DateFormatter()
        f.dateFormat = "EEEE"
        return f.string(from: Date())
    }

    private var dateLine: String {
        let f = DateFormatter()
        f.dateFormat = "EEEE · d MMMM"
        return f.string(from: Date())
    }

    private var mysteryType: String? {
        prayerStore.getRosarySchedule(day: weekday)
    }

    private var mysteryTitle: String {
        guard let type = mysteryType else { return "Today's Rosary" }
        return "The \(type.capitalized) Mysteries"
    }

    private func prayer(_ id: String) -> Prayer? {
        prayerStore.prayers.first { $0.id == id }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                background.ignoresSafeArea()
                ScrollView {
                    VStack(alignment: .leading, spacing: 28) {
                        Text(dateLine)
                            .font(.subheadline.weight(.medium))
                            .foregroundColor(.secondary)
                            .padding(.horizontal)

                        rosaryHero
                        dailyPrayers
                        verseOfDay
                    }
                    .padding(.vertical)
                }
            }
            .navigationTitle("Today")
        }
    }

    // MARK: - Rosary hero

    private var rosaryHero: some View {
        NavigationLink {
            RosaryPlayerView()
        } label: {
            ZStack(alignment: .bottomLeading) {
                LinearGradient(
                    colors: [Color.deepPurple, Color.deepPurple.opacity(0.65)],
                    startPoint: .topLeading, endPoint: .bottomTrailing
                )
                Image("app_home_image")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .opacity(0.18)

                VStack(alignment: .leading, spacing: 8) {
                    Text("DAILY ROSARY")
                        .font(.caption.weight(.bold))
                        .foregroundColor(.white.opacity(0.8))
                    Text(mysteryTitle)
                        .font(.title2.bold())
                        .foregroundColor(.white)
                    HStack(spacing: 6) {
                        Image(systemName: "play.circle.fill")
                        Text("Pray today's Rosary")
                            .fontWeight(.semibold)
                    }
                    .font(.subheadline)
                    .foregroundColor(.white)
                    .padding(.top, 4)
                }
                .padding(20)
            }
            .frame(height: 180)
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .padding(.horizontal)
        }
        .buttonStyle(.plain)
    }

    // MARK: - Daily prayers

    private var dailyPrayers: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Daily prayers")
                .font(.headline)
                .foregroundColor(colorScheme == .dark ? .nightText : .black)
                .padding(.horizontal)

            VStack(spacing: 8) {
                ForEach(dailyPrayerIds, id: \.self) { id in
                    if let prayer = prayer(id) {
                        TodayPrayerRow(prayer: prayer)
                    }
                }
            }
            .padding(.horizontal)
        }
    }

    // MARK: - Verse of the day

    private var verseOfDay: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Verse of the day")
                .font(.headline)
                .foregroundColor(colorScheme == .dark ? .nightText : .black)

            Text("In principio erat Verbum, et Verbum erat apud Deum, et Deus erat Verbum.")
                .font(.body.italic())
                .foregroundColor(colorScheme == .dark ? .nightText : .primary)

            Button {
                selectedTab = 1 // jump to the Bible tab
            } label: {
                Text("John 1:1  ›")
                    .font(.caption.weight(.semibold))
                    .foregroundColor(.deepPurple)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(colorScheme == .dark ? Color.black.opacity(0.3) : Color.white)
                .shadow(color: colorScheme == .dark ? .clear : Color.black.opacity(0.06), radius: 5, y: 2)
        )
        .padding(.horizontal)
    }
}

/// One row in the Today "Daily prayers" list with an inline Latin audio button.
struct TodayPrayerRow: View {
    let prayer: Prayer
    @EnvironmentObject private var audio: AudioManager
    @Environment(\.colorScheme) private var colorScheme

    private let lang = "la" // Latin is the traditional/TikTok hook

    var body: some View {
        let isCurrent = audio.isCurrent(prayerId: prayer.id, lang: lang)
        let hasAudio = audio.hasAudio(prayerId: prayer.id, lang: lang)
        HStack(spacing: 14) {
            Button {
                audio.toggle(prayerId: prayer.id, lang: lang)
            } label: {
                Image(systemName: (isCurrent && audio.isPlaying) ? "pause.circle.fill" : "play.circle.fill")
                    .font(.system(size: 34))
                    .foregroundColor(hasAudio ? .deepPurple : .gray.opacity(0.4))
            }
            .disabled(!hasAudio)

            VStack(alignment: .leading, spacing: 2) {
                Text(prayer.displayTitleLatin)
                    .font(.subheadline.weight(.semibold))
                    .foregroundColor(colorScheme == .dark ? .nightText : .primary)
                Text(prayer.displayTitleEnglish)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            Spacer()
            if isCurrent {
                ProgressView(value: audio.progress)
                    .frame(width: 56)
                    .tint(.deepPurple)
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(colorScheme == .dark ? Color.black.opacity(0.25) : Color.white)
                .shadow(color: colorScheme == .dark ? .clear : Color.black.opacity(0.05), radius: 3, y: 1)
        )
    }
}
