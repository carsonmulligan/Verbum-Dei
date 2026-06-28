# AquinasAI — Design Review & Redesign Proposal

*Prepared June 2026. Audience: product/design. Scope: a design review of the
current app + a proposed redesign centered on (1) an audio prayer experience for
the TikTok funnel and (2) a daily-rosary habit, without disrupting existing users.*

---

## 1. Who actually uses this

- **Core persona:** a Catholic who wants to **pray the Rosary daily**, and also
  wants a **Bible** + a library of traditional prayers in Latin/English/Spanish.
- **Acquisition reality:** a large share arrive from **TikTok of prayers being
  read aloud**. They come for *audio prayer*, then (ideally) stay for the Bible
  and daily rosary.
- **Constraint:** the app is live with many users. Bible reading, display modes,
  and bookmarks must keep working. Redesign is **additive and phased**, not a
  rip-and-replace.

**The core tension:** the thing that brings users in (hearing a prayer) is the
thing the app does *worst* — there's no audio at all, and prayers are buried two
taps deep behind a Bible-first home.

---

## 2. Current screens (as built)

### 2.1 Home — `ContentView` / `BookList`

```
┌──────────────────────────────────────────┐
│ ☾                              [ Latin ▾ ] │  ← toolbar: dark toggle | display mode
│                                            │
│            ✝  (app_home_image)             │  ← hero cross image
│                                            │
│              Latin Vulgate                 │  ← large title = display-mode name
│                                            │
│   ( Old Testament )  ( New Testament )     │  ← pills row 1: testament SELECTOR
│   ( Search ) ( Bookmarks ) ( Prayers )     │  ← pills row 2: ACTIONS (open sheets)
│   (          Speed Reader          )       │  ← pill row 3: ACTION (open sheet)
│ ──────────────────────────────────────── │
│   Genesis                              ›   │
│   Exodus                               ›   │  ← scrollable book list (filtered
│   Leviticus                            ›   │     by selected testament)
│   Numeri                               ›   │
│   …                                        │
└──────────────────────────────────────────┘
```

**Friction:** pills mix two unrelated semantics in one visual style — *selectors*
(Old/New Testament, which filter the list below) sit next to *actions*
(Search/Bookmarks/Prayers/Speed Reader, which open modal sheets). A user can't
tell from the pill which kind of thing they're tapping.

### 2.2 Bible reader — `BookView`

```
┌──────────────────────────────────────────┐
│ ‹ Back        Genesis             ⊡        │  ← ⊡ = speed-reader (text.viewfinder)
│ (1)(2)(3)(4)(5)(6)(7)(8) …                 │  ← horizontal chapter pills
│ ──────────────────────────────────────── │
│ Chapter 1                                  │
│ 1  In principio creavit Deus…              │
│    In the beginning God created…           │  ← verse, per display mode
│ 2  Terra autem erat inanis…                │
│    And the earth was void…                 │
└──────────────────────────────────────────┘
```

### 2.3 Prayers — `PrayersView` (modal sheet)

```
┌──────────────────────────────────────────┐
│ 🔍  Search prayers                  Done   │
│ (All Prayers)(Order of Mass)(Rosary→)(Divine
│  Mercy)(Liturgy of the Hours)(Angelus…)    │  ← category pills (horizontal scroll)
│              [ Latin-English ▾ ]            │  ← language picker
│ ┌────────────────────────────────────────┐ │
│ │ Pater Noster                       🔖   │ │  ← PrayerCard: title(s) + full text
│ │ Our Father                              │ │     + bookmark.  NO audio control.
│ │ Pater noster, qui es in caelis…         │ │
│ └────────────────────────────────────────┘ │
│ ┌────────────────────────────────────────┐ │
│ │ Ave Maria … Hail Mary …            🔖   │ │
│ └────────────────────────────────────────┘ │
└──────────────────────────────────────────┘
```

Note: the **Rosary** pill is special — it's a `NavigationLink` that pushes a
*different* screen, while every other pill just filters the list in place.

### 2.4 Rosary — `RosaryView` (pushed from Prayers › Rosary)

```
┌──────────────────────────────────────────┐
│ ‹ Prayers           Rosary                 │
│ (Sun)(Mon)(Tue)(Wed)(Thu)(Fri)(Sat)       │  ← day selector (defaults to today)
│              [ Latin-English ▾ ]           │
│ Glorious Mysteries                         │  ← mystery for the selected day
│ 1. The Resurrection                        │
│   Pater Noster … Ave Maria ×10 … Gloria…   │  ← template-driven prayer sequence
└──────────────────────────────────────────┘
```

### 2.5 Speed Reader hub — `SpeedReaderHubView` (modal sheet)

```
┌──────────────────────────────────────────┐
│ Close            Speed Reader              │
│            ⊡  Speed Reader                 │
│  "Read Scripture and prayers one word at   │
│   a time…"                                 │
│ [Bible][Prayers][Rosary][Divine Mercy]     │  ← content-type picker — SAME set as
│ [Mass][Angelus][Liturgy of Hours]          │     the Prayers categories!
│ Select a Book ▾                            │
│   ▸ Genesis            50 chapters         │
│   ▸ Exodus             40 chapters     ▶   │
│ → launches SpeedReaderView (RSVP) fullscreen
└──────────────────────────────────────────┘
```

---

## 3. Current navigation map

```
                    ┌─────────────────┐
                    │   HOME (Bible)  │
                    │  BookList view  │
                    └───────┬─────────┘
        ┌──────────┬────────┼─────────┬───────────────┐
        ▼          ▼        ▼         ▼               ▼
   [Old/New]   (Search)  (Bookmarks) (Prayers)   (Speed Reader)
   filters     sheet      sheet       sheet          sheet
   list          │          │           │              │
        ▼         │          │           ▼              ▼
   BookView ──⊡──▶│          │      PrayersView    SpeedReaderHub
   (reader)  SpeedReaderView │       │   │            │  │  │
                  (RSVP)     │     list  Rosary→    Bible Prayers Rosary…
                             │     (read) RosaryView    └──┴──┴─▶ SpeedReaderView
                             │                                      (RSVP)
                          (verse →
                           bookmark)
```

**The jumble, precisely:** *Rosary*, *Prayers*, *Divine Mercy*, *Mass*,
*Angelus*, *Liturgy* are each reachable **two ways** — once to **read**
(Prayers sheet) and once to **speed-read** (Speed Reader hub) — and the Rosary is
*also* a special push inside Prayers. Three doors to the same content, each in a
different interaction mode, all launched as modal sheets off a Bible-first home.
Nothing establishes a daily ritual or surfaces audio.

---

## 4. Proposed aesthetic direction

> **"Illuminated office"** — a modern breviary. Warm paper and deep liturgical
> purple, with **gold-leaf** as the single sharp accent (currently there is no
> accent beyond purple-on-paper, which reads generic). Latin set in a
> characterful serif; English/Spanish in a clean reading serif. Catholic imagery
> used as *atmosphere* (soft, darkened hero washes) rather than clip-art.

| Token        | Now                          | Proposed                                            |
|--------------|------------------------------|-----------------------------------------------------|
| Background   | paperWhite / nightBackground | keep, add subtle paper grain texture                |
| Primary      | deepPurple (#8954A0)         | deepen to a vespers purple; reserve for chrome      |
| **Accent**   | *(none)*                     | **gold leaf (#C8A24B)** for "now playing", today, CTAs |
| Display font | system largeTitle            | a distinctive serif for Latin titles (e.g. New York / a licensed display face) |
| Body         | system / Times New Roman     | New York (SF Serif) for verse + prayer text         |
| Imagery      | one cross png                | rotating darkened sacred-art hero (bundled Catholic images) |

This keeps the existing palette legible to current users while giving the app a
memorable, non-templated identity (and moves it away from the "purple gradient on
white" AI-default look).

---

## 5. Proposed information architecture — a Tab Bar

Replace the "everything is a sheet off the Bible home" model with **3 tabs**,
folding Speed Reader from a destination into a *mode* (a toggle inside reading
views) so the triple-door jumble collapses.

```
        ┌───────────────────────────────────────────────┐
        │                  TAB BAR                        │
        │   ✦ Today        ✝ Bible        ☩ Prayers       │
        └───────────────────────────────────────────────┘
            │                │                  │
   daily ritual + audio   current home      unified library
   (TikTok landing)       (preserved)       (+ audio, rosary)
```

- **Today** — new default landing. The TikTok hook: audio-first, daily rosary,
  verse of the day, a sacred-art hero.
- **Bible** — *the current home, essentially unchanged* (books, testaments,
  display modes, reader, bookmarks). Existing muscle memory preserved.
- **Prayers** — the current prayer library + categories, now with **audio**, and
  the Rosary promoted to a first-class flow shared with Today.

> Speed Reader is no longer its own door. It becomes a **toolbar toggle**
> ("Read ▸ / Listen ◀ / Speed ⊡") available inside any prayer or chapter — same
> feature, one obvious place, no duplicate content trees.

### 5.1 Today (new)

```
┌──────────────────────────────────────────┐
│  Friday · 27 June            ☾            │
│ ┌────────────────────────────────────────┐│
│ │   [ darkened sacred-art hero image ]    ││
│ │   THE SORROWFUL MYSTERIES               ││  ← auto-selected by weekday
│ │   ▶  Pray today's Rosary   · 18 min     ││  ← ONE-TAP audio rosary  (gold)
│ └────────────────────────────────────────┘│
│  Daily prayers                             │
│  ▶ Gloria Patri      Latin · 0:24    🔖   │  ← inline audio play (bundled mp3)
│  ▶ Pater Noster      Latin · 0:41         │
│  ▶ Ave Maria         Latin · 0:30         │
│  ─────────────────────────────────────    │
│  Verse of the day                          │
│  "In principio erat Verbum…"  → John 1:1   │  → deep-links into Bible tab
└──────────────────────────────────────────┘
```

### 5.2 Prayer with audio — `PrayerCard` evolved

```
┌────────────────────────────────────────┐
│ Gloria Patri                       🔖   │
│ Glory Be                                │
│ Gloria Patri, et Filio, et Spiritui…    │
│ ┌──────────────────────────────────────┐│
│ │ ▶  ──────●────────────────  0:11/0:24 ││  ← audio scrubber
│ │ Voice: Adam (Latin)   [ Read | Speed ]││  ← mode toggle replaces SR hub
│ └──────────────────────────────────────┘│
└────────────────────────────────────────┘
```

### 5.3 Rosary player (audio-guided)

```
┌──────────────────────────────────────────┐
│ ‹            The Sorrowful Mysteries       │
│        [ darkened mystery art ]            │
│   2nd Decade · The Scourging at the Pillar │
│   Ave Maria  (3 of 10)                     │  ← progress through the decade
│   "…benedictus fructus ventris tui, Iesus."│  ← optional highlight-as-it-reads
│                                            │
│        ⏮     ⏯  (gold)     ⏭              │  ← now-playing transport
│   ●●●○○○○○○○  decade beads                  │
│   Latin ▾        autoplay ⦿                │
└──────────────────────────────────────────┘
```

### 5.4 Proposed navigation map

```
   ┌────────── TAB BAR ──────────┐
   ▼              ▼               ▼
 TODAY          BIBLE          PRAYERS
   │              │               │
   │              ▼               ▼
   │           BookView        Prayer library (categories)
   │           (reader)            │
   │              │                ├─▶ Prayer detail  ──┐
   ├─▶ Rosary player ◀─────────────┤  (Read|Listen|Speed)│  one shared
   │   (audio)                     └─▶ Rosary player ◀───┘  reading surface
   └─▶ Daily prayer audio ─────────────────────────────────┘
                       (Listen/Speed are a TOGGLE, not a separate hub)
```

Three doors collapse to one: content lives in **Prayers** (and is surfaced on
**Today**); how you consume it — read, listen, or speed-read — is a toggle on the
detail screen, not a parallel navigation tree.

---

## 6. Where audio fits + voiceover roadmap

- Audio is **bundled mp3** (already started): `Resources/TTS/<prayer_id>_<lang>.mp3`,
  voices Latin=Adam@0.85 / English=Daniel / Spanish=Charlotte. See
  `Resources/TTS/README.md` and `voiceover_manifest.json`.
- A small **`AudioPlayer` service** (`AVAudioPlayer` + a `@Published` now-playing
  state) backs: inline play on Today/PrayerCard, the rosary auto-sequencer, and a
  global mini now-playing bar.
- **Coverage plan:** core 6 prayers done → full `prayers.json` (~52.6k chars,
  fits the 70k budget) → rosary/mass/hours later (needs plan upgrade).

---

## 7. Migration plan (non-breaking, phased)

1. **Phase 0 (done):** stable prayer IDs; bundle core audio; manifest + contract.
2. **Phase 1 — audio, no IA change:** add `AudioPlayer` + a play button on the
   existing `PrayerCard`. Ship value to TikTok users *without* touching navigation.
3. **Phase 2 — Today tab:** introduce a `TabView` (Today / Bible / Prayers).
   *Bible tab = today's home verbatim*, so existing users are unaffected. Today
   becomes the launch tab (A/B against current behavior).
4. **Phase 3 — unify Speed Reader:** convert the SR hub into a Read|Listen|Speed
   toggle on detail screens; keep the hub temporarily as a redirect.
5. **Phase 4 — rosary player + aesthetic pass:** audio-guided rosary, gold
   accent, sacred-art heros, serif typography.

Each phase is shippable and reversible; nothing removes Bible reading, display
modes, or bookmarks.

---

## 8. Open questions (for you)

- Tab bar of **3 (Today/Bible/Prayers)** vs keeping Bible as the launch screen
  with a new "Today/Pray" pill?
- Should **Today launch by default**, or only for users arriving from the prayer
  funnel?
- How aggressive on the **aesthetic** (gold + serif + sacred-art) vs. staying
  close to the current purple-on-paper to avoid startling regulars?
