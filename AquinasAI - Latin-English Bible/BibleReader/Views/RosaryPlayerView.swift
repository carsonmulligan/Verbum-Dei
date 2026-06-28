import SwiftUI

/// Audio-guided Rosary: shows the full sequence (how to pray it) and can read
/// the whole thing aloud, auto-advancing through each prayer with adjustable speed.
struct RosaryPlayerView: View {
    @EnvironmentObject private var prayerStore: PrayerStore
    @EnvironmentObject private var audio: AudioManager
    @Environment(\.colorScheme) private var colorScheme
    @StateObject private var player = RosaryAudioPlayer()

    @State private var selectedDay: String = RosaryPlayerView.today()

    private static let weekDays = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]
    private static func today() -> String {
        let f = DateFormatter(); f.dateFormat = "EEEE"; return f.string(from: Date())
    }

    private var background: Color { colorScheme == .dark ? .nightBackground : .paperWhite }
    private var primaryText: Color { colorScheme == .dark ? .nightText : .primary }

    private var mysteryType: String? { prayerStore.rosaryPrayers?.schedule[selectedDay] }
    private var mysteryTitle: String {
        guard let t = mysteryType else { return "Rosary" }
        return "The \(t.capitalized) Mysteries"
    }

    var body: some View {
        ZStack {
            background.ignoresSafeArea()
            VStack(spacing: 0) {
                daySelector
                Text(mysteryTitle)
                    .font(.title3.bold())
                    .foregroundColor(primaryText)
                    .padding(.top, 4)
                stepList
                playerBar
            }
        }
        .navigationTitle("Rosary")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear(perform: rebuild)
        .onChange(of: selectedDay) { _, _ in
            player.stop()
            rebuild()
        }
        .onDisappear { player.stop() }
    }

    private func rebuild() {
        guard let type = mysteryType,
              let mysteries = prayerStore.getRosaryMysteries(type: type) else { return }
        player.build(mysteryType: type, mysteries: mysteries)
    }

    // MARK: - Day selector

    private var daySelector: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(Self.weekDays, id: \.self) { day in
                    RosaryDayPill(
                        title: String(day.prefix(3)),
                        isSelected: selectedDay == day,
                        action: { selectedDay = day }
                    )
                }
            }
            .padding(.horizontal)
        }
        .padding(.vertical, 12)
    }

    // MARK: - Step list (how to pray)

    private var stepList: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 4) {
                    ForEach(Array(player.steps.enumerated()), id: \.element.id) { index, step in
                        if index == 0 || player.steps[index - 1].section != step.section {
                            Text(step.section)
                                .font(.caption.weight(.bold))
                                .foregroundColor(.deepPurple)
                                .padding(.top, 12).padding(.horizontal)
                        }
                        stepRow(index: index, step: step)
                            .id(index)
                    }
                }
                .padding(.bottom, 8)
            }
            .onChange(of: player.currentIndex) { _, newIndex in
                withAnimation { proxy.scrollTo(newIndex, anchor: .center) }
            }
        }
    }

    private func stepRow(index: Int, step: RosaryStep) -> some View {
        let isCurrent = index == player.currentIndex
        let hasAudio = step.audioPrayerId != nil
        return HStack(spacing: 10) {
            Image(systemName: step.isAnnouncement ? "sparkles" : (hasAudio ? "circle.fill" : "circle"))
                .font(.system(size: 8))
                .foregroundColor(isCurrent ? .deepPurple : .secondary)
            Text(step.label)
                .font(isCurrent ? .body.weight(.semibold) : .body)
                .foregroundColor(isCurrent ? .deepPurple : primaryText)
            Spacer()
            if isCurrent && player.isPlaying {
                Image(systemName: "waveform")
                    .foregroundColor(.deepPurple)
                    .font(.caption)
            }
        }
        .padding(.vertical, 6).padding(.horizontal)
        .background(isCurrent ? Color.deepPurple.opacity(0.12) : .clear)
        .contentShape(Rectangle())
        .onTapGesture { player.seek(to: index) }
    }

    // MARK: - Player bar

    private var playerBar: some View {
        VStack(spacing: 10) {
            Text(player.currentStep?.label ?? "Ready")
                .font(.footnote)
                .foregroundColor(.secondary)
                .lineLimit(1)

            HStack(spacing: 36) {
                Button { player.previous() } label: {
                    Image(systemName: "backward.fill").font(.title3)
                }
                Button {
                    audio.stop() // don't overlap with single-prayer playback
                    player.toggle()
                } label: {
                    Image(systemName: player.isPlaying ? "pause.circle.fill" : "play.circle.fill")
                        .font(.system(size: 56))
                }
                Button { player.next() } label: {
                    Image(systemName: "forward.fill").font(.title3)
                }
            }
            .foregroundColor(.deepPurple)

            HStack(spacing: 12) {
                Picker("Language", selection: $player.lang) {
                    Text("Latin").tag("la")
                    Text("English").tag("en")
                    Text("Español").tag("es")
                }
                .pickerStyle(.segmented)

                HStack(spacing: 4) {
                    Image(systemName: "gauge.with.dots.needle.50percent")
                        .font(.caption).foregroundColor(.secondary)
                    Text(String(format: "%.2g×", player.rate))
                        .font(.caption.monospacedDigit())
                        .foregroundColor(.secondary)
                        .frame(width: 36)
                }
            }

            Slider(value: $player.rate, in: 0.75...1.5, step: 0.05)
                .tint(.deepPurple)
        }
        .padding()
        .background(
            (colorScheme == .dark ? Color.black.opacity(0.35) : Color.white)
                .shadow(color: colorScheme == .dark ? .clear : .black.opacity(0.08), radius: 6, y: -2)
        )
    }
}

/// A single day-of-week pill in the Rosary day selector.
private struct RosaryDayPill: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(
                    Capsule()
                        .fill(isSelected ? Color.deepPurple : Color.clear)
                        .overlay(Capsule().strokeBorder(Color.deepPurple, lineWidth: 1))
                )
                .foregroundColor(isSelected ? .white : .deepPurple)
        }
    }
}
