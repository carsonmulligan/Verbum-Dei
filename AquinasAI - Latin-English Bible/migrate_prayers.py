#!/usr/bin/env python3
"""
Prayer Migration Script for AquinasAI Bible App
Combines all individual prayer JSON files into comprehensive trilingual format
"""

import json
import os
from typing import Dict, List, Any

def load_json_file(filepath: str) -> Dict[str, Any]:
    """Load and parse a JSON file"""
    try:
        with open(filepath, 'r', encoding='utf-8') as f:
            return json.load(f)
    except FileNotFoundError:
        print(f"Warning: File {filepath} not found")
        return {}
    except json.JSONDecodeError as e:
        print(f"Error parsing {filepath}: {e}")
        return {}

def extract_prayers_from_main(prayers_data: Dict) -> List[Dict]:
    """Extract prayers from prayers.json"""
    prayers = []
    if 'prayers' in prayers_data:
        for prayer in prayers_data['prayers']:
            # Convert to comprehensive format
            prayer_obj = {
                "id": prayer.get('id', prayer.get('title', '').lower().replace(' ', '_')),
                "title": prayer.get('title_english', prayer.get('title', '')),
                "title_latin": prayer.get('title_latin', prayer.get('title', '')),
                "title_english": prayer.get('title_english', prayer.get('title', '')),
                "title_spanish": "",  # To be filled in
                "latin": prayer.get('latin', ''),
                "english": prayer.get('english', ''),
                "spanish": "",  # To be filled in
                "tags": prayer.get('tags', ['devotional']),
                "usage": "devotional"
            }
            prayers.append(prayer_obj)
    return prayers

def extract_prayers_from_mass(mass_data: Dict) -> List[Dict]:
    """Extract prayers from order_of_mass.json"""
    prayers = []
    if 'prayers' in mass_data:
        for prayer in mass_data['prayers']:
            prayer_obj = {
                "id": prayer.get('id', prayer.get('title', '').lower().replace(' ', '_')),
                "title": prayer.get('title_english', prayer.get('title', '')),
                "title_latin": prayer.get('title_latin', prayer.get('title', '')),
                "title_english": prayer.get('title_english', prayer.get('title', '')),
                "title_spanish": "",  # To be filled in
                "latin": prayer.get('latin', ''),
                "english": prayer.get('english', ''),
                "spanish": "",  # To be filled in
                "tags": ["mass"],
                "usage": "mass"
            }
            prayers.append(prayer_obj)
    return prayers

def extract_prayers_from_rosary(rosary_data: Dict) -> List[Dict]:
    """Extract prayers from rosary_prayers.json"""
    prayers = []
    if 'common_prayers' in rosary_data:
        for key, prayer in rosary_data['common_prayers'].items():
            prayer_obj = {
                "id": key,
                "title": prayer.get('title_english', key.replace('_', ' ').title()),
                "title_latin": prayer.get('title_latin', ''),
                "title_english": prayer.get('title_english', ''),
                "title_spanish": "",  # To be filled in
                "latin": prayer.get('latin', ''),
                "english": prayer.get('english', ''),
                "spanish": "",  # To be filled in
                "tags": ["rosary"],
                "usage": "rosary"
            }
            prayers.append(prayer_obj)
    return prayers

def extract_prayers_from_divine_mercy(dm_data: Dict) -> List[Dict]:
    """Extract prayers from divine_mercy_chaplet.json"""
    prayers = []
    if 'divine_mercy_chaplet' in dm_data and 'common_prayers' in dm_data['divine_mercy_chaplet']:
        for key, prayer in dm_data['divine_mercy_chaplet']['common_prayers'].items():
            prayer_obj = {
                "id": key,
                "title": prayer.get('title_english', key.replace('_', ' ').title()),
                "title_latin": prayer.get('title_latin', ''),
                "title_english": prayer.get('title_english', ''),
                "title_spanish": "",  # To be filled in
                "latin": prayer.get('latin', ''),
                "english": prayer.get('english', ''),
                "spanish": "",  # To be filled in
                "tags": ["divine_mercy"],
                "usage": "divine_mercy"
            }
            prayers.append(prayer_obj)
    return prayers

def extract_prayers_from_angelus(angelus_data: Dict) -> List[Dict]:
    """Extract prayers from angelus_domini.json"""
    prayers = []
    if 'angelus' in angelus_data and 'prayers' in angelus_data['angelus']:
        for prayer in angelus_data['angelus']['prayers']:
            prayer_obj = {
                "id": f"angelus_{prayer.get('order', 1)}",
                "order": prayer.get('order'),
                "title": prayer.get('title_english', prayer.get('title', '')),
                "title_latin": prayer.get('title_latin', ''),
                "title_english": prayer.get('title_english', ''),
                "title_spanish": "",  # To be filled in
                "latin": prayer.get('latin', ''),
                "english": prayer.get('english', ''),
                "spanish": "",  # To be filled in
                "instructions": prayer.get('instructions', ''),
                "tags": ["angelus", "marian"],
                "usage": "angelus"
            }
            prayers.append(prayer_obj)
    return prayers

def extract_prayers_from_liturgy_hours(lh_data: Dict) -> List[Dict]:
    """Extract prayers from liturgy_of_hours.json"""
    prayers = []
    if 'liturgy_of_hours' in lh_data and 'prayers' in lh_data['liturgy_of_hours']:
        for prayer in lh_data['liturgy_of_hours']['prayers']:
            prayer_obj = {
                "id": f"lh_{prayer.get('order', 1)}",
                "order": prayer.get('order'),
                "title": prayer.get('title_english', prayer.get('title', '')),
                "title_latin": prayer.get('title_latin', ''),
                "title_english": prayer.get('title_english', ''),
                "title_spanish": "",  # To be filled in
                "latin": prayer.get('latin', ''),
                "english": prayer.get('english', ''),
                "spanish": "",  # To be filled in
                "instructions": prayer.get('instructions', ''),
                "tags": ["liturgy_hours"],
                "usage": "liturgy_hours"
            }
            prayers.append(prayer_obj)
    return prayers

def main():
    """Main migration function"""
    resources_dir = "Resources"
    
    # Load all existing prayer files
    prayers_data = load_json_file(f"{resources_dir}/prayers.json")
    mass_data = load_json_file(f"{resources_dir}/order_of_mass.json")
    rosary_data = load_json_file(f"{resources_dir}/rosary_prayers.json")
    dm_data = load_json_file(f"{resources_dir}/divine_mercy_chaplet.json")
    angelus_data = load_json_file(f"{resources_dir}/angelus_domini.json")
    lh_data = load_json_file(f"{resources_dir}/liturgy_of_hours.json")
    
    # Extract prayers from each file
    all_prayers = {
        "main_prayers": extract_prayers_from_main(prayers_data),
        "mass_prayers": extract_prayers_from_mass(mass_data),
        "rosary_prayers": extract_prayers_from_rosary(rosary_data),
        "divine_mercy_prayers": extract_prayers_from_divine_mercy(dm_data),
        "angelus_prayers": extract_prayers_from_angelus(angelus_data),
        "liturgy_hours_prayers": extract_prayers_from_liturgy_hours(lh_data)
    }
    
    # Generate migration report
    print("=== PRAYER MIGRATION REPORT ===")
    total_prayers = 0
    for category, prayers in all_prayers.items():
        count = len(prayers)
        total_prayers += count
        print(f"{category}: {count} prayers")
        
        # Show first few prayer IDs as examples
        if prayers:
            example_ids = [p['id'] for p in prayers[:3]]
            print(f"  Examples: {', '.join(example_ids)}")
    
    print(f"\nTotal prayers to migrate: {total_prayers}")
    
    # Save extracted prayers for manual review
    output_file = f"{resources_dir}/extracted_prayers_for_migration.json"
    with open(output_file, 'w', encoding='utf-8') as f:
        json.dump(all_prayers, f, indent=2, ensure_ascii=False)
    
    print(f"\nExtracted prayers saved to: {output_file}")
    print("\nNext steps:")
    print("1. Review the extracted prayers")
    print("2. Add Spanish translations to each prayer")
    print("3. Merge into prayers_comprehensive.json")
    print("4. Update your app to use the comprehensive file")

if __name__ == "__main__":
    main() 