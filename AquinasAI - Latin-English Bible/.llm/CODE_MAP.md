# Code Map

## Directory Structure

```
AquinasAI - Latin-English Bible/
├── .llm/                    # LLM context files (this folder)
├── BibleReader/             # Main source code
│   ├── Models/              # Data structures
│   ├── ViewModels/          # Business logic
│   └── Views/               # SwiftUI components
├── Resources/               # JSON data files
│   └── Bible/               # Bible translations
├── Assets.xcassets/         # App icons and colors
└── AquinasAI___Latin_English_BibleApp.swift  # Entry point
```

## Source Files

### Models (`BibleReader/Models/`)

| File | Lines | Purpose |
|------|-------|---------|
| `BibleContent.swift` | ~200 | Core data structures: `Book`, `Chapter`, `Verse`, `Language`, `DisplayMode` enums, and `BookNameMappings` for cross-language name resolution |
| `Prayer.swift` | ~750 | Prayer models: base `Prayer` struct, specialized containers (`RosaryPrayersContainer`, `OrderOfMassContainer`, etc.), and `PrayerStore` ObservableObject |
| `Bookmark.swift` | ~60 | `Bookmark` struct with `BookmarkType` enum (verse/prayer) |
| `BibleMetadata.swift` | ~80 | Static book ordering and name data for 73 Catholic Bible books |

### ViewModels (`BibleReader/ViewModels/`)

| File | Lines | Purpose |
|------|-------|---------|
| `BibleViewModel.swift` | ~300 | Loads all 3 Bible JSONs, manages `DisplayMode`, provides book availability checks |
| `SearchViewModel.swift` | ~130 | Full-text search with verse reference parsing (e.g., "John 3:16") |
| `BookmarkStore.swift` | ~70 | UserDefaults-backed bookmark CRUD operations |

### Views (`BibleReader/Views/`)

| File | Lines | Purpose |
|------|-------|---------|
| `ContentView.swift` | ~512 | Main navigation hub, testament selector (OT/NT), book list, theme toggle |
| `VerseViews.swift` | ~324 | Chapter display with parallel text based on `DisplayMode` |
| `BookmarkViews.swift` | ~481 | Bookmark list, editing, filtering, and deletion |
| `PrayersView.swift` | ~357 | Prayer category browser and detail view |
| `PrayerSharedViews.swift` | ~511 | Reusable prayer components, category tabs, language selector |
| `RosaryView.swift` | ~548 | Interactive rosary guide with mystery selection and decade tracking |
| `SearchView.swift` | ~212 | Search input and results display |

## Resource Files

### Bible Data (`Resources/Bible/`)

| File | Size | Content |
|------|------|---------|
| `vulgate_latin.json` | 4.5 MB | Latin Vulgate (73 books) |
| `vulgate_english.json` | 5.2 MB | Catholic Public Domain Version |
| `vulgate_spanish_RV.json` | 4.2 MB | Reina-Valera Spanish |
| `mappings_three_languages.json` | 15 KB | Book name translations across languages |

### Prayer Data (`Resources/`)

| File | Size | Content |
|------|------|---------|
| `prayers.json` | 62 KB | Core prayers (Pater Noster, Ave Maria, Credo, etc.) |
| `rosary_prayers.json` | 13 KB | Rosary mysteries with day schedule |
| `divine_mercy_chaplet.json` | 8.6 KB | Divine Mercy Chaplet |
| `order_of_mass.json` | 29 KB | Full Mass liturgy |
| `angelus_domini.json` | 7.3 KB | Angelus prayers |
| `liturgy_of_hours.json` | 12 KB | Liturgy of the Hours |

## Key Entry Points

### App Launch
```
AquinasAI___Latin_English_BibleApp.swift
  └── ContentView()
        ├── BibleViewModel (loads Bible)
        ├── BookmarkStore (loads bookmarks)
        └── PrayerStore (loads prayers)
```

### Navigation Flow
```
ContentView (testament/book selection)
  ├── Book selected → VerseViews (chapter/verse display)
  ├── Prayers tab → PrayersView → Prayer detail
  │                 └── RosaryView (if rosary selected)
  ├── Bookmarks tab → BookmarkViews
  └── Search → SearchView → Results → VerseViews
```

## Import Dependencies

All files use only standard Apple frameworks:
- `SwiftUI` - UI components
- `Foundation` - JSON parsing, UserDefaults
- `Combine` - `@Published` property wrappers (implicit via SwiftUI)

No external packages or CocoaPods.
