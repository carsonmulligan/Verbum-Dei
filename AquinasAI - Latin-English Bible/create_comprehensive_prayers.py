#!/usr/bin/env python3
"""
Script to create comprehensive prayer files with Spanish translations merged in.
This will update all prayer JSON files to include Spanish text where available.
"""

import json
import os
from typing import Dict, Any, List

def load_spanish_translations() -> Dict[str, str]:
    """Load Spanish translations from the spanish_prayers.json file."""
    try:
        with open('Resources/spanish_prayers.json', 'r', encoding='utf-8') as f:
            data = json.load(f)
            return data.get('spanish_translations', {})
    except FileNotFoundError:
        print("❌ Spanish prayers file not found")
        return {}
    except json.JSONDecodeError as e:
        print(f"❌ Error decoding Spanish prayers: {e}")
        return {}

def normalize_key(text: str) -> str:
    """Normalize a text string to match prayer IDs."""
    return text.lower().replace(' ', '_').replace(',', '').replace('.', '').replace("'", '').replace('"', '').replace('(', '').replace(')', '')

def find_spanish_translation(prayer_data: Dict[str, Any], translations: Dict[str, str]) -> str:
    """Find Spanish translation for a prayer using various matching strategies."""
    
    # Try direct key matches
    possible_keys = []
    
    # Add title variations
    if 'title' in prayer_data:
        possible_keys.append(normalize_key(prayer_data['title']))
        possible_keys.append(prayer_data['title'].lower())
    
    if 'title_latin' in prayer_data and prayer_data['title_latin']:
        possible_keys.append(normalize_key(prayer_data['title_latin']))
        possible_keys.append(prayer_data['title_latin'].lower())
    
    if 'title_english' in prayer_data and prayer_data['title_english']:
        possible_keys.append(normalize_key(prayer_data['title_english']))
        possible_keys.append(prayer_data['title_english'].lower())
    
    # Try exact matches first
    for key in possible_keys:
        if key in translations:
            return translations[key]
    
    # Try partial matches
    for key in possible_keys:
        for trans_key, trans_value in translations.items():
            if key in trans_key or trans_key in key:
                return trans_value
    
    return None

def update_basic_prayers(translations: Dict[str, str]) -> None:
    """Update the basic prayers.json file with Spanish translations."""
    try:
        with open('Resources/prayers.json', 'r', encoding='utf-8') as f:
            data = json.load(f)
        
        updated_count = 0
        for prayer in data['prayers']:
            spanish_text = find_spanish_translation(prayer, translations)
            if spanish_text:
                prayer['spanish'] = spanish_text
                updated_count += 1
        
        # Write back to file
        with open('Resources/prayers.json', 'w', encoding='utf-8') as f:
            json.dump(data, f, indent=2, ensure_ascii=False)
        
        print(f"✅ Updated {updated_count} basic prayers with Spanish translations")
        
    except Exception as e:
        print(f"❌ Error updating basic prayers: {e}")

def update_rosary_prayers(translations: Dict[str, str]) -> None:
    """Update the rosary prayers with Spanish translations."""
    try:
        with open('Resources/rosary_prayers.json', 'r', encoding='utf-8') as f:
            data = json.load(f)
        
        updated_count = 0
        for prayer_key, prayer_data in data['common_prayers'].items():
            spanish_text = find_spanish_translation(prayer_data, translations)
            if spanish_text:
                prayer_data['spanish'] = spanish_text
                updated_count += 1
        
        # Write back to file
        with open('Resources/rosary_prayers.json', 'w', encoding='utf-8') as f:
            json.dump(data, f, indent=2, ensure_ascii=False)
        
        print(f"✅ Updated {updated_count} rosary prayers with Spanish translations")
        
    except Exception as e:
        print(f"❌ Error updating rosary prayers: {e}")

def update_mass_prayers(translations: Dict[str, str]) -> None:
    """Update the mass prayers with Spanish translations."""
    try:
        with open('Resources/order_of_mass.json', 'r', encoding='utf-8') as f:
            data = json.load(f)
        
        updated_count = 0
        for prayer in data['prayers']:
            spanish_text = find_spanish_translation(prayer, translations)
            if spanish_text:
                prayer['spanish'] = spanish_text
                updated_count += 1
        
        # Write back to file
        with open('Resources/order_of_mass.json', 'w', encoding='utf-8') as f:
            json.dump(data, f, indent=2, ensure_ascii=False)
        
        print(f"✅ Updated {updated_count} mass prayers with Spanish translations")
        
    except Exception as e:
        print(f"❌ Error updating mass prayers: {e}")

def update_divine_mercy_prayers(translations: Dict[str, str]) -> None:
    """Update the divine mercy prayers with Spanish translations."""
    try:
        with open('Resources/divine_mercy_chaplet.json', 'r', encoding='utf-8') as f:
            data = json.load(f)
        
        updated_count = 0
        for prayer_key, prayer_data in data['divine_mercy_chaplet']['common_prayers'].items():
            spanish_text = find_spanish_translation(prayer_data, translations)
            if spanish_text:
                prayer_data['spanish'] = spanish_text
                updated_count += 1
        
        # Write back to file
        with open('Resources/divine_mercy_chaplet.json', 'w', encoding='utf-8') as f:
            json.dump(data, f, indent=2, ensure_ascii=False)
        
        print(f"✅ Updated {updated_count} divine mercy prayers with Spanish translations")
        
    except Exception as e:
        print(f"❌ Error updating divine mercy prayers: {e}")

def update_angelus_prayers(translations: Dict[str, str]) -> None:
    """Update the angelus prayers with Spanish translations."""
    try:
        with open('Resources/angelus_domini.json', 'r', encoding='utf-8') as f:
            data = json.load(f)
        
        updated_count = 0
        for prayer in data['angelus']['prayers']:
            spanish_text = find_spanish_translation(prayer, translations)
            if spanish_text:
                prayer['spanish'] = spanish_text
                updated_count += 1
        
        # Write back to file
        with open('Resources/angelus_domini.json', 'w', encoding='utf-8') as f:
            json.dump(data, f, indent=2, ensure_ascii=False)
        
        print(f"✅ Updated {updated_count} angelus prayers with Spanish translations")
        
    except Exception as e:
        print(f"❌ Error updating angelus prayers: {e}")

def update_liturgy_hours_prayers(translations: Dict[str, str]) -> None:
    """Update the liturgy of hours prayers with Spanish translations."""
    try:
        with open('Resources/liturgy_of_hours.json', 'r', encoding='utf-8') as f:
            data = json.load(f)
        
        updated_count = 0
        for prayer in data['liturgy_of_hours']['prayers']:
            spanish_text = find_spanish_translation(prayer, translations)
            if spanish_text:
                prayer['spanish'] = spanish_text
                updated_count += 1
        
        # Write back to file
        with open('Resources/liturgy_of_hours.json', 'w', encoding='utf-8') as f:
            json.dump(data, f, indent=2, ensure_ascii=False)
        
        print(f"✅ Updated {updated_count} liturgy of hours prayers with Spanish translations")
        
    except Exception as e:
        print(f"❌ Error updating liturgy of hours prayers: {e}")

def main():
    """Main function to update all prayer files with Spanish translations."""
    print("🚀 Starting comprehensive prayer file updates with Spanish translations...")
    
    # Load Spanish translations
    translations = load_spanish_translations()
    if not translations:
        print("❌ No Spanish translations loaded. Exiting.")
        return
    
    print(f"📚 Loaded {len(translations)} Spanish translations")
    
    # Update each prayer file type
    update_basic_prayers(translations)
    update_rosary_prayers(translations)
    update_mass_prayers(translations)
    update_divine_mercy_prayers(translations)
    update_angelus_prayers(translations)
    update_liturgy_hours_prayers(translations)
    
    print("✅ Comprehensive prayer file updates completed!")
    print("\n📋 Summary:")
    print("- All prayer JSON files have been updated with Spanish translations where available")
    print("- The app can now display prayers in Latin, English, Spanish, and bilingual combinations")
    print("- Six display modes are now supported: Latin, English, Spanish, Latin-English, Latin-Spanish, English-Spanish")

if __name__ == "__main__":
    main() 