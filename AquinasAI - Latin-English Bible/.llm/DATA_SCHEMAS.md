# Data Schemas

## Bible JSON Schema

**Files**: `vulgate_latin.json`, `vulgate_english.json`, `vulgate_spanish_RV.json`

```json
{
  "charset": "UTF-8",
  "lang": "latin|english|spanish",
  "BookName": {
    "1": {
      "1": "First verse text...",
      "2": "Second verse text...",
      "3": "Third verse text..."
    },
    "2": {
      "1": "Chapter 2 verse 1...",
      "2": "Chapter 2 verse 2..."
    }
  }
}
```

**Structure**:
- Top-level keys are book names (e.g., "Genesis", "Exodus")
- Book values are objects with chapter numbers as string keys
- Chapter values are objects with verse numbers as string keys
- Verse values are the actual text content

**Example** (Genesis 1:1 in Latin):
```json
{
  "Genesis": {
    "1": {
      "1": "In principio creavit Deus caelum et terram."
    }
  }
}
```

## Book Name Mappings Schema

**File**: `mappings_three_languages.json`

```json
{
  "Genesis": {
    "latin": "Genesis",
    "english": "Genesis",
    "spanish": "Génesis"
  },
  "Exodus": {
    "latin": "Exodus",
    "english": "Exodus",
    "spanish": "Éxodo"
  }
}
```

**Purpose**: Maps canonical English book names to their equivalents in all three languages.

## Prayer JSON Schema

**File**: `prayers.json`

```json
{
  "prayers": [
    {
      "title": "Prayer Name",
      "title_latin": "Nomen Orationis",
      "title_english": "Prayer Name",
      "title_spanish": "Nombre de Oración",
      "latin": "Full prayer text in Latin...",
      "english": "Full prayer text in English...",
      "spanish": "Full prayer text in Spanish...",
      "instructions": "Optional usage instructions"
    }
  ]
}
```

## Rosary Prayers Schema

**File**: `rosary_prayers.json`

```json
{
  "common_prayers": [
    {
      "name": "Sign of the Cross",
      "name_latin": "Signum Crucis",
      "latin": "...",
      "english": "...",
      "spanish": "..."
    }
  ],
  "joyful_mysteries": [
    {
      "number": 1,
      "title": "The Annunciation",
      "title_latin": "Annuntiatio",
      "title_spanish": "La Anunciación",
      "scripture_reference": "Luke 1:26-38",
      "fruit": "Humility"
    }
  ],
  "sorrowful_mysteries": [...],
  "glorious_mysteries": [...],
  "luminous_mysteries": [...],
  "schedule": {
    "Sunday": "glorious",
    "Monday": "joyful",
    "Tuesday": "sorrowful",
    "Wednesday": "glorious",
    "Thursday": "luminous",
    "Friday": "sorrowful",
    "Saturday": "joyful"
  }
}
```

## Order of Mass Schema

**File**: `order_of_mass.json`

```json
{
  "order_of_mass": {
    "introductory_rites": {
      "title": "Introductory Rites",
      "title_latin": "Ritus Initiales",
      "title_spanish": "Ritos Iniciales",
      "order": [
        {
          "name": "Entrance",
          "name_latin": "Introitus",
          "description": "...",
          "texts": {
            "latin": "...",
            "english": "...",
            "spanish": "..."
          }
        }
      ]
    },
    "liturgy_of_word": {...},
    "liturgy_of_eucharist": {...},
    "communion_rite": {...},
    "concluding_rites": {...}
  }
}
```

## Divine Mercy Chaplet Schema

**File**: `divine_mercy_chaplet.json`

```json
{
  "divine_mercy_chaplet": {
    "title": "Divine Mercy Chaplet",
    "title_latin": "Coronilla Divinae Misericordiae",
    "instructions": "...",
    "prayers": [
      {
        "name": "Opening Prayer",
        "name_latin": "...",
        "when": "At the beginning",
        "latin": "...",
        "english": "...",
        "spanish": "..."
      }
    ]
  }
}
```

## Bookmark (UserDefaults) Schema

**Key**: `SavedBookmarks`

```json
[
  {
    "id": "UUID-string",
    "type": "verse|prayer",
    "bookName": "Genesis",
    "chapterNumber": 1,
    "verseNumber": 1,
    "verseText": "In the beginning...",
    "language": "english",
    "note": "User's note",
    "dateAdded": "2024-01-15T10:30:00Z"
  }
]
```

## Swift Type Mappings

| JSON Field | Swift Type |
|------------|------------|
| String values | `String` |
| Number values | `Int` (parsed from String keys) |
| `type` | `BookmarkType` enum |
| `language` | `Language` enum |
| `id` | `UUID` |
| `dateAdded` | `Date` (ISO8601) |
