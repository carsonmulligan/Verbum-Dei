#!/usr/bin/env python3
"""
Create Full Comprehensive Prayer File
Builds complete prayers_comprehensive.json with all 130+ prayers
"""

import json
from typing import Dict, List, Any

# Spanish translations for common prayers (authentic Catholic translations)
SPANISH_TRANSLATIONS = {
    "pater_noster": {
        "title_spanish": "Padre Nuestro",
        "spanish": "Padre nuestro, que estás en el cielo, santificado sea tu Nombre; venga a nosotros tu reino; hágase tu voluntad en la tierra como en el cielo. Danos hoy nuestro pan de cada día; perdona nuestras ofensas, como también nosotros perdonamos a los que nos ofenden; no nos dejes caer en la tentación, y líbranos del mal. Amén."
    },
    "ave_maria": {
        "title_spanish": "Ave María",
        "spanish": "Dios te salve, María, llena eres de gracia, el Señor es contigo. Bendita tú eres entre todas las mujeres, y bendito es el fruto de tu vientre, Jesús. Santa María, Madre de Dios, ruega por nosotros, pecadores, ahora y en la hora de nuestra muerte. Amén."
    },
    "gloria_patri": {
        "title_spanish": "Gloria al Padre",
        "spanish": "Gloria al Padre, y al Hijo, y al Espíritu Santo. Como era en el principio, ahora y siempre, por los siglos de los siglos. Amén."
    },
    "sign_of_the_cross": {
        "title_spanish": "Señal de la Cruz",
        "spanish": "En el nombre del Padre, y del Hijo, y del Espíritu Santo. Amén."
    },
    "credo_(apostles'_creed)": {
        "title_spanish": "Credo de los Apóstoles",
        "spanish": "Creo en Dios, Padre todopoderoso, Creador del cielo y de la tierra. Creo en Jesucristo, su único Hijo, nuestro Señor, que fue concebido por obra y gracia del Espíritu Santo, nació de santa María Virgen, padeció bajo el poder de Poncio Pilato, fue crucificado, muerto y sepultado, descendió a los infiernos, al tercer día resucitó de entre los muertos, subió a los cielos y está sentado a la derecha de Dios, Padre todopoderoso. Desde allí ha de venir a juzgar a vivos y muertos. Creo en el Espíritu Santo, la santa Iglesia católica, la comunión de los santos, el perdón de los pecados, la resurrección de la carne y la vida eterna. Amén."
    },
    "salve_regina": {
        "title_spanish": "Salve, Reina",
        "spanish": "Dios te salve, Reina y Madre de misericordia, vida, dulzura y esperanza nuestra; Dios te salve. A ti llamamos los desterrados hijos de Eva; a ti suspiramos, gimiendo y llorando en este valle de lágrimas. Ea, pues, Señora, abogada nuestra, vuelve a nosotros esos tus ojos misericordiosos; y después de este destierro, muéstranos a Jesús, fruto bendito de tu vientre. ¡Oh clemente, oh piadosa, oh dulce Virgen María!"
    },
    "kyrie_eleison": {
        "title_spanish": "Señor, Ten Piedad",
        "spanish": "Señor, ten piedad. Cristo, ten piedad. Señor, ten piedad."
    },
    "gloria_in_excelsis": {
        "title_spanish": "Gloria a Dios en el Cielo",
        "spanish": "Gloria a Dios en el cielo, y en la tierra paz a los hombres que ama el Señor. Por tu inmensa gloria te alabamos, te bendecimos, te adoramos, te glorificamos, te damos gracias, Señor Dios, Rey celestial, Dios Padre todopoderoso. Señor, Hijo único, Jesucristo. Señor Dios, Cordero de Dios, Hijo del Padre; tú que quitas el pecado del mundo, ten piedad de nosotros; tú que quitas el pecado del mundo, atiende nuestra súplica; tú que estás sentado a la derecha del Padre, ten piedad de nosotros; porque sólo tú eres Santo, sólo tú Señor, sólo tú Altísimo, Jesucristo, con el Espíritu Santo en la gloria de Dios Padre. Amén."
    },
    "sanctus": {
        "title_spanish": "Santo, Santo, Santo",
        "spanish": "Santo, Santo, Santo es el Señor, Dios del universo. Llenos están el cielo y la tierra de tu gloria. Hosanna en el cielo. Bendito el que viene en nombre del Señor. Hosanna en el cielo."
    },
    "agnus_dei": {
        "title_spanish": "Cordero de Dios",
        "spanish": "Cordero de Dios, que quitas el pecado del mundo, ten piedad de nosotros. Cordero de Dios, que quitas el pecado del mundo, ten piedad de nosotros. Cordero de Dios, que quitas el pecado del mundo, danos la paz."
    }
}

def load_extracted_prayers() -> Dict[str, Any]:
    """Load the extracted prayers file"""
    with open("Resources/extracted_prayers_for_migration.json", 'r', encoding='utf-8') as f:
        return json.load(f)

def add_spanish_translation(prayer: Dict[str, Any]) -> Dict[str, Any]:
    """Add Spanish translation if available"""
    prayer_id = prayer.get('id', '')
    
    if prayer_id in SPANISH_TRANSLATIONS:
        translation = SPANISH_TRANSLATIONS[prayer_id]
        prayer['title_spanish'] = translation.get('title_spanish', '')
        prayer['spanish'] = translation.get('spanish', '')
    else:
        # Add placeholder for manual translation
        prayer['title_spanish'] = ""
        prayer['spanish'] = ""
    
    return prayer

def categorize_prayer(prayer: Dict[str, Any], source_category: str) -> Dict[str, Any]:
    """Categorize prayer and add appropriate tags"""
    prayer_id = prayer.get('id', '')
    
    # Update tags based on prayer content and usage
    if source_category == "main_prayers":
        if any(tag in prayer.get('tags', []) for tag in ['mass', 'basic']):
            prayer['tags'] = ['basic', 'devotional']
        else:
            prayer['tags'] = ['devotional']
        prayer['usage'] = 'devotional'
    
    elif source_category == "mass_prayers":
        prayer['tags'] = ['mass', 'liturgical']
        prayer['usage'] = 'mass'
    
    elif source_category == "rosary_prayers":
        prayer['tags'] = ['rosary', 'devotional']
        prayer['usage'] = 'rosary'
    
    elif source_category == "divine_mercy_prayers":
        prayer['tags'] = ['divine_mercy', 'devotional']
        prayer['usage'] = 'divine_mercy'
    
    elif source_category == "angelus_prayers":
        prayer['tags'] = ['angelus', 'marian', 'devotional']
        prayer['usage'] = 'angelus'
    
    elif source_category == "liturgy_hours_prayers":
        prayer['tags'] = ['liturgy_hours', 'liturgical']
        prayer['usage'] = 'liturgy_hours'
    
    return prayer

def create_comprehensive_structure(extracted_data: Dict[str, Any]) -> Dict[str, Any]:
    """Create the full comprehensive prayer structure"""
    
    # Process all prayers
    all_prayers = []
    
    for category, prayers in extracted_data.items():
        for prayer in prayers:
            # Add Spanish translations
            prayer = add_spanish_translation(prayer)
            # Categorize properly
            prayer = categorize_prayer(prayer, category)
            all_prayers.append(prayer)
    
    # Organize prayers by category
    essential_prayers = []
    mass_prayers = []
    devotional_prayers = []
    liturgical_prayers = []
    
    for prayer in all_prayers:
        usage = prayer.get('usage', 'devotional')
        
        # Essential prayers (basic ones used everywhere)
        if prayer.get('id') in ['sign_of_the_cross', 'pater_noster', 'ave_maria', 'gloria_patri', 'apostles_creed']:
            essential_prayers.append(prayer)
        elif usage == 'mass':
            mass_prayers.append(prayer)
        elif usage in ['rosary', 'divine_mercy', 'angelus']:
            devotional_prayers.append(prayer)
        elif usage in ['liturgy_hours']:
            liturgical_prayers.append(prayer)
        else:
            devotional_prayers.append(prayer)
    
    # Create the comprehensive structure
    comprehensive = {
        "metadata": {
            "title": "AquinasAI Comprehensive Prayer Collection",
            "description": "Complete trilingual Catholic prayer collection for AquinasAI Bible App",
            "version": "1.0",
            "languages": ["latin", "english", "spanish"],
            "last_updated": "2024-12-19",
            "total_prayers": len(all_prayers),
            "collections": 6
        },
        
        "prayer_collections": {
            "essential_prayers": {
                "description": "Core Catholic prayers used throughout the liturgy and personal devotion",
                "category": "basic",
                "prayers": essential_prayers
            },
            
            "mass_ordinary": {
                "description": "Prayers of the Mass Ordinary that remain constant throughout the liturgical year",
                "category": "liturgical",
                "prayers": mass_prayers
            },
            
            "devotional_prayers": {
                "description": "Prayers for personal devotion including Rosary, Divine Mercy, and Angelus",
                "category": "devotional",
                "prayers": devotional_prayers
            },
            
            "liturgical_prayers": {
                "description": "Prayers from the Liturgy of the Hours and other liturgical contexts",
                "category": "liturgical",
                "prayers": liturgical_prayers
            }
        },
        
        "display_modes": {
            "single_language": ["latin_only", "english_only", "spanish_only"],
            "bilingual": ["latin_english", "latin_spanish", "english_spanish"],
            "trilingual": ["all_languages"]
        },
        
        "prayer_categories": {
            "basic": [p['id'] for p in essential_prayers],
            "mass": [p['id'] for p in mass_prayers if 'mass' in p.get('tags', [])],
            "marian": [p['id'] for p in all_prayers if 'marian' in p.get('tags', [])],
            "devotional": [p['id'] for p in devotional_prayers],
            "liturgical": [p['id'] for p in liturgical_prayers]
        },
        
        "usage_contexts": {
            "universal": "Used in multiple contexts",
            "mass": "Specific to Mass liturgy",
            "rosary": "Used in Rosary devotion",
            "divine_mercy": "Used in Divine Mercy Chaplet",
            "angelus": "Used in Angelus prayer",
            "liturgy_hours": "Used in Liturgy of the Hours",
            "devotional": "Personal devotional prayers"
        }
    }
    
    return comprehensive

def main():
    """Create the full comprehensive prayer file"""
    print("Creating comprehensive prayer file with all 130+ prayers...")
    
    # Load extracted prayers
    extracted_data = load_extracted_prayers()
    
    # Create comprehensive structure
    comprehensive = create_comprehensive_structure(extracted_data)
    
    # Save the comprehensive file
    output_file = "Resources/prayers_comprehensive_full.json"
    with open(output_file, 'w', encoding='utf-8') as f:
        json.dump(comprehensive, f, indent=2, ensure_ascii=False)
    
    # Print summary
    total_prayers = comprehensive['metadata']['total_prayers']
    collections = comprehensive['prayer_collections']
    
    print(f"\n✅ Created comprehensive prayer file: {output_file}")
    print(f"📊 Total prayers: {total_prayers}")
    print("\n📋 Collection breakdown:")
    for name, collection in collections.items():
        count = len(collection['prayers'])
        print(f"  • {name}: {count} prayers")
    
    # Count Spanish translations
    spanish_count = 0
    for collection in collections.values():
        for prayer in collection['prayers']:
            if prayer.get('spanish', '').strip():
                spanish_count += 1
    
    print(f"\n🇪🇸 Spanish translations: {spanish_count}/{total_prayers} ({spanish_count/total_prayers*100:.1f}%)")
    print(f"📝 Remaining to translate: {total_prayers - spanish_count}")
    
    print("\n🎯 Next steps:")
    print("1. Review prayers_comprehensive_full.json")
    print("2. Add remaining Spanish translations")
    print("3. Replace prayers_comprehensive.json with the full version")
    print("4. Update your app to use the comprehensive file")

if __name__ == "__main__":
    main() 