import json

def load_json(filename):
    with open(filename, 'r', encoding='utf-8') as f:
        return json.load(f)

def compare_sirach_verse():
    latin = load_json('Resources/vulgate_latin.json')
    english = load_json('Resources/vulgate_english.json')
    
    # Get Latin verse
    latin_verse = latin["Ecclesiasticus"]["1"]["1"]
    print("Latin verse:")
    print(latin_verse)
    print("\nLength:", len(latin_verse), "characters")
    
    # Get English verse
    english_verse = english["Sirach"]["1"]["1"]
    print("\nEnglish verse:")
    print(english_verse)
    print("\nLength:", len(english_verse), "characters")
    
    # Print surrounding verses for context
    print("\nSurrounding verses in Latin:")
    for verse in range(1, 4):
        if str(verse) in latin["Ecclesiasticus"]["1"]:
            print(f"{verse}: {latin['Ecclesiasticus']['1'][str(verse)]}")
            
    print("\nSurrounding verses in English:")
    for verse in range(1, 4):
        if str(verse) in english["Sirach"]["1"]:
            print(f"{verse}: {english['Sirach']['1'][str(verse)]}")

if __name__ == "__main__":
    compare_sirach_verse() 