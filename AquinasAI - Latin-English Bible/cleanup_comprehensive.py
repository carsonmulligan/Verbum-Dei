#!/usr/bin/env python3
"""
Clean up the comprehensive prayer file by removing duplicates
"""

import json
from typing import Dict, List, Any

def load_comprehensive() -> Dict[str, Any]:
    """Load the comprehensive prayer file"""
    with open("Resources/prayers_comprehensive.json", 'r', encoding='utf-8') as f:
        return json.load(f)

def deduplicate_prayers(prayers: List[Dict[str, Any]]) -> List[Dict[str, Any]]:
    """Remove duplicate prayers based on ID"""
    seen_ids = set()
    unique_prayers = []
    
    for prayer in prayers:
        prayer_id = prayer.get('id', '')
        if prayer_id not in seen_ids:
            seen_ids.add(prayer_id)
            unique_prayers.append(prayer)
        else:
            print(f"Removing duplicate: {prayer_id}")
    
    return unique_prayers

def clean_comprehensive(data: Dict[str, Any]) -> Dict[str, Any]:
    """Clean up the comprehensive prayer data"""
    
    # Deduplicate each collection
    for collection_name, collection in data['prayer_collections'].items():
        if 'prayers' in collection:
            original_count = len(collection['prayers'])
            collection['prayers'] = deduplicate_prayers(collection['prayers'])
            new_count = len(collection['prayers'])
            if original_count != new_count:
                print(f"{collection_name}: {original_count} -> {new_count} prayers")
    
    # Update total count
    total_prayers = sum(len(collection['prayers']) for collection in data['prayer_collections'].values() if 'prayers' in collection)
    data['metadata']['total_prayers'] = total_prayers
    
    # Update prayer categories
    all_prayers = []
    for collection in data['prayer_collections'].values():
        if 'prayers' in collection:
            all_prayers.extend(collection['prayers'])
    
    data['prayer_categories'] = {
        "basic": [p['id'] for p in all_prayers if 'basic' in p.get('tags', [])],
        "mass": [p['id'] for p in all_prayers if 'mass' in p.get('tags', [])],
        "marian": [p['id'] for p in all_prayers if 'marian' in p.get('tags', [])],
        "devotional": [p['id'] for p in all_prayers if 'devotional' in p.get('tags', [])],
        "liturgical": [p['id'] for p in all_prayers if 'liturgical' in p.get('tags', [])]
    }
    
    return data

def main():
    """Clean up the comprehensive prayer file"""
    print("Cleaning up comprehensive prayer file...")
    
    # Load data
    data = load_comprehensive()
    
    # Clean up
    cleaned_data = clean_comprehensive(data)
    
    # Save cleaned version
    with open("Resources/prayers_comprehensive.json", 'w', encoding='utf-8') as f:
        json.dump(cleaned_data, f, indent=2, ensure_ascii=False)
    
    # Print summary
    total_prayers = cleaned_data['metadata']['total_prayers']
    collections = cleaned_data['prayer_collections']
    
    print(f"\n✅ Cleaned comprehensive prayer file")
    print(f"📊 Total prayers: {total_prayers}")
    print("\n📋 Collection breakdown:")
    for name, collection in collections.items():
        if 'prayers' in collection:
            count = len(collection['prayers'])
            print(f"  • {name}: {count} prayers")
    
    # Count Spanish translations
    spanish_count = 0
    for collection in collections.values():
        if 'prayers' in collection:
            for prayer in collection['prayers']:
                if prayer.get('spanish', '').strip():
                    spanish_count += 1
    
    print(f"\n🇪🇸 Spanish translations: {spanish_count}/{total_prayers} ({spanish_count/total_prayers*100:.1f}%)")

if __name__ == "__main__":
    main() 