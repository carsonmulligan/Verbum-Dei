#!/usr/bin/env python3
"""
Script to merge completed Spanish prayers back into the main spanish_prayers.json file.

Usage:
1. Complete the truncated prayers in truncated_spanish_prayers.json
2. Run this script to merge them back into Resources/spanish_prayers.json
"""

import json
import os

def merge_completed_prayers():
    """Merge completed prayers from truncated_spanish_prayers.json into spanish_prayers.json"""
    
    # File paths
    truncated_file = "truncated_spanish_prayers.json"
    main_file = "Resources/spanish_prayers.json"
    backup_file = "Resources/spanish_prayers_backup.json"
    
    # Check if files exist
    if not os.path.exists(truncated_file):
        print(f"Error: {truncated_file} not found!")
        return False
    
    if not os.path.exists(main_file):
        print(f"Error: {main_file} not found!")
        return False
    
    try:
        # Load the truncated prayers file
        with open(truncated_file, 'r', encoding='utf-8') as f:
            truncated_data = json.load(f)
        
        # Load the main Spanish prayers file
        with open(main_file, 'r', encoding='utf-8') as f:
            main_data = json.load(f)
        
        # Create backup
        with open(backup_file, 'w', encoding='utf-8') as f:
            json.dump(main_data, f, ensure_ascii=False, indent=2)
        print(f"Created backup: {backup_file}")
        
        # Get the completed prayers
        completed_prayers = truncated_data.get("truncated_prayers_to_complete", {})
        
        # Count how many prayers are still truncated vs completed
        still_truncated = []
        completed_count = 0
        
        for prayer_key, prayer_text in completed_prayers.items():
            if prayer_text.endswith("..."):
                still_truncated.append(prayer_key)
            else:
                # Update the main file with the completed prayer
                if "spanish_translations" in main_data:
                    main_data["spanish_translations"][prayer_key] = prayer_text
                    completed_count += 1
        
        # Save the updated main file
        with open(main_file, 'w', encoding='utf-8') as f:
            json.dump(main_data, f, ensure_ascii=False, indent=2)
        
        # Report results
        print(f"\n=== Merge Results ===")
        print(f"Total prayers processed: {len(completed_prayers)}")
        print(f"Completed prayers merged: {completed_count}")
        print(f"Still truncated: {len(still_truncated)}")
        
        if still_truncated:
            print(f"\nPrayers still needing completion:")
            for prayer in still_truncated:
                print(f"  - {prayer}")
        
        if completed_count > 0:
            print(f"\nSuccessfully updated {main_file}")
            print(f"Backup saved as {backup_file}")
        
        return True
        
    except json.JSONDecodeError as e:
        print(f"Error parsing JSON: {e}")
        return False
    except Exception as e:
        print(f"Error: {e}")
        return False

def validate_completed_prayers():
    """Check which prayers in the truncated file are still incomplete"""
    
    truncated_file = "truncated_spanish_prayers.json"
    
    if not os.path.exists(truncated_file):
        print(f"Error: {truncated_file} not found!")
        return
    
    try:
        with open(truncated_file, 'r', encoding='utf-8') as f:
            data = json.load(f)
        
        completed_prayers = data.get("truncated_prayers_to_complete", {})
        
        still_truncated = []
        completed = []
        
        for prayer_key, prayer_text in completed_prayers.items():
            if prayer_text.endswith("..."):
                still_truncated.append(prayer_key)
            else:
                completed.append(prayer_key)
        
        print(f"=== Prayer Completion Status ===")
        print(f"Total prayers: {len(completed_prayers)}")
        print(f"Completed: {len(completed)}")
        print(f"Still truncated: {len(still_truncated)}")
        
        if completed:
            print(f"\nCompleted prayers:")
            for prayer in completed:
                print(f"  ✓ {prayer}")
        
        if still_truncated:
            print(f"\nStill need completion:")
            for prayer in still_truncated:
                print(f"  ⚠ {prayer}")
        
    except Exception as e:
        print(f"Error: {e}")

if __name__ == "__main__":
    import sys
    
    if len(sys.argv) > 1 and sys.argv[1] == "validate":
        validate_completed_prayers()
    else:
        print("Spanish Prayer Merger")
        print("====================")
        print()
        print("This script will merge completed prayers from truncated_spanish_prayers.json")
        print("back into Resources/spanish_prayers.json")
        print()
        
        # First show validation
        validate_completed_prayers()
        print()
        
        response = input("Do you want to proceed with merging? (y/n): ")
        if response.lower() in ['y', 'yes']:
            merge_completed_prayers()
        else:
            print("Merge cancelled.") 