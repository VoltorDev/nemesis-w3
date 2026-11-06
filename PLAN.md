# PLAN — Witcher 3 Némesis

Único plan vivo del proyecto. El diseño adaptado a Witcher 3 está en [docs/DISEÑO.md](docs/DISEÑO.md). Su base:

- [docs/LORE-Y-ENEMIGOS.md](docs/LORE-Y-ENEMIGOS.md): lore, inteligencia por tipo de enemigo y facciones.
- [docs/MODS-Y-MUNDO.md](docs/MODS-Y-MUNDO.md): mods de referencia y efectos sobre el mundo.
- El [informe sobre enRAGE](../../../outputs/enrage-nemesis-witcher3-21-10-2026/INFORME.md).

## Estado (04-11-2026)

- **Fase 0 superada en el juego**: persistencia 44/44.
- **Fase 1 jugable (v0.1) en `mod/modNemesis`, probada en el juego con el arnés automático**: nacimiento, emboscada, derrota sin recarga, guardar y cargar, supervivencia con cicatriz y muerte.
- Está pendiente probarla en el juego jugando de verdad. Se queda sin probar:
  - el traslado al poste;
  - el robo con dinero;
  - la IA peleando;
  - las inmunidades;
  - los filtros en el mundo abierto.
- Paquete para amigos: `dist/Nemesis-W3-22-10-2026.zip`, generado con `herramientas/empaquetar-amigos.ps1`.
- **Publicado en Nexus el 04-11-2026 a las 08:23** como mod 15458 «Nemesis - Bandits Who Come Back (WIP)» (https://www.nexusmods.com/witcher3/mods/15458), por Claude desde el Brave de Nico y por orden suya. Archivo «Nemesis 0.3.0 (WIP)», Main, sin descarga por gestor; portada como imagen; etiquetas Gameplay, AI-Generated Content y AI Media (más Remastered Compatible, que Nexus pone sola); terceros: No; créditos a enRAGE como inspiración y «Created with Claude»; permisos: re-subida, conversión y monetización no permitidas, modificación permitida con crédito y uso de assets pidiendo permiso. Al publicarlo, el archivo estaba en «Virus scanning is in progress». Antes:  `dist/Nemesis-W3-0.3.0-nexus.zip` (v0.3, textos en inglés y español según el idioma del juego), generado con `herramientas/empaquetar-nexus.ps1`; apto para el comprobador de paquetes y compila contra la 5.0.0.1090142. Nico decidió publicarlo ya como **work in progress** con el nombre «Nemesis - Bandits Who Come Back (WIP)». Kit, campos del formulario y portada (`docs/nexus/01-portada.jpg`) en [docs/NEXUS.md](docs/NEXUS.md); falta que Nico decida Vortex, permisos y quién sube, y que lo suba. La v0.2 y la v0.3 siguen **sin probar en el juego**.
- El juego de Nico queda sin el mod y con solo sus partidas originales.

## Fase 1 — un némesis (v0.1, en prueba con amigos)

| Paso | Resultado |
|---|---|
| Nacimiento al matar a un humano genérico (10 %, 30 % si es cabecilla) | PASA en el juego (arnés) |
| Emboscada con séquito según el rango y nivel según el rango | PASA en el juego (arnés) |
| Derrota sin recarga: robo, rango +1, despertar | PASA en el juego (arnés). Poste y robo con dinero, sin probar: el tutorial no tiene ni lo uno ni lo otro |
| Guardar y cargar el némesis | PASA en el juego (arnés) |
| Engaña a la muerte (35 % + 5 %/rango) con cicatriz, y muerte definitiva | PASA en el juego (arnés) |
| Inmunidades por Señal, nombre flotante, huida a más de 90 m, filtros de zona y misión, IA peleando | Sin probar en el juego |

**Siguiente:**
1. Primera partida real de Nico o de sus amigos en Velen con el zip.
2. Recoger `resultados-nemesis.txt` y `FEEDBACK.txt`.
3. Ajustar probabilidades y frecuencia.

## Fase 0 — base técnica (superada)

Hay dos suposiciones de las que depende todo:

1. **Persistencia.** Un árbol de objetos propio en `@addField(CR4Player) saved var` sobrevive a guardar → salir → cargar en la build 5.0.0.1048522 y no estropea la partida: Geralt conserva nivel, experiencia y equipo. La partida sigue cargando si cambia la clase o si se retira el mod. La comunidad lo usa (RER), pero la documentación oficial de `@addField` no menciona `saved`. El mod Nemesis 13930 avisó de partidas que perdían nivel y equipo cuando había muchos datos sueltos de mods.
2. **Derrota sin recarga.** Con inmortalidad de tipo inconsciente, Geralt cae, funde a negro y se levanta en vez de morir y recargar (`player.ws:1086-1099`, `unconscious.ws:79-129`, leídos en el código). La Fase 1 depende de esto.

| Paso | Qué | Resultado |
|---|---|---|
| 0 | Compila con `wcc_lite` junto a los scripts vanilla y a Segunda Pantalla | **OK** el 21-10-2026: v1, v1 + V2, v1 + Derrota y las tres juntas |
| 1-3 | Crear datos → guardar → salir → cargar → comprobación automática de los datos y de nivel, experiencia y ranuras de Geralt | **PASA 44/44** el 22-10-2026, prueba automática en el PC de Nico (`work/autoprueba/sesion1.log`, `sesion2.log`). Se conservan objetos anidados, decimales, cadenas con tildes y separadores, `name`, `map<name,int>`, el PNJ persistente (a 0 m del sitio) y su actitud base. Geralt queda intacto |
| 4 | V2: campo nuevo en una clase ya guardada | pendiente |
| 5 | Retirar el mod y cargar la partida de prueba | pendiente |
| 6 | Derrota: instalar con `-Derrota` y dejarse vencer; tiene que salir `NEM|DERROTA` y no recargar | pendiente |
| 7 | Opcional: morir sin guardar y comprobar que se pierde lo no guardado | pendiente |
| 8 | Opcional: repetir 1-3 con RER instalado | pendiente; RER no está instalado |

**Si falla el paso 3:** se mira qué tipo falla en las líneas `FALLA`.
- Si solo falla el `map`, se usan arrays paralelos.
- Si falla el árbol entero, el plan B son los facts (solo enteros) y el plan C, TW3SE, que antes pasa por `security-auditor`.
- Si fallan nivel, experiencia o ranuras de Geralt, **se para**: el sistema estaría estropeando partidas.

**Si falla el paso 6:** la derrota se rediseña como umbral de vida. Por debajo de X %, el némesis te perdona o huyes.

El procedimiento detallado está en el [README](README.md#fase-0-prueba-de-persistencia). Los resultados se apuntan con `herramientas/fase0.py` en `work/fase0-resultados.md`.

## Decisiones pendientes de Nico

1. **Nemesis 13930:** si lo juegas antes como referencia, en una partida desechable y nunca a la vez que este.
2. **Ámbito de la Fase 1:** solo Velen, como se propone, o más regiones.
3. **TW3SE:** no se usa mientras no haga falta.
4. **Nexus: Vortex, permisos, Donation Points y quién sube.** Propuestas en [docs/NEXUS.md](docs/NEXUS.md#decisiones) (puntos 5 a 7).

Decidido:
- 04-11-2026: **publicar en Nexus ya, como work in progress**, con textos en inglés y español según el idioma del juego, el nombre «Nemesis - Bandits Who Come Back (WIP)» (sin «Nemesis System») y enRAGE citado solo como inspiración. La consulta a `asistente-legal` sobre la palabra «Nemesis» queda como opcional, sin hacer.
- 21-10-2026: tras una derrota, Geralt **despierta junto al poste de viaje rápido descubierto más cercano**. El némesis se lleva **parte del dinero** y nunca espadas, equipo puesto ni objetos de misión. Cómo se hace: [DISEÑO.md §2.1](docs/DISEÑO.md).

## Fases siguientes

Solo se abren cuando pase la Fase 0. El contenido de cada una está en [DISEÑO.md §8](docs/DISEÑO.md):

1. **Un némesis:** cabecilla de bandidos en Velen.
2. **Facciones:** las de Velen, con guerras fuera de cámara.
3. **Encuentros:** tensión, cara a cara, interrogatorio y primer némesis limitado.
4. **Sociedad:** reputación, rumores, funerales y otras regiones.
5. **Opcional:** REDkit, trofeos propios y cicatrices visibles.

## Registro

- 21-10-2026: proyecto creado; mod de la Fase 0, scripts de compilación, instalación y lectura del log.
  - Compila sin errores junto a vanilla 5.0.0.1048522 y `modSegundaPantalla`, también con V2. Una prueba con un error metido a propósito falla como debe.
  - Probados: el instalador (un ciclo de instalar y retirar, que no deja nada en `Mods`) y el lector del log, con un log de ejemplo.
- 21-10-2026: revisión antes de instalar, a petición de Nico.
  - Lore, enemigos y mods investigados; diseño adaptado en `docs/`.
  - El PNJ de la prueba pasa a ser el cabecilla genérico `novigrad_bandit_leader_swordshield`, en actitud amistosa. Antes salía del modo foto, que podía generar un personaje de historia.
  - Se añaden a la prueba la comprobación de nivel, experiencia y ranuras de Geralt y la variante `-Derrota`.
  - Todo compila. Sigue pendiente la prueba dentro del juego.
- 21-10-2026: pulido antes de la prueba e **instalado** en `Mods\modNemesisPrueba`, sin variantes; coincide con el proyecto.
  - Solo actúa con Geralt (nunca con Ciri) y fuera de escenas, diálogos y combate.
  - La comprobación del PNJ persistente se reintenta hasta 20 s.
  - La foto de Geralt se refresca cada 2 s.
  - El instalador aparta la caché de scripts si no coincide con lo instalado; la de entonces se guardó como `x64.final.redscripts.antes-nemesis`.
  - `fase0.py` explica por qué no hay líneas y lista los fallos.
  - Comprobado que la opción de Steam lanza el juego con `-debugscripts` a través del lanzador de Segunda Pantalla.
- 22-10-2026, madrugada: Nico pide una **versión jugable** y que las pruebas en el juego las haga Claude.
  - Copia de las partidas en `work/copia-gamesaves-21-10-2026`.
  - **Primer arranque con el mod, vía Steam y REDlauncher: el juego falló** (CrashReporter a los 22 s, antes del menú; sin volcado legible). **No se ha reproducido** en tres arranques directos con `-debugscripts` (herramienta `arranque-prueba.ps1`), con y sin el `map` guardado; el último, estable 90 s en el menú. Se queda en vigilancia.
  - Nico denegó el control de la ventana del juego. Para probar sin tocar la pantalla se prepararon el arnés `variantes/autoprueba` (carga la última partida y guarda en ranura nueva) y `herramientas/autoprueba-fase0.ps1` (dos sesiones automáticas). **Sin ejecutar todavía.**
  - Pausado porque Nico va a jugar. Mod de prueba **retirado** del juego; solo queda `modSegundaPantalla`. Partidas intactas.
  - Siguiente: ejecutar `autoprueba-fase0.ps1` cuando Nico no esté jugando, y luego construir la Fase 1 jugable.
- 22-10-2026, mañana: **persistencia confirmada** (44/44).
  - La partida más reciente de Nico es el arranque del juego: Geralt a nivel 1, día 0, equipo inicial.
  - La derrota automática no llegó a ocurrir: el cabecilla hostil no atacó en 4 min (posible zona tutorial). La prueba de la Fase 1 provoca la derrota con `Kill(…, false, líder)`, que respeta la inmortalidad «inconsciente».
  - Mod jugable de la Fase 1 escrito en `mod/modNemesis` (datos, motor y enganches); compila. Arnés `variantes/arnes-fase1` y `herramientas/autoprueba-fase1.ps1`.
- 22-10-2026: **Fase 1 probada en el juego** con el arnés automático, en la partida de Nico (tutorial de Kaer Morhen, sin dinero ni postes descubiertos, con los filtros de zona desactivados por el arnés).
  - **Funciona**:
    - Nacimiento: el motor da la ruta exacta de la plantilla del caído.
    - Emboscada con séquito.
    - Derrota sin recarga y despertar.
    - Guardado y carga del némesis.
    - Supervivencia con cicatriz (odio de 50 a 75) y muerte definitiva.
  - **Corregido por las pruebas**:
    1. El estado vanilla «inconsciente» dejaba a Geralt atascado con 0 de vida. Se sustituye por una derrota propia: inmortal durante el encuentro y, al 3 % de vida, fundido, robo, poste, 40 % de vida.
    2. La generación fallaba 2 de cada 3 veces en sitios cerrados. Ahora prueba 6 direcciones y 3 distancias.
    3. Una emboscada con Geralt malherido era una derrota inmediata. Ahora no hay emboscada por debajo del 30 % de vida, y la derrota solo cuenta tras 3 s de encuentro.
    4. «Cargar la última partida» trajo una partida ya apartada. El arnés elige la partida por nombre (modos A/B).
  - **Sin probar en el juego**: el traslado al poste (en el tutorial no hay postes descubiertos), el robo con dinero real, los filtros de zona y misión en el mundo abierto, la IA real peleando y las inmunidades aplicadas.
  - Las partidas de prueba se apartan a `work/partidas-de-prueba`. El juego conserva su nombre en la lista de partidas aunque el archivo ya no esté.
- 22-10-2026: **pulido v0.2** (compila; **sin probar en el juego**: la prueba se cortó porque Nico iba a jugar). Correcciones:
  1. La inmortalidad del encuentro se guarda en la partida (`actor.ws`, `saved var immortalityFlags`). Pasa a un canal propio (`AIC_Fistfight`; `AIC_Combat` lo pisan las animaciones sincronizadas) y se limpia, junto con el bloqueo de la derrota, en cada carga.
  2. Si cae el líder con el séquito vivo, el encuentro sigue. Antes se borraba al séquito en plena pelea.
  3. Si sobrevive, su cuerpo desaparece de verdad.
  4. La autoría de la muerte es correcta («a manos de otros»).
  5. Pausa global de 2 h de juego entre emboscadas.
  6. Inmunidades completas por Señal.
  7. Nombres únicos.
  8. Las plantillas de misión y los jefes únicos de hansa quedan excluidos.
  9. Se permiten nacimientos en pueblos.
  10. Una escena o diálogo durante el encuentro retira a la banda.
  11. Familias de las expansiones (hansa en Toussaint, Rosa Llameante), con caída a bandido sin la expansión.
  12. Mensajes con lo robado y sin poste.
  - Instalador: se eleva a administrador si el juego está en Program Files; marca `LEEME-nemesis-w3.txt` para no pisar ni borrar otro `modNemesis`; los `.bat` avisan si se ejecutan sin descomprimir.
  - Arnés ampliado (guardar a mitad del encuentro, líder caído con séquito vivo, familia hansa). **Pendiente**: ejecutar `autoprueba-fase1.ps1` y regenerar el zip; el zip actual sigue siendo la v0.1.
  - Mejoras añadidas el mismo día, también solo compiladas:
    - Turno compartido con RER: sin emboscada si hay entidades `RandomEncountersReworked_Entity` a menos de 150 m; sus criaturas de contrato y recompensa nunca son némesis.
    - Botín: lo robado se guarda en el registro, el líder lo lleva encima y queda en su cadáver si muere del todo.
    - Brillo rojo (`FMV_Clue`) con los sentidos.
    - Sin emboscadas durante fundidos ni peleas a puñetazos.
    - El arnés da 1000 coronas en la sesión A y comprueba el botín en la B.
- 22-10-2026, tarde: **la prueba automática de la v0.2 no pasa del arranque.** Siete intentos, ninguno llegó a la emboscada:
  - 3 cierres del juego (`0xc0000005` en `witcher3.exe`, desplazamiento `0x1f15ac4`, siempre ~1 s después de cargar);
  - 4 sesiones paradas tras cargar.
  - **El entorno cuenta**:
    - Con la app de Claude en primer plano, el juego se pausa en partida.
    - Con foco desde el arranque, se queda en «Pulsa cualquier tecla».
    - El juego está en pantalla completa exclusiva.
    - Las pruebas que pasaron (madrugada) se hicieron con la pantalla bloqueada, sin nada que compitiera por el foco.
  - **Sin descartar que sea el mod**: no se ha podido comparar la v0.1 en las mismas condiciones.
  - Cambios hechos mientras tanto:
    - La limpieza de carga se retrasa a 3 s y solo actúa si hay marca propia.
    - El nombre interno de un PNJ solo se lee tras comprobar que lo mató Geralt.
    - No hay nacimientos en los primeros segundos.
    - El arnés: sin `AddMoney` (botín asignado en la sesión B), con trazas, y con salto de la pantalla de inicio.
    - El script de prueba da el foco al juego.
    - `herramientas/diagnostico-arranque.ps1` registra el foco y el avance del registro.
  - **Siguiente**: repetir la prueba con la pantalla bloqueada (como de madrugada); si vuelve a cerrarse, comparar contra la v0.1 en esas mismas condiciones. El zip sigue siendo la v0.1.
- 03-11-2026: el proyecto pasa a `mods\witcher3\nemesis` (antes `witcher3-nemesis`). Ningún script usaba la ruta vieja: todos parten de su propia carpeta. Solo la citan los registros antiguos de `work/`, que no se tocan.
- 03-11-2026: **preparado para Nexus, sin publicar** (no se ha abierto Nexus).
  - `herramientas/empaquetar-nexus.ps1` genera `dist/Nemesis-W3-<versión>-nexus.zip`: `Mods/modNemesis/content/scripts/local/*.ws`, la marca `LEEME-nemesis-w3.txt` con texto público y `README.txt` (fuente en `paquete-nexus/`). Sin instalador ni scripts: el mod funciona copiando la carpeta, y así no hay motivos de cuarentena. La versión sale de `NemesisVersion()` («0.2» → 0.2.0).
  - Comprobador `mods\herramientas\comprobar-paquete.py --juego witcher3`, sin `--permitir-scripts`: **apto**.
  - El contenido extraído del zip **compila** con `wcc_lite` junto a vanilla **5.0.0.1090142** y `modSegundaPantalla`. Control negativo con un error metido a propósito: falla, como debe. Es la primera compilación del mod contra la build del 29-10-2026; en el juego sigue sin probar.
  - `compilar-mod.ps1`: nuevo `-Origen` para compilar una copia externa del mod; temporales en `work/compilar` en vez de `%TEMP%`; muestra la versión del juego; guardado con BOM (en Windows PowerShell 5.1 salían mal las tildes).
  - Kit en `docs/NEXUS.md`. Hallazgos que pasan a decisiones de Nico (4 a 6): la v0.2 no ha pasado la prueba en el juego, los textos del juego están en español y el nombre choca con el mod 13930 y con la patente de Warner Bros.
  - Contradicción encontrada sin corregir: `paquete-amigos/LEEME.txt` dice que las partidas siguen cargando sin el mod «(comprobado)», pero el paso 5 de la Fase 0 sigue pendiente. El LEEME también se titula «versión 0.2» mientras el zip de amigos es la v0.1. Se arregla al regenerar el zip de amigos.
- 04-11-2026: **v0.3, textos bilingües y paquete de Nexus como work in progress** (sin publicar; no se ha abierto Nexus ni el navegador).
  - Nuevo `nemesis_textos.ws` con todos los textos que ve el jugador: avisos, frases de emboscada, apodos y nombre flotante («· rango N» / «· rank N»). Español si el idioma de texto del juego es `ES` o `ESMX`, inglés con cualquier otro. Se detecta con `theGame.GetGameLanguageName(audio, texto)`, la llamada de la que sale el `textLang` de Segunda Pantalla (sus logs en este PC dieron `ES` y `EN`), y se consulta en cada aviso.
  - Los apodos se guardan ahora como clave («Tuerto») y se traducen al mostrarlos. Los némesis de partidas de la 0.1/0.2, que guardaron el texto en español («el Tuerto»), se reconocen en la misma tabla y también cambian de idioma. No se añade ningún campo guardado. Los registros `NEM|`, la crónica y el temperamento siguen en español (depuración).
  - Corregido un comentario que no decía la verdad: cada cicatriz de Señal, bomba o virote cambia el apodo, no solo la primera.
  - `NemesisVersion()` = «0.3». El empaquetador exige los cuatro `.ws`; la marca y el `README.txt` del paquete llevan el nombre nuevo y el aviso de work in progress arriba.
  - **Compila** (`compilar-mod.ps1 -Fase1` y `-Arnes1`) junto a vanilla 5.0.0.1090142 y `modSegundaPantalla`; la caché cocinada contiene las funciones nuevas. **Control negativo**: un error a propósito en `nemesis_textos.ws` falla en la línea 15.
  - `dist/Nemesis-W3-0.3.0-nexus.zip`: comprobador común **apto**; sus `.ws` son idénticos (SHA-256) a los compilados y lo extraído del zip también compila. El zip de la 0.2.0 se conserva.
  - Portada tipográfica propia `docs/nexus/01-portada.jpg` (1920×1080, Pillow, fuentes Noto OFL), mirada antes de darla por buena. Script en `work/portada/portada.py`.
  - **Sin probar en el juego**: ni la v0.2 ni la v0.3, ni que los textos salgan en pantalla en cada idioma. El zip de amigos sigue siendo la v0.1.
