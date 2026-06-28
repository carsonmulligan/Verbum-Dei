import Foundation
import AVFoundation
import Combine

/// One step in the audio-guided Rosary (a single prayer recitation or a
/// mystery announcement). `audioPrayerId` is the prayers.json id whose bundled
/// mp3 should play, or nil for steps we don't have audio for yet (mystery
/// announcements, the Fatima prayer, the closing prayer).
struct RosaryStep: Identifiable {
    let id = UUID()
    let section: String       // e.g. "Opening" or "1. The Agony in the Garden"
    let label: String         // e.g. "Hail Mary (3 of 10)"
    let audioPrayerId: String?
    let isAnnouncement: Bool
}

/// Plays the whole Rosary as a continuous audio sequence, advancing through
/// steps automatically. Owns its own AVAudioPlayer (independent of AudioManager)
/// and supports adjustable playback speed.
final class RosaryAudioPlayer: NSObject, ObservableObject {
    @Published private(set) var steps: [RosaryStep] = []
    @Published private(set) var currentIndex = 0
    @Published private(set) var isPlaying = false
    @Published var rate: Float = 1.0 { didSet { player?.rate = rate } }
    /// Audio language code for the recitation: "la" | "en" | "es".
    @Published var lang = "la"
    /// Silent pause inserted between prayers (prayerful pacing until the
    /// recordings themselves carry punctuation pauses).
    var gap: TimeInterval = 0.7

    private var player: AVAudioPlayer?
    private var advanceTimer: Timer?

    /// Maps a Rosary step's logical prayer id to the bundled audio prayer id.
    private static let audioId: [String: String] = [
        "sign_of_the_cross": "signum_crucis",
        "apostles_creed": "credo_apostles_creed",
        "our_father": "pater_noster",
        "hail_mary": "ave_maria",
        "glory_be": "gloria_patri",
        "hail_holy_queen": "salve_regina"
        // "fatima_prayer", "final_prayer", mystery announcements: no audio yet
    ]

    var currentStep: RosaryStep? {
        steps.indices.contains(currentIndex) ? steps[currentIndex] : nil
    }

    // MARK: - Build the sequence

    func build(mysteryType: String, mysteries: [RosaryMystery]) {
        var result: [RosaryStep] = []

        func add(_ logicalId: String, label: String, section: String, count: Int = 1) {
            for i in 0..<count {
                let stepLabel = count > 1 ? "\(label) (\(i + 1) of \(count))" : label
                result.append(RosaryStep(
                    section: section,
                    label: stepLabel,
                    audioPrayerId: Self.audioId[logicalId],
                    isAnnouncement: false
                ))
            }
        }

        // Opening
        add("sign_of_the_cross", label: "Sign of the Cross", section: "Opening")
        add("apostles_creed", label: "Apostles' Creed", section: "Opening")
        add("our_father", label: "Our Father", section: "Opening")
        add("hail_mary", label: "Hail Mary", section: "Opening", count: 3)
        add("glory_be", label: "Glory Be", section: "Opening")

        // Five decades
        for (index, mystery) in mysteries.prefix(5).enumerated() {
            let n = index + 1
            let section = "\(n). \(mystery.english)"
            result.append(RosaryStep(
                section: section,
                label: "Announce the \(ordinal(n)) \(mysteryType.capitalized) Mystery",
                audioPrayerId: nil,
                isAnnouncement: true
            ))
            add("our_father", label: "Our Father", section: section)
            add("hail_mary", label: "Hail Mary", section: section, count: 10)
            add("glory_be", label: "Glory Be", section: section)
            result.append(RosaryStep(
                section: section,
                label: "Fatima Prayer",
                audioPrayerId: nil,
                isAnnouncement: false
            ))
        }

        // Closing
        add("hail_holy_queen", label: "Hail Holy Queen", section: "Closing")
        result.append(RosaryStep(section: "Closing", label: "Closing Prayer", audioPrayerId: nil, isAnnouncement: false))
        add("sign_of_the_cross", label: "Sign of the Cross", section: "Closing")

        steps = result
        currentIndex = 0
    }

    // MARK: - Transport

    func play() {
        guard !steps.isEmpty else { return }
        isPlaying = true
        playCurrent()
    }

    func pause() {
        isPlaying = false
        player?.pause()
        advanceTimer?.invalidate()
        advanceTimer = nil
    }

    func toggle() { isPlaying ? pause() : play() }

    func stop() {
        isPlaying = false
        player?.stop()
        player = nil
        advanceTimer?.invalidate()
        advanceTimer = nil
        currentIndex = 0
    }

    /// Jump to a specific step (e.g. tapping a row).
    func seek(to index: Int) {
        guard steps.indices.contains(index) else { return }
        player?.stop()
        player = nil
        advanceTimer?.invalidate()
        currentIndex = index
        if isPlaying { playCurrent() }
    }

    func next() { seek(to: min(currentIndex + 1, steps.count - 1)) }
    func previous() { seek(to: max(currentIndex - 1, 0)) }

    // MARK: - Private

    private func playCurrent() {
        guard isPlaying, let step = currentStep else { return }

        // Steps without audio: hold briefly so the user can pray/read, then advance.
        guard let prayerId = step.audioPrayerId,
              let url = Bundle.main.url(forResource: "\(prayerId)_\(lang)", withExtension: "mp3") else {
            scheduleAdvance(after: step.isAnnouncement ? 2.5 : 1.5)
            return
        }

        configureSession()
        do {
            let p = try AVAudioPlayer(contentsOf: url)
            p.delegate = self
            p.enableRate = true
            p.rate = rate
            p.prepareToPlay()
            player = p
            p.play()
        } catch {
            scheduleAdvance(after: gap)
        }
    }

    private func advance() {
        if currentIndex + 1 < steps.count {
            currentIndex += 1
            playCurrent()
        } else {
            stop()
        }
    }

    private func scheduleAdvance(after delay: TimeInterval) {
        advanceTimer?.invalidate()
        advanceTimer = Timer.scheduledTimer(withTimeInterval: delay, repeats: false) { [weak self] _ in
            self?.advance()
        }
    }

    private func configureSession() {
        #if os(iOS)
        let session = AVAudioSession.sharedInstance()
        try? session.setCategory(.playback, mode: .spokenAudio)
        try? session.setActive(true)
        #endif
    }

    private func ordinal(_ n: Int) -> String {
        ["First", "Second", "Third", "Fourth", "Fifth"][safe: n - 1] ?? "\(n)th"
    }
}

extension RosaryAudioPlayer: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        guard isPlaying else { return }
        scheduleAdvance(after: gap)
    }
}

private extension Array {
    subscript(safe index: Int) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
