"""Lee el resultado de la prueba de la Fase 0 en el log del juego.

Ejecútalo al cerrar el juego, después de cada sesión: el juego vuelve a crear scriptslog.txt
en cada arranque, así que lo que no se recoja se pierde. Muestra las líneas NEM| de la última
sesión y las añade, con fecha, a work/fase0-resultados.md.

Uso: python herramientas/fase0.py
"""

import sys
import time
from pathlib import Path

RAIZ = Path(__file__).resolve().parent.parent
LOG = Path.home() / "Documents" / "The Witcher 3" / "scriptslog.txt"
RESULTADOS = RAIZ / "work" / "fase0-resultados.md"


def leer_log():
    if not LOG.exists():
        return None
    datos = LOG.read_bytes()
    for codificacion in ("utf-8", "utf-16", "cp1252"):
        try:
            return datos.decode(codificacion)
        except UnicodeDecodeError:
            continue
    return datos.decode("utf-8", errors="replace")


def main():
    if hasattr(sys.stdout, "reconfigure"):
        sys.stdout.reconfigure(encoding="utf-8", errors="replace")
    texto = leer_log()
    if texto is None:
        print(f"No existe {LOG}. ¿Arrancaste el juego con -debugscripts?")
        return 2
    print(f"Log: {LOG} (modificado {time.strftime('%d-%m-%Y %H:%M', time.localtime(LOG.stat().st_mtime))})\n")
    lineas = []
    for linea in texto.splitlines():
        i = linea.find("NEM|")
        if i >= 0:
            lineas.append(linea[i:].strip())
    if not lineas:
        n = len(texto.splitlines())
        print("El log no tiene líneas NEM|. Posibles causas:\n"
              + ("- El log solo tiene la cabecera: los scripts se compilaron sin -debugscripts. Arranca desde Steam"
                 " (su opción ya lo pone) y, si se repite, ejecuta otra vez prueba-fase0.ps1 -Instalar.\n" if n <= 2 else "")
              + "- El mod no está instalado (prueba-fase0.ps1 -Instalar) o se arrancó sin él.\n"
              "- No llegaste a jugar 3 s seguidos con Geralt fuera de escenas, diálogos y combate.")
        return 2

    tipos = [l.split("|")[1] for l in lineas if l.count("|") >= 2]
    resumen = [l for l in lineas if l.startswith("NEM|RESUMEN|")]
    fallos = [l for l in lineas if l.startswith("NEM|FALLA|")]
    if "CREADO" in tipos:
        veredicto = ("CREADO: datos de prueba creados. Guarda en una ranura nueva, cierra y vuelve a cargar esa partida."
                     + (" (Si aparece CARGADO también, cargaste una partida que ya tenía datos.)" if "CARGADO" in tipos else ""))
    elif resumen:
        veredicto = ("TODO PASA" if not fallos else f"{len(fallos)} FALLOS") + " — " + resumen[-1].split("|", 2)[2]
    elif "CARGADO" in tipos:
        veredicto = "Sin resumen: el juego se cerró antes de terminar. Tras cargar, espera unos 25 s jugando antes de salir."
    else:
        veredicto = "Sin resumen ni datos creados: revisa las líneas de arriba."

    for l in lineas:
        print(l)
    if fallos:
        print("\nFallos:")
        for l in fallos:
            print("  " + l.split("|", 2)[2])
        if any("Geralt" in l for l in fallos):
            print("  ¡Atención! Falla el estado de Geralt: no sigas usando esa partida.")
    print("\n" + veredicto)

    RESULTADOS.parent.mkdir(exist_ok=True)
    nuevo = not RESULTADOS.exists()
    with RESULTADOS.open("a", encoding="utf-8") as f:
        if nuevo:
            f.write("# Fase 0 — resultados\n\nUna sección por sesión de juego recogida con `herramientas/fase0.py`.\n")
        f.write(f"\n## {time.strftime('%d-%m-%Y %H:%M')} — {veredicto}\n\n```\n" + "\n".join(lineas) + "\n```\n")
    print(f"Apuntado en {RESULTADOS}")
    return 0 if ("CREADO" in tipos or (resumen and not fallos)) else 1


if __name__ == "__main__":
    sys.exit(main())
