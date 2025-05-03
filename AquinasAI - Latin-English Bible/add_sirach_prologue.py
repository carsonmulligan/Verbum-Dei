import json

def load_json(filename):
    with open(filename, 'r', encoding='utf-8') as f:
        return json.load(f)

def save_json(data, filename):
    with open(filename, 'w', encoding='utf-8') as f:
        json.dump(data, f, indent=2, ensure_ascii=False)

def add_prologue():
    # Load both versions
    latin = load_json('Resources/vulgate_latin.json')
    english = load_json('Resources/vulgate_english.json')
    
    # Extract prologue from Latin verse
    full_text = latin["Ecclesiasticus"]["1"]["1"]
    prologue_end = full_text.find("Omnis sapientia")
    
    latin_prologue = full_text[:prologue_end].strip()
    latin_verse = full_text[prologue_end:].strip()
    
    # Create English translation of the prologue
    english_prologue = """Prologue: Many great teachings have been given to us through the Law and the Prophets and the others that followed them, on account of which we should praise Israel for instruction and wisdom. Now, those who read the scriptures must not only themselves understand them, but must also as lovers of learning be able through the spoken and written word to help those who are outside. My grandfather Jesus, after devoting himself especially to the reading of the Law and the Prophets and the other books of our ancestors, and after acquiring considerable proficiency in them, was himself also led to write something pertaining to instruction and wisdom, so that by becoming familiar with his book those who love learning might make even greater progress in living according to the law. You are urged therefore to read with good will and attention, and to be indulgent in cases where, despite our diligent labor in translating, we may seem to have rendered some phrases imperfectly. For what was originally expressed in Hebrew does not have exactly the same sense when translated into another language. Not only this book, but even the Law itself, the Prophecies, and the rest of the books differ not a little when read in the original. When I came to Egypt in the thirty-eighth year of the reign of King Euergetes and stayed for some time, I found opportunity for no small instruction. It seemed highly necessary that I should myself devote some diligence and labor to the translation of this book. During that time I have applied my skill day and night to complete and publish the book for those living abroad who wished to gain learning and are disposed to live according to the law."""

    # Update Latin version
    latin["Ecclesiasticus"]["1"]["1"] = latin_verse
    latin["Ecclesiasticus"]["0"] = {"1": latin_prologue}
    
    # Update English version
    english["Sirach"]["1"]["1"] = english["Sirach"]["1"]["1"]  # Keep existing verse
    english["Sirach"]["0"] = {"1": english_prologue}
    
    # Save updated versions with _updated suffix
    save_json(latin, 'Resources/vulgate_latin_updated.json')
    save_json(english, 'Resources/vulgate_english_updated.json')
    
    print("Changes made:")
    print("\n1. Separated prologue from Sirach 1:1 in Latin version")
    print("2. Added prologue as chapter 0, verse 1 in both versions")
    print("3. Saved updated versions as *_updated.json")
    print("\nPlease review the changes in the updated files.")
    
    # Print the changes for verification
    print("\nNew Latin structure:")
    print("Prologue (Chapter 0:1):", latin["Ecclesiasticus"]["0"]["1"][:100], "...")
    print("Verse 1:1:", latin["Ecclesiasticus"]["1"]["1"])
    
    print("\nNew English structure:")
    print("Prologue (Chapter 0:1):", english["Sirach"]["0"]["1"][:100], "...")
    print("Verse 1:1:", english["Sirach"]["1"]["1"])

if __name__ == "__main__":
    add_prologue() 