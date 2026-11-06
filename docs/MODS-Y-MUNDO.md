# Mods de referencia y efectos sobre el mundo para el Némesis de W3 — 21-10-2026

Modelo: claude-opus-5-5 (agente `analista-mods`) · Origen de las ideas: enRAGE (RDR2), ya analizado y no repetido · Destino: The Witcher 3 Remastered, ejecutable 5.0.0.1048522, Steam, DX12, uso personal.

**Alcance que he aplicado.** Amplío el anexo D del [informe del 21-10-2026](../../../../outputs/enrage-nemesis-witcher3-21-10-2026/anexos/D-destino-witcher3.md) sin repetir lo que ya verificó: REDkit, anotaciones, `saved var`, shared-utils, RER, TW3SE, Spawn Menu y W3MCL. No toco lore, inteligencia por tipo de enemigo ni facciones por región, porque eso va en `LORE-Y-ENEMIGOS.md`. **No he descargado ningún mod de Nexus**, porque exige login. De los mods de Nexus solo he leído la descripción que publica el autor. De RER y shared-utils he leído el código de los clones de referencia con `git show`, sin ejecutar nada. **No he copiado código ajeno**: solo cito nombres de API, clases y etiquetas para que se puedan localizar.

## Leyenda de etiquetas

Todas las consultas son del 21-10-2026.

- **VERIFICADO (VAN archivo:línea).** La declaración o el código existe en los scripts vanilla instalados en `C:\Program Files (x86)\Steam\steamapps\common\The Witcher 3\content\content0\scripts\`. Prueba que la API existe, **no** cómo se comporta en partida.
- **VERIFICADO (NX id).** Así lo dice el autor en la descripción del mod, leída con la API pública GraphQL v2 de Nexus. Es una fuente de **comunidad** y una declaración sin probar. Las pestañas de permisos de Nexus no se pueden leer: la web devuelve 403 y la API no expone ese campo.
- **VERIFICADO (RER\@a255b3c archivo:línea / SU\@778de92 archivo:línea).** Lectura del código de los clones de comunidad. RER no tiene licencia. SU tiene licencia MIT y su README dice además que el código es de dominio público.
- **PROYECTO LOCAL (archivo:línea).** `witcher3-nemesis` o `witcher3-segunda-pantalla`.
- **NO VERIFICADO.** Inferencia mía o dato que no he podido comprobar.

## Resultado

1. **Ya existe un Némesis para tu misma build.** Es *Nemesis - Enemy Grudge System*, de Exiur (Nexus 13930, v1.1.3, creado el 09-10-2026 y actualizado el 21-10-2026). Dice estar probado en «el parche del 8 de octubre de 2026 (scripts 5.0.1048522)» [VERIFICADO (NX 13930)].
   - El enemigo que te vence se lleva coronas y objetos, recibe un nombre y una guarida, y se adapta a lo que usaste al final de la pelea (señales, paradas, esquivas, bombas, ballesta).
   - Los tablones de anuncios publican un contrato sobre él. Te escribe cartas, gana títulos y escapa una vez con una cicatriz.
   - Es casi exactamente tu Fase 1. **Lo que no tiene** es lo propio de enRAGE: rencor por actos y no solo por derrota, temperamentos, facciones y vida fuera de cámara.
   - **No conviene instalarlo junto a tu Némesis**, porque los dos interceptarían la muerte de Geralt.
   - Mi recomendación: jugarlo como referencia de lo que ya funciona, y diferenciar el tuyo por el rencor y las facciones (§5).
2. **La derrota de Geralt deja de ser un bloqueo.** El juego base ya tiene un estado «inconsciente» que evita la pantalla de muerte: lo usa cuando te vence un guardia, y también cuando el modo de inmortalidad de Geralt es `AIM_Unconscious`. En ese estado funde a negro, quita dinero, adelanta el reloj y revive a Geralt [VERIFICADO (VAN `game/player/player.ws:1086-1099`, `game/player/states/unconscious.ws:79-130,173-188`, `game/player/r4Player.ws:1705-1711`)]. Es el camino natural para «el némesis te perdona o te deja por muerto». Falta probarlo en partida.
3. **Riesgo nuevo para la Fase 0.** Exiur y su otro mod, Living Economy, documentan esto: con tres mods que guardaban muchos valores en Geralt, las partidas perdían el nivel, la experiencia y las ranuras de equipo. Lo atribuyen a que «el juego solo guarda cierto número de valores en Geralt», y lo arreglaron guardando todo en un único registro [VERIFICADO (NX 13930, NX 13678)].
   - El mecanismo exacto está NO VERIFICADO.
   - Tu mod de prueba ya usa una sola raíz guardada [PROYECTO LOCAL (`mod/modNemesisPrueba/content/scripts/local/nemesisPrueba.ws:10-11`)].
   - **Añadiría a la Fase 0** dos cosas: comprobar el nivel, la experiencia y las ranuras de Geralt tras cargar, y repetir la prueba con RER instalado, que añade su propio campo guardado.
4. **El menú de opciones en 5.0 se registra sin `filelist`.** Tres fuentes de comunidad coinciden: basta con copiar el XML del menú en `bin\config\r4game\user_config_matrix\pc\` [VERIFICADO (NX 13930, NX 13731, NX 13995: «Remastered 5.01 DX12 probado con generate_filelists=false»)]. En tu instalación no hay `filelist` [VERIFICADO (listado local)]. Que funcione en tu juego está NO VERIFICADO. **Hay un fallo conocido en 5.0:** solo abren su página los 10 primeros mods de la lista *Opciones > Mods* [VERIFICADO (NX 13284)].
5. **El nombre del némesis sí puede salir en la placa y en la barra de jefe.** Las dos piden el nombre a `GetDisplayName()` desde scripts de HUD que se pueden envolver [VERIFICADO (VAN `game/gui/hud/modules/hudModuleEnemyFocus.ws:352,556-562`, `hudModuleBossFocus.ws:48-60,125-130`)]. Lo confirman en la práctica Nemesis 13930, con el nombre en la barra de jefe, y Enemy Scaling Offset, que pone «Elite» en la placa [VERIFICADO (NX 13930, NX 13334)]. Esto mejora el «Parcial» del anexo D.
6. **Tu build es casi seguro el parche del 08-10-2026, el que la comunidad llama «5.01».**
   - Exiur asocia ese parche a los scripts 5.0.1048522 [VERIFICADO (NX 13930)].
   - `gameplay.xml` y `graphics.xml` de tu instalación tienen fecha del 08-10-2026 [VERIFICADO (listado local)].
   - Que el parche sea el mismo es una inferencia (NO VERIFICADO), pero resuelve la duda abierta del anexo D.

## 1. Mods de referencia

**Licencias.** No he podido leer la pestaña «Permissions and credits» de ningún mod de Nexus. Mientras no se lean, todos se tratan como «todos los derechos reservados»: **solo ideas, descritas con palabras propias, y nada de código**. Las excepciones con licencia legible son SU (MIT) y el repositorio de Apocrypha Menu Framework en GitHub (GPL-3.0, según la API de GitHub). RER no tiene licencia en su repositorio.

### 1.1 Enemigos que recuerdan, vuelven o escalan

| Mod | Qué hace | Versión del juego | Uso | Riesgo con el Némesis | Etiqueta |
|---|---|---|---|---|---|
| **Nemesis - Enemy Grudge System** (13930, v1.1.3, Exiur) | Ver el Resultado, punto 1. Además: despiertas en un poste de viaje rápido, una posada o una herbolaria; vuelve más fuerte con cada victoria y gana un título a la segunda; a la tercera es «Witcher-Bane». Su guarida muestra el rango con restos y cuervos. Te persigue si sangras cerca de su guarida. Dos némesis cercanos se enfrentan entre sí. Tiene contrato en el tablón, brillo rojo con los sentidos de brujo, notas en *Libros*, trofeo para el caballo y opción de pin de la guarida. Máximo de 1 a 5 némesis a la vez. Filtra: misiones, jefes, monstruos de contrato, la Cacería Salvaje, aldeanos, ahogamiento y caídas siguen con muerte y recarga | Probado en 5.0.1048522 | **Referencia de diseño y benchmark jugable.** No es dependencia ni se instala a la vez | **Alto si conviven**: los dos interceptan la muerte del jugador. Exiur dice que no hace nada si otro mod salva antes a Geralt. Publica en el tablón en una ranura distinta de Living Economy | VERIFICADO (NX 13930). Permisos sin leer |
| Omega's Enemy Level Scaling (12676, v1.0.4) | Escalado por niveles de amenaza (jefe, contrato, élite…) usando los ID de localización para reconocer jefes y variantes con nombre | 5.x (actualizado el 14-10-2026) | Idea: identificar jefes y monstruos con nombre sin listas a mano | Medio: si sube el nivel del némesis, se suma a tu propio escalado | VERIFICADO (NX 12676) |
| Enemy Scaling Offset (13334, v1.2.0) | Desfase de nivel por clase de enemigo y probabilidad de «Elite» con más nivel y vida, marcado en la placa. Desde la 1.2.0 ya no edita `npc.ws` ni guarda nada en la partida | 5.0 | Idea: la placa se puede reescribir | Medio: escala lo mismo que tu némesis | VERIFICADO (NX 13334) |
| King of the Hunt (13245, beta) | Jefes más agresivos según pierden vida; ajuste de los «humanos expertos» (contraataque y aguante) | 5.0 | Idea para el némesis humano de rango alto | Bajo | VERIFICADO (NX 13245) |
| Restored Buffed Monster (8206) | Restaura el sistema vanilla de bonificaciones de los monstruos por clima, luna y hora | Next-Gen; sin confirmar en 5.0 | Idea: tu némesis puede seguir la misma lógica (§4) | Bajo | VERIFICADO (NX 8206). El sistema vanilla, VERIFICADO (VAN `game/npc/npc.ws:766-788`) |

### 1.2 Encuentros y spawns dinámicos

| Mod | Qué hace | Versión | Uso | Riesgo | Etiqueta |
|---|---|---|---|---|---|
| **Random Encounters Reworked** (5018, v4.0.2) | Contratos, recompensas, emboscadas, cacerías y ecosistema; sin merges | Next-Gen y Remastered | **Compatibilidad prioritaria** (§2). Ideas, no código | Medio: los dos generan enemigos | VERIFICADO (NX 5018, RER\@a255b3c). Sin licencia |
| No Safe Path (12239, v2.6) | Spawns por tiradas común, raro y muy raro; ruido de combate que atrae depredadores; hordas de hasta 10; noches más peligrosas | 5.x (actualizado el 07-10-2026) | Solo ideas | **Alto**: otra fuente de spawns sin coordinación. No lo combinaría con RER y el Némesis | VERIFICADO (NX 12239) |
| Bandit Camp and Monster Nest Respawn (12260, v4.1) y Bandit and Monster Respawn (14684, v1.0) | Repueblan campamentos y nidos tras X días. Temporizador por sitio, entidades `PM_DontPersist`, no generan con el jugador cerca y descartan los campamentos ocupados por PNJ amistosos tras una misión. El 14684 genera al acercarse (120 m) y retira al alejarse (160 m) | 12260 para 4.04 (necesita merge); 14684 para Remastered 4.x/5.x | **Ideas clave** para los campamentos de facción y el «estado de regiones» (§3) | Medio: un campamento repoblado puede chocar con la guarida de un némesis | VERIFICADO (NX 12260, NX 14684) |
| Monster Arena (13746) | Genera hasta 3 grupos de 93 enemigos alrededor de Geralt y se niega dentro de pueblos | 5.x | Prueba de que la generación en anillo sobre suelo transitable funciona en 5.x | Bajo | VERIFICADO (NX 13746) |
| Eternal Hunt (8449, v7.72) | Overhaul enorme: encuentros propios, más de 40 enemigos únicos, perseguidores tras cada combate, IA nueva | Última versión y 1.32 | Solo ideas (§1.5) | **Alto**: dice que reconoce otros mods y «los anula cuando lo cree oportuno», y que eso «no es negociable» | VERIFICADO (NX 8449) |

### 1.3 Recompensas y contratos generados

| Mod | Qué hace | Versión | Uso | Riesgo | Etiqueta |
|---|---|---|---|---|---|
| Witcher's Work (13238, v1.2.2) | Cada 72 h de juego hay un 33 % de que salga un contrato en el tablón de tu región. Nota con plazo, zona de búsqueda a 300–700 m, monstruo a ±5 niveles y recompensa que el monstruo lleva encima y que pasa por el pago vanilla de contratos. Sin entrada en el diario: solo un pin con el tiempo restante | 5.x | Idea para el contrato sobre el némesis | Medio: ocupa espacio en el tablón | VERIFICADO (NX 13238) |
| Infinite Contracts (13664) | Contratos completos: nota, cliente con líneas vanilla ya dobladas, regateo vanilla, 262 lugares reales, barra de jefe y trofeo. Declara sus ganchos: `CR4Player.OnSpawned`, `CNewNPC.OnInteraction`, `CR4HudModuleDialog`, `CR4NoticeBoardMenu.OnErrandSelected`, `CR4MapMenu.UpdateEntityPins` y `CR4HudModuleMinimap2` | 5.00 o posterior | Mapa de los puntos de enganche de un contrato por script | Medio: envuelve lo mismo que haría tu contrato | VERIFICADO (NX 13664) |
| Monster Hunt Contracts (13635) | Más de 600 notas y rasgos de criatura, como regeneración, furia final o caparazón que se rompe. Dice ser compatible con RER y Eternal Hunt | 5.x | Ideas de rasgos para el némesis monstruo | Medio | VERIFICADO (NX 13635) |
| Daily Monster Hunt Challenge (1296) | Apuesta diaria por cazar un objetivo antes de medianoche | 4.03; sin actualizar desde 2023 | Solo idea | Sin confirmar en 5.x | VERIFICADO (NX 1296) |

### 1.4 Facciones, guerras, ocupación y patrullas

| Mod | Qué hace | Versión | Uso | Riesgo | Etiqueta |
|---|---|---|---|---|---|
| The 3rd Nilfgaardian War (9298, v2.9) | La guerra se refleja en el mundo: lugares, campamentos y asentamientos cambian según tus decisiones. Edita niveles (`.w2l`) y el navmesh de Velen, Novigrad y Huerto Blanco. No admite desinstalarlo a mitad de partida | 5.x (19-10-2026) | Referencia de lo que **exige REDkit** | **Alto**: incompatible con cualquier mod que toque el navmesh de esas regiones | VERIFICADO (NX 9298) |
| Dynamic Consequences of War (10812, WIP) | Cambia banderas, PNJ y objetos según quién gane la guerra; rompe algunas misiones | Next-Gen | Igual: es trabajo de capas en REDkit | Alto | VERIFICADO (NX 10812) |
| The WAR Project (12204, demo) | Recrea contenido cortado de la guerra | 5.x | Solo seguimiento | Sin evaluar | VERIFICADO (solo el resumen, NX 12204) |

No encontré ningún mod de «patrullas» o «facciones con jerarquía» por script. Busqué en Nexus por *patrol*, *faction*, *army*, *occupation*, *bounty* y *ambush*, y por nombre en GitHub [VERIFICADO (NX, búsqueda)]. Que no aparezca no prueba que no exista.

### 1.5 IA de combate humana mejorada

| Mod | Qué hace | Uso | Riesgo | Etiqueta |
|---|---|---|---|---|
| Eternal Hunt (8449) | Humanos que cambian de estilo según su vida, que lanzan bombas y dagas, y que **por miedo, cuando cae su grupo, suplican clemencia o huyen** | Idea directa para tu interrogatorio (Fase 3): miedo, súplica y huida | Alto si se combina (§1.2) | VERIFICADO (NX 8449) |
| W3EE Redux (5802, v1.47a) y Spectre (14629, port a 5.01 en pruebas) | Overhauls completos de combate y progresión | Ninguno | Alto: cambian todo el equilibrio sobre el que escalaría el némesis | VERIFICADO (NX 5802, NX 14629) |
| Combat Tweaks Remaster (13527) | Ajustes de daño, bloqueo, contraataque y remates por menú. Dice que los guardias de ciudad solo quedan noqueados | Referencia: confirma el comportamiento vanilla de «guardia que noquea» | Bajo | VERIFICADO (NX 13527) |
| Deadly Guards (4828) | Hace que perder contra los guardias mate a Geralt. **Edita `player.ws`** | Ninguno: confirma que en vanilla el guardia te deja inconsciente | **Alto**: reemplaza el archivo donde está tu gancho de derrota | VERIFICADO (NX 4828) |

### 1.6 Mundo vivo, reacciones de PNJ, rumores y tablones

| Mod | Qué hace | Versión | Uso | Riesgo | Etiqueta |
|---|---|---|---|---|---|
| **Villages Remember** (13731, v1.1.0, Exiur) | Memoria por aldea de contratos y muertes, con la ayuda y el daño separados y el daño desvaneciéndose más lento. Los rumores se extienden a las aldeas cercanas. Avisos del diario, líneas sobre la cabeza de los aldeanos y diálogo entre dos de ellos. Si te temen, cierran las puertas y esconden la mercancía; si eres héroe, te dejan regalos. Notas por aldea en *Libros* | Probado en 5.0.1048522 | **Referencia principal** para tu Fase 4 (reputación por asentamiento y testigos) | Medio: dos sistemas de reputación por aldea se pisarían | VERIFICADO (NX 13731) |
| **Living Economy** (13678, v1.3.1, Exiur) | Precios por región, mercado que reacciona a tus ventas, rutas comerciales que cortan los monstruos y noticias semanales en el tablón. Tiene un mod enlace opcional con Nemesis: las tiendas cercanas a un némesis vivo suben precios | Probado en 5.0.1048522 | **El patrón del «mod enlace»** (§2) y la idea de que el némesis encarezca la zona | Medio: si ambos tocan precios, se multiplican | VERIFICADO (NX 13678) |
| Reputation System - Remastered (12987) | Recupera la reputación por región (5 niveles) con efecto en precios y apuestas | 5.01 | Ideas | Medio: también toca precios | VERIFICADO (NX 12987) |
| No Indignant NPCs (3190, v3.2) | Reacciones de los PNJ a choques, señales, espadas y robo, configurables por menú y sin merges | 5.x | Referencia de dónde están las reacciones | Bajo | VERIFICADO (NX 3190) |
| The Witcher Alive (13383) | PNJ que hablan con un LLM (Gemini) por voz, con DLL nativa y app externa | **Solo funciona en la build 5.0.0.1044392**, no en la tuya | **Evitar**: nativo, depende de la nube y de otra build | Alto | VERIFICADO (NX 13383) |

### 1.7 Nombres, títulos, cicatrices y apariencias

- Nombres y títulos: Nemesis 13930, con nombres por región y tipo de monstruo, y título en la barra de jefe. Enemy Scaling Offset, con «Elite» en la placa [VERIFICADO (NX 13930, NX 13334)].
- **Cicatrices dinámicas en enemigos: no encontré ningún mod.** Lo más parecido son los cambios de apariencia por historia de Dynamic Appearances Project (9219), hechos con REDkit [VERIFICADO (solo el resumen, NX 9219)]. Nemesis 13930 menciona «vuelve con cicatriz», pero no dice si es visual o una resistencia nueva [NO VERIFICADO].

### 1.8 Frameworks de configuración y menús

| Herramienta | Qué hace | Uso | Riesgo | Etiqueta |
|---|---|---|---|---|
| Menú XML vanilla en `user_config_matrix\pc` | Página propia en *Opciones > Mods*; en 5.0 basta con copiar el XML | **Usar** | Bajo | VERIFICADO (NX 13930/13731/13995). En tu juego, NO VERIFICADO |
| Mod Settings Menu Fix (13284) | Arregla el fallo de 5.0 por el que la entrada 11 y siguientes de *Opciones > Mods* no abren; solo anotaciones | Solo si pasas de 10 mods con menú | Bajo | VERIFICADO (NX 13284) |
| Mods Menu Pagination (13519) | Pagina la lista de mods | Alternativa al anterior | Bajo | VERIFICADO (NX 13519) |
| W3MCL (13995) | Fusiona ajustes, teclas y menús con una DLL `winmm.dll` o `.asi` | Evitar mientras no haga falta | Medio: nativo, en pruebas | VERIFICADO (NX 13995) |
| Apocrypha Menu Framework (13656) | Menú ImGui sobre DX12 que muestra las páginas XML de todos los mods. Ofrece «ajustes por partida» en un fichero junto al guardado | Evitar como dependencia | Medio-alto: `dinput8.dll` nativo y código generado con IA según su autor | VERIFICADO (NX 13656). GitHub GPL-3.0 |
| Menu Filelist Updater (7171) | Mantiene los `filelist.txt` de 4.x | No hace falta en 5.0 si se confirma el punto 4 del Resultado | Bajo | VERIFICADO (NX 7171) |
| SU *menu descriptors* | Descripción al pasar el ratón por una opción del menú | Opcional | Bajo | VERIFICADO (SU\@778de92 `README.md`) |

### 1.9 Persistencia y utilidades

- **SU (Nexus 12997, v4.1; GitHub MIT).** Muchos de sus módulos son solo anotaciones: tablones (`W3NoticeBoard`), glosario (`CR4GlossaryBooksMenu`), pines (`CR4MapMenu` y `CR4HudModuleMinimap2`), oneliners (`CR4Game`), elecciones de diálogo (`CR4HudModuleDialog`), interacción con PNJ (`CInteractionComponent`) y modificadores de daño (`CActor.ReduceDamage`) [VERIFICADO (SU\@778de92: los `annotations.ws` de cada módulo)].
  - **Ojo:** los módulos *journalquest*, *custombossbar*, *customcooldowns* y *storage* **sustituyen archivos vanilla enteros**. *journalquest* trae su propio `game/player/r4Player.ws` de 14 686 líneas, y *custombossbar* su `hudModuleBossFocus.ws` [VERIFICADO (SU\@778de92, listado `content/scripts/game/...`)].
  - No usaría esos cuatro: reemplazar `r4Player.ws` choca con la versión 5.0 y con cualquier otro mod.
  - Si el paquete «todo en uno» de Nexus los incluye: NO VERIFICADO.
- **Community Patch - Shared Imports (2110).** Importa clases del motor no expuestas. Es de 2024 y dice estar probado en 1.30 o posterior. No hace falta para el Némesis [VERIFICADO (NX 2110)].
- **Witcher's Path (13423).** Guarda sus datos en la partida y dice que, al quitar el mod, «el juego ignora esos datos» y las partidas cargan [VERIFICADO (NX 13423)]. Apoya el paso 5 de tu Fase 0, sin sustituirlo.
- **Witcher Statistics (13095).** Contadores de muertes y estilo de combate (paradas, esquivas, señales por tipo, bombas, ballesta) [VERIFICADO (NX 13095)]. Confirma que todo lo que el némesis necesita «aprender» se puede detectar por script.

### 1.10 Trofeos

Trophy Stats (13299), Useful Monster Trophies Remaster (13298) y Better Trophies (10201) dan estadísticas a los trofeos de caballo existentes mediante XML [VERIFICADO (NX 13299, NX 13298, NX 10201)]. Sirven de referencia para un trofeo de némesis (§4).

## 2. Compatibilidad con RER (prioridad)

| Punto | Qué hace RER | Qué debe hacer el Némesis | Etiqueta |
|---|---|---|---|
| Ganchos | Solo envuelve `CR4Player.OnSpawned`, `W3ActorRemains.OnItemTaken` (trofeos) y `CR4IngameMenu` (descripciones del menú). **No toca la muerte del jugador** | Tu gancho de derrota no choca con RER | VERIFICADO (RER\@a255b3c `src/annotations.ws:2-15`, `src/annotations/trophy.wss:3-4`, `src/helpers/menu_descriptors/main.wss:48`) |
| Reconocer sus criaturas | Les pone etiquetas: `RandomEncountersReworked_Entity`, `..._BountyCreature`, `..._ContractCreature` y `RER_BountyEntity` | (a) No lanzar una emboscada del Némesis si hay entidades de RER cerca. (b) Decidir si un monstruo de RER puede volverse némesis; Exiur lo permite. (c) Excluir las criaturas de contrato de RER, igual que el vanilla excluye las suyas | VERIFICADO (RER `src/bestiary/bestiary_entry.wss:189`, `src/bounty/bounty_manager.wss:852,900`, `src/contract/states/processing.wss:317`) |
| Cuándo no genera | Aborta si estás en interior, en combate, en barco o nadando, en escena, en cinemática o diálogo, en un fundido, con Ciri, en pelea a puños o cerca de un pin de misión | Usar las mismas condiciones; son API vanilla verificadas en §3.12 | VERIFICADO (RER `src/helpers/is_player_busy.wss:4-24`, `src/helpers/should_abort_spawn.wss:26-50`) |
| Tablón | Mete su contrato sustituyendo una nota de relleno (`flaw`) mediante un inyector de SU con su propia etiqueta | Usar otra etiqueta y no ocupar la misma nota de relleno. El vanilla muestra como mucho 6 notas por tablón | VERIFICADO (RER `src/contract/injectors.wss:21-54`; VAN `game/gameplay/board.ws:43`) |
| Guardado | Añade un campo guardado a `CR4Player` | Contar con el límite del Resultado, punto 3; probar la Fase 0 con RER instalado | VERIFICADO (RER `src/annotations.ws:2`) |
| Acceso a RER | Expone `getRandomEncountersReworked()` en el jugador | **Nunca referenciarlo desde el mod principal**, porque sin RER no compilaría. Si algún día hace falta, un mod enlace aparte (`modNemesisRER`) que solo se instala con RER: es el patrón de Exiur, cuyos enlaces «no compilan sin los dos mods» | VERIFICADO (RER `src/annotations.ws:5-6`; NX 13930, NX 13731) |
| Dependencias | RER necesita SU | Si el Némesis usa SU, comparte la dependencia | VERIFICADO (RER@a255b3c `README.md:38`; requisito «Sharedutils 12997» en NX 5018) |

Recomendación propia: un **turno compartido de encuentros**. Antes de lanzar una emboscada, el Némesis mira si hay entidades de RER en un radio grande (por ejemplo, 150 m) y si hubo combate hace menos de N minutos. Si es así, aplaza. RER no expone un evento de «acabo de generar» y yo no he encontrado ninguno [NO VERIFICADO], así que la etiqueta es la única señal fiable.

## 3. Efectos sobre el mundo que admite W3

Todas las referencias son VAN salvo que se diga otra cosa. Que una API exista no prueba cómo se comporta en partida.

### 3.0 Derrota sin recarga (lo que desbloquea la Fase 1)

- `OnDeath` del jugador manda a Geralt al estado `Unconscious`, en vez de a la muerte, en tres casos: si el atacante es un PNJ guardia, si fue un ascensor o si **`WillBeUnconscious()`** es verdadero. Siempre exige que no vaya montado ni nadando y que no esté hundido en el agua (`game/player/player.ws:1086-1099`).
- `WillBeUnconscious()` es verdadero cuando el actor tiene inmortalidad del tipo inconsciente (`game/actor.ws:265-270`). Se activa con `SetImmortalityMode(AIM_Unconscious, canal)`. Los canales son `AIC_Default`, `AIC_Combat`, `AIC_Scene`, `AIC_Mutation11`, `AIC_Fistfight`, `AIC_SyncedAnim`, `AIC_WhiteRaffardsPotion` y `AIC_Cheat` (`game/types.ws:17-24`). La pelea a puños vanilla usa exactamente esto (`game/player/r4Player.ws:3999`).
- Con un guardia, el estado funde a negro y quita dinero según la dificultad: 25 % (máx. 750), 40 % (1250), 65 % (1750) u 85 % (2250). Después adelanta el reloj, devuelve la espada, revive y muestra un mensaje (`game/player/states/unconscious.ws:83-97,173-188,139-153,49`). Al revivir se libera el bloqueo de guardado por muerte (`game/player/r4Player.ws:1705-1711`).
- **Cómo se usaría.** Al empezar la pelea con el némesis, se pone a Geralt en `AIM_Unconscious` con un canal propio, o se envuelve `OnDeath` comprobando el atacante. Al despertar, se aplican las consecuencias propias (robo, teletransporte a un poste, crónica). **Riesgo medio.** Está sin probar si las animaciones de levantarse quedan bien fuera de los casos del guardia y del ascensor, y si choca con Undying, la Mutación 11 o la armadura reforzada (Exiur dice que esas salvan primero). Deadly Guards edita justo este archivo.

### 3.1 Tabla de efectos

| Efecto | ¿Por script? | API y evidencia | Riesgo |
|---|---|---|---|
| **Tablón: cartel de recompensa por un némesis** | Sí | `W3NoticeBoard.AddErrand(ErrandDetailsList)` (`game/gameplay/board.ws:311`). La nota es una clave de localización con título y texto `_text` (`game/gui/menus/noticeBoardMenu.ws:116-117`). Al cogerla se crea el fact `newQuestFact` y se da el objeto `addedItemName` (`board.ws:722-729`). Hay una función de misión `AddErrandsToTheNoticeBoard` (`game/quests/quest_function.ws:1322`). Para texto dinámico hay que envolver el menú, como hace SU, o usar cadenas fijas de REDkit | Medio: 6 notas como mucho (`board.ws:43`), que compiten con RER, Living Economy y otros |
| **Contratos** | Parcial | No hay creación de misiones del diario por script en vanilla: se hacen con quest graphs de REDkit. Por script se monta un «pseudo-contrato» con nota, fact, pin, monstruo con barra de jefe y pago, que es lo que hacen Witcher's Work e Infinite Contracts [NX 13238, NX 13664]. Entrada en el diario: SU *journalquest*, que reemplaza `r4Player.ws` (descartado, §1.9), o REDkit | Medio |
| **Precios y actitud de comerciantes** | Sí | `CInventoryComponent.SetPriceMultiplier(mult)` y `GetMerchantPriceModifier(shopNPC, item)`, que es script y combina multiplicadores por zona, tipo y origen (`game/components/inventoryComponent.ws:2860-2915`). `GetItemPriceModified` es nativa (`:604`). Que el motor llame a `GetMerchantPriceModifier` está NO VERIFICADO; Living Economy y Reputation System prueban que en 5.x se pueden cambiar precios [NX 13678, NX 12987]. Lo de esconder mercancía o negarse a venderte lo hace Villages Remember [NX 13731] | Medio: choca con cualquier mod de economía |
| **Guardias y patrullas** | Parcial | Los guardias son `ENGT_Guard` y el vanilla los trata aparte (`game/player/player.ws:1086`, `game/actor.ws:5836`). Se pueden generar con plantillas, hostilidad (anexo D) y movimiento latente `ActionMoveTo`. Rutas con action points y job trees: REDkit (OF-7 del anexo D) | Medio por script; alto con rutinas |
| **Rumores y gritos de PNJ** | Sí | Texto sobre una entidad con la función nativa del HUD `ShowOneliner(text, entity)` y `HideOneliner` (`game/gui/hud/hud.ws:9-10`), que el propio jugador usa (`game/player/player.ws:2054`). Gritos con voz vanilla: `PlayVoiceset` (`game/actor.ws:912`). Mensaje en el HUD: `DisplayHudMessage` (`game/player/r4Player.ws:11241`). Aviso: `ShowNotification` (`game/gui/r4guimanager.ws:1389`). Villages Remember hace hablar a dos aldeanos entre sí [NX 13731] | Bajo |
| **Pines de mapa** | Sí | Pines de usuario: `ToggleUserMapPin`, `GetUserMapPinLimits` y `GetUserMapPinCount` (`game/commonMapManager.ws:142-146`). En 5.0 hay hasta 30 (anexo D, OF-2). Pines propios con SU *mappins* (anotaciones). Exiur usa el pin rápido y dice que espera si ya tienes uno tuyo [NX 13930] | Bajo. Tu Segunda Pantalla oculta el minimapa del juego [PROYECTO LOCAL `witcher3-segunda-pantalla/README.md:34`]: el pin también debe emitirse al log para el panel |
| **Glosario y bestiario** | Glosario sí; bestiario parcial | Entradas de libros con texto dinámico: SU *glossary* envuelve `CR4GlossaryBooksMenu` (`game/gui/menus/glossary/glossaryBooksMenu.ws:6`; SU\@778de92 `.../glossary/books/annotations.ws`). `ActivateEntry` del diario necesita un recurso de diario existente (`game/journal.ws:213`), así que un bestiario nuevo exige REDkit (`CR4JournalDLCMounter`, anexo D) | Bajo en el glosario; alto en el bestiario |
| **Cartas y libros con texto dinámico** | Sí | `GetBookText(item)` es script y el juego base **ya genera texto por código para un libro** (el Almanaque de Gwent) (`game/components/inventoryComponent.ws:1611-1621`). Lo llama el menú de inventario al leer (`game/gui/menus/inventoryMenu.ws:3830`). Se envuelve para el objeto «carta del némesis». El objeto en sí necesita una definición XML propia (`CR4DefinitionsDLCMounter`, anexo D) o reutilizar uno vanilla. Nemesis 13930 envía cartas así [NX 13930] | Bajo-medio: el XML del objeto |
| **Botín y trofeos al matar al némesis** | Sí | Dar objetos al PNJ antes de su muerte para que caigan en sus restos (`AddAnItem`, anexo D). Los restos ya gestionan trofeos (`game/gameplay/containers/actorRemains.ws:110`). La ranura de trofeo del caballo es `EES_HorseTrophy` (`inventoryComponent.ws:3566,3893`). Un trofeo nuevo pide XML con DLC mounter. RER envuelve `W3ActorRemains.OnItemTaken`, pero el encadenado de anotaciones lo soporta | Bajo con objetos vanilla; medio con trofeos nuevos |
| **Estado de regiones: aldeas abandonadas o repobladas** | **Muy limitado por script** | `CWorld.ShowLayerGroup` y `HideLayerGroup` (`engine/world.ws:9,12`) existen y el vanilla las usa con rutas internas de capas (`game/r4Game.ws:792`). Pero las capas y las comunidades de aldea las controlan las misiones, y los cambios serios son ediciones de nivel en REDkit (3rd Nilfgaardian War, Dynamic Consequences of War) [NX 9298, NX 10812]. Por script es realista **añadir** gente (refugiados, guardias, bandidos `PM_DontPersist` que se generan cerca y se retiran lejos, como 14684), no vaciar aldeas vanilla | **Alto** si se tocan capas: puede romper misiones |
| **Clima y hora** | Sí | `RequestWeatherChangeTo(nombre, mezcla, pausaDeMisión)` y `GetWeatherConditionName` (`engine/environment.ws:53-54`); fase lunar `GetCurMoonState` (`game/environmentManager.ws:14`). La hora, en el anexo D §3.7. El juego ya da bonificaciones a los monstruos por hora, clima y luna (`game/npc/npc.ws:766-788`) | Bajo leyendo; medio forzando el clima, porque las misiones también lo fuerzan |
| **Nombre visible del némesis** | Sí, en el HUD | Envolver `CR4HudModuleEnemyFocus.UpdateName` (`hudModuleEnemyFocus.ws:556-562`), que recibe `GetDisplayName()` del objetivo (`:352`). Barra de jefe: `ShowBossIndicator(true, tag, actor)` es pública (`hudModuleBossFocus.ws:48`) y el nombre sale de `GetDisplayName()` (`:125-130`); para reescribirlo hay que envolver el módulo. `SetBossTag` y `GetBossTag` en el jugador (`r4Player.ws:15369-15374`) | Bajo. Los subtítulos y otros textos siguen con el nombre vanilla |
| **Brillo con los sentidos de brujo** | Sí | `SetFocusModeVisibility(FMV_Clue)` (`game/gameplayEntity.ws:131`); en el juego, `FMV_Clue` brilla en rojo (`game/gameplay/containers/container.ws:36`). Las huellas de criatura usan las clases de pistas de `game/gameplay/monster_hunting/` (`clue_corpse.ws:6`) | Bajo |
| **No poder meditar cerca de la guarida** | Sí | `BlockAction(EIAB_MeditationWaiting, motivo, …)` y `UnblockAction` (`game/gameplay/fast_travel_entities/fastTravelEntity.ws:252,279`) | Bajo: hay que desbloquear siempre al salir de la zona |

### 3.2 Detectar misión o zona de misión, para no interferir

No hay una API única de «zona de misión». Se combinan señales, todas verificadas:

| Señal | API | Evidencia |
|---|---|---|
| Escena o cinemática | `IsInNonGameplayCutscene()`, `IsInGameplayScene()` | `game/actor.ws:684-685` |
| Diálogo o escena en curso | `theGame.IsDialogOrCutscenePlaying()`, `IsCurrentlyPlayingNonGameplayScene()` | `game/r4Game.ws:1329`, `engine/game.ws:179` |
| Interior o asentamiento | `thePlayer.IsInInterior()`, **`IsInSettlement()`** | `game/player/r4Player.ws:433-434` |
| Combate | `IsInCombat()` | `game/actor.ws:561` |
| Guardado bloqueado (heurística: muchas fases de misión lo bloquean) | `theGame.AreSavesLocked()` | `game/commonGame.ws:207` |
| Pines de misión cerca | `GetAreaMapPins()`, `GetMapPinInstances(worldPath)`, `IsQuestPinType(type)` | `game/commonMapManager.ws:111,123,134` (es el método de RER) |
| Misión seguida | `GetJournalManager().GetTrackedQuest()` | `game/gui/hud/modules/hudModuleJournalUpdate.ws:670` |
| Enemigo de misión, jefe o contrato | Habilidad con etiqueta `Boss`, clase `W3MonsterHuntNPC`, PNJ `ENGT_Quest` | `game/actor.ws:6632`, `game/npc/monsterHuntNPC.ws:6`, `game/gameplay/items/spells/axiiEntity.ws:137` |
| Región y zona | `GetCommonMapManager().GetCurrentArea()`, `theGame.GetCurrentZone()` | `commonMapManager.ws:148`, `game/r4Game.ws:1482` |

Riesgo: **medio**. Una zona de misión sin pines ni bloqueo de guardado pasaría el filtro. La mitigación es la de Exiur: excluir los jefes, los monstruos de contrato y la Cacería Salvaje, y no generar dentro de asentamientos [VERIFICADO (NX 13930)].

## 4. Mejoras propias de W3 que enRAGE no tiene

**Aviso:** la idea 1 y buena parte de las 2 a 5 **ya las hace Nemesis 13930**. Si quieres algo distinto, la diferencia está en las ideas 6 a 9 y en el núcleo de enRAGE.

| # | Idea | Viabilidad técnica | Coste |
|---|---|---|---|
| 1 | **Aprende de cómo lo venciste**: señal (Igni, Aard…), aceite, bombas, ballesta, paradas, esquivas | Detección: la señal con `GetSignType()` e `IsActionWitcherSign()` (`game/gameplay/actions/baseAction.ws:210,626`); a distancia con `IsActionRanged()` (`:625`); bomba si el causante es `W3Petard` (`game/actor.ws:3111`); virote si es `W3BoltProjectile` (`:5810`); paradas y contraataques con `IsParried()` e `IsCountered()` (`game/gameplay/actions/attackAction.ws:217-219`); esquiva con `WasDodged()` (`baseAction.ws:447`); aceites aplicados con `GetOilsAppliedOnItem` (`game/components/inventoryComponent.ws:2436`). Respuesta: inmunidad a estados con `AddBuffImmunity` (`game/actor.ws:4108`; RER lo usa contra los derribos, `src/bestiary/bestiary_entry.wss:318-320`) y menos daño envolviendo `CActor.ReduceDamage` (`game/actor.ws:5734`; SU *damagemodifiers*, MIT). VERIFICADO como API | **Moderado** |
| 2 | **Contrato de brujo sobre el némesis** | Nota en el tablón, fact, pin y barra de jefe (§3.1). VERIFICADO como API. Texto dinámico de la nota: envolviendo el menú, NO VERIFICADO sin SU | Moderado |
| 3 | **Trofeo del némesis** | Trofeo vanilla del tipo de monstruo en sus restos: sin XML. Trofeo propio con estadísticas: XML con DLC mounter (anexo D). La ranura del caballo, `EES_HorseTrophy`. VERIFICADO como API | Trivial con trofeo vanilla; Moderado con uno propio |
| 4 | **Mutaciones o equipo según cómo lo venciste**: se pone la armadura que te quitó, gana resistencias | `AddAbility` y `EquipItem` (anexo D), `AddBuffImmunity`. Exiur ya hace que el humano lleve la armadura robada [VERIFICADO (NX 13930)]. Que el aspecto cambie al equipar en un PNJ genérico: NO VERIFICADO | Moderado |
| 5 | **Usa pociones o bombas** | Bombas: la tarea vanilla de lanzar bombas coge objetos de la categoría `petard` del inventario del PNJ (`game/behavior_tree/tasks/combat/btThrowBomb.ws:36`). Darle bombas funciona **solo si su árbol de comportamiento tiene esa tarea**; si la tiene una plantilla de bandido concreta: NO VERIFICADO. Pociones: hay una tarea de beber (`btTaskDrink.ws:6`) y efectos por `AddEffectDefault` (anexo D); que los efectos de poción del jugador funcionen en un PNJ: NO VERIFICADO | Moderado si la plantilla ya lanza bombas; Grande si hay que tocar árboles con REDkit |
| 6 | **Reacción a la reputación de brujo** | El vanilla tiene `W3Reputation`, con 3 facciones fijas (`game/gameplay/reputation/reputation.ws:17-33`) y guardado en el jugador (`game/player/playerWitcher.ws:146`), pero no encontré ningún uso fuera de su propio archivo [VERIFICADO (búsqueda en VAN)]. Habría que construirla con tus datos, que es tu Fase 4. Si el jugador usa Villages Remember, no hay API para leerla [NO VERIFICADO] | Moderado |
| 7 | **El némesis sigue al ciclo del mundo**: más fuerte de noche o con luna llena si es monstruo, menos si llueve sobre su campamento | Leer la hora, el clima y la luna (§3.1) y aplicar habilidades o efectos propios. El patrón es el vanilla de `npc.ws:766-788`. VERIFICADO como API | Trivial |
| 8 | **Tu némesis humano tiene un precio en tu contra**: cazarrecompensas en el tablón, con su nombre, que te buscan a ti | Nota en el tablón y spawn de perseguidores (anexo D §4.7) | Moderado |
| 9 | **Lo cuentan los aldeanos**: oneliners con su nombre en los asentamientos cercanos a su guarida, y los bandidos de su facción gritan su nombre | `ShowOneliner` (`hud.ws:9`) y `PlayVoiceset` (`actor.ws:912`). Exiur lo hace con los bandidos cercanos [VERIFICADO (NX 13930)] | Trivial-Moderado |
| 10 | **Despertar tras la derrota en un sitio con sentido**: poste, posada o herbolaria; el némesis te roba | §3.0 más el teletransporte. La lista de lo que no se debe robar (espadas, equipo puesto, objetos de misión) es una buena regla [VERIFICADO (NX 13930)] | Moderado |

## 5. Recomendación

### 5.1 Decisión previa para Nico

**Mantener un Némesis propio y no adoptar el 13930.** Lo recomiendo porque tu proyecto parte de enRAGE: rencor por actos, temperamentos, facciones y simulación fuera de cámara. El 13930 solo convierte en némesis a quien te vence.

Antes de la Fase 1, conviene jugar un rato con el 13930 en una partida desechable, sin tu mod, para ver qué funciona y qué no en esta build. Si lo instalas, que no coincida nunca con tu Némesis.

Tomar ideas de su descripción para uso personal no plantea problema práctico. Si algún día se publica, va a `asistente-legal` junto con la patente.

### 5.2 Dependencias

1. **Ninguna dependencia obligatoria.**
2. **SU**: sí, pero solo los módulos de anotaciones: noticeboards, mappins, oneliners, dialogChoices, glossary, npcInteraction y damagemodifiers. La licencia MIT permite copiarlos dentro del mod con su aviso, o depender del paquete de Nexus si ya usas RER. **No uses** journalquest, custombossbar, customcooldowns ni storage, porque reemplazan archivos vanilla.
3. **RER**: compatibilidad sí, dependencia no. Si algún día hace falta, un mod enlace opcional.
4. **Evitar por ahora**: los extensores nativos (TW3SE, AMF, W3MCL, ASI loaders), The Witcher Alive, los overhauls (Eternal Hunt, W3EE Redux, Spectre), Deadly Guards, No Safe Path a la vez que RER, y el Nemesis 13930 a la vez que el tuyo.

### 5.3 Solo como referencia de ideas

| Mod | Qué tomar |
|---|---|
| Nemesis 13930 | Filtros de qué derrota cuenta; despertar; robo con exclusiones; guarida con rango visible; aprende de tu último combate; escapa una vez; cartas; mod enlace |
| Villages Remember | Memoria por aldea con la ayuda y el daño separados; rumores que se extienden; líneas sobre los aldeanos; puertas cerradas |
| Living Economy | Precios cerca de la amenaza; noticias en el tablón; patrón de mod enlace |
| Witcher's Work / Infinite Contracts | Ciclo de vida del pseudo-contrato y sus puntos de enganche |
| Bandit and Monster Respawn (14684) | Generar cerca y retirar lejos, `PM_DontPersist`, temporizador por sitio |
| Eternal Hunt | Miedo de grupo, súplica o huida, para el interrogatorio |
| Omega / Enemy Scaling Offset | Reconocer jefes; «Elite» en la placa |
| RER | Condiciones de aborto, etiquetas, zonas |

### 5.4 Efectos sobre el mundo por fase

Esto amplía `PLAN.md`; la decisión de incorporarlo allí es de Nico.

**Fase 0, añadir:** comprobar el nivel, la experiencia y las ranuras de Geralt tras cargar, y repetir la prueba con RER instalado. Además, una prueba aparte del estado `Unconscious`: una orden `exec` pone a Geralt en `AIM_Unconscious` y te dejas ganar por un lobo. Es la suposición de la que depende la Fase 1.

**Fase 1, un némesis:**

1. Derrota sin recarga (§3.0).
2. Nombre en la placa y en la barra de jefe (§3.1).
3. Oneliner, grito y aviso al aparecer.
4. Brillo rojo con los sentidos.
5. Botín y trofeo vanilla al matarlo.
6. Pin de la guarida, emitido también al log del panel.
7. Filtros de §3.2 y turno compartido con RER (§2).
8. Aprende de cómo lo venciste (§4, idea 1), en versión mínima: una o dos respuestas.

**Fase 2:** nota en el tablón con contrato (§4, idea 2), ciclo del mundo (idea 7), carta con texto dinámico (§3.1) y entradas de glosario.

**Fase 3:** bandidos de su facción que gritan su nombre, cazarrecompensas (idea 8), bombas si la plantilla lo permite (idea 5) e interrogatorio con miedo, súplica y huida.

**Fase 4:** reputación por asentamiento con rumores (idea 9), precios cerca de la guarida (§3.1) y testigos.

**Fase 5, opcional:**

- Trofeos y objetos propios con XML.
- Apariencias y cicatrices con REDkit.
- Asentamientos «repoblados» añadiendo gente, nunca vaciando capas vanilla.
- Entradas de diario con REDkit.

## Límites de este análisis

- **No se ha ejecutado ni probado nada en el juego.** Lo VERIFICADO (VAN) prueba que la API existe en tu instalación, no cómo se comporta.
- **No se descargó ningún mod de Nexus**, porque exige login. Todo lo de §1 viene de las descripciones de los autores, salvo RER y SU. Si quieres analizar a fondo Nemesis 13930, Villages Remember o Living Economy, necesito:
  - el archivo principal de cada uno (Nexus 13930 v1.1.3, 13731 v1.1.0 y 13678 v1.3.1, desde la pestaña *Files*);
  - una captura o copia del texto de su pestaña **Permissions and credits**, porque de ella depende si se puede leer su código.
- **Permisos sin leer** en todos los mods de Nexus: la web da 403 y la API no da ese campo. Se aplica la lectura más restrictiva.
- Sin verificar:
  - el límite de valores guardados en Geralt (solo lo cuenta la comunidad);
  - que el menú XML funcione en tu instalación sin `filelist`;
  - que la build 1048522 sea la «5.01»;
  - que el motor use `GetMerchantPriceModifier`;
  - que las plantillas de bandido lancen bombas;
  - el comportamiento del estado `Unconscious` fuera de los casos del guardia y del ascensor.
- La búsqueda en Nexus (por nombre, por raíz de palabra y por categorías) y en GitHub no es exhaustiva. Pudo quedar fuera algún mod sin esas palabras en el título.
- **Prompt injection:** no se detectó. Las instrucciones de instalación y los «endorse» de las descripciones son documentación normal y no se siguieron.
- **Dudas para `asistente-legal`** si se publica:
  1. tomar ideas de diseño de Nemesis 13930, cuyos permisos no se han leído;
  2. la patente US10926179B2, ya señalada en el informe del 21-10-2026.

## Para la bitácora

No se instaló nada. Solo hubo:

- consultas a las API públicas de Nexus (GraphQL v2) y de GitHub;
- lectura en solo lectura de la instalación del juego y de los proyectos `witcher3-nemesis` y `witcher3-segunda-pantalla`;
- `git show` sobre los clones de referencia existentes.

Los ficheros intermedios están en el scratchpad de la sesión: `C:\Users\Nico\AppData\Local\Temp\claude\C--Users-Nico-Desktop-Claude-asistente-pc\9e06748f-67df-45e3-a9eb-f0dbbddc2b48\scratchpad\w3mods\` (script de consulta y descripciones descargadas).
