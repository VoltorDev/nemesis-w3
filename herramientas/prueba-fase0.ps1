# Instala o retira el mod de prueba de la Fase 0 en la carpeta Mods del juego.
# Uso: .\herramientas\prueba-fase0.ps1 -Instalar [-V2] [-Derrota]   |   .\herramientas\prueba-fase0.ps1 -Retirar
# Solo toca Mods\modNemesisPrueba. El juego recompila los scripts al arrancar si cambian.
# Úsalo con una partida desechable: el mod guarda datos propios en la partida.

param([switch]$Instalar, [switch]$V2, [switch]$Derrota, [switch]$AutoDerrota, [switch]$Retirar)

$ErrorActionPreference = "Stop"
$raiz = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
$juego = "C:\Program Files (x86)\Steam\steamapps\common\The Witcher 3"
$destino = Join-Path $juego "Mods\modNemesisPrueba"

if ($Instalar -eq $Retirar) {
    Write-Host "Indica -Instalar (opcionalmente con -V2) o -Retirar."
    exit 1
}
if (Get-Process witcher3 -ErrorAction SilentlyContinue) {
    Write-Host "Cierra el juego antes de instalar o retirar el mod." -ForegroundColor Red
    exit 1
}

if (Test-Path $destino) { Remove-Item -Recurse -Force -LiteralPath $destino }

# El juego compila los scripts en x64.final.redscripts y puede reutilizarla. Si no coincide con lo
# instalado (sin el mod al instalarlo, con él al retirarlo), se aparta para que la regenere al
# arrancar; el lanzador de Segunda Pantalla hace lo mismo con la suya.
function Revisar-Cache([bool]$debeTenerMod) {
    $cache = Join-Path $juego "content\content0\x64.final.redscripts"
    if (-not (Test-Path $cache)) { return }
    # Los nombres de clase quedan en ASCII dentro de la caché; los textos del log, no.
    $tiene = [Text.Encoding]::ASCII.GetString([IO.File]::ReadAllBytes($cache)).Contains("CNemesisPrueba")
    if ($tiene -ne $debeTenerMod) {
        Move-Item -Force $cache "$cache.antes-nemesis"
        Write-Host "Caché de scripts apartada a x64.final.redscripts.antes-nemesis: el juego recompilará al arrancar (tarda un poco más)."
    }
}

if ($Retirar) {
    Revisar-Cache $false
    Write-Host "Retirado: ya no existe $destino." -ForegroundColor Green
    exit 0
}

Copy-Item -Recurse (Join-Path $raiz "mod\modNemesisPrueba") $destino
if ($V2) {
    Copy-Item (Join-Path $raiz "mod\variantes\v2\nemesisPruebaV2.ws") (Join-Path $destino "content\scripts\local")
}
if ($Derrota -or $AutoDerrota) {
    Copy-Item (Join-Path $raiz "mod\variantes\derrota\nemesisPruebaDerrota.ws") (Join-Path $destino "content\scripts\local")
}
if ($AutoDerrota) {
    Copy-Item (Join-Path $raiz "mod\variantes\autoderrota\nemesisPruebaAutoDerrota.ws") (Join-Path $destino "content\scripts\local")
}
Revisar-Cache $true
$archivos = Get-ChildItem $destino -Recurse -File | ForEach-Object { $_.Name }
Write-Host ("Instalado en ${destino}: " + ($archivos -join ", ")) -ForegroundColor Green
Write-Host "Arranca el juego con -debugscripts (la opción de Steam de Segunda Pantalla ya lo hace) y carga la partida de prueba."
