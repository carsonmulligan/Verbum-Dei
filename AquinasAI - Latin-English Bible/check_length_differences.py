import json

def load_json(filename):
    with open(filename, 'r', encoding='utf-8') as f:
        return json.load(f)

def find_significant_differences():
    latin = load_json('Resources/vulgate_latin.json')
    english = load_json('Resources/vulgate_english.json')
    
    # Book name mappings
    book_mappings = {
        "Ecclesiasticus": "Sirach",
        "Machabaeorum I": "1-Maccabees",
        "Machabaeorum II": "2-Maccabees",
        "ad Thessalonicenses II": "2-Thessalonians",
        # Add more mappings as needed
    }
    
    significant_differences = []
    
    # Check each book
    for latin_book in latin:
        if latin_book == "charset":
            continue
            
        # Find corresponding English book name
        english_book = book_mappings.get(latin_book, latin_book)
        if english_book not in english:
            continue
            
        # Check each chapter
        for chapter in latin[latin_book]:
            if chapter not in english[english_book]:
                continue
                
            # Check each verse
            for verse in latin[latin_book][chapter]:
                if verse not in english[english_book][chapter]:
                    continue
                    
                latin_text = latin[latin_book][chapter][verse]
                english_text = english[english_book][chapter][verse]
                
                # Check if Latin is significantly longer (3x or more)
                if len(latin_text) > len(english_text) * 3:
                    # Check for prologue or other indicators
                    has_prologue = "Prologus" in latin_text or "PROLOGUS" in latin_text
                    difference = {
                        "book": f"{latin_book} ({english_book})",
                        "chapter": chapter,
                        "verse": verse,
                        "latin_length": len(latin_text),
                        "english_length": len(english_text),
                        "ratio": len(latin_text) / len(english_text),
                        "has_prologue": has_prologue,
                        "latin_preview": latin_text[:100] + "..." if len(latin_text) > 100 else latin_text,
                        "english_preview": english_text[:100] + "..." if len(english_text) > 100 else english_text
                    }
                    significant_differences.append(difference)
    
    # Sort by ratio of length difference
    significant_differences.sort(key=lambda x: x['ratio'], reverse=True)
    
    # Print findings
    print(f"Found {len(significant_differences)} verses with significant length differences:\n")
    for diff in significant_differences:
        print(f"{diff['book']} {diff['chapter']}:{diff['verse']}")
        print(f"Length ratio (Latin/English): {diff['ratio']:.1f}")
        print(f"Has prologue: {diff['has_prologue']}")
        print("\nLatin preview:")
        print(diff['latin_preview'])
        print("\nEnglish text:")
        print(diff['english_preview'])
        print("\n" + "="*80 + "\n")

if __name__ == "__main__":
    find_significant_differences() 