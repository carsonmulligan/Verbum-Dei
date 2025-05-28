# Plan for Adding Spanish Language Support to AquinasAI Bible App

## Overview
Add Spanish language support to the existing Latin-English Bible app, allowing users to read the Bible in Spanish alongside or instead of Latin and English.

## Current State Analysis
- **Existing Languages**: Latin (Vulgate) and English
- **Current Display Modes**: Latin Only, English Only, Bilingual (Latin-English)
- **Spanish Data**: Already available in `Resources/vulgate_spanish_RV.json`
- **Data Structure**: All three JSON files follow the same structure with book names as keys

## Proposed Language Display Options

### Six Display Modes:
1. **Latin Only** - Current functionality
2. **English Only** - Current functionality  
3. **Spanish Only** - New
4. **Latin-English** - Current bilingual mode
5. **Latin-Spanish** - New bilingual mode
6. **English-Spanish** - New bilingual mode

### UI Design for Language Selection:
- Replace current binary toggle with a more sophisticated language selector
- Options:
  - **Primary Language Selector**: Latin | English | Spanish
  - **Secondary Language Toggle**: None | Latin | English | Spanish (excluding primary)
  - Or use a segmented control with the 6 modes listed above

## Technical Implementation Plan

### 1. Data Model Updates

#### A. Extend `Verse` Model
```swift
struct Verse: Identifiable, Equatable {
    let id: String
    let number: Int
    let latinText: String
    let englishText: String
    let spanishText: String  // NEW
}
```

#### B. Update `DisplayMode` Enum
```swift
enum DisplayMode: CaseIterable {
    case latinOnly
    case englishOnly
    case spanishOnly           // NEW
    case latinEnglish         // Renamed from bilingual
    case latinSpanish         // NEW
    case englishSpanish       // NEW
    
    var description: String { ... }
    var languages: [Language] { ... }
}

enum Language: CaseIterable {
    case latin, english, spanish
    
    var displayName: String { ... }
    var jsonFileName: String { ... }
}
```

### 2. Mapping System Updates

#### A. Extend `mappings.json`
Add Spanish book name mappings:
```json
{
    "description": "Mapping between Vulgate (Latin), English, and Spanish book names",
    "vulgate_to_english": { ... existing ... },
    "vulgate_to_spanish": {
        "Genesis": "Génesis",
        "Exodus": "Éxodo",
        "ad Corinthios I": "1 Corintios",
        // ... complete mapping
    },
    "english_to_vulgate": { ... existing ... },
    "spanish_to_vulgate": {
        "Génesis": "Genesis",
        "Éxodo": "Exodus", 
        "1 Corintios": "ad Corinthios I",
        // ... complete mapping
    },
    "english_to_spanish": { ... },
    "spanish_to_english": { ... }
}
```

#### B. Update `BookNameMappings` Struct
```swift
struct BookNameMappings: Codable {
    let description: String
    let vulgate_to_english: [String: String]
    let vulgate_to_spanish: [String: String]  // NEW
    let english_to_vulgate: [String: String]
    let spanish_to_vulgate: [String: String]  // NEW
    let english_to_spanish: [String: String]  // NEW
    let spanish_to_english: [String: String]  // NEW
}
```

### 3. BibleViewModel Updates

#### A. Load Three Language Files
```swift
private func loadBibleContent() {
    guard let latinUrl = Bundle.main.url(forResource: "vulgate_latin", withExtension: "json"),
          let englishUrl = Bundle.main.url(forResource: "vulgate_english", withExtension: "json"),
          let spanishUrl = Bundle.main.url(forResource: "vulgate_spanish_RV", withExtension: "json") else {
        // handle error
    }
    
    // Load and merge all three languages
}
```

#### B. Three-Way Merge Logic
- Use Latin as the canonical structure (since it's the Vulgate)
- Match English and Spanish books/chapters/verses to Latin equivalents
- Handle missing translations gracefully

#### C. Add Language Helper Methods
```swift
func getBookName(for latinName: String, in language: Language) -> String
func getDisplayText(for verse: Verse, in mode: DisplayMode) -> String
```

### 4. UI Updates

#### A. Language Selector Component
Create a new `LanguageSelectorView` to replace the current simple toggle:
```swift
struct LanguageSelectorView: View {
    @Binding var displayMode: DisplayMode
    
    // Grid or segmented control for 6 options
    // Or primary/secondary language dropdowns
}
```

#### B. Update ContentView
- Replace current display mode toggle with new language selector
- Update navigation title based on selected languages
- Handle new display modes in verse rendering

#### C. Verse Display Logic
Update verse rendering to handle three languages:
```swift
struct VerseView: View {
    let verse: Verse
    let displayMode: DisplayMode
    
    var body: some View {
        VStack(alignment: .leading) {
            switch displayMode {
            case .spanishOnly:
                Text(verse.spanishText)
            case .latinSpanish:
                Text(verse.latinText).font(.body)
                Text(verse.spanishText).font(.caption).foregroundColor(.secondary)
            case .englishSpanish:
                Text(verse.englishText).font(.body)
                Text(verse.spanishText).font(.caption).foregroundColor(.secondary)
            // ... other cases
            }
        }
    }
}
```

### 5. Data Preparation

#### A. Analyze Spanish JSON Structure
- Verify book names match expected format
- Check for any structural differences
- Identify any missing books/chapters/verses

#### B. Create Spanish Book Name Mappings
- Map Spanish book names to Latin equivalents
- Handle variations in naming conventions
- Account for books that might be named differently

### 6. Testing Strategy

#### A. Data Integrity Tests
- Verify all three language files load correctly
- Ensure verse counts match across languages
- Test edge cases (missing verses, different chapter counts)

#### B. UI Testing
- Test all 6 display modes
- Verify language switching works smoothly
- Test search functionality with Spanish text
- Verify bookmarks work with Spanish content

### 7. Migration Strategy

#### A. Backwards Compatibility
- Ensure existing bookmarks continue to work
- Migrate existing display mode preferences
- Handle users upgrading from previous version

#### B. Default Settings
- Set sensible defaults for new language options
- Consider user's device language for initial Spanish preference

## Implementation Order

1. **Phase 1**: Data model updates and Spanish data loading
2. **Phase 2**: Extend mappings and three-way merge logic  
3. **Phase 3**: Update UI components for language selection
4. **Phase 4**: Update verse display logic for new modes
5. **Phase 5**: Testing and refinement
6. **Phase 6**: Update search, bookmarks, and other features

## Potential Challenges

1. **Book Name Variations**: Spanish book names in the JSON might not match standard conventions
2. **Verse Numbering**: Different traditions might have different verse numbering
3. **Missing Content**: Some verses might be missing in one language
4. **UI Complexity**: Six display modes might be overwhelming for users
5. **Performance**: Loading three large JSON files might impact startup time

## Alternative UI Approaches

### Option 1: Six-Button Grid
```
[Latin Only]    [English Only]    [Spanish Only]
[Latin-English] [Latin-Spanish]   [English-Spanish]
```

### Option 2: Primary + Secondary Dropdowns
```
Primary: [Latin ▼]  Secondary: [English ▼]
```

### Option 3: Segmented Control with Overflow
```
[Latin] [English] [Spanish] [Bilingual ▼]
```

## Recommended Next Steps

1. Analyze the Spanish JSON file structure in detail
2. Create the Spanish book name mappings
3. Start with Phase 1 implementation
4. Test with a small subset of books first
5. Gather user feedback on preferred UI approach 