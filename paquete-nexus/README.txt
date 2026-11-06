NEMESIS - BANDITS WHO COME BACK (WIP)
for The Witcher 3: Wild Hunt - Next-Gen (5.0)
Version {{VERSION}} - WORK IN PROGRESS / EARLY BETA

(Resumen en español al final.)

*** WORK IN PROGRESS - PLEASE READ FIRST ***
This is an early beta. It has NOT been tested in long playthroughs yet, so expect bugs and rough
edges. Use a NEW SAVE SLOT and keep a backup of your saves before trying it. Bug reports and ideas
are very welcome (Bugs and Posts tabs on the Nexus page).

WHAT IT DOES
Some of the bandits, deserters and pirates you kill don't die. One of them crawls away, badly
hurt, and swears to remember you. From then on he is your NEMESIS, with a name, a nickname and a
temper of his own (hothead, proud, cold, coward, greedy, loyal or drifter).

- He comes back: some in-game hours later he ambushes you in the same region with his gang.
  His name floats over his head and he comes prepared: if you burned him with Igni he no longer
  burns; if you knocked him down with Aard, he no longer falls.
- If he beats you, Geralt does not die and the game does not reload. The screen fades to black,
  he takes part of your coin (never swords, worn gear or quest items), ranks up, and you wake up
  next to the nearest discovered fast travel signpost (or where you fell, if there is none).
- He carries what he stole: kill him for good and you get it back from his body.
- Witcher senses show him in red.
- If you beat him, he may cheat death again, with a new scar and more hatred... or die for good.
- Run far enough away and he loses your trail. For now.

It only works with generic humans, never with story characters. Nothing happens in the prologue,
Kaer Morhen, the Isle of Mists, Vizima or the Spiral. Ambushes never start indoors, in
settlements, while swimming or riding, during cutscenes or dialogues, or while a quest blocks
saving. Nemeses are rare on purpose: a kill has a 10% chance (30% for a gang leader) of creating
one, and he waits a few in-game hours before coming back.

LANGUAGE
In-game messages, nemesis nicknames and the floating name are in ENGLISH, or in SPANISH if the
game's text language is Spanish (Spain or Latin America). The mod follows the text language set
in the game options.

STATUS
- Version 0.1 passed automated in-game tests on Steam, DX12, game version 5.0.0.1048522: birth
  of a nemesis, ambush with his gang, defeat without reload, save and load, cheating death with a
  scar, and final death.
- Versions 0.2 and {{VERSION}} add fixes, features and the English texts on top of it. They compile
  against game version 5.0.0.1090142, but have had little in-game testing so far.
- Not tested yet while really playing: being moved to a signpost, the coin theft with real money,
  the AI in long fights, the immunities, the region filters in the open world, GOG, Vortex, and
  loading a save made with the mod after removing the mod.
- During automated tests of 0.2 on the author's PC the game closed a few times about one second
  after loading a save. The cause has not been pinned down (it may be the test setup, not the
  mod). If it happens to you, please report it.
- During an ambush Geralt cannot die (not even from a fall). If he reaches his limit, it counts as
  a defeat against the nemesis.
- If a cutscene or a quest dialogue starts in the middle of an ambush, the gang leaves so the quest
  is not broken.

REQUIREMENTS
- The Witcher 3: Wild Hunt updated to the Next-Gen version (5.0 or later), Windows.
- Nothing else: no REDkit, no Script Merger, no script extender.

INSTALLATION (manual)
1. Close the game.
2. Copy the "Mods" folder from this archive into your game folder (the one that contains "bin"
   and "content"). If you already have a "Mods" folder, merge them. You should end up with
   <game folder>\Mods\modNemesis\content\scripts\local\ holding four .ws files
   (nemesis_datos.ws, nemesis_ganchos.ws, nemesis_motor.ws and nemesis_textos.ws).
3. Start the game. The first start takes a little longer: the game recompiles its scripts.

Updating from an older version: delete the old Mods\modNemesis folder first, then copy the new
one. Nemeses already in your saves are kept and their nicknames switch to the new texts.

Vortex: the archive uses the standard Mods\modNemesis layout, but installing with Vortex has not
been tested. If in doubt, install manually.

COMPATIBILITY
- Script-only mod built with the official annotations (@addField, @addMethod, @wrapMethod).
  It does not replace any vanilla script file, so Script Merger is not needed and there is nothing
  to merge for it.
- It hooks CR4ScriptedHud.OnTick and CNewNPC.OnDeath (wrappers chain with other mods) and stores
  its data in one object attached to the player inside your save.
- Do NOT use it together with another nemesis or grudge mod (for example "Nemesis - Enemy Grudge
  System"): both handle Geralt's defeat.
- Possible conflicts: mods that replace those two methods entirely (@replaceMethod) or that
  change how Geralt dies or becomes immortal.
- Random Encounters Reworked: designed to coexist (no ambush while RER creatures are within 150 m,
  and RER contract creatures never become nemeses), but not tested together yet.
- Works alongside "Second Screen" (both wrap the same HUD tick).

UNINSTALL
1. Close the game.
2. Delete <game folder>\Mods\modNemesis. The game recompiles its scripts on the next start.
Your nemeses stay asleep inside the saves that have them. Loading such a save without the mod is
expected to work, but it has not been tested yet: keep a backup.

BUG REPORTS
Use the Bugs tab on the Nexus page. To help: start the game with the launch option -debugscripts
and attach the lines that start with "NEM|" from Documents\The Witcher 3\scriptslog.txt. Those
debug lines are written in Spanish; just paste them as they are. With the debug console enabled,
the command nemesis_estado writes a summary of your nemeses to that same log.

CREDITS
Design inspired by the ideas of the enRAGE mod for Red Dead Redemption 2. No code, text or assets
from enRAGE are used. The Witcher 3 belongs to CD PROJEKT RED; nothing from the game is included.

----------------------------------------------------------------------------------------------------
RESUMEN EN ESPAÑOL
Némesis - Bandits Who Come Back {{VERSION}}. TRABAJO EN CURSO (beta temprana): aún no se ha
probado en partidas largas y puede tener fallos. Usa una ranura de guardado nueva y haz copia de
tus partidas. Se agradecen mucho los reportes de fallos.

Algunos bandidos, desertores y piratas que matas sobreviven, juran venganza y vuelven a emboscarte
con su banda, con nombre propio y preparados contra lo que los tumbó. Si te vencen, Geralt no
muere: te roban parte del dinero, suben de rango y despiertas en el poste de viaje rápido más
cercano.

- Idioma: los avisos, los apodos y el nombre flotante salen en español si el idioma de texto del
  juego es español (de España o de Latinoamérica), y en inglés con cualquier otro.
- Requisitos: The Witcher 3 actualizado a la versión 5.0 (Next-Gen) en Windows. Nada más.
- Instalar: con el juego cerrado, copia la carpeta "Mods" de este archivo dentro de la carpeta del
  juego (la que tiene "bin" y "content"). El primer arranque tarda algo más porque recompila. Si
  actualizas, borra antes la carpeta Mods\modNemesis antigua.
- Compatibilidad: solo scripts con anotaciones oficiales; no sustituye archivos del juego y no
  necesita Script Merger. No lo uses a la vez que otro mod de némesis.
- Quitar: borra la carpeta Mods\modNemesis con el juego cerrado. Guarda copia de tus partidas: que
  carguen sin el mod aún no está comprobado.
- Estado: la versión 0.1 pasó pruebas automáticas en el juego (Steam, 5.0.0.1048522); la 0.2 y
  esta compilan con la 5.0.0.1090142 pero apenas se han probado en el juego. En las pruebas
  automáticas de la 0.2 el juego se cerró varias veces justo después de cargar, por una causa aún
  sin aislar: si te pasa, avísame. Sin probar en GOG ni con Vortex.
- Fallos: pestaña Bugs de la página de Nexus, con las líneas "NEM|" de
  Documentos\The Witcher 3\scriptslog.txt (arranca el juego con -debugscripts).
