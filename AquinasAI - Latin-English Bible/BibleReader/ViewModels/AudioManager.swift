import Foundation
import AVFoundation
import Combine

/// Plays bundled prayer voiceovers (`Resources/TTS/<prayerId>_<lang>.mp3`).
/// Shared app-wide so a prayer started on the Today tab stays reflected in the
/// Prayers tab and a future global now-playing bar.
final class AudioManager: NSObject, ObservableObject {
    /// `"<prayerId>_<lang>"` of the track currently loaded, or nil when idle.
    @Published private(set) var nowPlayingKey: String?
    @Published private(set) var isPlaying = false
    /// 0...1 playback progress of the current track.
    @Published private(set) var progress: Double = 0
    @Published private(set) var duration: TimeInterval = 0

    /// Optional hook for sequenced playback (rosary decades, prayer chains).
    var onFinish: ((String?) -> Void)?

    private var player: AVAudioPlayer?
    private var ticker: Timer?

    /// Bundle resource name for a prayer in a given language code (`la`/`en`/`es`).
    static func key(prayerId: String, lang: String) -> String { "\(prayerId)_\(lang)" }

    /// Whether a bundled mp3 exists for this prayer + language.
    func hasAudio(prayerId: String, lang: String) -> Bool {
        Bundle.main.url(forResource: Self.key(prayerId: prayerId, lang: lang), withExtension: "mp3") != nil
    }

    /// True when this specific track is the one currently loaded.
    func isCurrent(prayerId: String, lang: String) -> Bool {
        nowPlayingKey == Self.key(prayerId: prayerId, lang: lang)
    }

    /// Toggle play/pause for a track; loads it first if it isn't current.
    func toggle(prayerId: String, lang: String) {
        let key = Self.key(prayerId: prayerId, lang: lang)
        if nowPlayingKey == key, let player = player {
            player.isPlaying ? pause() : resume()
        } else {
            start(key: key)
        }
    }

    func pause() {
        player?.pause()
        isPlaying = false
        stopTicker()
    }

    func resume() {
        guard player != nil else { return }
        configureSession()
        player?.play()
        isPlaying = true
        startTicker()
    }

    func stop() {
        player?.stop()
        player = nil
        isPlaying = false
        nowPlayingKey = nil
        progress = 0
        duration = 0
        stopTicker()
    }

    // MARK: - Private

    private func start(key: String) {
        guard let url = Bundle.main.url(forResource: key, withExtension: "mp3") else {
            return
        }
        configureSession()
        do {
            let newPlayer = try AVAudioPlayer(contentsOf: url)
            newPlayer.delegate = self
            newPlayer.prepareToPlay()
            player = newPlayer
            nowPlayingKey = key
            duration = newPlayer.duration
            progress = 0
            newPlayer.play()
            isPlaying = true
            startTicker()
        } catch {
            player = nil
            nowPlayingKey = nil
        }
    }

    private func configureSession() {
        #if os(iOS)
        let session = AVAudioSession.sharedInstance()
        try? session.setCategory(.playback, mode: .spokenAudio)
        try? session.setActive(true)
        #endif
    }

    private func startTicker() {
        stopTicker()
        ticker = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            guard let self = self, let player = self.player, player.duration > 0 else { return }
            self.progress = player.currentTime / player.duration
        }
    }

    private func stopTicker() {
        ticker?.invalidate()
        ticker = nil
    }
}

extension AudioManager: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        isPlaying = false
        progress = 1
        stopTicker()
        // Notify listeners (e.g. the rosary sequencer) that playback finished.
        onFinish?(nowPlayingKey)
    }
}
