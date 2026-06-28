# RosaryWidget — home/lock screen widget

Shows which Rosary mysteries are prayed today (Joyful / Sorrowful / Glorious /
Luminous). The Swift source is committed here, but the **widget extension target
must be created in Xcode** (WidgetKit targets can't be added safely by editing
the project file from the command line).

## One-time Xcode setup

1. **File → New → Target… → Widget Extension.**
   - Product name: `RosaryWidget`
   - Bundle id: `NA.AquinasAI---Latin-English-Bible.RosaryWidget`
   - Uncheck "Include Configuration App Intent" (this is a static widget).
2. Xcode generates a starter `RosaryWidget.swift` + Info.plist in a new group.
   **Replace** the generated `RosaryWidget.swift` with the one in this folder
   (`RosaryWidget/RosaryWidget.swift`), or delete the generated one and add this
   file to the target.
3. Add the shared schedule helper to the widget target:
   - Select `BibleReader/Models/RosarySchedule.swift` in the navigator.
   - In the File inspector → **Target Membership**, check **RosaryWidget** (keep
     the app target checked too). This file is self-contained — no `PrayerStore`
     or JSON needed — so the widget resolves today's mystery from
     `RosaryMysterySet.canonicalSchedule`.
4. Build & run the `RosaryWidget` scheme, or run the app and long-press the home
   screen → add the "Today's Mysteries" widget.

## Deep linking (optional, for tap-to-open)

The widget sets `widgetURL(aquinasai://rosary/today)`. To make tapping open the
app on the Rosary:

1. App target → Info → URL Types → add scheme `aquinasai`.
2. In the SwiftUI `App`/root view add:
   ```swift
   .onOpenURL { url in
       if url.host == "rosary" { /* route to RosaryView / RosaryPlayerView */ }
   }
   ```

## Behavior

- The timeline emits one entry per day for the next 7 days and refreshes after
  the next local midnight, so the widget flips to the new mystery automatically
  without the app running.
- Supported families: `systemSmall`, `systemMedium`, and (iOS 16+) the
  `accessoryRectangular` / `accessoryInline` lock-screen widgets.

## Out of scope (future)

- Liturgical-season overrides (e.g. Sundays in Advent/Lent). The widget uses the
  standard weekday schedule; see `ROSARY_MYSTERIES_WIDGET_PLAN.md`.
