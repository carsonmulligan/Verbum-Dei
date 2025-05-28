# Adding Spanish Translations to Prayers - Implementation Plan

## Current Prayer Structure Analysis

### Existing Prayer Collections
1. **Main Prayers** (`prayers.json`) - 60+ traditional Catholic prayers
2. **Order of Mass** (`order_of_mass.json`) - Complete Mass ordinary with structure
3. **Rosary Prayers** (`rosary_prayers.json`) - Rosary-specific prayers
4. **Liturgy of Hours** (`liturgy_of_hours.json`) - Divine Office prayers with timing
5. **Divine Mercy Chaplet** (`divine_mercy_chaplet.json`) - Structured chaplet prayers
6. **Angelus Domini** (`angelus_domini.json`) - Traditional Angelus with instructions

### Current Prayer Data Structure
```json
{
  "title": "Prayer Name",
  "title_latin": "Latin Title",
  "title_english": "English Title", 
  "latin": "Latin text...",
  "english": "English text...",
  "id": "unique_identifier", // optional
  "tags": ["category1", "category2"], // optional
  "instructions": "When/how to pray", // optional
  "order": 1 // for structured prayers
}
```

## Phase 1: Data Structure Updates

### A. Extend Prayer Model
Update the base prayer structure to include Spanish:

```json
{
  "title": "Prayer Name",
  "title_latin": "Latin Title",
  "title_english": "English Title",
  "title_spanish": "Título Español", // NEW
  "latin": "Latin text...",
  "english": "English text...",
  "spanish": "Texto español...", // NEW
  "id": "unique_identifier",
  "tags": ["category1", "category2"],
  "instructions": "When/how to pray",
  "instructions_spanish": "Cuándo/cómo rezar", // NEW
  "order": 1
}
```

### B. Create Spanish Prayer Mappings
Create `Resources/spanish_prayer_mappings.json`:

```json
{
  "description": "Spanish translations for Catholic prayers",
  "prayer_translations": {
    "pater_noster": {
      "title_spanish": "Padre Nuestro",
      "spanish": "Padre nuestro, que estás en el cielo, santificado sea tu Nombre; venga a nosotros tu reino; hágase tu voluntad en la tierra como en el cielo. Danos hoy nuestro pan de cada día; perdona nuestras ofensas, como también nosotros perdonamos a los que nos ofenden; no nos dejes caer en la tentación, y líbranos del mal. Amén."
    },
    "ave_maria": {
      "title_spanish": "Ave María",
      "spanish": "Dios te salve, María, llena eres de gracia, el Señor es contigo. Bendita tú eres entre todas las mujeres, y bendito es el fruto de tu vientre, Jesús. Santa María, Madre de Dios, ruega por nosotros, pecadores, ahora y en la hora de nuestra muerte. Amén."
    }
    // ... continue for all prayers
  },
  "instruction_translations": {
    "morning_prayer": "Oración matutina",
    "evening_prayer": "Oración vespertina",
    "before_meals": "Antes de las comidas",
    "after_meals": "Después de las comidas"
  }
}
```

## Phase 2: Prayer Categories & Spanish Translations

### A. Essential Prayers (Priority 1)
**Basic Prayers:**
- Pater Noster → Padre Nuestro
- Ave Maria → Ave María  
- Gloria Patri → Gloria al Padre
- Signum Crucis → Señal de la Cruz
- Credo → Credo

**Mass Ordinary:**
- Kyrie Eleison → Señor, Ten Piedad
- Gloria in Excelsis → Gloria a Dios
- Sanctus → Santo, Santo, Santo
- Agnus Dei → Cordero de Dios

### B. Devotional Prayers (Priority 2)
**Marian Prayers:**
- Salve Regina → Salve, Reina
- Memorare → Acordaos
- Ave Regina Caelorum → Ave, Reina de los Cielos
- Alma Redemptoris Mater → Alma Redentora Madre

**Saints & Angels:**
- Sancte Michael Archangele → San Miguel Arcángel
- Angele Dei → Ángel de Dios
- Ad Te, Beate Ioseph → A Ti, San José

### C. Liturgical Prayers (Priority 3)
**Liturgy of Hours:**
- Magnificat → Magníficat
- Benedictus → Bendito
- Nunc Dimittis → Ahora Puedes Despedir

**Seasonal Prayers:**
- Te Deum → Te Deum
- Veni Creator Spiritus → Ven, Espíritu Creador
- Regina Caeli → Reina del Cielo

## Phase 3: Implementation Strategy

### A. Create Spanish Prayer Database
1. **Research authentic Spanish translations** from:
   - Spanish Catholic liturgical books
   - Vatican Spanish translations
   - Traditional Spanish prayer books
   - Episcopal conferences of Spanish-speaking countries

2. **Maintain regional consistency** using:
   - Universal Spanish (avoiding regional dialects)
   - Traditional Catholic terminology
   - Formal liturgical language

### B. Data Migration Process
1. **Create migration script** to:
   - Parse existing prayer files
   - Match prayers with Spanish translations
   - Generate updated JSON files
   - Validate data integrity

2. **Update file structure**:
   ```
   Resources/
   ├── prayers_trilingual.json
   ├── order_of_mass_trilingual.json
   ├── rosary_prayers_trilingual.json
   ├── liturgy_of_hours_trilingual.json
   ├── divine_mercy_chaplet_trilingual.json
   └── angelus_domini_trilingual.json
   ```

### C. App Integration Updates

#### 1. Prayer Models
```swift
struct Prayer: Codable, Identifiable {
    let id: String
    let title: String
    let titleLatin: String
    let titleEnglish: String
    let titleSpanish: String? // NEW
    let latin: String
    let english: String
    let spanish: String? // NEW
    let tags: [String]?
    let instructions: String?
    let instructionsSpanish: String? // NEW
    let order: Int?
}
```

#### 2. Prayer Display Logic
```swift
enum PrayerLanguage: String, CaseIterable {
    case latin = "latin"
    case english = "english"
    case spanish = "spanish"
    
    var displayName: String {
        switch self {
        case .latin: return "Latin"
        case .english: return "English"
        case .spanish: return "Español"
        }
    }
}

enum PrayerDisplayMode: String, CaseIterable {
    case latinOnly = "latinOnly"
    case englishOnly = "englishOnly"
    case spanishOnly = "spanishOnly"
    case latinEnglish = "latinEnglish"
    case latinSpanish = "latinSpanish"
    case englishSpanish = "englishSpanish"
    case trilingual = "trilingual"
}
```

#### 3. Prayer View Updates
- Add language selector to prayer views
- Support for trilingual display modes
- Dynamic text sizing for longer Spanish texts
- Proper Spanish typography and accents

## Phase 4: Quality Assurance

### A. Translation Validation
1. **Theological accuracy** - Ensure doctrinal correctness
2. **Liturgical authenticity** - Match official Church translations
3. **Language quality** - Proper Spanish grammar and style
4. **Cultural sensitivity** - Appropriate for all Spanish-speaking regions

### B. Testing Strategy
1. **Unit tests** for prayer loading and display
2. **UI tests** for language switching
3. **Accessibility tests** for Spanish screen readers
4. **Performance tests** with larger trilingual datasets

## Phase 5: Advanced Features

### A. Prayer Search Enhancement
- Search in Spanish titles and content
- Trilingual search results
- Spanish phonetic search support

### B. Audio Integration (Future)
- Spanish pronunciation guides
- Regional accent options
- Liturgical chant in Spanish

### C. Cultural Adaptations
- Spanish feast day prayers
- Regional devotions (Guadalupe, Santiago, etc.)
- Spanish mystic traditions (Teresa, John of the Cross)

## Implementation Timeline

### Week 1-2: Research & Planning
- Gather authentic Spanish prayer translations
- Create comprehensive translation mappings
- Design updated data structures

### Week 3-4: Data Migration
- Create trilingual prayer files
- Implement migration scripts
- Validate translation accuracy

### Week 5-6: App Integration
- Update prayer models and views
- Implement language selection
- Add trilingual display modes

### Week 7-8: Testing & Polish
- Comprehensive testing
- UI/UX refinements
- Performance optimization

## Success Metrics

1. **Coverage**: 100% of existing prayers translated
2. **Quality**: Liturgically accurate Spanish translations
3. **Usability**: Seamless language switching
4. **Performance**: No degradation with trilingual support
5. **Accessibility**: Full Spanish screen reader support

## Files to Create/Update

### New Files:
- `Resources/spanish_prayer_mappings.json`
- `Resources/prayers_trilingual.json`
- `add_spanish_prayers_migration.swift`

### Updated Files:
- All existing prayer JSON files
- Prayer model classes
- Prayer view components
- Search functionality
- Settings/preferences

This plan provides a systematic approach to adding comprehensive Spanish language support to the prayer functionality, maintaining the same high quality and liturgical authenticity as the existing Latin-English implementation. 