#!/usr/bin/env python3
"""
Script to validate the three-language Bible book mappings
"""

import json
import sys

def load_json_file(filename):
    """Load and return JSON data from file"""
    try:
        with open(filename, 'r', encoding='utf-8') as f:
            return json.load(f)
    except Exception as e:
        print(f"Error loading {filename}: {e}")
        return None

def get_book_names_from_bible_json(filename):
    """Extract book names from Bible JSON file"""
    data = load_json_file(filename)
    if not data:
        return set()
    
    # Filter out non-book keys
    excluded_keys = {'charset', 'lang'}
    return set(key for key in data.keys() if key not in excluded_keys)

def validate_mappings():
    """Validate the three-language mappings"""
    print("🔍 Validating Three-Language Bible Mappings\n")
    
    # Load the mappings
    mappings = load_json_file('Resources/mappings_three_languages.json')
    if not mappings:
        return False
    
    # Load actual book names from JSON files
    latin_books = get_book_names_from_bible_json('Resources/vulgate_latin.json')
    english_books = get_book_names_from_bible_json('Resources/vulgate_english.json')
    spanish_books = get_book_names_from_bible_json('Resources/vulgate_spanish_RV.json')
    
    print(f"📚 Books found in JSON files:")
    print(f"   Latin: {len(latin_books)} books")
    print(f"   English: {len(english_books)} books")
    print(f"   Spanish: {len(spanish_books)} books\n")
    
    # Validate mapping completeness
    errors = []
    warnings = []
    
    # Check if all Latin books have English mappings
    vulgate_to_english = set(mappings['vulgate_to_english'].keys())
    missing_english = latin_books - vulgate_to_english
    if missing_english:
        errors.append(f"❌ Latin books missing English mappings: {missing_english}")
    
    # Check if all Latin books have Spanish mappings
    vulgate_to_spanish = set(mappings['vulgate_to_spanish'].keys())
    missing_spanish = latin_books - vulgate_to_spanish
    if missing_spanish:
        warnings.append(f"⚠️  Latin books missing Spanish mappings: {missing_spanish}")
    
    # Check reverse mappings consistency
    english_to_vulgate = set(mappings['english_to_vulgate'].keys())
    spanish_to_vulgate = set(mappings['spanish_to_vulgate'].keys())
    
    # Validate bidirectional consistency
    for latin, english in mappings['vulgate_to_english'].items():
        if mappings['english_to_vulgate'].get(english) != latin:
            errors.append(f"❌ Bidirectional mapping error: {latin} <-> {english}")
    
    for latin, spanish in mappings['vulgate_to_spanish'].items():
        reverse_latin = mappings['spanish_to_vulgate'].get(spanish)
        if reverse_latin != latin:
            if reverse_latin:
                errors.append(f"❌ Bidirectional mapping error: {latin} -> {spanish} -> {reverse_latin}")
            else:
                warnings.append(f"⚠️  Missing reverse mapping: {spanish} -> {latin}")
    
    # Check for books in JSON files not in mappings
    unmapped_english = english_books - english_to_vulgate
    if unmapped_english:
        warnings.append(f"⚠️  English books not in mappings: {unmapped_english}")
    
    unmapped_spanish = spanish_books - spanish_to_vulgate
    if unmapped_spanish:
        warnings.append(f"⚠️  Spanish books not in mappings: {unmapped_spanish}")
    
    # Check for mappings pointing to non-existent books
    mapped_but_missing_english = vulgate_to_english - latin_books
    if mapped_but_missing_english:
        warnings.append(f"⚠️  Mappings for non-existent Latin books: {mapped_but_missing_english}")
    
    # Print results
    if not errors and not warnings:
        print("✅ All mappings are valid!")
        return True
    
    if warnings:
        print("⚠️  WARNINGS:")
        for warning in warnings:
            print(f"   {warning}")
        print()
    
    if errors:
        print("❌ ERRORS:")
        for error in errors:
            print(f"   {error}")
        print()
        return False
    
    print("✅ No critical errors found (only warnings)")
    return True

def print_mapping_stats():
    """Print statistics about the mappings"""
    mappings = load_json_file('Resources/mappings_three_languages.json')
    if not mappings:
        return
    
    print("📊 Mapping Statistics:")
    print(f"   Vulgate -> English: {len(mappings['vulgate_to_english'])} mappings")
    print(f"   Vulgate -> Spanish: {len(mappings['vulgate_to_spanish'])} mappings")
    print(f"   English -> Vulgate: {len(mappings['english_to_vulgate'])} mappings")
    print(f"   Spanish -> Vulgate: {len(mappings['spanish_to_vulgate'])} mappings")
    print(f"   English -> Spanish: {len(mappings['english_to_spanish'])} mappings")
    print(f"   Spanish -> English: {len(mappings['spanish_to_english'])} mappings")
    
    missing_books = mappings.get('missing_books', {})
    if missing_books.get('latin_only'):
        print(f"\n📖 Books only in Latin: {missing_books['latin_only']}")

if __name__ == "__main__":
    print_mapping_stats()
    print()
    success = validate_mappings()
    sys.exit(0 if success else 1) 