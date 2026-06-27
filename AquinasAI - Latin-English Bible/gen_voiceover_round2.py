#!/usr/bin/env python3
"""Round 2: slower Adam Latin + more English male voices. Glory Be."""
import os, json, urllib.request, urllib.error

API_KEY = None
with open(".env") as f:
    for line in f:
        if line.startswith("ELEVEN_LABS_API_KEY"):
            API_KEY = line.strip().split("=", 1)[1]

MODEL = "eleven_multilingual_v2"
OUT = "voiceover_samples"
os.makedirs(OUT, exist_ok=True)

LATIN = "Gloria Patri, et Filio, et Spiritui Sancto. Sicut erat in principio, et nunc, et semper, et in saecula saeculorum. Amen."
ENGLISH = "Glory be to the Father, and to the Son, and to the Holy Spirit. As it was in the beginning, is now, and ever shall be, world without end. Amen."

# (filename, voice_id, text, speed)
JOBS = [
    # Adam Latin, two slower speeds (1.0 = normal, lower = slower)
    ("glory_be_latin_adam_slow85.mp3", "pNInz6obpgDQGcFmaJgB", LATIN, 0.85),
    ("glory_be_latin_adam_slow75.mp3", "pNInz6obpgDQGcFmaJgB", LATIN, 0.75),
    # More English male voices (premade IDs)
    ("glory_be_english_daniel_male.mp3", "onwK4e9ZLuTAKqWW03F9", ENGLISH, 0.95),  # Daniel - British, authoritative
    ("glory_be_english_george_male.mp3", "JBFqnCBsd6RMkjVDRZzb", ENGLISH, 0.95),  # George - warm British
    ("glory_be_english_brian_male.mp3",  "nPczCjzI2devNBz1zQrb", ENGLISH, 0.95),  # Brian - deep US narrator
    ("glory_be_english_bill_male.mp3",   "pqHfZKP75CvOlQylNhV4", ENGLISH, 0.95),  # Bill - older, trustworthy
]

total = 0
for fname, vid, text, speed in JOBS:
    body = json.dumps({
        "text": text,
        "model_id": MODEL,
        "voice_settings": {"stability": 0.5, "similarity_boost": 0.75, "style": 0.0, "speed": speed},
    }).encode()
    req = urllib.request.Request(
        f"https://api.elevenlabs.io/v1/text-to-speech/{vid}",
        data=body,
        headers={"xi-api-key": API_KEY, "Content-Type": "application/json"},
        method="POST",
    )
    try:
        with urllib.request.urlopen(req) as resp:
            audio = resp.read()
        with open(f"{OUT}/{fname}", "wb") as o:
            o.write(audio)
        total += len(text)
        print(f"OK  {fname}  (speed {speed}, {len(text)} chars, {len(audio)} bytes)")
    except urllib.error.HTTPError as e:
        print(f"ERR {fname}: {e.code} {e.read().decode()[:300]}")

print(f"\nTOTAL CHARACTERS BILLED: {total}")
