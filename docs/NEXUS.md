# Publicar en Nexus Mods — kit completo

**Sin publicar.** Kit actualizado el 04-11-2026 para la versión **0.3.0**, que se publica como **work in progress / early beta** por decisión de Nico de ese día. Nada se ha subido ni se ha abierto Nexus. Sigue el formato del kit de Second Screen ([segunda-pantalla/docs/NEXUS.md](../../segunda-pantalla/docs/NEXUS.md)).

| Pieza | Dónde está |
|---|---|
| Archivo para subir | `dist/Nemesis-W3-0.3.0-nexus.zip` (19,9 KB, SHA-256 `B6390ED4…4C45`, generado el 04-11-2026). El de la 0.2.0 se conserva en `dist/`, sin publicar |
| Regenerarlo | `.\herramientas\empaquetar-nexus.ps1` (toma la versión de `NemesisVersion()` y pasa el comprobador) |
| Fuente del README del paquete | `paquete-nexus/README.txt` (`{{VERSION}}` se sustituye al empaquetar) |
| Imagen principal | `docs/nexus/01-portada.jpg` (1920×1080, tipográfica, generada con `work/portada/portada.py`) |

Contenido del zip, con la estructura que esperan Nexus y Vortex para Witcher 3:

```
README.txt                                        inglés, con resumen en español
Mods/modNemesis/LEEME-nemesis-w3.txt              marca del mod (la reconoce el instalador de amigos)
Mods/modNemesis/content/scripts/local/nemesis_datos.ws
Mods/modNemesis/content/scripts/local/nemesis_ganchos.ws
Mods/modNemesis/content/scripts/local/nemesis_motor.ws
Mods/modNemesis/content/scripts/local/nemesis_textos.ws   textos en inglés y español
```

**Sin instalador ni scripts, a propósito.** El mod funciona copiando la carpeta `Mods`, así que un `.bat` o `.ps1` no aportaba nada y era un motivo más de cuarentena: las dos versiones de Second Screen quedaron retenidas por llevar ejecutables. Tampoco lleva recolector de resultados ni cuestionario: eso sigue solo en el zip de amigos.

## Publicado el 04-11-2026

Mod 15458, https://www.nexusmods.com/witcher3/mods/15458. Lo subió Claude desde el Brave de Nico, por orden suya, con los campos, la descripción, el changelog y la portada de este kit. Decisiones del 04-11 tomadas al publicar: descarga por gestor **desactivada** (punto 5) y permisos como los de Second Screen (punto 6; Nexus aún no permite importarlos, se pusieron a mano). Al publicar, el archivo estaba en el escaneo antivirus. Solo lleva `.ws` y `.txt`, así que no debería repetirse la cuarentena de Second Screen, que ahora también salta con scripts.

## Decisiones

Tomadas:

1. **Publicar ya como work in progress** (Nico, 04-11-2026), con el aviso arriba en el README, en el resumen y en la descripción: sin probar en partidas largas, posibles fallos, se agradecen los reportes.
2. **Idioma:** desde la 0.3.0 los avisos, apodos, frases y el nombre flotante salen en español si el idioma de texto del juego es español (`ES` o `ESMX`) y en inglés con cualquier otro. Los registros `NEM|` siguen en español, porque son para depurar.
3. **Nombre:** `Nemesis - Bandits Who Come Back (WIP)`, la propuesta de Nico. No usa «Nemesis System» (marca y patente US10926179B2 de Warner Bros) y el subtítulo lo separa del mod 13930 «Nemesis - Enemy Grudge System». Riesgo menor que queda, como criterio propio: los dos empiezan por «Nemesis -» y saldrán juntos en la búsqueda de Nexus. Si se quiere separar más, la alternativa es `Bandits Who Come Back - Nemeses (WIP)`. La consulta a `asistente-legal` sobre la palabra «Nemesis» sigue siendo opcional; no se ha hecho.
4. **enRAGE:** solo se cita como inspiración de diseño, sin usar nada suyo, que es lo que exige su licencia.

Pendientes de Nico:

5. **Descarga con gestor (Vortex): activada el 06-11-2026 por orden de Nico** en el archivo 0.3.0 (Files › ⋮ › Edit › File options › «Allow mod manager download»). La descripción del archivo empieza ahora por «Install with Vortex, or copy the Mods folder…». Comprobado en la página pública: el archivo ofrece «Mod manager download» y «Manual download», y la cabecera dice «Virus scan: Safe to use». La estructura es la estándar (`Mods/modNemesis`, más un `README.txt` en la raíz), pero sigue sin probarse una instalación real con Vortex; la descripción del mod lo avisa. En cada versión nueva, dejar la casilla marcada al subir.
6. **Permisos y Donation Points.** Propuesta abajo, copiada de lo que elegiste para Second Screen.
7. **Quién sube.** Tú, o Claude desde Brave con tu sesión, como se hizo con Second Screen. En ese caso hace falta tu orden expresa en esa sesión.

Del PLAN siguen abiertas: «Ámbito de la Fase 1: solo Velen o más regiones» (el código actual actúa en todo el mundo abierto salvo prólogo, Kaer Morhen, Isla de la Niebla, Vizima y la Espiral, y así lo describe este kit) y «Nemesis 13930» (por eso la descripción pide no usarlos juntos).

## Paso a paso en Nexus

1. Entra en nexusmods.com con tu cuenta › **Upload › Add a mod**. Juego: **The Witcher 3**.
2. **Mod details:** rellena los campos de la sección siguiente. Pega la descripción en el editor en modo BBCode.
3. **Media:** sube `docs/nexus/01-portada.jpg` como imagen principal (título «Nemesis - Bandits Who Come Back»). Las capturas del juego de «Imágenes» se pueden añadir después.
4. **Files:** sube `Nemesis-W3-0.3.0-nexus.zip` como **Main file**, con los datos del apartado «Archivo». Desactiva la descarga con gestor si decides lo del punto 5.
5. **Requirements:** nada.
6. **Permissions:** según el apartado «Permisos».
7. Revisa la vista previa y publica. Nexus pasa el archivo por su antivirus antes de permitir la descarga; tarda unos minutos.

## Campos (listos para copiar)

- **Mod name:** `Nemesis - Bandits Who Come Back (WIP)`
- **Version:** `0.3.0`
- **Category:** `Gameplay Changes`, o `Gameplay` si el desplegable lo llama así; si no existe ninguna de las dos, `Combat`. **Sin comprobar:** no he abierto Nexus, así que mira el desplegable. Es la más probable porque el mod cambia lo que pasa al matar y al morir, no solo el combate.
- **Language:** English (la página). Los textos del juego están en inglés y en español.
- **Author:** tu usuario de Nexus.
- **Brief overview** (350 caracteres, el límite):

  ```
  Work in progress / early beta. Bandits, deserters and pirates you kill may survive, swear revenge and come back as named nemeses with their gang, immune to what took them down. If one beats you, Geralt doesn't die: he takes part of your coin and you wake at a signpost. English/Spanish texts. Not yet tested in long playthroughs; bug reports welcome.
  ```

  Si Nexus lo corta por contar distinto, quita « / early beta» (quedan 337).

- **Tags sugeridas** (elige las que ofrezca Nexus): Gameplay, Combat, Enemies, NPCs, Immersion, Lore-Friendly, Script.

## Requisitos

| Requisito | Nota |
|---|---|
| The Witcher 3 actualizado a la 5.0 (Next-Gen) | No es un mod, no se añade en la pestaña Requirements. Ya está en la descripción |

No necesita REDkit, Script Merger ni script extender.

## Archivo

- **Name:** `Nemesis 0.3.0 (WIP)`
- **Version:** `0.3.0`
- **Category:** Main file
- **Description** (203 caracteres):

  ```
  Work in progress / early beta. Copy the Mods folder into your game folder (delete an older modNemesis first). No installer, no Script Merger. English or Spanish texts, following the game's text language.
  ```

## Descripción (pegar en modo BBCode)

```
[center][size=6][b][color=#b33a3a]NEMESIS[/color][/b][/size]
[size=5][b]Bandits Who Come Back[/b][/size]
[size=4]The bandit you left for dead remembers your face.[/size][/center]
[center][url=https://ko-fi.com/thevoltor][img width=145,height=36]https://storage.ko-fi.com/cdn/kofi6.png[/img][/url]
[i]Free and always will be. If it helps you, you can buy me a coffee.[/i][/center]

[quote][size=4][b]WORK IN PROGRESS / EARLY BETA (0.3.0)[/b][/size]
This mod has [b]not been tested in long playthroughs yet[/b]. Expect bugs and rough edges. [b]Use a new save slot and keep a backup of your saves.[/b] Bug reports and ideas are very welcome in the Bugs and Posts tabs: they are what will get this out of beta.[/quote]

Some of the bandits, deserters and pirates you kill don't die. One of them crawls away, badly hurt, and swears to remember you. From then on he is [b]your nemesis[/b]: he has a name, a nickname, a temper of his own, and he will come back for you.

[size=5][b]Features[/b][/size]
[list]
[*][b]Nemeses are born from your kills.[/b] A generic human enemy you defeat may survive (10%, 30% for a gang leader) with a scar and a grudge. Seven tempers (hothead, proud, cold, coward, greedy, loyal, drifter) decide how soon he returns.
[*][b]He comes back with his gang.[/b] Some in-game hours later he ambushes you in the same region, with more men the higher his rank, and his name floating over his head.
[*][b]He learns.[/b] If you burned him with Igni he no longer burns; if Aard knocked him down, he no longer falls. Every sign leaves its own scar, nickname and immunity.
[*][b]Defeat without reload.[/b] If he beats you, Geralt does not die. The screen fades to black, he takes part of your coin (never swords, worn gear or quest items), ranks up, and you wake up next to the nearest discovered signpost.
[*][b]Get your coin back.[/b] He carries what he stole; kill him for good and it's on his body.
[*][b]Cheating death.[/b] Beat him and he may survive again, with another scar and more hatred, or die for good.
[*][b]Witcher senses[/b] show him in red. Run far enough and he loses your trail. For now.
[*][b]English and Spanish.[/b] Messages, nicknames and the floating name follow the game's text language: Spanish (Spain or Latin America) gets Spanish, every other language gets English.
[/list]

[size=5][b]Where it happens[/b][/size]
Only generic humans can become nemeses, never story characters. Nothing happens in the prologue, Kaer Morhen, the Isle of Mists, Vizima or the Spiral. Ambushes never start indoors, in settlements, while swimming or riding, during cutscenes or dialogues, or while a quest blocks saving. If a cutscene starts mid-ambush, the gang leaves so your quest isn't broken. Nemeses are rare on purpose.

[size=5][b]Requirements[/b][/size]
[list]
[*]The Witcher 3: Wild Hunt [b]Next-Gen (5.0 or later)[/b] on Windows. Built on Steam (DX12).
[*]Nothing else: no REDkit, no Script Merger, no script extender.
[/list]

[size=5][b]Installation[/b][/size]
[list=1]
[*]Close the game.
[*]Copy the [b]Mods[/b] folder from the archive into your game folder (the one with [i]bin[/i] and [i]content[/i]). Merge it if you already have one. You should get [i]Mods\modNemesis\content\scripts\local\[/i] with four .ws files.
[*]Start the game. The first start takes a little longer while the game recompiles its scripts.
[/list]
Updating: delete the old [i]Mods\modNemesis[/i] folder first. Nemeses already in your saves are kept.
Vortex has not been tested yet; manual install is recommended for this beta.

[size=5][b]Compatibility[/b][/size]
Script-only mod using the official annotations (@addField, @addMethod, @wrapMethod). [b]No vanilla script files are replaced and no Script Merger is needed.[/b] It wraps CR4ScriptedHud.OnTick and CNewNPC.OnDeath (wrappers chain with other mods) and stores its data in a single object attached to the player in your save.
[list]
[*][b]Do not use it together with another nemesis or grudge mod[/b] (e.g. Nemesis - Enemy Grudge System): both handle Geralt's defeat.
[*]Possible conflicts: mods that fully replace those two methods (@replaceMethod) or change how Geralt dies or becomes immortal.
[*][b]Random Encounters Reworked:[/b] designed to share the road (no ambush while RER creatures are within 150 m; RER contract and bounty creatures never become nemeses). Not tested together yet.
[*][b]Second Screen:[/b] works alongside it (both wrap the same HUD tick; tested together with an earlier build).
[/list]

[size=5][b]Uninstall[/b][/size]
Close the game and delete [i]Mods\modNemesis[/i]. Your nemeses stay asleep inside the saves that have them. Loading those saves without the mod is expected to work but hasn't been tested yet, so keep a backup.

[size=5][b]Known issues and limits[/b][/size]
[list]
[*][b]Work in progress:[/b] version 0.1 passed automated in-game tests; 0.2 and 0.3 add fixes, features and the English texts, but have had little in-game testing so far.
[*]During automated tests of 0.2 on my PC the game closed a few times about one second after loading a save. The cause hasn't been pinned down (it may be the test setup, not the mod). If it happens to you, please report it.
[*]No new voice lines: the nemesis speaks through on-screen messages. His name floats over his head, not on the health bar.
[*]During an ambush Geralt cannot die, not even from a fall; reaching the limit counts as a defeat against the nemesis.
[*]Not tested yet in real play: being moved to a signpost, the theft with real money, the AI in long fights, immunities and region filters in the open world, GOG and Vortex.
[/list]

[size=5][b]Bug reports[/b][/size]
Please use the [b]Bugs[/b] tab. If you can, start the game with the launch option [i]-debugscripts[/i] and paste the lines that start with [i]NEM|[/i] from [i]Documents\The Witcher 3\scriptslog.txt[/i] (they are written in Spanish; paste them as they are). With the debug console on, [i]nemesis_estado[/i] writes a summary of your nemeses to that log.

[size=5][b]Support[/b][/size]
The mod is free and will stay free. If you'd like to buy me a coffee, I'm on [url=https://ko-fi.com/thevoltor]Ko-fi[/url] - entirely optional, nothing is locked behind it.

[size=5][b]Credits[/b][/size]
Design inspired by the ideas of the enRAGE mod for Red Dead Redemption 2. No code, text or assets from enRAGE are used. The Witcher 3 belongs to CD PROJEKT RED; nothing from the game is redistributed. Created with Claude.

[spoiler=Español]
[b]Némesis - Bandits Who Come Back[/b] (0.3.0). [b]Trabajo en curso / beta temprana:[/b] aún no se ha probado en partidas largas y puede tener fallos. Usa una ranura de guardado nueva y haz copia de tus partidas. Se agradecen mucho los reportes en la pestaña Bugs.

Algunos bandidos, desertores y piratas que matas no mueren: juran venganza y vuelven a emboscarte con su banda, con nombre y apodo propios y preparados contra lo que los tumbó (si los quemaste con Igni, ya no arden). Si te vencen, Geralt no muere ni se recarga la partida: te roban parte del dinero (nunca espadas, equipo ni objetos de misión), suben de rango y despiertas junto al poste de viaje rápido más cercano. Lo robado lo llevan encima: si los matas del todo, lo recuperas.

[b]Idioma:[/b] los avisos, los apodos y el nombre flotante salen en español si el idioma de texto del juego es español (de España o de Latinoamérica), y en inglés con cualquier otro.

[b]Requisitos:[/b] The Witcher 3 actualizado a la 5.0 (Next-Gen) en Windows. Nada más: ni REDkit ni Script Merger.

[b]Instalación:[/b] con el juego cerrado, copia la carpeta [i]Mods[/i] del archivo dentro de la carpeta del juego. El primer arranque tarda algo más porque el juego recompila sus scripts. Si actualizas, borra antes la carpeta [i]Mods\modNemesis[/i] antigua.

[b]Compatibilidad:[/b] solo scripts con las anotaciones oficiales; no sustituye archivos del juego. No lo uses a la vez que otro mod de némesis. Convive con Second Screen y está pensado para convivir con Random Encounters Reworked.

[b]Quitarlo:[/b] borra [i]Mods\modNemesis[/i] con el juego cerrado. Guarda copia de tus partidas: que carguen sin el mod aún no está comprobado.

[b]Fallos:[/b] pestaña Bugs, mejor con las líneas [i]NEM|[/i] de [i]Documentos\The Witcher 3\scriptslog.txt[/i] (arranca con [i]-debugscripts[/i]). En las pruebas automáticas de la 0.2 el juego se cerró varias veces justo después de cargar, por una causa aún sin aislar: si te pasa, avísame.

[b]Apoyo:[/b] el mod es gratis y lo seguirá siendo. Si quieres invitarme a un café, estoy en [url=https://ko-fi.com/thevoltor]Ko-fi[/url]; es totalmente opcional y no desbloquea nada.
[/spoiler]
```

«Created with Claude» es opcional: quítalo de Credits si no lo quieres.

«Tested together with an earlier build» se apoya en que las sesiones del arnés del 22-10-2026 (v0.1) corrieron con `modSegundaPantalla` instalado (líneas `SP|` y `NEM|` en el mismo log) y en que hoy la 0.3 compila junto a él.

**Cuando la 0.3 pase la prueba en el juego**, actualiza «STATUS» en `paquete-nexus/README.txt` y «Known issues» de esta descripción, y regenera el zip.

## Registro de cambios (Changelog)

Para el archivo 0.3.0 (Files › menú del archivo › Add changelog, una línea por entrada):

```
Version 0.3.0
Work in progress / early beta: first public release.
In-game texts in English, or in Spanish when the game's text language is Spanish.
Bandits, deserters and pirates you kill can survive and come back as named nemeses with their gang.
Defeat without reload: the nemesis robs part of your coin, ranks up and you wake at the nearest signpost.
Scars, nicknames and immunities by sign, stolen coin carried on the nemesis, red glow in witcher senses.
Shares the road with Random Encounters Reworked and works alongside Second Screen.
```

## Imágenes

| Archivo | Estado | Título propuesto |
|---|---|---|
| `docs/nexus/01-portada.jpg` | **Hecha** (04-11-2026): portada tipográfica propia, 1920×1080, con el título, «Work in progress» y una frase de qué hace. Solo formas y texto; fuentes Noto Serif y Noto Sans (licencia OFL); nada de arte, logos ni capturas de CD Projekt. Se regenera con `C:\Python314\python.exe work\portada\portada.py docs\nexus\01-portada.jpg` | Nemesis - Bandits Who Come Back |

Opcionales, capturas del juego para cuando se pueda (con el juego en inglés, los avisos ya salen en inglés):

| Archivo | Qué debe verse | Título propuesto |
|---|---|---|
| `02-nacimiento.jpg` | Tras una pelea con bandidos, el aviso «Among the fallen, one is still breathing…» | One of them is still breathing |
| `03-emboscada.jpg` | La banda en un camino de Velen, con el nombre flotante («Name Nickname · rank N») | He comes back with his gang |
| `04-sentidos.jpg` | Sentidos de brujo con el némesis en rojo | Witcher senses mark him in red |
| `05-derrota.jpg` | Geralt despierto junto al poste, con el aviso de las coronas robadas | Defeated, not dead |
| `06-engana-a-la-muerte.jpg` | El aviso «…his body is gone. He'll be back.» | He cheats death |
| `07-botin.jpg` | Saqueo del cadáver con las coronas recuperadas | Take your coin back |
| `00-cabecera.jpg` | Cabecera de 1300×372 con el título arriba y la mitad inferior solo fondo: Nexus pinta encima desde y≈170 (lección de Second Screen) | — |

**Cómo hacer las capturas:**
- En una **partida desechable** en Velen, nunca en la principal, con copia previa de `gamesaves`. Guarda las partidas de prueba en `work/` como en las pruebas anteriores.
- Para no esperar horas de juego, monta el mod con el arnés (`mod/variantes/arnes-fase1`), que fuerza nacimiento y emboscada. El arnés **nunca va en el zip** y se retira al acabar; no guardes partidas con él.
- Captura con F12 de Steam o con Win+Alt+ImprPant. Formato 16:9 en JPG, a 1920×1080 o 2560×1440, con el HUD visible para que se lean los avisos.
- Dar foco al juego o pulsar teclas en su ventana necesita tu permiso en esa sesión (el 22-10-2026 lo denegaste). Si no, las haces tú jugando.

## Permisos (propuesta, los mismos que Second Screen)

- **Upload permission:** *You are not allowed to upload this file to other sites under any circumstances.*
- **Modification permission:** *You are allowed to modify my files and release bug fixes or improve on the features so long as you credit me as the original creator.*
- **Asset use permission:** *You must get permission from me before you are allowed to use any of the assets in this file.*
- **Conversion permission:** *No permitida* (Nexus solo ofrece «No permitida» o «Permitida con crédito»).
- **Asset use in mods/files that are being sold:** *not allowed* (las normas de CD Projekt lo exigen).
- **Asset use in mods/files that earn donation points:** *You must get permission from me…*
- **Contenido de terceros:** No. El paquete solo lleva scripts propios y texto; la portada solo lleva formas y texto propios.

## Donaciones

Enlace a Ko-fi (https://ko-fi.com/thevoltor) en la descripción (botón «Buy me a coffee» bajo el título, sección Support y línea «Apoyo» en español), puesto el 05-11-2026 por orden de Nico. Donation Points de Nexus: sigue siendo **decisión tuya** si los activas ya en la beta o con la primera versión estable.

## Comprobaciones hechas (04-11-2026, versión 0.3.0)

- **Compila** con `wcc_lite` de REDkit (`compilar-mod.ps1 -Fase1`) junto a los scripts vanilla de la versión instalada **5.0.0.1090142** y a `modSegundaPantalla`: «Success! Scripts cooked». La caché cocinada contiene `NemesisApodoTexto` y `NemesisIdiomaEspanol`, así que incluye el archivo nuevo. También compila con el arnés (`-Arnes1`).
- **Control negativo:** una copia en `work/negativa-0.3` con un error metido a propósito en `nemesis_textos.ws` falla en `nemesis_textos.ws[15]` («syntax error… near 'ERROR_A_PROPOSITO'»).
- **Empaquetador** ejecutado con Windows PowerShell 5.1: zip de 6 archivos con separadores `/`. Los cuatro `.ws` del zip son idénticos byte a byte (SHA-256) a los de `mod/modNemesis` que se compilaron, y el contenido **extraído del zip** también compila (`-Origen work\nexus-verificacion-0.3\Mods\modNemesis`).
- **Comprobador común**, `python -I mods\herramientas\comprobar-paquete.py <zip> --juego witcher3`, sin `--permitir-scripts`: **apto**.
- **Detección del idioma:** `theGame.GetGameLanguageName(audio, texto)`, la misma llamada que usa Segunda Pantalla para su `textLang` y que la condición vanilla de idioma de las misiones (`chosenLanguageCondition.ws`) trata como idioma de texto. Los logs de Segunda Pantalla en este PC ya devolvieron `ES` y `EN`; `ESMX` sale de la tabla vanilla de códigos, sin verlo en el juego.
- **Sin probar:** la 0.2 y la 0.3 en el juego (ni con el arnés ni jugando), que los textos salgan en pantalla en cada idioma, que el HUD dibuje bien las comillas “ ” y el «·», Vortex, GOG y cargar una partida con datos del mod después de retirarlo (paso 5 de la Fase 0).

## Lo que solo puede hacer Nico

1. Tomar las decisiones 5 a 7.
2. Entrar en Nexus con su cuenta (login y 2FA).
3. Subir y publicar, o dar la orden expresa para que lo haga Claude desde Brave con su sesión.
4. Elegir permisos y Donation Points en el formulario.
5. Hacer las capturas opcionales, o dar permiso para que Claude controle la ventana del juego durante esa sesión.
6. Atender Posts y Bugs después de publicar.
