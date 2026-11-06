# Witcher 3 Némesis

Sistema Némesis propio para The Witcher 3 Remastered (5.0, Steam, DX12), escrito en WitcherScript. Uso personal. El planteamiento, adaptado al lore, a los enemigos y al mundo de Witcher 3, está en [docs/DISEÑO.md](docs/DISEÑO.md).

Toma como referencia de diseño el mod enRAGE de RDR2: sus reglas, fórmulas y parámetros, descritos con palabras propias. **No se reutiliza código ni texto de enRAGE**, porque su licencia lo prohíbe. El análisis completo y el plan por fases están en [el informe del 21-10-2026](../../../outputs/enrage-nemesis-witcher3-21-10-2026/INFORME.md), y el estado y lo pendiente, en [PLAN.md](PLAN.md), el único plan vivo.

## Versión jugable (Fase 1)

`mod/modNemesis` es la v0.3 (`NemesisVersion()` en `nemesis_datos.ws`); la v0.1 es la que pasó la prueba en el juego y la que lleva el zip de amigos. El estado de cada una está en el [PLAN](PLAN.md).

Desde la v0.3 los avisos, apodos y el nombre flotante salen en **español si el idioma de texto del juego es español** (`ES` o `ESMX`) y en **inglés con cualquier otro**. Todos esos textos están en `nemesis_textos.ws`; los registros `NEM|` siguen en español.

- Al matar a un bandido, desertor o pirata genérico, a veces sobrevive y se convierte en némesis.
- Vuelve a emboscarte con su banda.
- Si te vence, despiertas en el poste más cercano sin una parte del dinero.
- Si lo vences, puede volver a engañar a la muerte.

Funcionamiento y límites en `paquete-amigos/LEEME.txt`.

- **Para jugarla o pasársela a otros:** `dist/Nemesis-W3-<fecha>.zip`, que trae instalador, recolector de resultados, desinstalador y cuestionario. Se regenera con `.\herramientas\empaquetar-amigos.ps1`.
- **Para Nexus Mods (público, sin publicar todavía; se publicará como «Nemesis - Bandits Who Come Back (WIP)»):** `dist/Nemesis-W3-<versión>-nexus.zip`, hoy el de la 0.3.0, con solo `Mods/modNemesis` y un `README.txt` en inglés con resumen en español; sin instalador ni scripts, para no dar motivos de cuarentena. Se regenera con `.\herramientas\empaquetar-nexus.ps1`, que toma la versión de `NemesisVersion()` y pasa el comprobador común de paquetes. El kit de publicación (campos del formulario, descripción BBCode, changelog, imágenes, permisos, decisiones pendientes) está en [docs/NEXUS.md](docs/NEXUS.md), y la portada en `docs/nexus/01-portada.jpg`.
- **Prueba automática en este PC**, sin tocar la pantalla: `.\herramientas\autoprueba-fase1.ps1`. Hace dos sesiones de unos 5 min, deja los registros en `work/autoprueba-fase1/`, aparta las partidas de prueba a `work/partidas-de-prueba/` y retira el mod al terminar.
- **Compilar:** `.\herramientas\compilar-mod.ps1 -Fase1`. Con `-Origen <carpeta modNemesis>` compila otra copia, por ejemplo la extraída del zip de Nexus. Los temporales van a `work/compilar`.

## Estructura

| Carpeta | Qué hay |
|---|---|
| `mod/modNemesis/` | **Mod jugable** (Fase 1): datos guardados, motor, enganches y textos en inglés y español |
| `mod/variantes/arnes-fase1/` | Arnés de prueba automática de la Fase 1 (solo para este PC; nunca va en el zip) |
| `paquete-amigos/` | Fuente del zip para amigos: instalador, recolector, desinstalador, LEEME y cuestionario |
| `paquete-nexus/` | Fuente del `README.txt` del zip de Nexus (`{{VERSION}}` se rellena al empaquetar) |
| `dist/` | Zips generados: el de amigos y el de Nexus |
| `herramientas/empaquetar-amigos.ps1`, `empaquetar-nexus.ps1` | Generan los dos zips |
| `mod/modNemesisPrueba/` | Mod temporal de la **Fase 0**: prueba si los datos propios sobreviven a guardar y cargar |
| `mod/variantes/v2/` | Archivo extra para el paso 4 de la Fase 0: añade un campo a una clase ya guardada |
| `mod/variantes/derrota/` | Archivo extra para probar la derrota sin recarga (Geralt queda inconsciente en vez de morir) |
| `docs/` | Diseño adaptado a Witcher 3 (`DISEÑO.md`), lore y enemigos, mods de referencia y efectos sobre el mundo, el kit de Nexus (`NEXUS.md`) y sus imágenes (`docs/nexus/`) |
| `herramientas/compilar-mod.ps1` | Compila el mod con `wcc_lite` de REDkit sin abrir el juego |
| `herramientas/prueba-fase0.ps1` | Instala o retira el mod de prueba en la carpeta `Mods` del juego |
| `herramientas/fase0.py` | Lee `scriptslog.txt` después de cada sesión y apunta el resultado en `work/fase0-resultados.md` |
| `work/` | Resultados de pruebas y temporales; no es fuente |

## Relación con Segunda Pantalla

Reutiliza lo que ya se comprobó en [witcher3-segunda-pantalla](../segunda-pantalla/README.md):

- El mod escribe en `Documentos\The Witcher 3\scriptslog.txt` con `LogChannel`, y eso **exige arrancar el juego con `-debugscripts`**. La opción de lanzamiento de Steam de Segunda Pantalla ya lo hace.
- El juego recompila los scripts al arrancar si cambia un mod.
- Las anotaciones (`@addField`, `@wrapMethod`) se encadenan con las de Segunda Pantalla, que también envuelve `CR4ScriptedHud.OnTick`.

Los dos mods son independientes: este no edita nada de aquel.

## Fase 0: prueba de persistencia

Lo que se prueba: un árbol de objetos propio colgado del jugador (`@addField(CR4Player) saved var`) sobrevive a guardar, salir del juego y cargar. Incluye listas de objetos anidados, enteros, decimales, cadenas, `name`, un `map` y el enlace a un PNJ real con `PM_Persist`. De eso depende todo el sistema.

El mod no necesita teclas ni consola. Actúa cuando llevas **3 s jugando con Geralt** después de cargar, fuera de escenas, diálogos y combate. Con Ciri no hace nada. Entonces:

- **Si la partida no tiene datos**, crea un conjunto fijo de datos de prueba y escribe `NEM|CREADO`. También genera a 4 m de Geralt un cabecilla de bandidos genérico, `novigrad_bandit_leader_swordshield`, la misma plantilla con la que empezará la Fase 1. Lo pone en actitud amistosa para que no haya combate y se pueda guardar. Si aparece, no lo mates antes de guardar.
- **Al cargar**, además apunta como `NEM|INFO` si el cabecilla conserva la actitud. Ese dato decide si el sistema tiene que volver a aplicarla en cada carga.
- **Si ya los tiene**, los compara campo a campo con los valores esperados y escribe una línea `NEM|PASA` o `NEM|FALLA` por cada comprobación. También comprueba el nivel, la experiencia y el equipo de Geralt. Espera hasta 20 s a que se cargue el cabecilla y al final escribe `NEM|RESUMEN`.
- Mientras juegas, cada 2 s actualiza la «foto» de Geralt que va dentro de la partida, así que lo que hagas antes de guardar no da falsos fallos.

### Procedimiento

**Importante:** usa una **partida desechable**. El mod mete datos propios en la partida; no la mezcles con tu partida principal.

Antes de empezar: el mod ya está instalado y compilado (21-10-2026). Si solo quieres jugar la prueba, empieza en el paso 3.

1. `.\herramientas\compilar-mod.ps1` tiene que decir OK.
2. `.\herramientas\prueba-fase0.ps1 -Instalar`. Si hace falta, aparta la caché de scripts para que el juego recompile: **el primer arranque tarda algo más**.
3. Abre el juego **desde Steam**: su opción de lanzamiento ya pone `-debugscripts`. Carga una partida que no te importe, de una zona tranquila con Geralt (Velen, por ejemplo), y juega unos **5 s** sin combate. A tu lado aparecerá el cabecilla amistoso.
4. **Guarda manualmente** en una ranura nueva, la «partida de prueba», y cierra el juego del todo.
5. `python herramientas/fase0.py`: debe mostrar `CREADO`.
6. Abre el juego otra vez desde Steam y **carga la partida de prueba**. Juega unos **25 s** sin combate, cierra el juego y ejecuta `python herramientas/fase0.py`. Debe mostrar todo `PASA`, incluidos nivel, experiencia y ranuras de equipo de Geralt. **Este es el resultado clave.** Si fallan los de Geralt, para y no sigas con esa partida.
7. Paso 4, cambio de clase: `.\herramientas\prueba-fase0.ps1 -Instalar -V2`, abre el juego, carga la partida de prueba, espera, cierra y ejecuta `python herramientas/fase0.py`. Pasa si carga, los datos antiguos siguen intactos y aparece la línea del campo nuevo con su valor.
8. Paso 5, retirar el mod: `.\herramientas\prueba-fase0.ps1 -Retirar`, abre el juego y carga la partida de prueba. Pasa si **carga sin bloquearse**; esto no deja líneas en el log, así que se apunta a mano. **No guardes** en esta sesión, porque perderías los datos de prueba para el paso siguiente.
9. **Derrota sin recarga**, que es de lo que depende la Fase 1: `.\herramientas\prueba-fase0.ps1 -Instalar -Derrota`, carga la partida de prueba y déjate vencer por enemigos, por ejemplo lobos. Geralt debe quedar inconsciente y levantarse **sin recargar**. Cierra y ejecuta `python herramientas/fase0.py`: deben aparecer dos líneas `NEM|DERROTA`, la de caer y la de levantarse. Solo funciona una vez por carga.
10. Opcional, muerte: con el mod instalado, carga la partida de prueba y apunta el número `sesiones` que sale en el log. Déjate matar sin guardar, deja que el juego recargue y vuelve a mirar el log: `sesiones` debe ser el mismo. Confirma que lo no guardado se pierde al morir.

Al terminar: `.\herramientas\prueba-fase0.ps1 -Retirar` (también aparta la caché para que el juego recompile sin el mod) y borra la partida de prueba si quieres.

Si `fase0.py` no encuentra líneas `NEM|`, te dice la causa probable: caché sin `-debugscripts`, mod sin instalar o no llegaste a los 3 s jugando.
