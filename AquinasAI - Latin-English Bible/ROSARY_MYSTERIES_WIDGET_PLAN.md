# Plan: "Today's Mysteries" Screen + Home Screen Widget

Goal: surface *which Rosary mysteries are prayed today* (and the upcoming
weekly rhythm) both as an **optional in-app screen** and as a **home screen /
lock screen widget**, so a user can glance at their phone and know whether
today is Joyful, Sorrowful, Glorious, or Luminous.

This builds directly on logic the app already has — it is mostly extraction and
packaging, not new domain code.

---

## What already exists (reuse, don't rebuild)

- **Schedule data** lives in `Resources/rosary_prayers.json` under the
  `schedule` key — a `weekday → mystery-type` map:

  | Day | Mystery |
  |-----|---------|
  | Monday | joyful |
  | Tuesday | sorrowful |
  | Wednesday | glorious |
  | Thursday | luminous |
  | Friday | sorrowful |
  | Saturday | joyful |
  | Sunday | glorious |

- **Lookup logic** already exists: `PrayerStore.getRosarySchedule(day:)`
  (`BibleReader/Models/Prayer.swift:781`) returns the mystery key for a weekday
  string.
- **The five mysteries per set** live under the `mysteries` key, decoded as
  `[String: [RosaryMystery]]` (`Prayer.swift:115`, `RosaryMystery` at `:142`).
- **`TodayView`** (`BibleReader/Views/TodayView.swift:29-36`) already derives the
  current weekday and renders "The {Type} Mysteries" in the Rosary hero card.

So the model + schedule are done. The new work is (1) a richer dedicated screen
and (2) a widget target that can read the same data outside the app process.

---

## Part 1 — Optional in-app "Mysteries This Week" screen

A standalone screen (reachable from the Today tab and/or the Rosary view) that
shows:

1. **Today's mystery** — large header, the set name in Latin + English, the five
   decade titles, and a "Pray now" button that deep-links into the existing
   `RosaryView` / `RosaryPlayerView` for that set.
2. **The week at a glance** — a 7-row list (Mon–Sun) highlighting today, each row
   tappable to preview that day's set. (`RosaryView` already renders a weekday
   strip at `RosaryView.swift:83` — generalize that instead of duplicating.)

### Steps
1. Add a small pure helper so both the app and the widget share one source of
   truth for "mystery for a given date":
   - New file `BibleReader/Models/RosarySchedule.swift`
   - `enum RosaryMysterySet: String { case joyful, sorrowful, glorious, luminous }`
     with `displayName`, `latinName`, and an `sfSymbol`/accent color.
   - `static func set(for date: Date, using schedule: [String:String]) -> RosaryMysterySet?`
     — wraps the weekday formatting now inlined in `TodayView` so the logic isn't
     copy-pasted. Refactor `TodayView.mysteryType` to call it.
2. New view `BibleReader/Views/MysteriesView.swift`
   (`MysteriesThisWeekView` — note `RosaryView.swift` already has a private
   `MysteriesView`, so name it distinctly) using existing color tokens
   (`.deepPurple`, `.paperWhite`, `.nightBackground`).
3. Entry points: a row/button in `TodayView` ("See this week's mysteries →") and
   optionally a toolbar item in `RosaryView`.
4. "Optional" = gate visibility behind a setting, e.g.
   `@AppStorage("showMysteriesScreen") var showMysteriesScreen = true`, with a
   toggle wherever app settings live.

No new data files; no JSON schema changes.

---

## Part 2 — Home Screen / Lock Screen Widget (WidgetKit)

A WidgetKit extension that renders today's mystery. Because widgets run in a
**separate process/target**, they cannot reach the app's `PrayerStore`
directly — the shared data must be reachable from both.

### 2a. Share data across the target boundary
The `schedule` and `mysteries` data is static and bundled. Two options:

- **Option A (recommended): bundle `rosary_prayers.json` into the widget target
  too** and decode the `schedule` map there. Simplest; no runtime coupling. Add
  the resource to the widget target's "Copy Bundle Resources" and reuse the
  `RosaryMysterySet` helper from Part 1 (add the shared Swift file to *both*
  targets' membership).
- **Option B: App Group + cached snapshot.** Add an App Group
  (`group.NA.AquinasAI`) and have the app write today's resolved mystery into the
  shared `UserDefaults(suiteName:)`. More moving parts; only needed if the data
  ever becomes dynamic/user-specific. **Defer this** — start with Option A.

### 2b. Create the widget extension
1. In Xcode: **File → New → Target → Widget Extension**, name `RosaryWidget`
   (bundle id `NA.AquinasAI---Latin-English-Bible.RosaryWidget`). No
   configuration intent needed for v1 (static widget).
2. Add target membership for: `RosarySchedule.swift` (the shared helper) and
   `rosary_prayers.json`.
3. **TimelineProvider** — `RosaryTimelineProvider`:
   - Entry: `struct RosaryEntry: TimelineEntry { let date: Date; let set: RosaryMysterySet? }`.
   - `placeholder` → today's set (or `.joyful` as a stand-in).
   - `getTimeline` → build **one entry per day** from `Date()` forward (e.g. the
     next 7 days at local midnight) so the widget flips automatically at the day
     boundary without the app running. Refresh policy `.after(nextMidnight)`.
   - Use the device's local calendar for the weekday so it matches the app.
4. **Views** (SwiftUI, sized per family):
   - `.systemSmall` — accent icon + "Joyful Mysteries" + weekday.
   - `.systemMedium` — add the five decade titles (English, condensed).
   - `.accessoryRectangular` / `.accessoryInline` (lock screen) — "Today: Joyful".
   - Respect light/dark via `colorScheme`; reuse the per-set accent color.
5. **Deep link**: set `.widgetURL(URL(string: "aquinasai://rosary/today")!)` so
   tapping opens the app to today's Rosary. Register a URL scheme in the app's
   Info and handle it (`onOpenURL`) to route into `RosaryView`/`RosaryPlayerView`.

### 2c. Edge cases
- **Locale/first-day-of-week**: always resolve by the date's weekday name, not an
  index, to stay aligned with the JSON keys.
- **Liturgical overrides** (e.g. Sundays of Advent/Lent traditionally Sorrowful):
  out of scope for v1 — the weekday table is the standard popular usage. Note it
  as a future enhancement, not a v1 requirement.
- **Timeline staleness**: regenerate the 7-day timeline each refresh so it never
  runs dry.

---

## Suggested build order (small, shippable commits)
1. Extract `RosarySchedule.swift` + `RosaryMysterySet`; refactor `TodayView` to
   use it. (Pure refactor, no UI change — safe.)
2. Build the optional in-app "Mysteries This Week" screen + entry point + setting.
3. Add the WidgetKit extension (Option A), small + medium families.
4. Add lock-screen accessory families + deep linking.
5. (Later, optional) App Group snapshot + liturgical-season overrides.

## Files touched / added
- **Add** `BibleReader/Models/RosarySchedule.swift` (shared helper, both targets)
- **Add** `BibleReader/Views/MysteriesThisWeekView.swift`
- **Add** `RosaryWidget/` target (provider + views + Info.plist)
- **Edit** `BibleReader/Views/TodayView.swift` (use helper; add entry point)
- **Edit** app Info / URL scheme + `onOpenURL` routing
- **No change** to `rosary_prayers.json` schema (only add it to widget target
  membership)

## Out of scope for v1
- Liturgical-calendar season overrides
- User-customizable schedules
- App Group dynamic snapshots (use bundled JSON instead)
