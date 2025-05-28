#!/usr/bin/env python3
"""
Script to update truncated_spanish_prayers.json with complete prayers from spanishtrucatesfull.json
"""

import json
import os

def update_truncated_prayers():
    """Update truncated prayers with complete versions from spanishtrucatesfull.json"""
    
    # File paths
    full_prayers_file = "Resources/spanishtrucatesfull.json"
    truncated_file = "truncated_spanish_prayers.json"
    
    # Check if files exist
    if not os.path.exists(full_prayers_file):
        print(f"Error: {full_prayers_file} not found!")
        return False
    
    if not os.path.exists(truncated_file):
        print(f"Error: {truncated_file} not found!")
        return False
    
    try:
        # Load the full prayers file
        with open(full_prayers_file, 'r', encoding='utf-8') as f:
            full_prayers = json.load(f)
        
        # Load the truncated prayers file
        with open(truncated_file, 'r', encoding='utf-8') as f:
            truncated_data = json.load(f)
        
        # Update truncated prayers with complete versions
        updated_count = 0
        still_missing = []
        
        for prayer_key in truncated_data["truncated_prayers_to_complete"]:
            if prayer_key in full_prayers:
                # Update with complete version
                truncated_data["truncated_prayers_to_complete"][prayer_key] = full_prayers[prayer_key]
                updated_count += 1
                print(f"✓ Updated: {prayer_key}")
            else:
                still_missing.append(prayer_key)
                print(f"⚠ Still missing: {prayer_key}")
        
        # Save the updated truncated prayers file
        with open(truncated_file, 'w', encoding='utf-8') as f:
            json.dump(truncated_data, f, ensure_ascii=False, indent=2)
        
        print(f"\n=== Update Results ===")
        print(f"Total prayers: {len(truncated_data['truncated_prayers_to_complete'])}")
        print(f"Updated with complete versions: {updated_count}")
        print(f"Still missing: {len(still_missing)}")
        
        if still_missing:
            print(f"\nPrayers still needing completion:")
            for prayer in still_missing:
                print(f"  - {prayer}")
        
        print(f"\nUpdated {truncated_file} successfully!")
        return True
        
    except Exception as e:
        print(f"Error: {e}")
        return False

if __name__ == "__main__":
    print("Updating Truncated Spanish Prayers")
    print("==================================")
    print()
    update_truncated_prayers() 