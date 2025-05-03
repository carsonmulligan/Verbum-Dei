import json

def load_json(filename):
    with open(filename, 'r', encoding='utf-8') as f:
        return json.load(f)

def save_json(data, filename):
    with open(filename, 'w', encoding='utf-8') as f:
        json.dump(data, f, indent=2, ensure_ascii=False)

def create_aligned_content():
    latin = load_json('esther_latin.json')
    english = load_json('esther_english.json')
    
    # Create new aligned versions
    aligned_latin = {"charset": "utf-8", "Esther": {}}
    aligned_english = {"charset": "utf-8", "Esther": {}}
    
    # Process each chapter in Latin version
    for chapter, verses in latin["Esther"].items():
        if chapter not in aligned_latin["Esther"]:
            aligned_latin["Esther"][chapter] = {}
            aligned_english["Esther"][chapter] = {}
            
        # Process each verse
        for verse, latin_text in verses.items():
            aligned_latin["Esther"][chapter][verse] = latin_text
            # If there's a corresponding English verse, use it
            if chapter in english["Esther"] and verse in english["Esther"][chapter]:
                aligned_english["Esther"][chapter][verse] = english["Esther"][chapter][verse]
            else:
                # Mark missing translations
                aligned_english["Esther"][chapter][verse] = f"[TRANSLATION NEEDED] {latin_text}"
    
    # Save aligned versions
    save_json(aligned_latin, 'esther_latin_aligned.json')
    save_json(aligned_english, 'esther_english_aligned.json')
    
    # Create a mapping file to track verse correspondences
    mapping = {
        "charset": "utf-8",
        "book": "Esther",
        "notes": "This mapping file tracks the correspondence between Latin Vulgate and English translations",
        "verse_mapping": {}
    }
    
    for chapter in aligned_latin["Esther"]:
        for verse in aligned_latin["Esther"][chapter]:
            key = f"{chapter}:{verse}"
            mapping["verse_mapping"][key] = {
                "has_translation": chapter in english["Esther"] and verse in english["Esther"][chapter],
                "latin_text": aligned_latin["Esther"][chapter][verse],
                "english_text": aligned_english["Esther"][chapter][verse]
            }
    
    save_json(mapping, 'esther_mapping.json')

if __name__ == "__main__":
    create_aligned_content() 