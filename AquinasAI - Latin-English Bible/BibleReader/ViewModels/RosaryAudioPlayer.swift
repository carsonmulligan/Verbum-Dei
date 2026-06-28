import Foundation
import AVFoundation
import Combine

/// A unit of the Rosary shown as one card in the reading view. Most blocks are a
/// single prayer; a Hail Mary block carries `beadCount == 10` (or 3) and renders
/// a bead tracker instead of repeating the text. `audioPrayerId` is the
/// prayers.json id whose bundled mp3 backs the optional audio (nil = no audio yet).
struct RosaryBlock: Identifiable {
    let id = UUID()
    let section: String
    let title: String
    let latin: String?
    let english: String?
    let spanish: String?
    let beadCount: Int
    let audioPrayerId: String?
    let isAnnouncement: Bool
    let mysteryDescription: String?
}

/// Sequences the Rosary as optional continuous audio over the reading view.
/// Tracks the current block and, within a multi-bead block, the current bead so
/// the UI can highlight exactly what's being prayed. Audio is layered on top of
/// the always-present text — it is never required to read.
final class RosaryAudioPlayer: NSObject, ObservableObject {
    @Published private(set) var blocks: [RosaryBlock] = []
    @Published private(set) var currentBlockIndex = 0
    @Published private(set) var currentBead = 0
    @Published private(set) var isPlaying = false
    @Published var rate: Float = 1.0 { didSet { player?.rate = rate } }
    /// Audio language code for the recitation: "la" | "en" | "es".
    @Published var lang = "la"
    /// Silent pause between recitations (until recordings carry their own pauses).
    var gap: TimeInterval = 0.6

    private var player: AVAudioPlayer?
    private var advanceTimer: Timer?

    /// Maps a Rosary prayer's logical id to its bundled audio prayer id.
    static let audioId: [String: String] = [
        "sign_of_the_cross": "signum_crucis",
        "apostles_creed": "credo_apostles_creed",
        "our_father": "pater_noster",
        "hail_mary": "ave_maria",
        "glory_be": "gloria_patri",
        "hail_holy_queen": "salve_regina"
    ]

    var currentBlock: RosaryBlock? {
        blocks.indices.contains(currentBlockIndex) ? blocks[currentBlockIndex] : nil
    }

    func load(_ blocks: [RosaryBlock]) {
        stop()
        self.blocks = blocks
        currentBlockIndex = 0
        currentBead = 0
    }

    // MARK: - Transport

    func play() {
        guard !blocks.isEmpty else { return }
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
        currentBlockIndex = 0
        currentBead = 0
    }

    /// Jump to a specific block + bead (tapping a card or a bead).
    func seek(block: Int, bead: Int = 0) {
        guard blocks.indices.contains(block) else { return }
        player?.stop()
        player = nil
        advanceTimer?.invalidate()
        currentBlockIndex = block
        currentBead = max(0, bead)
        if isPlaying { playCurrent() }
    }

    func next() { seek(block: min(currentBlockIndex + 1, blocks.count - 1)) }
    func previous() { seek(block: max(currentBlockIndex - 1, 0)) }

    // MARK: - Private

    private func playCurrent() {
        guard isPlaying, let block = currentBlock else { return }

        guard let prayerId = block.audioPrayerId,
              let url = Bundle.main.url(forResource: "\(prayerId)_\(lang)", withExtension: "mp3") else {
            // No audio for this block yet — hold briefly, then advance.
            scheduleAdvance(after: block.isAnnouncement ? 2.5 : 1.2)
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
        guard isPlaying, let block = currentBlock else { return }
        if currentBead + 1 < block.beadCount {
            currentBead += 1
            playCurrent()
        } else if currentBlockIndex + 1 < blocks.count {
            currentBlockIndex += 1
            currentBead = 0
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
}

extension RosaryAudioPlayer: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        guard isPlaying else { return }
        scheduleAdvance(after: gap)
    }
}
