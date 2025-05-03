import json

def load_json(filename):
    with open(filename, 'r', encoding='utf-8') as f:
        return json.load(f)

def save_json(data, filename):
    with open(filename, 'w', encoding='utf-8') as f:
        json.dump(data, f, indent=2, ensure_ascii=False)

def update_vulgate():
    # Load files
    vulgate = load_json('Resources/vulgate_english.json')
    updated_esther = load_json('esther_english_updated.json')
    
    # Comment out old Esther by adding prefix to each verse
    if 'Esther' in vulgate:
        for chapter in vulgate['Esther']:
            for verse in vulgate['Esther'][chapter]:
                vulgate['Esther'][chapter][verse] = "/* OLD VERSION: " + vulgate['Esther'][chapter][verse] + " */"
    
    # Add updated Esther
    vulgate['Esther'] = updated_esther['Esther']
    
    # Save updated Vulgate
    save_json(vulgate, 'Resources/vulgate_english.json')
    print("Successfully updated Esther in the English Vulgate")

if __name__ == "__main__":
    update_vulgate() 