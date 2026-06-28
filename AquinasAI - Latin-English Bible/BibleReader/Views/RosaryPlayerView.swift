import SwiftUI

/// Reading-first Rosary: the full prayer text is always shown (single or parallel
/// languages). Audio is an optional "Listen" layer that highlights the prayer
/// being said and walks the bead tracker — never required to read.
struct RosaryPlayerView: View {
    @EnvironmentObject private var prayerStore: PrayerStore
    @ObservedObject private var audio = AudioManager.shared
    @Environment(\.colorScheme) private var colorScheme
    @StateObject private var player = RosaryAudioPlayer()

    @State private var selectedDay: String = RosaryPlayerView.today()
    @State private var selectedLanguage: PrayerLanguage = .latinEnglish

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
                header
                blockList
                listenBar
            }
        }
        .navigationTitle("Rosary")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear(perform: rebuild)
        .onChange(of: selectedDay) { _, _ in rebuild() }
        .onChange(of: selectedLanguage) { _, newValue in player.lang = newValue.audioLangCode }
        .onDisappear { player.stop() }
    }

    // MARK: - Header (day + mystery + language)

    private var header: some View {
        VStack(spacing: 8) {
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
            .padding(.top, 10)

            Text(mysteryTitle)
                .font(.title3.bold())
                .foregroundColor(primaryText)

            Picker("Language", selection: $selectedLanguage) {
                ForEach(PrayerLanguage.allCases, id: \.self) { lang in
                    Text(lang.displayName).tag(lang)
                }
            }
            .pickerStyle(.menu)
            .tint(.deepPurple)
        }
        .padding(.bottom, 6)
    }

    // MARK: - Reading list

    private var blockList: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 10) {
                    ForEach(Array(player.blocks.enumerated()), id: \.element.id) { index, block in
                        if index == 0 || player.blocks[index - 1].section != block.section {
                            Text(block.section)
                                .font(.caption.weight(.bold))
                                .foregroundColor(.deepPurple)
                                .padding(.top, 14)
                                .padding(.horizontal)
                        }
                        RosaryBlockCard(
                            block: block,
                            language: selectedLanguage,
                            isCurrent: index == player.currentBlockIndex,
                            currentBead: player.currentBead,
                            isPlaying: player.isPlaying,
                            onTap: { player.seek(block: index) },
                            onSelectBead: { bead in player.seek(block: index, bead: bead) }
                        )
                        .id(index)
                        .padding(.horizontal)
                    }
                }
                .padding(.vertical, 4)
            }
            .onChange(of: player.currentBlockIndex) { _, newIndex in
                withAnimation { proxy.scrollTo(newIndex, anchor: .center) }
            }
        }
    }

    // MARK: - Listen bar (optional audio layer)

    private var listenBar: some View {
        VStack(spacing: 8) {
            HStack(spacing: 24) {
                Button { player.previous() } label: {
                    Image(systemName: "backward.fill")
                }
                .disabled(!player.isPlaying)

                Button {
                    audio.stop() // don't overlap with single-prayer playback
                    player.toggle()
                } label: {
                    Image(systemName: player.isPlaying ? "pause.circle.fill" : "play.circle.fill")
                        .font(.system(size: 46))
                }

                Button { player.next() } label: {
                    Image(systemName: "forward.fill")
                }
                .disabled(!player.isPlaying)

                VStack(alignment: .leading, spacing: 1) {
                    Text(player.isPlaying ? "Now praying" : "Listen")
                        .font(.caption2).foregroundColor(.secondary)
                    Text(player.currentBlock?.title ?? "Pray the whole Rosary")
                        .font(.footnote.weight(.medium))
                        .foregroundColor(primaryText)
                        .lineLimit(1)
                }
                Spacer()
            }
            .foregroundColor(.deepPurple)

            HStack(spacing: 8) {
                Image(systemName: "tortoise").font(.caption2).foregroundColor(.secondary)
                Slider(value: $player.rate, in: 0.75...1.5, step: 0.05)
                    .tint(.deepPurple)
                Image(systemName: "hare").font(.caption2).foregroundColor(.secondary)
                Text(String(format: "%.2g×", player.rate))
                    .font(.caption2.monospacedDigit())
                    .foregroundColor(.secondary)
                    .frame(width: 34)
            }
        }
        .padding()
        .background(
            (colorScheme == .dark ? Color.black.opacity(0.35) : Color.white)
                .shadow(color: colorScheme == .dark ? .clear : .black.opacity(0.08), radius: 6, y: -2)
        )
    }

    // MARK: - Build sequence

    private func rebuild() {
        guard let cp = prayerStore.rosaryPrayers?.common_prayers,
              let type = mysteryType,
              let mysteries = prayerStore.getRosaryMysteries(type: type) else {
            player.load([])
            return
        }

        var blocks: [RosaryBlock] = []
        func add(_ key: String, section: String, beads: Int = 1) {
            guard let p = cp[key] else { return }
            blocks.append(RosaryBlock(
                section: section,
                title: p.title_english ?? p.title_latin ?? key,
                latin: p.latin, english: p.english, spanish: p.spanish,
                beadCount: beads,
                logicalId: key,
                audioPrayerId: RosaryAudioPlayer.audioId[key],
                isAnnouncement: false,
                mysteryDescription: nil
            ))
        }

        add("sign_of_the_cross", section: "Opening")
        add("apostles_creed", section: "Opening")
        add("our_father", section: "Opening")
        add("hail_mary", section: "Opening", beads: 3)
        add("glory_be", section: "Opening")

        for (i, m) in mysteries.prefix(5).enumerated() {
            let section = "\(i + 1). \(m.english)"
            blocks.append(RosaryBlock(
                section: section,
                title: m.english,
                latin: m.latin, english: m.english, spanish: nil,
                beadCount: 1,
                logicalId: nil,
                audioPrayerId: nil,
                isAnnouncement: true,
                mysteryDescription: m.description ?? prayerStore.getMysteryDescription(for: type)
            ))
            add("our_father", section: section)
            add("hail_mary", section: section, beads: 10)
            add("glory_be", section: section)
            add("fatima_prayer", section: section)
        }

        add("hail_holy_queen", section: "Closing")
        add("final_prayer", section: "Closing")
        add("sign_of_the_cross", section: "Closing")

        player.load(blocks)
        player.lang = selectedLanguage.audioLangCode
    }
}

// MARK: - Block card

/// One prayer card in the Rosary reading view. Shows the prayer text in the
/// selected language(s); a multi-bead block shows a bead tracker instead of
/// repeating the text.
private struct RosaryBlockCard: View {
    let block: RosaryBlock
    let language: PrayerLanguage
    let isCurrent: Bool
    let currentBead: Int
    let isPlaying: Bool
    let onTap: () -> Void
    let onSelectBead: (Int) -> Void
    @Environment(\.colorScheme) private var colorScheme

    private var primaryText: Color { colorScheme == .dark ? .nightText : .primary }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(block.title)
                    .font(.headline)
                    .foregroundColor(.deepPurple)
                Spacer()
                if isCurrent && isPlaying {
                    Image(systemName: "waveform").foregroundColor(.deepPurple).font(.caption)
                }
            }

            if block.isAnnouncement {
                if let desc = block.mysteryDescription {
                    Text(desc).font(.subheadline).foregroundColor(.secondary)
                }
            } else {
                prayerText
                if block.beadCount > 1 {
                    beadRow
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(isCurrent ? Color.deepPurple.opacity(0.12)
                      : (colorScheme == .dark ? Color.black.opacity(0.25) : Color.white))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .strokeBorder(Color.deepPurple.opacity(isCurrent ? 0.5 : 0.15), lineWidth: 1)
        )
        .contentShape(Rectangle())
        .onTapGesture(perform: onTap)
    }

    @ViewBuilder
    private var prayerText: some View {
        if language.showsLatin, let latin = block.latin {
            Text(latin).font(.body).foregroundColor(primaryText)
        }
        if language.showsEnglish, let english = block.english {
            Text(english).font(.body).italic().foregroundColor(.secondary)
        }
        if language.showsSpanish {
            if let spanish = block.spanish {
                Text(spanish).font(.body).italic().foregroundColor(.secondary)
            } else if !language.showsLatin && !language.showsEnglish, let english = block.english {
                Text(english).font(.body).foregroundColor(primaryText) // fallback
            }
        }
    }

    private var beadRow: some View {
        HStack(spacing: 7) {
            ForEach(0..<block.beadCount, id: \.self) { bead in
                Circle()
                    .fill((isCurrent && bead <= currentBead) ? Color.deepPurple : Color.deepPurple.opacity(0.2))
                    .frame(width: 11, height: 11)
                    .onTapGesture { onSelectBead(bead) }
            }
        }
        .padding(.top, 4)
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
