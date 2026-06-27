#!/usr/bin/env python3
"""Generate Glory Be (Gloria Patri) voiceover samples via ElevenLabs.
Test run: 3 voices x 3 languages = 9 mp3 files. Uses eleven_multilingual_v2."""
import os, json, urllib.request, urllib.error

API_KEY = None
with open(".env") as f:
    for line in f:
        if line.startswith("ELEVEN_LABS_API_KEY"):
            API_KEY = line.strip().split("=", 1)[1]

MODEL = "eleven_multilingual_v2"
OUT = "voiceover_samples"
os.makedirs(OUT, exist_ok=True)

TEXTS = {
    "latin":   "Gloria Patri, et Filio, et Spiritui Sancto. Sicut erat in principio, et nunc, et semper, et in saecula saeculorum. Amen.",
    "english": "Glory be to the Father, and to the Son, and to the Holy Spirit. As it was in the beginning, is now, and ever shall be, world without end. Amen.",
    "spanish": "Gloria al Padre, y al Hijo, y al Espíritu Santo. Como era en el principio, ahora y siempre, por los siglos de los siglos. Amén.",
}

# Standard ElevenLabs premade voices (same IDs on every account)
VOICES = {
    "adam_male":      "pNInz6obpgDQGcFmaJgB",
    "rachel_female":  "21m00Tcm4TlvDq8ikWAM",
    "charlotte_female": "XB0fDUnXU5powFXDhCwa",
}

total_chars = 0
manifest = []
for vname, vid in VOICES.items():
    for lang, text in TEXTS.items():
        body = json.dumps({
            "text": text,
            "model_id": MODEL,
            "voice_settings": {"stability": 0.5, "similarity_boost": 0.75, "style": 0.0},
        }).encode()
        req = urllib.request.Request(
            f"https://api.elevenlabs.io/v1/text-to-speech/{vid}",
            data=body,
            headers={"xi-api-key": API_KEY, "Content-Type": "application/json"},
            method="POST",
        )
        fname = f"{OUT}/glory_be_{lang}_{vname}.mp3"
        try:
            with urllib.request.urlopen(req) as resp:
                audio = resp.read()
            with open(fname, "wb") as out:
                out.write(audio)
            total_chars += len(text)
            manifest.append((fname, len(text), len(audio)))
            print(f"OK  {fname}  ({len(text)} chars, {len(audio)} bytes)")
        except urllib.error.HTTPError as e:
            print(f"ERR {fname}: {e.code} {e.read().decode()[:200]}")

print(f"\nTOTAL CHARACTERS BILLED: {total_chars}")
print(f"FILES: {len(manifest)}")
