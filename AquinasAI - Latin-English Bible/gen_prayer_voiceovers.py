#!/usr/bin/env python3
"""Generate prayer voiceovers for AquinasAI via ElevenLabs.

Output is platform-neutral so the same files bundle into iOS now and Android later:
  Resources/TTS/<prayer_id>_<lang>.mp3   (lang = la|en|es)
  Resources/TTS/voiceover_manifest.json  (cross-platform contract)

<prayer_id> matches the `id` the Swift Prayer model computes from `title`
(lowercased, spaces -> "_", punctuation stripped), so iOS finds files with no
extra mapping. Names are lowercase + underscores only -> also valid Android res/raw.

Usage:
  python3 gen_prayer_voiceovers.py            # generate the SELECTED batch
  python3 gen_prayer_voiceovers.py --all      # generate every prayer in prayers.json
"""
import os, sys, json, re, urllib.request, urllib.error

MODEL = "eleven_multilingual_v2"
OUT = "Resources/TTS"
SRC = "Resources/prayers.json"

# Final voice profile chosen by the user (see memory: elevenlabs-voice-profile).
VOICE = {
    "la": {"name": "Adam",      "voice_id": "pNInz6obpgDQGcFmaJgB", "speed": 0.85},
    "en": {"name": "Daniel",    "voice_id": "onwK4e9ZLuTAKqWW03F9", "speed": 0.95},
    "es": {"name": "Charlotte", "voice_id": "XB0fDUnXU5powFXDhCwa", "speed": 1.0},
}
TEXT_KEY = {"la": "latin", "en": "english", "es": "spanish"}

# Small validation batch: the most-used prayers (all have Spanish text).
SELECTED_TITLES = [
    "Signum Crucis",            # Sign of the Cross
    "Pater Noster",             # Our Father
    "Ave Maria",                # Hail Mary
    "Gloria Patri",             # Glory Be
    "Credo (Apostles' Creed)",  # Apostles' Creed
    "Salve Regina",             # Hail Holy Queen
]

def prayer_id(title):
    """Mirror Swift Prayer.id normalization."""
    s = title.lower().replace(" ", "_")
    for c in [",", ".", "'", '"', "(", ")"]:
        s = s.replace(c, "")
    return s

def load_key():
    with open(".env") as f:
        for line in f:
            if line.startswith("ELEVEN_LABS_API_KEY"):
                return line.strip().split("=", 1)[1]
    raise SystemExit("ELEVEN_LABS_API_KEY not found in .env")

def tts(api_key, voice_id, text, speed):
    body = json.dumps({
        "text": text,
        "model_id": MODEL,
        "voice_settings": {"stability": 0.5, "similarity_boost": 0.75, "style": 0.0, "speed": speed},
    }).encode()
    req = urllib.request.Request(
        f"https://api.elevenlabs.io/v1/text-to-speech/{voice_id}",
        data=body, method="POST",
        headers={"xi-api-key": api_key, "Content-Type": "application/json"},
    )
    with urllib.request.urlopen(req) as resp:
        return resp.read()

def main():
    do_all = "--all" in sys.argv
    api_key = load_key()
    os.makedirs(OUT, exist_ok=True)
    prayers = json.load(open(SRC))["prayers"]
    if not do_all:
        wanted = set(SELECTED_TITLES)
        prayers = [p for p in prayers if p["title"] in wanted]

    manifest_path = os.path.join(OUT, "voiceover_manifest.json")
    manifest = {"model": MODEL, "voices": VOICE, "prayers": {}}
    if os.path.exists(manifest_path):
        manifest = json.load(open(manifest_path))
        manifest["voices"] = VOICE  # keep current profile

    total_chars = 0
    for p in prayers:
        pid = prayer_id(p["title"])
        entry = {"title": p["title"], "files": {}}
        for lang, vk in TEXT_KEY.items():
            text = p.get(vk)
            if not text:
                continue
            fname = f"{pid}_{lang}.mp3"
            try:
                audio = tts(api_key, VOICE[lang]["voice_id"], text, VOICE[lang]["speed"])
            except urllib.error.HTTPError as e:
                print(f"ERR {fname}: {e.code} {e.read().decode()[:200]}")
                continue
            with open(os.path.join(OUT, fname), "wb") as o:
                o.write(audio)
            total_chars += len(text)
            entry["files"][lang] = {"file": fname, "chars": len(text), "voice": VOICE[lang]["name"]}
            print(f"OK  {fname}  ({len(text)} chars)")
        manifest["prayers"][pid] = entry

    with open(manifest_path, "w") as o:
        json.dump(manifest, o, ensure_ascii=False, indent=2)
    print(f"\nPrayers: {len(prayers)}  |  Characters billed this run: {total_chars}")
    print(f"Manifest: {manifest_path}")

if __name__ == "__main__":
    main()
