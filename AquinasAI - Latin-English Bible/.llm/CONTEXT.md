# LLM Context: AquinasAI Latin-English Bible

## Quick Summary
iOS Bible app with parallel text display (Latin/English/Spanish), traditional Catholic prayers, and bookmark system. Built with SwiftUI + MVVM, no external dependencies.

## Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                         Views                                │
│  ContentView → VerseViews → PrayerViews → BookmarkViews     │
└─────────────────────────────┬───────────────────────────────┘
                              │
┌─────────────────────────────▼───────────────────────────────┐
│                      ViewModels                              │
│  BibleViewModel    SearchViewModel    BookmarkStore          │
│  (Bible loading)   (text search)      (persistence)          │
└─────────────────────────────┬───────────────────────────────┘
                              │
┌─────────────────────────────▼───────────────────────────────┐
│                       Models                                 │
│  BibleContent  Prayer  Bookmark  BibleMetadata              │
└─────────────────────────────┬───────────────────────────────┘
                              │
┌─────────────────────────────▼───────────────────────────────┐
│                    JSON Resources                            │
│  Bible: vulgate_*.json    Prayers: prayers.json + 5 others  │
└─────────────────────────────────────────────────────────────┘
```

## Key Enums

```swift
// Display modes for parallel text
enum DisplayMode: String, CaseIterable {
    case latinOnly, englishOnly, spanishOnly
    case latinEnglish, latinSpanish, englishSpanish
}

// Supported languages
enum Language: String, Codable {
    case latin, english, spanish
}

// Bookmark types
enum BookmarkType: String, Codable {
    case verse, prayer
}
```

## Data Flow

1. **Bible Content**: `vulgate_*.json` → `BibleViewModel.loadBible()` → `@Published books` → Views
2. **Prayers**: `*.json` → `PrayerStore.loadAllPrayers()` → `@Published prayers` → Views
3. **Bookmarks**: User action → `BookmarkStore` → UserDefaults → Persisted

## State Management Patterns

```swift
// View owns ViewModel
@StateObject private var viewModel = BibleViewModel()

// Share across view hierarchy
.environmentObject(bookmarkStore)

// Access in child views
@EnvironmentObject var bookmarkStore: BookmarkStore
```

## File Relationships

```
ContentView.swift
├── uses BibleViewModel (loads Bible content)
├── uses BookmarkStore (manages bookmarks)
├── navigates to VerseViews (displays chapters/verses)
├── navigates to PrayersView (prayer browsing)
└── navigates to BookmarkViews (bookmark management)

VerseViews.swift
├── receives Book, Chapter from navigation
├── uses DisplayMode to show 1 or 2 languages
└── uses BookmarkStore for verse bookmarking

PrayersView.swift / RosaryView.swift
├── uses PrayerStore (loaded prayers)
└── uses BookmarkStore for prayer bookmarking
```

## Important Conventions

- **No external dependencies** - Pure SwiftUI + Foundation
- **JSON resources** - All Bible/prayer content in bundled JSON
- **UserDefaults** - Only persistence mechanism (for bookmarks)
- **73 books** - Catholic Bible canon (includes deuterocanonical)
- **3 languages** - Latin (Vulgate), English (CPDV), Spanish (Reina-Valera)

## Color Scheme

```swift
extension Color {
    static let deepPurple = Color(red: 137/255, green: 84/255, blue: 160/255)
    static let paperWhite = Color(red: 0.98, green: 0.96, blue: 0.93)
    static let nightBackground = Color(red: 0.1, green: 0.1, blue: 0.12)
}
```

## Build Commands

```bash
# Open in Xcode
open "../AquinasAI - Latin-English Bible.xcodeproj"

# Build from CLI
xcodebuild -project "../AquinasAI - Latin-English Bible.xcodeproj" \
  -scheme "AquinasAI - Latin-English Bible" -configuration Debug build
```

## Common Tasks

| Task | Files to Modify |
|------|-----------------|
| Add new display mode | `BibleContent.swift` (enum), `VerseViews.swift` (rendering) |
| Add new prayer type | `Prayer.swift` (model), `PrayerSharedViews.swift` (UI) |
| Modify bookmark behavior | `BookmarkStore.swift`, `BookmarkViews.swift` |
| Change navigation | `ContentView.swift` |
| Update search logic | `SearchViewModel.swift`, `SearchView.swift` |
| Add new language | All Bible/Prayer JSONs, `BibleContent.swift`, `Prayer.swift` |
