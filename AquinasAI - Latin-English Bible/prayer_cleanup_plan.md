# Prayer System Cleanup & Unification Plan

## 🚨 **Current Issues Identified**

### 1. **Code Bug - Missing Case Statements**
- `PrayerStore.loadPrayers()` has incomplete switch statement
- Missing `case "angelus_domini.json":` and `case "liturgy_of_hours.json":` 
- This is why Angelus and Liturgy of Hours show "No Prayers Found"

### 2. **Resource File Chaos**
Current Resources directory has **16 prayer-related files** with massive duplication:

**Active Files (6):**
- `prayers.json` (62KB) - Basic prayers
- `rosary_prayers.json` (13KB) - Rosary prayers  
- `order_of_mass.json` (29KB) - Mass prayers
- `divine_mercy_chaplet.json` (8.4KB) - Divine Mercy prayers
- `angelus_domini.json` (6.1KB) - Angelus prayers
- `liturgy_of_hours.json` (12KB) - Liturgy prayers

**Redundant/Legacy Files (10):**
- `prayers_comprehensive.json` (117KB) - Massive duplicate
- `extracted_prayers_for_migration.json` (107KB) - Migration artifact
- `spanish_prayers.json` (33KB) - Translation source (can be archived)
- `spanish_prayers_backup.json` (32KB) - Backup duplicate
- `prayers_batch1.json`, `prayers_batch2.json`, `prayers_batch3.json` - Migration artifacts
- `combined_prayers_fixed.json` - Migration artifact
- `spanishtrucatesfull.json` - Truncated version
- `mappings_three_languages.json` - Bible mappings (wrong location)

## 🎯 **Proposed Solution: Unified Prayer System**

### **Phase 1: Fix Critical Bug**
1. Fix `PrayerStore.loadPrayers()` switch statement
2. Add missing case statements for Angelus and Liturgy of Hours
3. Test prayer loading functionality

### **Phase 2: Resource Consolidation**
Create a single, well-organized prayer system:

```
Resources/
├── Prayers/
│   ├── prayers.json              # All basic prayers
│   ├── rosary.json              # Rosary prayers & mysteries
│   ├── mass.json                # Order of Mass prayers
│   ├── divine_mercy.json        # Divine Mercy chaplet
│   ├── angelus.json             # Angelus Domini prayers
│   └── liturgy_hours.json       # Liturgy of the Hours
├── Bible/
│   ├── vulgate_latin.json
│   ├── vulgate_english.json
│   ├── vulgate_spanish_RV.json
│   └── mappings_three_languages.json
└── Archive/
    └── [all legacy prayer files]
```

### **Phase 3: Data Model Simplification**
Unify all prayer models into a single, consistent structure:

```swift
struct Prayer: Identifiable, Codable {
    let id: String
    let title: String
    let title_latin: String?
    let title_english: String?
    let title_spanish: String?
    let latin: String
    let english: String
    let spanish: String?
    let category: PrayerCategory
    let order: Int?
    let instructions: String?
    let count: Int?
    let intentions: [String]?
}

struct PrayerCollection: Codable {
    let prayers: [Prayer]
    let metadata: CollectionMetadata?
}

struct CollectionMetadata: Codable {
    let name: String
    let description: String
    let version: String
    let lastUpdated: Date
}
```

### **Phase 4: Simplified Loading System**
Replace complex category-specific containers with unified loading:

```swift
class PrayerStore: ObservableObject {
    @Published var prayers: [Prayer] = []
    
    private let prayerFiles = [
        "prayers.json": PrayerCategory.basic,
        "rosary.json": PrayerCategory.rosary,
        "mass.json": PrayerCategory.mass,
        "divine_mercy.json": PrayerCategory.divine,
        "angelus.json": PrayerCategory.angelus,
        "liturgy_hours.json": PrayerCategory.hours
    ]
    
    func loadPrayers() {
        var allPrayers: [Prayer] = []
        
        for (filename, category) in prayerFiles {
            if let prayers = loadPrayerFile(filename, category: category) {
                allPrayers.append(contentsOf: prayers)
            }
        }
        
        self.prayers = allPrayers
    }
}
```

## 🔧 **Implementation Steps**

### **Step 1: Emergency Fix (Immediate)**
- Fix PrayerStore switch statement
- Test Angelus and Liturgy of Hours loading

### **Step 2: File Reorganization**
- Create new simplified JSON files
- Move Bible files to Bible/ subdirectory
- Archive legacy files

### **Step 3: Code Refactoring**
- Simplify prayer models
- Update PrayerStore loading logic
- Remove category-specific containers

### **Step 4: Testing & Validation**
- Verify all prayers load correctly
- Test all six language modes
- Validate search functionality

## 📊 **Benefits**

1. **Reduced Complexity**: 6 files instead of 16
2. **Consistent Structure**: Single prayer model for all categories
3. **Better Organization**: Logical file structure
4. **Easier Maintenance**: Unified loading system
5. **Improved Performance**: Less file I/O and parsing
6. **Bug Prevention**: Simpler code = fewer bugs

## 🚀 **File Size Reduction**
- Current: ~400KB of prayer files (with duplicates)
- Proposed: ~130KB of prayer files (no duplicates)
- Space saved: ~270KB + better organization 