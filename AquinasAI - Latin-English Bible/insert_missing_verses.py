import json

def load_json(filename):
    with open(filename, 'r', encoding='utf-8') as f:
        return json.load(f)

def save_json(data, filename):
    with open(filename, 'w', encoding='utf-8') as f:
        json.dump(data, f, indent=2, ensure_ascii=False)

def insert_missing_verses():
    # Load the files
    english_vulgate = load_json('Resources/vulgate_english.json')
    missing_verses = load_json('missing_verse_translations.json')
    
    # Keep track of changes
    changes_made = []
    
    # Insert missing verses
    for book_name, book_data in missing_verses['translations'].items():
        if book_name not in english_vulgate:
            print(f"Warning: Book {book_name} not found in English Vulgate")
            continue
            
        for chapter, verses in book_data.items():
            if chapter not in english_vulgate[book_name]:
                print(f"Warning: Chapter {chapter} not found in {book_name}")
                continue
                
            for verse, content in verses.items():
                # Add the verse
                english_vulgate[book_name][chapter][verse] = content['english']
                changes_made.append(f"{book_name} {chapter}:{verse}")
    
    # Save the updated vulgate
    save_json(english_vulgate, 'Resources/vulgate_english_updated.json')
    
    # Print summary
    print("\nChanges made:")
    for change in changes_made:
        print(f"Added verse: {change}")
    print(f"\nTotal verses added: {len(changes_made)}")
    print("\nUpdated Vulgate saved to 'Resources/vulgate_english_updated.json'")
    print("Please review the changes before replacing the original file.")

if __name__ == "__main__":
    insert_missing_verses() 