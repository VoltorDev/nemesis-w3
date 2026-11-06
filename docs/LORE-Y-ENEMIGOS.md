# Lore y enemigos del sistema Némesis

21-10-2026 · Modelo: claude-opus-5-5 · Destino: The Witcher 3 Remastered 5.0 (Steam) con Hearts of Stone (HoS) y Blood and Wine (BaW) · Diseño de partida: [informe de enRAGE](../../../../outputs/enrage-nemesis-witcher3-21-10-2026/INFORME.md) y [PLAN.md](../PLAN.md).

Este documento fija **qué puede ser némesis, con qué facciones y bajo qué reglas de lore**. No sustituye al plan: las decisiones que se acepten se apuntan en `PLAN.md`.

## Resultado

- **Némesis completo** (memoria, rencor, diálogo y facción): solo **humanos y no humanos sapientes genéricos**, es decir, bandidos, desertores, piratas, renegados, cazadores de brujas, bandas de Novigrado, hansas de Toussaint y, con cuidado, elfos y enanos Scoia'tael.
- **Némesis limitado** (recuerda, vuelve con cicatrices, no habla ni tiene facción): alfas y bestias territoriales con apoyo en el bestiario (alghul que lidera ghuls, garkain que lidera vampiros menores, lobo alfa, oso, grifo viudo, leshen con marcado, trol de piedra con diálogo de texto, licántropo, espectro ligado a una venganza).
- **Nunca némesis**: lo que el lore describe como **sin mente o sin individuo** (gólems, elementales, insectoides, ghuls, sumergidos, arpías, sirenas, sabuesos), lo que es **único y de misión** (Cacería Salvaje, vampiros superiores, Moiras, Gran Cuatro, Barón…) y lo **pacífico** (doppler, duende, súcubo).
- **Fase 1:** un **líder de bandidos en Velen** con la plantilla `living_world\enemy_templates\novigrad_bandit_leader_swordshield.w2ent`, lejos de los núcleos de misiones. Es la opción con más lore y menos riesgo (detalle en §6).

## 0. Fuentes y cómo se citan

| Fuente | Qué aporta | Cómo se cita |
|---|---|---|
| Scripts del juego, `C:\Program Files (x86)\Steam\steamapps\common\The Witcher 3\content\content0\scripts\` | Tipos de enemigo en tiempo de ejecución | `archivo.ws:línea` |
| Depot de REDkit, `…\The Witcher 3 REDkit\r4data\` | Plantillas reales y *voicesets* | Ruta relativa a `r4data` |
| **Bestiario del juego**: base de cadenas `r4data\LocalEditorStringDataBaseW3_UTF8.db` (SQLite, solo lectura) | Texto del bestiario en español (idioma 7) | `[BJ recurso.journal #STRING_ID]` |
| Categoría de cada criatura en el bestiario: el aceite que recomienda la entrada `.journal` (`itemsUsedAgainstCreature`) | Qué `EMonsterCategory` le corresponde | `[aceite: X]` |
| **Wiki de comunidad** witcher.fandom.com, leída el 21-10-2026 por su API de MediaWiki (la web devuelve 402/403) | Lore de novelas y juegos | `[W: Página]` = `https://witcher.fandom.com/wiki/Página`, consultado el 21-10-2026 |
| Novelas de Sapkowski | Solo **a través de la wiki**, que cita la obra | "(novela X, vía [W: …])" |

Etiquetas: **[BJ]** = dato del bestiario del juego; **[W]** = dato de la wiki; **[código]** = dato del juego verificado en archivos; **[juicio]** = criterio propio de diseño. Lo dudoso va marcado y se recoge en "No verificado".

La relación "aceite → categoría" es una inferencia: los nombres de aceite coinciden con los valores del enum (`Necrophage`, `Specter`, `Cursed`, `Vampire`, `Relic`, `Hybrid`, `Insectoid`, `Draconide`, `Magicals`, `Beast`), salvo `Ogre`, que se asume `MC_Troll` (ogroides).

## 1. Tipos de enemigo y su inteligencia

### 1.1 Cómo distingue el juego los tipos [código]

- `EMonsterCategory` en `game\types.ws:359-375`: `MC_NotSet, MC_Relic, MC_Necrophage, MC_Cursed, MC_Beast, MC_Insectoid, MC_Vampire, MC_Specter, MC_Draconide, MC_Hybrid, MC_Troll, MC_Human, MC_Unused, MC_Magicals, MC_Animal`.
- Se lee con `theGame.GetMonsterParamsForActor(...)` (`game\r4Game.ws:266`). Atajos: `CActor.IsHuman()` (`game\actor.ws:1641`), `IsMonster()` (`actor.ws:1691`) e `IsAnimal()` (`actor.ws:1712`).
- **Ojo:** `MonsterCategoryIsMonster` (`types.ws:382-388`) devuelve `false` para `MC_Human`, `MC_Animal` **y `MC_Beast`**. Un lobo o un oso no son "monstruo" para `IsMonster()`.
- `ENPCGroupType`: el enum es nativo y no está en los scripts. Valores que aparecen en el código: `ENGT_Enemy`, `ENGT_Commoner`, `ENGT_Guard` y `ENGT_Quest`. Por defecto es `ENGT_Enemy` (`npc\npc.ws:82`) y se lee con `GetNPCType()` (`npc.ws:270`).
- **Protección nativa de PNJ de misión:** al inicializarse, los PNJ `ENGT_Commoner`, `ENGT_Guard` y `ENGT_Quest` quedan en modo *inconsciente* en vez de morir, si no tienen otro modo fijado (`npc.ws:443-466`). El sistema **no debe tocar nunca** la inmortalidad de un `ENGT_Quest`.

### 1.2 Tabla de inteligencia por categoría y especie

Columnas: **Sap.** = ¿es sapiente?; **Mem.** = ¿tiene memoria o rencor personal?; **Habla** = ¿puede hablar o negociar?; **Grupo** = ¿actúa en grupo o con jerarquía? Las plantillas son de `characters\npc_entities\…` salvo que se indique otra ruta.

#### Humanos y no humanos (`MC_Human`)

| Especie / grupo | Plantillas | Sap. | Mem. | Habla | Grupo | Fuente |
|---|---|---|---|---|---|---|
| Humanos (bandidos, desertores, piratas, soldados) | `living_world\enemy_templates\*` (69), `crowd_npc\bandit`, `nilfgaard_soldier`, `redania_soldier`… | Sí | Sí | Sí, aunque en el juego solo con *voicesets* | Sí, con jefes y rangos | [W: Velen], [W: Hanse] |
| Elfos y enanos Scoia'tael | `crowd_npc\scoiatael_soldier\scoiatael_elf_lvl1`, `scoiatael_dwarf_lvl2`, `scoiatael_elf_woman` | Sí | Sí | Sí | Comandos de una veintena; en 1272, restos menguados | [W: Scoia'tael], [W: Nonhuman] |
| Enanos de los bajos fondos | `crowd_npc\novigrad_rogue\novigrad_rogue_dwarf_lvl2`, `novigrad_gang_cleaver` | Sí | Sí | Sí | Banda de Varese "el Carnicero" | [W: Big Four] |

#### Vampiros (`MC_Vampire`)

| Especie | Plantillas | Sap. | Mem. | Habla | Grupo | Fuente |
|---|---|---|---|---|---|---|
| Vampiro superior | Solo personajes únicos: `dlc\bob\…\main_npc\regis`, `dettlaff`, `oriana` | Sí, inteligencia y conducta humanas | Sí | Sí | Solitarios; casi inmortales: solo otro superior los mata del todo | [BJ highervampire.journal #1077673-1077674], [W: Higher Vampire]; Regis en la novela *Bautismo de fuego*, vía [W: Higher Vampire] |
| Bruja (lamia) | `dlc\bob\…\monsters\bruxa`, `dlc\bob\data\living_world\enemy_templates\bruxa_cloaked_hostile_mid` ("Mujer encapuchada") | Sí según la wiki; algunas hablan la lengua común | Probable | Sí en el lore; **en el juego no tienen líneas genéricas** | Solitarias | [BJ bruxa.journal #1188874], [W: Bruxa], [W: Vampire] (novela *El último deseo*) |
| Alpa | `dlc\bob\…\monsters\bruxa_alp` | Dudoso; se mezcla entre la gente con forma humana | Dudoso | No consta | Solitaria | [BJ alp.journal #1208708-1208709] |
| Katakan / nekurat | `vampire_katakan_lvl1/3`, `_mh` | No consta | No consta | No | Acechadores solitarios | [BJ bestiarykatakan.journal #1077667-1077668] |
| Ekimmara | `vampire_ekima_lvl1`, `_mh` | No: el bestiario dice que no son humanos muertos y que son crueles | No | No | No | [BJ bestiaryekkima.journal #1077305, #1077672] |
| Fleder | `dlc\bob\…\monsters\fleder` | No: "menos inteligencia" que otros vampiros | No | No | No | [BJ fleder.journal #1208895] |
| Garkain | `dlc\bob\…\monsters\garkain`, `garkain_mh` | Parcial | No consta | No | **Sí: lidera manadas de otros vampiros menores** | [BJ garkain.journal #1208647-1208648] |

#### Malditos (`MC_Cursed`) [aceite: Cursed]

| Especie | Plantillas | Sap. | Mem. | Habla | Grupo | Fuente |
|---|---|---|---|---|---|---|
| Hombre lobo | `werewolf_lvl1/2`, `_lvl3-5__lycan` | El humano sí; la bestia combina instinto de lobo con astucia humana | **La forma humana no recuerda** lo que hizo la bestia. La wiki matiza que los nacidos lobo controlan el cambio | No en forma bestia | Caza solo; llama a lobos | [BJ bestiarywerewolf.journal #591641, #1077714], [W: Werewolf] |
| Ulfhedinn / voref (Skellige) | `werewolf_lvl3-5__lycan` (asignación por nombre, sin verificar) | Igual que el hombre lobo | Igual | No | Llama a lobos | [BJ lycanthrope.journal #1077716-1077717] |
| Berserker (Skellige) | `crowd_npc\skellige_warrior\skellige_berserker_lvl2` (humano), `monsters\bear_berserker_lvl1` (oso) | Sí en forma humana; en forma de oso pierde la razón | Humano: sí | Humano: sí | Guerreros de clan | [BJ bestiarywerebear.journal #1077712-1077713] |
| Malogrado | `_quest__miscreant*` | No | No | No | No | [BJ bestiarymiscreant.journal #477315]; plantillas solo de misión |

#### Ogroides (`MC_Troll`) [aceite: Ogre]

| Especie | Plantillas | Sap. | Mem. | Habla | Grupo | Fuente |
|---|---|---|---|---|---|---|
| Trol de piedra | `troll_cave_lvl1-3`, `troll_cave_mh__black` | **Sí, limitada**: razona, usa fuego y herramientas | Plausible | **Sí, lengua común básica; adora acertijos y rimas**; puede cobrar peaje y reparar un puente | Solitarios o en pareja | [BJ trollcave.journal #1077866-1077867], [W: Troll] (novela *El último deseo*), [W: Rock troll] |
| Trol de hielo | `troll_cave_lvl3__ice`, `troll_cave_lvl4__ice`, `troll_ice_lvl13` | Limitada | Plausible | **No domina la lengua común**; más cruel | No consta | [BJ icetroll.journal #1077868-1077869] |
| Nekker / fuuca | `nekker_lvl1-3`, `nekker_lvl3__warrior`, `nekker_mh__warrior` | No | No | No | Colonias; los "guerreros" son más fuertes, pero el ataque es desorganizado | [BJ nekker.journal #1077848-1077849] |
| Cíclope | `cyclop_lvl1/2` | No consta | No consta | No | No | [BJ cyclops.journal #1077861-1077862]: odio a los humanos; muy longevos |
| Gigante de hielo | `ice_giant` (jefe de misión) | **Parece razonar**, pero todo intento de hablar con él acaba en muerte | — | No | Somete a sirenas | [BJ icegiant.journal #1077864-1077865] |

#### Necrófagos (`MC_Necrophage`) [aceite: Necrophage]

| Especie | Plantillas | Sap. | Mem. | Habla | Grupo | Fuente |
|---|---|---|---|---|---|---|
| Ghul / graveir | `ghoul_lvl1-3` | **No**: ni razón ni conciencia | No | No | Grupos pequeños | [BJ bestiaryghoul.journal #397259, #1077290] |
| Alghul / cemetauro | `alghoul_lvl1-4`, `alghoul_mh` | **Parcial**: piensa con antelación | No consta | No | **Sí: los ghuls le dejan liderar la manada** | [BJ bestiaryalghoul.journal #397244, #1077291], [W: Alghoul] |
| Sumergido | `drowner_lvl1-4` | No; cobardes por naturaleza | No | No | En grupo | [BJ drowner.journal #1077571] |
| Bruja sepulcral / bruja del agua | `hag_grave_lvl1`, `hag_water_lvl1/2`, `_mh` | No consta | No consta | No | **Territoriales**, con guarida propia | [BJ gravehag.journal #1077604-1077605], [BJ waterhag.journal #1077606-1077607] |
| Necrófago de niebla (fogling) y su variante fuego fatuo | `fogling_lvl1-4`, `fogling_lvl3__willowisp` | No consta | No | No | No consta | [aceite: Necrophage]; sin texto revisado |
| Rotfiend | `rotfiend_lvl1-3` | No | No | No | Grupo | [aceite: Necrophage] |

#### Espectros (`MC_Specter`) [aceite: Specter]

| Especie | Plantillas | Sap. | Mem. | Habla | Grupo | Fuente |
|---|---|---|---|---|---|---|
| Aparición (*wraith*) | `wraith_lvl1-4`, `_mh` | Restos de una persona | **Sí, en sentido amplio**: rabia, sensación de agravio y odio a los vivos; ligada a lugares importantes en vida | No | No | [BJ wraith.journal #1077837-1077838]; la wiki dice que pueden **buscar venganza** [W: Wraith] |
| Dama del mediodía | `noonwraith_lvl1-3`, `_mh` | Restos de una persona | **Sí**: busca al amante infiel o a la rival; ligada a un **objeto** de fuerte carga emocional | No | No | [BJ bestiarynoonwright.journal #397261, #1077306], [W: Noonwraith] |
| Aparición nocturna | `nightwraith_lvl1-3`, `_mh` | Ídem | Tristeza y cólera | No | No | [BJ bestiarymoonwright.journal #397245, #1077804] |
| Hym | `_quest__him` | — | Atormenta solo a culpables de crímenes | Habla solo a su víctima | No | [BJ him.journal #1077281-1077282] |
| Barghest | `dlc\bob\…\monsters\barghest` | No | Ligado a una maldición o a una tragedia pasada | No | **Manada** | [BJ barghests.journal #1208636-1208637] |

#### Híbridos (`MC_Hybrid`) [aceite: Hybrid]

| Especie | Plantillas | Sap. | Mem. | Habla | Grupo | Fuente |
|---|---|---|---|---|---|---|
| Grifo | `gryphon_lvl1-3`, `_mh__volcanic` | No | **Pareja de por vida; defiende a su pareja hasta la muerte** | No | Pareja | [BJ griffin.journal #1077514-1077515] |
| Arpía / ériña | `harpy_lvl1-3` | No; cobardes y cautelosas | No | No | Bandadas de hasta 20 | [BJ harpy.journal #1077902-1077903] |
| Sirena / lamia marina | `siren_lvl1-3`, `siren_mh__lamia` | **En W3, no**; la leyenda dice que antes eran amistosas | Sin rencor individual; "quizá resentidas" como especie | No | Cazan en grupo | [BJ siren.journal #1077907-1077908]. Las sirenas parlantes de las novelas (Sh'eenaz en *La espada del destino*) son **sirénidos**, que la wiki distingue de la sirena monstruo [W: Mermaid], [W: Sh'eenaz] |
| Súcubo | `crowd_npc\succubus` | Sí en apariencia | No consta | Plausible | No | [BJ succubus.journal #1077913-1077914]: pacíficos por naturaleza |

#### Reliquias (`MC_Relic`) [aceite: Relic]

| Especie | Plantillas | Sap. | Mem. | Habla | Grupo | Fuente |
|---|---|---|---|---|---|---|
| Leshen | `lessog_lvl1`, `lessog_lvl2__ancient`, `lessog_mh` | Alta según la wiki | **Marca a una persona y renace mientras el marcado siga en su territorio** | No | Controla animales y plantas; centro de cultos locales | [BJ leshy1.journal #1077921-1077922], [W: Leshen] |
| Demonibestia / chort | `bies_lvl1/2`, `bies_mh`, `czart_lvl1`, `czart_mh` | No; el chort **no habla**, solo gruñe | No | No | Solitarios | [BJ fiend2.journal #1077924-1077925], [BJ czart2.journal #1077928-1077929] |
| Doppler | (sin plantilla genérica hostil) | **Sí, "increíble inteligencia"** | Sí | Sí | Comunidad oculta en Novigrado; perseguidos | [BJ doppler.journal #1082147-1082148], [W: Doppler] |
| Moiras de Cenagal del Jorobado | `_quest__witch_1-3` | Sí | Sí | Sí | Trío; dominan Velen | [BJ witches.journal #1078137], [W: Crones] |
| Silvano, duende | (únicos) | Sí | — | Sí | — | [W: Sylvan], [BJ godling.journal #1078141] |

#### Draconidos (`MC_Draconide`), insectoides (`MC_Insectoid`) y elementa (`MC_Magicals`)

| Especie | Plantillas | Sap. | Mem. | Habla | Grupo | Fuente |
|---|---|---|---|---|---|---|
| Wyverno (y wyverno real) | `wyvern_lvl1/2`, `_mh` | No | No consta; "irascibles" | No | No | [BJ bestiarywyvern.journal #1077794-1077795] |
| Basilisco, cocatriz, cola bífida | `basilisk_lvl1`, `cockatrice_lvl1`, `forktail_lvl1/2` | No | No | No | No | [aceite: Draconide] |
| Endriago, aracas, kikimora | `endriaga_*`, `arachas_*`, `dlc\bob\…\kikimore*` | No | No | No | **Colmena**: obreras, guerreras y reina | [BJ bestiaryendriag.journal #1077728], [BJ kikimora.journal #1208684-1208685], [W: Kikimore] |
| Gólem | `golem_lvl1-3`, `golem_lvl2__ifryt` | **No: materia sin cerebro** que obedece a su creador | No | No | No | [BJ bestiarygolem.journal #1077692-1077693], [W: Golem] |
| Elemental de tierra o de hielo | `elemental_dao_lvl1-3`, `_mh` | **No: sin conciencia ni voluntad propia** | No | No | No | [BJ bestiaryelemental.journal #396141], [BJ icegolem.journal #1077694-1077695] |
| Sabueso de la Cacería Salvaje | `wildhunt_minion_lvl1/2`, `_mh` | No | No | No | Corre con sus amos | [BJ whminion.journal #1077935-1077936] [aceite: Magicals] |

#### Cacería Salvaje (guerreros)

| Especie | Plantillas | Sap. | Mem. | Habla | Grupo | Fuente |
|---|---|---|---|---|---|---|
| Guerreros Aen Elle ("Jinetes Rojos") | `crowd_npc\wild_hunt_lvl3\wild_hunt_lvl3`; generales en `main_npc\eredin`, `imlerith`, `caranthil` | **Sí: son elfos Aen Elle, no espectros** | Sí | Sí | **Ejército**: rey Eredin, generales, navegante, guerreros y sabuesos | [W: Wild Hunt]; novelas *La dama del lago* y *La torre de la golondrina*, vía [W: Wild Hunt]. Su categoría de monstruo no está comprobada |

#### Bestias y animales (`MC_Beast` / `MC_Animal`) [aceite: Beast]

| Especie | Plantillas | Sap. | Mem. | Habla | Grupo | Fuente |
|---|---|---|---|---|---|---|
| Lobo, huargo, lobo blanco | `wolf_lvl1`, `wolf_lvl1__alpha`, `wolf_lvl2__alpha`, `wolf_white_lvl3__alpha` | No, pero "compensan con inteligencia" su debilidad | No | No | **Manada**; los machos fuertes cazan solos | [BJ wolf.journal #1077619-1077620] |
| Oso | `bear_lvl1__black`, `bear_lvl2-3__grizzly`, `bear_lvl3__white` | No | No consta | No | **Solitario** y territorial | [BJ bear.journal #1077636-1077637] |
| Perro salvaje, jabalí, pantera (BaW) | `wild_dog_lvl1`, `dlc\…\wild_boar_*`, `panther_*` | No | No | No | Manada / solitario | [aceite: Beast] |

## 2. Veredicto por tipo

**(a) Némesis completo** · **(b) Némesis limitado** · **(c) Nunca némesis**. La justificación de lore se apoya en la tabla anterior; "[juicio]" marca lo que es decisión de diseño.

| Tipo | Veredicto | Por qué |
|---|---|---|
| Humanos genéricos hostiles (bandido, desertor, pirata, renegado, esclavista, hansa, matón) | **(a)** | Sapientes, organizados en bandas con jefe [W: Hanse]; Velen en 1272 está lleno de "hombres armados de toda clase" [W: Velen]. Hay plantillas con líder y *voicesets* (§3). |
| Cazadores de brujas / Fuego Eterno | **(a)**, solo en Novigrado, Oxenfurt y Velen | Organización fanática con apoyo de la Iglesia [W: Witch hunter]. Un fanático que guarda rencor a un mutante encaja de lleno. **Riesgo:** no hay plantilla "cazador de brujas" genérica en `enemy_templates`; las de `crowd_npc\inquisition_soldier` son de comunidad y su hostilidad está por probar. |
| Elfos y enanos Scoia'tael | **(a)** con cuidado | Sapientes, en comandos con jefe [W: Scoia'tael]. En 1272 son restos menguados y perseguidos [W: Third Nilfgaard War], así que un némesis Scoia'tael debe ser raro, pequeño y con motivos (venganza por un pogromo, no bandidaje). [juicio] |
| Caballeros renegados de la Rosa Llameante (HoS) | **(a)** | Radovid disolvió la Orden; parte de sus miembros se hicieron mercenarios [W: Order of the Flaming Rose]. Plantillas: `dlc\ep1\data\living_world\enemy_templates\flaming_rose_guard_*` ("Caballero renegado"). |
| Berserker de Skellige (forma humana) | **(a)** en forma humana; la forma de oso, como (b) | Humano con una maldición que oculta [BJ bestiarywerebear #1077712-1077713]. Encaja en un clan. [juicio] |
| Trol de piedra | **(b)**, con diálogo de texto | Razona y habla lo básico, le gustan los acertijos y puede negociar un peaje [BJ trollcave], [W: Troll]. Sin facción ni rangos. Rencor por un puente destrozado o por un hermano muerto: plausible [juicio]. Sin voz nueva: solo texto en pantalla. |
| Trol de hielo | **(b)**, sin diálogo | No domina la lengua común y es más cruel [BJ icetroll]. |
| Vampiro superior | **(c)** para el sistema | Sapiente y con rencor (Dettlaff es justo eso), pero **todos los del juego son únicos de BaW**, no hay plantilla genérica, son casi inmortales y "extremadamente raros" [BJ highervampire]. Solo como referencia. |
| Bruja (lamia) y alpa | **(b)**, solo en Toussaint | Pueden ser inteligentes [W: Bruxa] y la alpa se mezcla entre la gente [BJ alp]. Como no hay voz genérica ni facción, se quedan en "la mujer encapuchada que vuelve". La plantilla `bruxa_cloaked_hostile_mid` sirve para eso. |
| Garkain | **(b)**, alfa | Lidera manadas de vampiros menores [BJ garkain]. |
| Katakan | **(b)** débil | Acechador solitario que regenera [BJ bestiarykatakan]. "Vuelve" es creíble; "recuerda", no consta. |
| Ekimmara, fleder | **(c)** | Crueles y de poca inteligencia [BJ bestiaryekkima, fleder]. |
| Hombre lobo / ulfhedinn | **(b)**, ligado a la luna llena | El humano maldito **no recuerda** lo que hace la bestia [BJ bestiarywerewolf]. La memoria del némesis tiene que ser "de la maldición": vuelve a la misma zona en luna llena y huye herido llamando a lobos. Sin diálogo. **El rencor personal es licencia de diseño** [juicio]. |
| Espectro vengativo (aparición, dama del mediodía) | **(b)**, ligado a un lugar o a un objeto | Las apariciones odian a los vivos y pueden buscar venganza [BJ wraith], [W: Wraith]; la dama del mediodía está atada a un objeto [BJ bestiarynoonwright]. **Uso estrella:** un némesis humano muerto por Geralt puede volver como aparición en el lugar de su muerte. No persigue fuera de su sitio. |
| Leshen | **(b)**, con marcado | El marcado es canon: renace mientras el marcado siga en su territorio [BJ leshy1], [W: Leshen]. Es el "vuelve más fuerte" con lore propio. |
| Alghul | **(b)**, alfa de manada | Piensa con antelación y lidera ghuls [BJ bestiaryalghoul]. |
| Grifo | **(b)** | Pareja de por vida que defiende hasta la muerte [BJ griffin]. Un grifo viudo que caza a Geralt es lore directo. |
| Lobo alfa, oso | **(b)** | Manada con macho dominante [BJ wolf]; oso solitario y territorial [BJ bear]. "La bestia que te dejó la cicatriz". Sin diálogo. |
| Wyverno real, cíclope, demonibestia | **(b)** débil | Bestia territorial marcada; el lore no da memoria [juicio]. Opcional. |
| Brujas de cementerio y del agua | **(b)** débil | Territoriales con guarida [BJ gravehag, waterhag]. Prioridad baja. |
| Ghul, sumergido, rotfiend, fogling, nekker, arpía, sirena, insectoides | **(c)** | Sin individuo: masas, colmenas o bandadas sin mente [BJ]. Pueden ser **séquito** de un némesis (b). |
| Gólem, elementales | **(c)** | Sin mente y obedientes a su creador [BJ bestiarygolem], [BJ icegolem]. **El némesis sería el mago que lo crea**, no el gólem [juicio]. |
| Sabuesos y guerreros de la Cacería Salvaje | **(c)** | Ligados a la historia principal (Kaer Morhen, Isla de la Niebla, Eredin). Que aparezcan fuera de guion rompe la trama. Solo referencia. |
| Doppler, duende, súcubo, silvano | **(c)** | Pacíficos o únicos [BJ doppler], [BJ godling], [BJ succubus]. Un doppler perseguido puede ser **víctima** en la crónica, no enemigo. |
| Moiras, malogrado, hym, gigante de hielo, Golyat, jefes de contrato | **(c)** | Únicos y de misión. |

## 3. Facciones por región

### 3.1 Restricción clave: personajes únicos

El sistema **solo usa PNJ genéricos**. No puede convertir en némesis, herir ni matar a un personaje de historia. Regla técnica propuesta [juicio]:

1. **Solo pueden ser némesis los PNJ que el propio sistema genera** desde las plantillas de §3.2–3.8, o enemigos ya existentes con `GetNPCType() == ENGT_Enemy` que **no** salgan de `characters\npc_entities\main_npc\`, `secondary_npc\`, `quests\…` ni `dlc\*\data\quests\…`.
2. Nunca un `ENGT_Quest`, `ENGT_Guard` o `ENGT_Commoner` (`npc.ws:443-466`).
3. Nunca dentro de un área de misión activa, interior o escena (filtro ya previsto en el informe, anexo D).

**Personajes que solo sirven de ambientación** (se pueden nombrar en biografías, rumores o en la crónica; nunca se generan ni se tocan):

| Región | Personajes |
|---|---|
| Huerto Blanco | Capitán Peter Saar Gwynleve (guarnición nilfgaardiana) [W: White Orchard] |
| Velen | El Barón Sangriento (Phillip Strenger), las Moiras, la Abuela del orfanato, Ves y Roche [W: Phillip Strenger], [W: Crones] |
| Novigrado / Oxenfurt | La Gran Cuatro (Francis Bedlam, Whoreson Junior, Carlo Varese, Sigi Reuven / Dijkstra), el jerarca Hemmelfart, Radovid, Menge [W: Big Four], [W: Eternal Fire] |
| Skellige | Crach an Craite, Cerys, Hjalmar, Svanrige, Udalryk, Holger Mano Negra (clan Dimun) [W: Clan Dimun] |
| Kaer Morhen | Vesemir, Lambert, Eskel, la Cacería (Eredin, Imlerith, Caranthir) |
| HoS | Olgierd von Everec y su banda, Gaunter O'Dimm, los Borsody, Shani [W: Olgierd von Everec] |
| Toussaint | Anna Henrietta, Syanna, Dettlaff, Regis, Orianna, Damien de la Tour, y **los tres jefes de hansa**: Filibert Cuatrodedos, Antoine Straggen y Loth el Mestizo [W: Hanse] (tienen plantilla propia en `dlc\bob\data\living_world\enemy_templates\raider_*`, así que se tratan como únicos) |

### 3.2 Cómo detectar la región [código]

- `theGame.GetCommonMapManager().GetCurrentArea()` devuelve un `name` (`commonMapManager.ws:148`). Valores en el código: `AN_Prologue_Village` y `AN_Prologue_Village_Winter` (Huerto Blanco), `AN_NMLandNovigrad`, `AN_Skellige_ArdSkellig`, `AN_Kaer_Morhen`, `AN_Island_of_Myst`, `AN_Spiral`, `AN_Wyzima`, `AN_Bob` / `AN_Dlc_Bob`.
- **Velen y Novigrado/Oxenfurt comparten mundo.** El juego los separa así: en `AN_NMLandNovigrad`, si `X > 970` o `Y < 1600`, es `AN_Velen` (`commonMapManager.ws:348-353`). El sistema puede usar el mismo criterio.
- **Isla de la Niebla, La Espiral y el castillo de Vizima son mundos de misión.** Quedan fuera del sistema.

Los *voicesets* (los gritos de combate grabados) que llevan las plantillas de bandido están comprobados en los binarios del depot. Son la única "voz" del sistema:

| Familia de plantilla | *Voicesets* |
|---|---|
| `baron_renegade_*` | `voiceset_baron` |
| `nml_deserters_*`, `slaver_*` | `voiceset_verden` |
| `novigrad_bandit_*` | `voiceset_temerian`, `voiceset_verden` |
| `nilfgaardian_deserter_*` | `voiceset_nilfgaardian`, `voiceset_novigrad` |
| `lw_giggler_*` | `voiceset_novigrad` |
| `skellige_bandit_*`, `skellige_pirate_*`, `nml_pirates_*` | `voiceset_skellige` (algunas, también `voiceset_novigrad`) |
| `dlc\bob\…\raider_*` | `voiceset_toussaint` |
| `dlc\bob\…\thug_*` | `voiceset_beauclair` |
| `dlc\ep1\…\flaming_rose_guard_*` | `voiceset_rogue` |

### 3.3 Huerto Blanco (prólogo)

Contexto: en primavera de 1272 Nilfgaard tomó Huerto Blanco y dejó una guarnición; el pueblo perdió su independencia [W: White Orchard], [W: Third Nilfgaard War].

| Facción | Plantillas | Rivalidades de lore | Líder |
|---|---|---|---|
| Desertores temerios (soldados vencidos convertidos en salteadores) | `nml_deserters_axe_normal` ("Desertor"), `_bow`, `_sword_easy` | Odian a Nilfgaard y al que colabora con él | Exsargento temerio. **No hay plantilla de líder de desertores**: se usaría una genérica subida de nivel y equipo |
| Desertores nilfgaardianos | `nilfgaardian_deserter_bow`, `_shield`, `_sword_hard` | La guarnición los ahorcaría; los temerios también los odian | Exdecurión |
| Guarnición nilfgaardiana | `crowd_npc\nilfgaard_soldier\*` | — | **No hostil por defecto: no usar** |

Recomendación: **región de baja prioridad**. Es el tutorial, es pequeña y está muy guionizada (grifo, Huerto Blanco). Sirve como origen de biografías ("desertó en Huerto Blanco").

### 3.4 Velen (Tierra de Nadie)

Contexto: provincia temeria arrasada en 1272, con campos de batalla, aldeas destruidas y hambre. Sus caminos están llenos de mercenarios, soldados de legiones temerias disueltas, merodeadores y bandidos. Los hombres del Barón aterrorizan a la población casi tanto como los dos ejércitos [W: Velen]. Las Moiras gobiernan de hecho el Cenagal [W: Crookback Bog].

| Facción | Plantillas (verificadas en el depot) | Dónde la pone el propio juego | Rivalidades de lore | Líder |
|---|---|---|---|---|
| **Bandidos de Velen** | `novigrad_bandit_*`, incluidos `novigrad_bandit_leader_swordshield` y `novigrad_bandit_leader_axe2h`; también `crowd_npc\bandit\bandit_lvl1/2`, `bandit_ranged` | En todo el campo | Contra desertores (botín) y contra la población | **Cabecilla**, con plantilla propia |
| Desertores (temerios y nilfgaardianos) | `nml_deserters_*`, `nilfgaardian_deserter_*` | `living_world\custom_events\nml\greyrocks\gr13_ferry_station_3` (con esclavistas) | Entre ellos (nordling contra imperial); los nilfgaardianos del ejército los persiguen | Exoficial |
| Renegados | `baron_renegade_*`, con jefe `baron_renegade_boss` ("Líder de los renegados") | `custom_events\nml\crow_perch\cp_glinsk` y `custom_events\nml\the_mire\tm12_refugee_camp` | Por su *voiceset* (`voiceset_baron`) están ligados al entorno del Barón. **Que sean hombres expulsados por él o que actúen por su cuenta no está comprobado** | Jefe renegado |
| Esclavistas | `slaver_2h_axe`, `slaver_blunt`, `slaver_sword_easy` ("Conductor de esclavos") | Embarcadero de Greyrocks | Enemigos de todos; aliados ocasionales de desertores | Capataz. Sin plantilla de líder |
| Piratas del Pontar y la costa | `nml_pirates_*` con `nml_pirates_boss` ("Líder pirata") | `custom_events\nml\spitfire_bluff\sb2/sb3/sb14/sb18` (base pirata, notas) | Contra los "Risueños" (las notas de Spitfire Bluff los citan juntos) | Capitán, con plantilla propia |
| "Risueños" (*Gigglers*) | `lw_giggler_melee`, `_melee_spear`, `_ranged`, `lw_giggler_boss` ("Risueño") | `custom_events\nml\spitfire_bluff\sb5_gigglers_hideout` | Rivales de los piratas. **La etiqueta "caníbales" del encargo no la respalda ningún texto del juego**: la plantilla de caníbal es otra (`crowd_npc\bandit\cannibal`, casa de caníbales en `the_descent\de_38`) | Jefe, con plantilla propia |
| Scoia'tael | `crowd_npc\scoiatael_soldier\*` | Campamento en `custom_events\nml\homestead\hs2_scoiatael_camp` | Contra cazadores de brujas, soldados redanios y bandidos humanos | Jefe de comando |
| Caballeros renegados (HoS) | `dlc\ep1\data\living_world\enemy_templates\flaming_rose_guard_*` | Plantillas *living world* de HoS | Contra Redania, que disolvió la Orden | Caballero caído |
| Cazadores de brujas | `crowd_npc\inquisition_soldier\*` | Velen, Novigrado y Oxenfurt según la wiki [W: Witch hunter] | Contra Scoia'tael, magos y dopplers | Capitán cazador. Hostilidad por probar |

**Rivalidades útiles para guerras** [juicio sobre base de lore]: bandidos contra desertores (botín y territorio), piratas contra Risueños (costa de Spitfire Bluff), desertores temerios contra desertores nilfgaardianos (odio nacional), Scoia'tael contra cualquiera humano.

**Zonas a evitar en Velen:** Percha del Cuervo y alrededores (misiones del Barón), Cenagal del Jorobado (Moiras, orfanato), Montecalvo y la Isla de Fyke [W: Crookback Bog], [W: Crow's Perch].

### 3.5 Novigrado y Oxenfurt

Contexto: Novigrado es ciudad libre dentro de Redania. La gobierna el jerarca del Fuego Eterno y los jefes del hampa tienen mucho que decir [W: Novigrad]. Hay cazas de brujas, de no humanos y de dopplers [W: Witch hunts]. Oxenfurt es la ciudad universitaria de Redania [W: Oxenfurt].

| Facción | Plantillas | Rivalidades de lore | Líder |
|---|---|---|---|
| Matones de Whoreson Junior | `crowd_npc\novigrad_rogue\novigrad_gang_whoreson`, `novigrad_rogue_lvl1/2`, `_ranged` | La Gran Cuatro se disputa la ciudad [W: Big Four] | Lugarteniente genérico (nunca Whoreson) |
| Enanos de Carlo Varese ("el Carnicero") | `novigrad_gang_cleaver`, `novigrad_rogue_dwarf_lvl2` | Contra las otras tres bandas | Capataz enano |
| Mendigos de Francis Bedlam | `novigrad_gang_beggar` | Contra Whoreson | Jefe de mendigos |
| Hombres de Sigi Reuven / Dijkstra | `novigrad_gang_djikstra` | Contra Whoreson | Matón de confianza |
| Cazadores de brujas | `crowd_npc\inquisition_soldier\inquisition_soldier_lvl1/2`, `inquisition_torturer_lvl1` | Contra magos, no humanos y dopplers [W: Witch hunter] | Capitán. **Si muere, chocaría con la guardia de la ciudad**: hay que probarlo |
| Soldados redanios y guardia de Novigrado | `crowd_npc\redania_soldier\*`, `novigrad_soldier\*` | — | **No usar: son `ENGT_Guard` o de comunidad** |

**Advertencia de lore:** tras la caída de Whoreson, otros criminales intentaron llenar el vacío [W: Hanse]. Es el hueco natural para un **jefe nuevo y genérico** del sistema, sin tocar a la Gran Cuatro.

**Riesgo alto:** la ciudad está llena de misiones principales y de PNJ de comunidad. Mejor dejarla como teatro de la Fase 2 en adelante y con encuentros solo de noche en barrios concretos [juicio].

### 3.6 Skellige

Contexto: siete clanes con jarl, bajo un rey elegido en asamblea [W: Skellige]. Los continentales los ven como piratas, "y no sin razón" [W: Skellige]. El clan Dimun tiene fama de tramposos, ladrones y saqueadores [W: Clan Dimun].

| Facción | Plantillas | Rivalidades de lore | Líder |
|---|---|---|---|
| Piratas | `skellige_pirate_*`, con `skellige_pirate_leader_swordshield`; `crowd_npc\skellige_pirate\skellige_pirate_lvl1-3` | Por lore, piratas de bandera Dimun contra los demás clanes [juicio basado en [W: Clan Dimun]] | **Capitán**, con plantilla propia |
| Bandidos isleños | `skellige_bandit_*` (14 plantillas; en la base de cadenas figura un `skellige_bandit_leader_hammer2h`, pero el archivo no está en el depot) | Contra granjeros y clanes | Cabecilla genérico |
| Berserkers | `crowd_npc\skellige_warrior\skellige_berserker_lvl2` + `monsters\bear_berserker_lvl1` | Ocultan su don [BJ bestiarywerebear] | Guerrero solitario |
| Guardias de clan (Brokvar, An Craite, Dimun, Drummond, Heymaey) | `gameplay\community\community_npcs\skellige\regular\skellige_warrior_*`, `crowd_npc\skellige_clans\*` | — | **No usar como enemigos**: son de comunidad. Sirven de afiliación ("un antiguo remero Dimun") |

**Zonas a evitar:** Kaer Trolde (coronación y funeral de Bran), Hindarsfjall (templo de Freya), el bosque de Undvik (gigante de hielo).

### 3.7 Kaer Morhen

No hay facción humana plausible. El valle está aislado, los brujos apenas trataban con los kaedwenianos [W: Kaer Morhen] y la Batalla de Kaer Morhen contra la Cacería es misión principal. **Recomendación: excluir Kaer Morhen del sistema.** Como mucho, se pueden usar sus bestias marcadas (lobos, osos), como en §2. El pogromo histórico contra los brujos de Kaedwen [W: Kaer Morhen] es material de biografía.

### 3.8 Hearts of Stone (sobre el mapa de Velen, Novigrado y Oxenfurt)

| Facción | Plantillas | Uso |
|---|---|---|
| Caballeros renegados de la Rosa Llameante | `dlc\ep1\data\living_world\enemy_templates\flaming_rose_guard_bow/halberd/hammer/mace/shield/sword/xbow` | **Facción (a) nueva**, con lore sólido: Radovid vendió sus bienes y disolvió la Orden; parte de sus miembros acabaron de mercenarios [W: Order of the Flaming Rose] |
| Banda de Olgierd (Compañía Libre Redania) | `dlc\ep1\…\crowd_npc\olgierds_gang_members\*` | **Solo referencia**: ligada a la trama de HoS [W: Olgierd von Everec]. Un exmiembro genérico, tras el desenlace, encaja como biografía |
| Soldados ofiri (Hakland) | `crowd_npc\hakland_warrior` | Solo misión |

### 3.9 Toussaint (Blood and Wine)

Contexto: ducado autónomo y vasallo de Nilfgaard. No tiene ejército propio y depende de caballeros andantes y de la Guardia Ducal [W: Toussaint], [W: Knight errant]. Hacia 1275, tres hansas de forajidos se asentaron en el campo y pelearon con caballeros y guardias [W: Hanse].

| Facción | Plantillas (`dlc\bob\data\living_world\enemy_templates\`) | Rivalidades de lore | Líder |
|---|---|---|---|
| **Hansas** ("Bandido de la hansa") | `raider_lvl1_*`, `raider_lvl2_*`, `raider_ranged_*`, `raider_leader` y perros `hansa_dog*` | Contra caballeros andantes y Guardia Ducal; las hansas se ayudan entre campamentos vecinos [W: Hanse] | **Jefe de hansa genérico** con `raider_leader`. Los tres jefes canónicos, solo referencia |
| Matones de Beauclair | `thug_lvl1_*`, `thug_lvl2_*` (`voiceset_beauclair`) | Bajos fondos urbanos | Cabecilla de barrio |
| Bandidos nazairis | Plantillas de misión (`q703_*nazairian*`) y de fondo (`background_npc\bob_bandit\background_nazairi*`) | Nazair es una provincia de Nilfgaard [W: Nazair; no leída en detalle] | **Solo referencia**: las plantillas son de misión o de fondo |
| Caballeros andantes y Guardia Ducal | `crowd_npc\bob_knight\*`, `bob_guard\*` | — | No hostiles: **aliados** potenciales en la crónica |

Vampiros (b): `bruxa_cloaked_hostile_mid` y `garkain_mid` dan némesis limitados con sabor local.

### 3.10 Tabla de rivalidades para guerras (Fase 2)

| Facción A | Facción B | Relación de partida | Base |
|---|---|---|---|
| Bandidos de Velen | Desertores | Hostil, compiten por botín | [W: Velen] [juicio] |
| Desertores temerios | Desertores nilfgaardianos | Muy hostil | Guerra en curso [W: Third Nilfgaard War] |
| Piratas del Pontar | Risueños | Hostil | Notas de `spitfire_bluff\sb3_boatyard` (sin leer su texto) |
| Cazadores de brujas | Scoia'tael | Muy hostil | [W: Witch hunts] |
| Caballeros renegados | Cazadores de brujas | Ambigua: algunos caballeros se unieron a ellos y otros se hicieron mercenarios | [W: Order of the Flaming Rose] |
| Bandas de Novigrado | Entre sí | Hostil, con equilibrio frágil | [W: Big Four], [W: Hanse] |
| Piratas de Skellige | Bandidos isleños | Neutral u oportunista | [juicio] |
| Hansas | Hansas | **Aliadas** (se piden ayuda) | [W: Hanse] |

## 4. Traducción de conceptos de enRAGE al lore de W3

### 4.1 Temperamentos

Se conservan los siete de enRAGE porque sus multiplicadores ya están estudiados (anexo A del informe). Solo cambia el nombre visible y su lectura en el mundo [juicio]:

| enRAGE | En W3 | Quién lo suele tener |
|---|---|---|
| Hothead | **Sanguíneo** | Bandidos jóvenes, piratas de Skellige, berserkers |
| Proud | **Orgulloso** | Caballeros renegados, guerreros de clan, jefes de hansa con ínfulas de nobleza |
| Cold | **Frío** | Desertores nilfgaardianos (disciplina imperial), cazadores de brujas |
| Coward | **Cobarde** | Esclavistas, matones de mendigos |
| Greedy | **Codicioso** | Mercenarios, esclavistas, contrabandistas de Novigrado |
| Loyal | **Leal** | Miembros de clan, Scoia'tael, hombres de un jefe de banda |
| Drifter | **Vagabundo** | Desertores sin bandera, refugiados armados |

El **fanatismo** (Fuego Eterno) se trata como rasgo de devoción alta y no como un octavo temperamento, para no romper la tabla de enRAGE.

### 4.2 Oficios

enRAGE deduce el oficio del nombre del modelo del motor. En W3 se deduce de la **ruta de la plantilla** [juicio]:

- `nml_deserters_*` y `nilfgaardian_deserter_*` → desertor (exsoldado).
- `*_pirate_*` → pirata o remero.
- `slaver_*` → esclavista.
- `novigrad_rogue_*` / `novigrad_gang_*` → matón, ladrón, contrabandista.
- `flaming_rose_guard_*` → caballero caído.
- `raider_*` → forajido de hansa.
- `inquisition_*` → cazador de brujas o torturador.
- Oficios previos para la biografía, de las plantillas civiles: `nml_villager` (campesino de Velen), `novigrad_craftsman`, `skellige_craftsmen`, `bob_vineyard` (vendimiador), `bob_worker`, pescador, leñador, herbolario, carbonero o saqueador de campos de batalla (`lw_de6_scavenger_keyholder` existe como plantilla).

### 4.3 Fes

| Fe | Dónde y entre quién | Fuente |
|---|---|---|
| **Fuego Eterno** | Novigrado y Redania; de ella dependen los cazadores de brujas | [W: Eternal Fire] |
| **Melitele** | Diosa madre del Norte; mujeres, campesinos, leñadores; templos con hospitales y orfanatos | [W: Melitele] |
| **Freya** | Skellige; la sirven solo sacerdotisas; reservada con los magos | [W: Freya] |
| Dioses del mar, **Hemdall** y héroes fundadores | Skellige | [W: Skellige] |
| **Druidas** | Influyentes sobre todo en Skellige | [W: Druid] |
| **Profeta Lebioda** | Novigrado (sus restos están en el Gran Templo), Toussaint, Kovir, Ban Ard | [W: Lebioda] |
| **Kreve** | Norte, sobre todo Kaedwen; pierde fieles ante el Fuego Eterno en Redania | [W: Kreve] |
| **Gran Sol** | Religión oficial de Nilfgaard: desertores imperiales, nobleza de Toussaint | [W: Great Sun] |
| Culto a las Moiras | Velen (Downwarren): pagano y cruel | [W: Crookback Bog] |
| Ninguna | Brujos y muchos forajidos | [juicio] |

La devoción modula el rencor como en enRAGE: un devoto del Fuego Eterno odia más a un mutante [juicio].

### 4.4 Tipos de biografía

Fechas según la wiki, que marca las del juego como no canónicas en algunos casos:

- **Primera guerra con Nilfgaard**, colina de Sodden (1263), donde murieron catorce magos [W: Battle of Sodden Hill].
- **Segunda guerra**, terminada en 1268 [W: Third Nilfgaard War].
- **Pogromos de no humanos y Scoia'tael**, condenados como forajidos tras la Paz de Cintra [W: Scoia'tael].
- **Tercera guerra (1271-1272)**: caída de Huerto Blanco, legiones temerias disueltas que se hacen guerrilla o bandidaje [W: Third Nilfgaard War].
- **La peste Catriona** ("Muerte Roja"), que asola el campo del Norte tras la invasión [W: Catriona].
- **Cazas de brujas** de 1272: hogueras y torturas [W: Witch hunts].
- **La Cacería Salvaje**: avistamientos y luna roja como presagio [BJ whminion #1077936]; solo como rumor.
- **Disolución de la Rosa Llameante** [W: Order of the Flaming Rose].
- **Skellige**: incursiones, remos y la muerte del rey Bran [W: Bran Tuirseach].
- **Toussaint (~1275)**: hansas contra caballeros andantes [W: Hanse].

Las biografías se escriben de cero, sin reutilizar los ~270 sucesos de enRAGE (licencia).

### 4.5 Telegramas → cartas, mensajeros y tablones

- W3 no tiene telégrafo. Se sustituye por **cartas** (un mensajero encontrado en un cadáver, o una nota en el inventario), **mensajeros** (el juego tiene un "Mensajero de cazador de brujas", `quests\part_1\quest_files\q303_treasure\characters\q303_witch_hunter_courier.w2ent`, aunque es de misión) y **tablones de anuncios**.
- El tablón existe en el código: `W3NoticeBoard` (`game\gameplay\board.ws:27`) con `AddErrand` (`board.ws:311`). **Falta comprobar** si admite avisos con texto dinámico o solo entradas registradas de antemano.
- `living_world\posters\` (nml, novigrad, prologue, skellige) contiene carteles del mundo; sin revisar a fondo.

### 4.6 Periódico → rumores, pregones y tablones

- Sin prensa en el lore del juego [juicio]. La crónica de enRAGE se reparte en: **rumores de taberna** (texto en pantalla), **carteles de "se busca"** en los tablones y la **crónica completa en el panel de Segunda Pantalla**.
- En Skellige, los escaldos y las baladas ya hacen de crónica en el lore: los ulfhedinn vencidos tienen balada propia [BJ lycanthrope #1077716].

### 4.7 Funerales según la cultura

| Cultura | Rito | Fuente |
|---|---|---|
| Skellige | **Barco funerario en llamas**; banquete en la fortaleza del clan | [W: Bran Tuirseach] |
| Continente (Temeria, Velen) | **Enterramiento en cementerio**; los gnomos incineran | [BJ gravehag #1077604] (un erudito critica que los humanos entierren) |
| Fuego Eterno | Hogueras para ejecutar herejes, no como funeral | [W: Witch hunts] |
| Nilfgaard, elfos, enanos | **No verificado** | — |

Un funeral atacado o respetado se traduce igual que en enRAGE: modifica odio y miedo.

### 4.8 Reputación por asentamiento y trato al brujo y a los no humanos

- **Brujos:** son mutantes y se les teme. La propaganda de las iglesias los presenta como monstruos; se les trata como marginados y a veces con odio [W: Witcher]. Base lore de la **reputación negativa de partida**.
- **No humanos:** la xenofobia alimenta pogromos; en tiempos de hambre o guerra, cualquier diferencia física puede desatar violencia [W: Nonhuman]. En Novigrado, las cazas de brujas van unidas a la persecución de no humanos [W: Witch hunts].

| Asentamiento | Trato al brujo | Trato a no humanos |
|---|---|---|
| Huerto Blanco | Necesitan sus servicios (contrato del grifo) | No verificado |
| Velen | Necesitan sus servicios; la población teme a soldados y bandidos por igual [W: Velen] | Hay campamento Scoia'tael escondido |
| Novigrado | Hostil para magia y mutantes; el Fuego Eterno manda [W: Eternal Fire] | **Perseguidos** [W: Witch hunts] |
| Oxenfurt | Ciudad de la Academia; hay cazadores de brujas | No verificado |
| Skellige | Cultura guerrera; las sacerdotisas de Freya desconfían de los magos [W: Freya] | No verificado |
| Toussaint | Caballeresco y autónomo [W: Toussaint] | No verificado |
| Kaedwen / Kaer Morhen | Histórico sentimiento antibrujo y pogromo [W: Kaer Morhen] | — |

## 5. Riesgos de lore e inmersión

1. **La cronología avanza con la historia.** La guerra de 1271-1272 [W: Third Nilfgaard War] cambia de estado según las decisiones del jugador (Radovid, Nilfgaard), y BaW ocurre años después (~1275 [W: Hanse]). **Regla:** las biografías no deben fechar sucesos posteriores al momento de la partida. La crónica no debe anunciar el desenlace de la guerra antes de que ocurra. Cómo se lee ese estado por *facts* está por comprobar.
2. **Regiones de misión que no conviene tocar:** Isla de la Niebla, La Espiral, castillo de Vizima (mundos aparte), Kaer Morhen, Percha del Cuervo, Cenagal del Jorobado, Montecalvo, el centro de Novigrado y el Gran Templo, Kaer Trolde, Hindarsfjall y Beauclair. Además, ningún spawn dentro de un área de misión activa.
3. **Sin voces nuevas.** Solo los *voicesets* existentes de §3.2 (`PlayVoiceset`, `actor.ws:912`). Todo diálogo, en texto. No poner en boca de un bandido de Skellige un *voiceset* temerio. La plantilla ya trae el suyo.
4. **Cacería Salvaje, vampiros superiores y Moiras fuera del sistema:** su aparición fuera de guion contradice la historia.
5. **Por qué un bandido guarda rencor o miedo a Geralt** (base de diseño):
   - **Miedo:** es un mutante con capacidades sobrehumanas [W: Witcher]. Además usa Señales; con Axii manipula la mente, algo que el juego ya ofrece en diálogos. El brujo es "el monstruo" para un campesino armado.
   - **Rencor:** mató a sus compañeros, le quitó el botín, cobró por su cabeza o le humilló delante de su banda. Un fanático del Fuego Eterno le odia por ser mutante.
   - **Sin anonimato:** en enRAGE, sin verte la cara no hay némesis. Geralt no puede ocultarse: su pelo blanco y sus ojos de gato le delatan siempre. **Consecuencia de diseño:** la regla de la máscara desaparece y todo agravio con testigo cuenta (rasgo canónico, ver "No verificado").
   - **Reputación previa:** el apodo de "Carnicero de Blaviken" encaja como rumor que eleva el miedo de partida (ver "No verificado").
6. **Scoia'tael y no humanos como némesis:** riesgo de caricatura. Deben tener motivos de lore (persecución, pogromo) y no ser "bandidos con orejas".
7. **Matar a un némesis en una ciudad:** puede activar a la guardia (`ENGT_Guard`) y al sistema de combate urbano del juego. Hay que probarlo antes de habilitar ciudades.

## 6. Recomendación para la Fase 1 (un solo némesis)

**Tipo:** humano, **cabecilla de bandidos** (veredicto a).
**Región:** **Velen** (`AN_NMLandNovigrad` con el criterio de `commonMapManager.ws:348-353`), en campo abierto y lejos de Percha del Cuervo, el Cenagal del Jorobado y Novigrado.
**Plantilla:** `r4data\living_world\enemy_templates\novigrad_bandit_leader_swordshield.w2ent`. Como séquito, `novigrad_bandit_sword` y `novigrad_bandit_ranged`. Variante de reaparición "más fuerte": `novigrad_bandit_leader_axe2h`.

Por qué:

1. **El lore lo pide.** Velen en 1272 está lleno de bandidos y desertores [W: Velen]. Un cabecilla que reaparece no choca con nada.
2. **Sapiencia completa.** Memoria, rencor y diálogo son verosímiles sin licencias (§1.2), y prepara la Fase 2: el cabecilla equivale al rango 5 de una facción de enRAGE.
3. **Tiene plantilla de líder propia** y *voicesets* `voiceset_temerian` y `voiceset_verden` comprobados, que encajan con una provincia temeria. Los desertores no tienen variante de líder en el depot.
4. **No arrastra personajes únicos.** `baron_renegade_boss` es la alternativa obvia, pero su *voiceset* y su ubicación (Percha del Cuervo, The Mire) lo atan al Barón y a sus misiones.
5. **Enemigo humano normal:** `ENGT_Enemy`, sin la protección de inconsciencia que tienen `Guard`, `Commoner` y `Quest`. Eso hace la prueba de muerte y supervivencia más limpia.

**Plan B (monstruo limitado):** un **alghul** (`alghoul_lvl2`) que lidera ghuls en un campo de batalla de Velen. Prueba el modo (b) sin diálogo y tiene lore directo [BJ bestiaryalghoul].

## No verificado

- **Atribución de especie a categoría por el aceite** del bestiario: es inferencia, no se ha leído el `CMonsterParam` de cada plantilla, porque el valor no aparece como texto en los binarios.
- **Categoría de los guerreros de la Cacería Salvaje** y de berserkers y ulfhedinn: qué plantilla corresponde a cada nombre se ha deducido del nombre del archivo.
- Valores completos del enum nativo `ENPCGroupType`: solo se han visto los cuatro que usan los scripts.
- Si las plantillas `crowd_npc\inquisition_soldier\*` y `scoiatael_soldier\*` son hostiles al generarlas por script.
- El nivel de cada plantilla; no se ha leído.
- Que `lw_giggler_*` sean caníbales: ningún texto del juego lo dice. Tampoco se ha leído el contenido de las notas de Spitfire Bluff que los relacionan con los piratas.
- La relación exacta de los "renegados" (`baron_renegade_*`) con el Barón.
- Que `skellige_bandit_leader_hammer2h` exista como archivo: está en la base de cadenas, pero no en `enemy_templates`.
- Si `W3NoticeBoard.AddErrand` admite texto dinámico.
- Cómo leer por *facts* el estado de la guerra o el epílogo (quién ganó, si Radovid vive) para la regla cronológica.
- Ritos funerarios de Nilfgaard, elfos y enanos, y el trato a no humanos en Huerto Blanco, Oxenfurt, Skellige y Toussaint.
- Rasgos canónicos de Geralt (pelo blanco, ojos de gato) y el apodo "Carnicero de Blaviken" (*El último deseo*). Son conocidos, pero en esta sesión no se han contrastado con la wiki ni con el juego.
- La página [W: Nazair] solo se ha localizado, no leído. El vínculo de los bandidos nazairis con la provincia se deduce del nombre.
- El trol de puente que cobra peaje y repara el puente viene de una cita de *El último deseo* recogida por [W: Troll]; no se ha leído en la novela.
- La wiki se leyó por su API (`api.php?action=parse`) porque la web devolvía 402/403. El contenido es el mismo wikitexto, pero no se ha visto la página renderizada.
