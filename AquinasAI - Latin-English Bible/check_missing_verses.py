import json

def load_json(filename):
    with open(filename, 'r', encoding='utf-8') as f:
        return json.load(f)

def check_verse(latin, english, latin_book, english_book, chapter, verse):
    print(f"\nChecking {latin_book} ({english_book}) {chapter}:{verse}")
    
    # Check if book exists in both versions
    if latin_book not in latin:
        print(f"Book {latin_book} not found in Latin Vulgate!")
        return
    if english_book not in english:
        print(f"Book {english_book} not found in English Vulgate!")
        print(f"Available English books: {list(english.keys())}")
        return
        
    # Check chapter
    if str(chapter) not in latin[latin_book]:
        print(f"Chapter {chapter} not found in Latin {latin_book}!")
        return
    if str(chapter) not in english[english_book]:
        print(f"Chapter {chapter} not found in English {english_book}!")
        print(f"Latin chapter {chapter} exists with verses: {list(latin[latin_book][str(chapter)].keys())}")
        return
        
    # Check verse
    if str(verse) not in latin[latin_book][str(chapter)]:
        print(f"Verse {verse} not found in Latin chapter!")
        return
    if str(verse) not in english[english_book][str(chapter)]:
        print(f"Verse {verse} not found in English chapter!")
        print("\nLatin text:")
        print(latin[latin_book][str(chapter)][str(verse)])
        # Print surrounding verses for context
        print("\nSurrounding verses in Latin:")
        for v in range(verse-2, verse+3):
            if str(v) in latin[latin_book][str(chapter)]:
                print(f"{v}: {latin[latin_book][str(chapter)][str(v)]}")
        print("\nAvailable verses in English chapter:")
        print(sorted([int(v) for v in english[english_book][str(chapter)].keys()]))
        return
    
    print("Verse exists in both versions:")
    print("\nLatin:", latin[latin_book][str(chapter)][str(verse)])
    print("\nEnglish:", english[english_book][str(chapter)][str(verse)])

def main():
    latin = load_json('Resources/vulgate_latin.json')
    english = load_json('Resources/vulgate_english.json')
    
    # Check each problematic verse with correct book names
    check_verse(latin, english, "Ecclesiasticus", "Sirach", 29, 35)
    check_verse(latin, english, "Machabaeorum I", "1-Maccabees", 11, 50)
    check_verse(latin, english, "ad Thessalonicenses II", "2-Thessalonians", 2, 17)

if __name__ == "__main__":
    main() 