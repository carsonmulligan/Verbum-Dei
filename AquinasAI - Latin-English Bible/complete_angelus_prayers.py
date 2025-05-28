#!/usr/bin/env python3
"""
Script to complete the remaining 3 Angelus prayers with full Spanish texts
"""

import json
import os

def complete_angelus_prayers():
    """Complete the remaining Angelus prayers with full Spanish texts"""
    
    # File paths
    truncated_file = "truncated_spanish_prayers.json"
    
    # Check if file exists
    if not os.path.exists(truncated_file):
        print(f"Error: {truncated_file} not found!")
        return False
    
    try:
        # Load the truncated prayers file
        with open(truncated_file, 'r', encoding='utf-8') as f:
            data = json.load(f)
        
        # Complete Spanish texts for the remaining Angelus prayers
        angelus_prayers = {
            "angelus_domini": """℣. El Ángel del Señor anunció a María.
℟. Y concibió por obra del Espíritu Santo.

Dios te salve, María, llena eres de gracia;
el Señor es contigo.
Bendita tú eres entre todas las mujeres,
y bendito es el fruto de tu vientre, Jesús.
Santa María, Madre de Dios,
ruega por nosotros, pecadores,
ahora y en la hora de nuestra muerte. Amén.

℣. He aquí la esclava del Señor.
℟. Hágase en mí según tu palabra.

Dios te salve, María, llena eres de gracia;
el Señor es contigo.
Bendita tú eres entre todas las mujeres,
y bendito es el fruto de tu vientre, Jesús.
Santa María, Madre de Dios,
ruega por nosotros, pecadores,
ahora y en la hora de nuestra muerte. Amén.

℣. Y el Verbo se hizo carne.
℟. Y habitó entre nosotros.

Dios te salve, María, llena eres de gracia;
el Señor es contigo.
Bendita tú eres entre todas las mujeres,
y bendito es el fruto de tu vientre, Jesús.
Santa María, Madre de Dios,
ruega por nosotros, pecadores,
ahora y en la hora de nuestra muerte. Amén.

℣. Ruega por nosotros, Santa Madre de Dios.
℟. Para que seamos dignos de alcanzar las promesas de Jesucristo.

℣. Oremos.
Derrama, Señor, tu gracia en nuestros corazones;
para que los que hemos conocido la Encarnación de Cristo, tu Hijo,
por el anuncio del Ángel,
por los méritos de su Pasión y Cruz
seamos llevados a la gloria de la Resurrección.
Por el mismo Cristo, Nuestro Señor. Amén.""",

            "angelus_1": """℣. El Ángel del Señor anunció a María.
℟. Y concibió por obra del Espíritu Santo.

Dios te salve, María, llena eres de gracia;
el Señor es contigo.
Bendita tú eres entre todas las mujeres,
y bendito es el fruto de tu vientre, Jesús.
Santa María, Madre de Dios,
ruega por nosotros, pecadores,
ahora y en la hora de nuestra muerte. Amén.""",

            "angelus_2": """℣. He aquí la esclava del Señor.
℟. Hágase en mí según tu palabra.

Dios te salve, María, llena eres de gracia;
el Señor es contigo.
Bendita tú eres entre todas las mujeres,
y bendito es el fruto de tu vientre, Jesús.
Santa María, Madre de Dios,
ruega por nosotros, pecadores,
ahora y en la hora de nuestra muerte. Amén.""",

            "angelus_3": """℣. Y el Verbo se hizo carne.
℟. Y habitó entre nosotros.

Dios te salve, María, llena eres de gracia;
el Señor es contigo.
Bendita tú eres entre todas las mujeres,
y bendito es el fruto de tu vientre, Jesús.
Santa María, Madre de Dios,
ruega por nosotros, pecadores,
ahora y en la hora de nuestra muerte. Amén."""
        }
        
        # Update the truncated prayers with complete versions
        updated_count = 0
        for prayer_key, complete_text in angelus_prayers.items():
            if prayer_key in data["truncated_prayers_to_complete"]:
                data["truncated_prayers_to_complete"][prayer_key] = complete_text
                updated_count += 1
                print(f"✓ Updated {prayer_key}")
        
        # Save the updated file
        with open(truncated_file, 'w', encoding='utf-8') as f:
            json.dump(data, f, ensure_ascii=False, indent=2)
        
        print(f"\n✅ Successfully completed {updated_count} Angelus prayers!")
        print(f"📄 Updated file: {truncated_file}")
        
        # Show completion status
        total_prayers = len(data["truncated_prayers_to_complete"])
        completed_prayers = sum(1 for text in data["truncated_prayers_to_complete"].values() 
                              if not text.endswith("..."))
        
        print(f"\n📊 Final Completion Status:")
        print(f"   Total prayers: {total_prayers}")
        print(f"   Completed: {completed_prayers}")
        print(f"   Remaining: {total_prayers - completed_prayers}")
        print(f"   Progress: {completed_prayers/total_prayers*100:.1f}%")
        
        if completed_prayers == total_prayers:
            print("\n🎉 ALL PRAYERS COMPLETED! 🎉")
        
        return True
        
    except json.JSONDecodeError as e:
        print(f"Error: Invalid JSON in {truncated_file}: {e}")
        return False
    except Exception as e:
        print(f"Error: {e}")
        return False

if __name__ == "__main__":
    complete_angelus_prayers() 