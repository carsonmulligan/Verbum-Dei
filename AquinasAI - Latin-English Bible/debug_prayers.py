#!/usr/bin/env python3

import json
import os

def check_prayer_file(filename):
    """Check if a prayer file exists and can be parsed"""
    filepath = f"Resources/{filename}"
    
    if not os.path.exists(filepath):
        print(f"❌ {filename} - FILE NOT FOUND")
        return False
    
    try:
        with open(filepath, 'r', encoding='utf-8') as f:
            data = json.load(f)
        
        print(f"✅ {filename} - Valid JSON")
        
        # Check structure based on file type
        if filename == "angelus_domini.json":
            if "angelus" in data and "prayers" in data["angelus"]:
                prayers = data["angelus"]["prayers"]
                print(f"   📿 Contains {len(prayers)} angelus prayers")
                for i, prayer in enumerate(prayers):
                    if "title" in prayer and "latin" in prayer and "english" in prayer:
                        print(f"   ✓ Prayer {i+1}: {prayer['title']}")
                    else:
                        print(f"   ❌ Prayer {i+1}: Missing required fields")
            else:
                print(f"   ❌ Invalid structure - missing 'angelus.prayers'")
                
        elif filename == "liturgy_of_hours.json":
            if "liturgy_of_hours" in data and "prayers" in data["liturgy_of_hours"]:
                prayers = data["liturgy_of_hours"]["prayers"]
                print(f"   ⛪ Contains {len(prayers)} liturgy prayers")
                for i, prayer in enumerate(prayers):
                    if "title" in prayer and "latin" in prayer and "english" in prayer:
                        print(f"   ✓ Prayer {i+1}: {prayer['title']}")
                    else:
                        print(f"   ❌ Prayer {i+1}: Missing required fields")
            else:
                print(f"   ❌ Invalid structure - missing 'liturgy_of_hours.prayers'")
        
        return True
        
    except json.JSONDecodeError as e:
        print(f"❌ {filename} - JSON PARSE ERROR: {e}")
        return False
    except Exception as e:
        print(f"❌ {filename} - ERROR: {e}")
        return False

def main():
    print("🔍 Debugging Prayer File Loading\n")
    
    # Check the problematic files
    files_to_check = [
        "angelus_domini.json",
        "liturgy_of_hours.json",
        "prayers.json",
        "rosary_prayers.json",
        "order_of_mass.json",
        "divine_mercy_chaplet.json"
    ]
    
    for filename in files_to_check:
        check_prayer_file(filename)
        print()
    
    # Check for duplicate/legacy files
    print("📁 Checking for duplicate files:")
    all_files = os.listdir("Resources/")
    prayer_files = [f for f in all_files if f.endswith('.json') and 'prayer' in f.lower()]
    
    for f in prayer_files:
        size = os.path.getsize(f"Resources/{f}")
        print(f"   📄 {f} ({size:,} bytes)")

if __name__ == "__main__":
    main() 