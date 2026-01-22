# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is an iOS app for reading the Bible in multiple languages (Latin, English, Spanish) with parallel text display, built with SwiftUI following MVVM architecture.

## Build and Development Commands

### Building and Running
```bash
# Open in Xcode (project is one level up from source directory)
open "../AquinasAI - Latin-English Bible.xcodeproj"

# Build from command line (requires Xcode Command Line Tools)
xcodebuild -project "../AquinasAI - Latin-English Bible.xcodeproj" -scheme "AquinasAI - Latin-English Bible" -configuration Debug build

# Run on iOS Simulator
xcrun simctl boot "iPhone 15 Pro" # or another available simulator
xcodebuild -project "../AquinasAI - Latin-English Bible.xcodeproj" -scheme "AquinasAI - Latin-English Bible" -destination 'platform=iOS Simulator,name=iPhone 15 Pro' build
```

### Testing
```bash
# Run unit tests
xcodebuild test -project "../AquinasAI - Latin-English Bible.xcodeproj" -scheme "AquinasAI - Latin-English Bible" -destination 'platform=iOS Simulator,name=iPhone 15 Pro'
```

## Architecture

### MVVM Structure
- **Models** (`BibleReader/Models/`): Data structures for Bible content, bookmarks, prayers
  - `BibleContent.swift`: Core Bible data structures (Book, Chapter, Verse)
  - `Prayer.swift`: Prayer models with multi-language support
  - `Bookmark.swift`: User bookmark persistence

- **ViewModels** (`BibleReader/ViewModels/`):
  - `BibleViewModel.swift`: Manages Bible content loading and display modes
  - `BookmarkStore.swift`: Handles bookmark persistence with UserDefaults
  - `SearchViewModel.swift`: Implements Bible search functionality

- **Views** (`BibleReader/Views/`):
  - `ContentView.swift`: Main navigation hub with testament selector
  - `VerseViews.swift`: Verse display with multi-language support
  - `PrayersView.swift`: Prayer browsing and display
  - `RosaryView.swift`: Interactive rosary prayer guide

### Data Sources
- **Bible Content**: JSON files in `Resources/Bible/`
  - `vulgate_latin.json`: Latin Vulgate text
  - `vulgate_english.json`: Catholic Public Domain Version
  - `vulgate_spanish_RV.json`: Spanish Reina-Valera translation

- **Prayer Content**: Separate JSON files in `Resources/`
  - `prayers.json`: Basic prayers collection
  - `rosary_prayers.json`: Rosary-specific prayers
  - `divine_mercy_chaplet.json`: Divine Mercy prayers
  - `order_of_mass.json`: Mass liturgy texts

### Display Modes
The app supports six display modes controlled by `DisplayMode` enum:
- Single language: Latin only, English only, Spanish only
- Bilingual: Latin-English, Latin-Spanish, English-Spanish

### Key Features
- **Parallel Text Display**: Side-by-side verse comparison
- **Bookmark System**: Verse and chapter bookmarking with notes
- **Search**: Full-text search across all languages
- **Prayer Collection**: Traditional Catholic prayers in three languages
- **Dark/Light Mode**: Theme toggle support
- **Chapter Navigation**: Quick chapter switching within books

## Important Conventions

### SwiftUI Patterns
- Use `@StateObject` for view-owned ViewModels
- Use `@EnvironmentObject` for shared state across views
- Prefer `NavigationStack` over deprecated `NavigationView`

### Data Persistence
- Bookmarks stored in UserDefaults via `BookmarkStore`
- No Core Data or external database dependencies

### Color Scheme
- Custom colors defined in `ContentView.swift` extensions
- `.deepPurple`: Primary accent color
- `.paperWhite`: Light mode background
- `.nightBackground`: Dark mode background

### File Organization
- Group related views in single files (e.g., all bookmark views in `BookmarkViews.swift`)
- Keep ViewModels focused on single responsibilities
- Store static data in JSON resources, not hardcoded

## Development Notes

- The Xcode project file is located one directory up from the source code
- All Bible and prayer content is bundled as JSON resources
- The app includes TTS (Text-to-Speech) audio files in `Resources/TTS/`
- Supports iOS 15.0 and later
- Uses native SwiftUI components without external dependencies