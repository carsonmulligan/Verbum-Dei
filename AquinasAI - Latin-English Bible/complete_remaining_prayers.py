#!/usr/bin/env python3
"""
Script to complete the remaining 4 truncated Spanish prayers with full texts
"""

import json
import os

def complete_remaining_prayers():
    """Complete the remaining truncated prayers with full Spanish texts"""
    
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
        
        # Complete Spanish texts for the remaining prayers
        complete_prayers = {
            "veni_creator_spiritus": """Ven, Espíritu Creador,
visita las almas de tus fieles
y llena de la divina gracia
los corazones que Tú mismo creaste.

Tú eres nuestro Consolador,
don de Dios Altísimo,
fuente viva, fuego, caridad
y espiritual unción.

Tú derramas sobre nosotros los siete dones;
Tú, el dedo de la mano de Dios;
Tú, el prometido del Padre;
Tú, que pones en nuestros labios
los tesoros de tu palabra.

Enciende con tu luz nuestros sentidos;
infunde tu amor en nuestros corazones;
y, con tu perpetuo auxilio,
fortalece nuestra débil carne.

Aleja de nosotros al enemigo,
danos pronto la paz,
sé Tú mismo nuestro guía,
y puestos bajo tu dirección,
evitaremos todo lo nocivo.

Por Ti conozcamos al Padre,
y también al Hijo;
y que en Ti, Espíritu de entrambos,
creamos en todo tiempo.

Gloria a Dios Padre,
y al Hijo que resucitó,
y al Espíritu Consolador,
por los siglos infinitos. Amén.""",

            "veni_sancte_spiritus_(sequence)": """Ven, Espíritu Divino,
manda tu luz desde el cielo.
Padre amoroso del pobre;
don, en tus dones espléndido;
luz que penetra las almas;
fuente del mayor consuelo.

Ven, dulce huésped del alma,
descanso de nuestro esfuerzo,
tregua en el duro trabajo,
brisa en las horas de fuego,
gozo que enjuga las lágrimas
y reconforta en los duelos.

Entra hasta el fondo del alma,
divina luz y enriquécenos.
Mira el vacío del hombre,
si tú le faltas por dentro;
mira el poder del pecado,
cuando no envías tu aliento.

Riega la tierra en sequía,
sana el corazón enfermo,
lava las manchas, infunde
calor de vida en el hielo,
doma el espíritu indómito,
guía al que tuerce el sendero.

Reparte tus siete dones,
según la fe de tus siervos;
por tu bondad y tu gracia,
dale al esfuerzo su mérito;
salva al que busca salvarse
y danos tu gozo eterno. Amén.""",

            "ave_maris_stella": """Salve, estrella del mar,
Madre y puerta del cielo,
Virgen eternamente feliz.

Recibiendo aquel Ave
de la boca de Gabriel,
confírmanos en la paz,
cambiando el nombre de Eva.

Rompe las cadenas de los reos,
da luz a los ciegos,
aleja nuestros males,
pide todos los bienes.

Muéstrate Madre;
que reciba por ti las súplicas
Aquel que por nosotros nació
y se dignó ser tuyo.

Virgen singular,
mansa entre todas,
líbranos de culpas,
haznos mansos y castos.

Concédenos vida pura,
prepara camino seguro,
para que viendo a Jesús,
nos gocemos siempre.

Alabanza a Dios Padre,
honor al Cristo supremo,
al Espíritu Santo,
honor uno a los tres. Amén.""",

            "te_deum": """Te alabamos, Señor,
y te reconocemos como Dios;
te ensalza el universo entero.
Los ángeles todos, los cielos y sus poderes,
los querubines y serafines
te cantan sin cesar:

Santo, Santo, Santo es el Señor,
Dios del universo;
llenos están los cielos y la tierra
de tu gloria.

Te alaba el glorioso coro de los apóstoles,
la multitud admirable de los profetas,
el ejército resplandeciente de los mártires.

La Iglesia santa, extendida por toda la tierra,
te proclama:
Padre de inmensa majestad,
Hijo único y verdadero, digno de adoración,
Espíritu Santo, Defensor.

Tú eres el Rey de la gloria, Cristo.
Tú eres el Hijo único del Padre.
Tú, para liberar al hombre,
aceptaste hacerte hombre
sin desdeñar el seno de la Virgen.

Tú, rotas las cadenas de la muerte,
abriste a los creyentes el reino de los cielos.
Tú te sientas a la derecha de Dios
en la gloria del Padre.
Creemos que has de venir
como juez.

Te rogamos, pues,
que vengas en ayuda de tus siervos,
a quienes redimiste con tu preciosa sangre.
Haz que en la gloria eterna
nos contemos entre tus santos.

Salva a tu pueblo, Señor,
y bendice tu heredad.
Sé su pastor y ensálzalo eternamente.

Día tras día te bendecimos
y alabamos tu nombre para siempre,
por los siglos de los siglos.

Dígnate, Señor, en este día
guardarnos del pecado.
Ten piedad de nosotros, Señor,
ten piedad de nosotros.

Que tu misericordia, Señor, venga sobre nosotros,
como lo esperamos de ti.
En ti, Señor, esperamos:
no seamos confundidos para siempre. Amén."""
        }
        
        # Update the truncated prayers with complete versions
        updated_count = 0
        for prayer_key, complete_text in complete_prayers.items():
            if prayer_key in data["truncated_prayers_to_complete"]:
                data["truncated_prayers_to_complete"][prayer_key] = complete_text
                updated_count += 1
                print(f"✓ Updated {prayer_key}")
        
        # Save the updated file
        with open(truncated_file, 'w', encoding='utf-8') as f:
            json.dump(data, f, ensure_ascii=False, indent=2)
        
        print(f"\n✅ Successfully completed {updated_count} prayers!")
        print(f"📄 Updated file: {truncated_file}")
        
        # Show completion status
        total_prayers = len(data["truncated_prayers_to_complete"])
        completed_prayers = sum(1 for text in data["truncated_prayers_to_complete"].values() 
                              if not text.endswith("..."))
        
        print(f"\n📊 Completion Status:")
        print(f"   Total prayers: {total_prayers}")
        print(f"   Completed: {completed_prayers}")
        print(f"   Remaining: {total_prayers - completed_prayers}")
        print(f"   Progress: {completed_prayers/total_prayers*100:.1f}%")
        
        return True
        
    except json.JSONDecodeError as e:
        print(f"Error: Invalid JSON in {truncated_file}: {e}")
        return False
    except Exception as e:
        print(f"Error: {e}")
        return False

if __name__ == "__main__":
    complete_remaining_prayers() 