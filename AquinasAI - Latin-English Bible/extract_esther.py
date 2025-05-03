import json
import sys

def extract_esther(input_file, output_file):
    with open(input_file, 'r', encoding='utf-8') as f:
        data = json.load(f)
        if 'Esther' in data:
            esther_content = {'charset': 'utf-8', 'Esther': data['Esther']}
            with open(output_file, 'w', encoding='utf-8') as out:
                json.dump(esther_content, out, indent=2, ensure_ascii=False)
            print(f"Extracted Esther content to {output_file}")
        else:
            print(f"No Esther content found in {input_file}")

# Extract from Latin Vulgate
extract_esther('Resources/vulgate_latin.json', 'esther_latin.json')
# Extract from English Vulgate
extract_esther('Resources/vulgate_english.json', 'esther_english.json') 