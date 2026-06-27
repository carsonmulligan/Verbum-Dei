# Prayer Voiceovers (TTS)

Pre-rendered ElevenLabs audio for the prayers, designed to be **shared across the
iOS app and the future Android app**.

## Naming contract

```
<prayer_id>_<lang>.mp3
```

- `<prayer_id>` is exactly the `id` the Swift `Prayer` model computes from `title`
  (lowercase, spaces → `_`, punctuation `, . ' " ( )` stripped).
  Example: `"Gloria Patri"` → `gloria_patri`, `"Credo (Apostles' Creed)"` → `credo_apostles_creed`.
- `<lang>` is `la` (Latin), `en` (English), `es` (Spanish).

Names are lowercase + underscores only on purpose: they are valid in the iOS
bundle **and** in Android `res/raw` (and `assets/`), so the same files drop into
both projects unchanged.

## Manifest

`voiceover_manifest.json` is the cross-platform source of truth:

```jsonc
{
  "model": "eleven_multilingual_v2",
  "voices": {
    "la": { "name": "Adam",      "voice_id": "...", "speed": 0.85 },
    "en": { "name": "Daniel",    "voice_id": "...", "speed": 0.95 },
    "es": { "name": "Charlotte", "voice_id": "...", "speed": 1.0  }
  },
  "prayers": {
    "gloria_patri": { "title": "Gloria Patri",
      "files": { "la": {"file": "gloria_patri_la.mp3", ...}, "en": {...}, "es": {...} } }
  }
}
```

## iOS bundling

The Xcode source folder is a **file-system-synchronized root group**, so every
`.mp3` added here is bundled automatically — no "Add Files to project" step.
At playback time, load by computed id:

```swift
// AVAudioPlayer example
let name = "\(prayer.id)_\(langCode)"        // langCode = "la" | "en" | "es"
if let url = Bundle.main.url(forResource: name, withExtension: "mp3") {
    player = try AVAudioPlayer(contentsOf: url)
    player?.play()
}
```

(No player is wired up yet — the in-app audio UX is still to be designed.)

## Android bundling (later)

Copy the same `*.mp3` into `app/src/main/res/raw/` (filenames already comply) and
reference via `R.raw.<prayer_id>_<lang>`, or into `assets/tts/` and open with the
`AssetManager`. Reuse `voiceover_manifest.json` as-is.

## Regenerating

```bash
python3 gen_prayer_voiceovers.py          # the SELECTED small batch
python3 gen_prayer_voiceovers.py --all    # every prayer in prayers.json
```

Requires `ELEVEN_LABS_API_KEY` in `.env`. Billing is per **character**.
Measured: core `prayers.json` (all 3 languages, one voice each) ≈ 52,600 characters.
