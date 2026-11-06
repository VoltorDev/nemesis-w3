# Compila el mod de prueba con wcc_lite de REDkit, sin abrir el juego, junto a los scripts del
# juego y a los mods de scripts que haya instalados (p. ej. Segunda Pantalla), para detectar
# errores y choques entre anotaciones antes de jugar.
# Uso: .\herramientas\compilar-mod.ps1 [-V2]
# wcc_lite crea editoruser.settings y profile.settings en Documentos\The Witcher 3; se apartan
# a work\apartado-wcc-lite para no dejar ajustes del editor en la carpeta del juego.

param([switch]$V2, [switch]$Derrota, [switch]$AutoDerrota, [switch]$AutoPrueba, [switch]$Fase1, [switch]$Arnes1,
      [string]$Origen)
# -Fase1: compila el mod jugable (mod\modNemesis) en vez del de prueba. -Arnes1: con su arnés de prueba.
# -Origen <carpeta>: compila la carpeta de mod indicada (la que contiene content\scripts), p. ej. la
#   extraída del zip de Nexus, en vez de la del proyecto.

$ErrorActionPreference = "Stop"
$raiz = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
$juego = "C:\Program Files (x86)\Steam\steamapps\common\The Witcher 3"
$redkit = "C:\Program Files (x86)\Steam\steamapps\common\The Witcher 3 REDkit"
$tmp = Join-Path $raiz "work\compilar"
$docs = Join-Path ([Environment]::GetFolderPath("MyDocuments")) "The Witcher 3"
$antes = @{}
foreach ($f in "editoruser.settings", "editoruser.settings.bak", "profile.settings", "profile.settings.bak") {
    $antes[$f] = Test-Path (Join-Path $docs $f)
}

if (Test-Path $tmp) { Remove-Item -Recurse -Force -LiteralPath $tmp }
New-Item -ItemType Directory -Force $tmp | Out-Null
Copy-Item -Recurse (Join-Path $juego "content\content0\scripts") (Join-Path $tmp "scripts")

# Otros mods de scripts instalados, salvo una copia vieja de este.
$otros = Get-ChildItem (Join-Path $juego "Mods") -Directory -ErrorAction SilentlyContinue |
    Where-Object { $_.Name -notin "modNemesisPrueba", "modNemesis" -and (Test-Path (Join-Path $_.FullName "content\scripts")) }
foreach ($m in $otros) {
    Copy-Item -Recurse -Force (Join-Path $m.FullName "content\scripts\*") (Join-Path $tmp "scripts")
}
$propio = if ($Fase1 -or $Arnes1) { "modNemesis" } else { "modNemesisPrueba" }
$carpetaPropia = Join-Path $raiz "mod\$propio"
if ($Origen) {
    $carpetaPropia = (Resolve-Path -LiteralPath $Origen).Path
    if (-not (Test-Path (Join-Path $carpetaPropia "content\scripts"))) { throw "No hay content\scripts en $carpetaPropia" }
    $propio = $carpetaPropia
}
Write-Host ("Con: vanilla" + (($otros | ForEach-Object { ", " + $_.Name }) -join "") + ", $propio" + $(if ($V2) { " + V2" } else { "" }) + $(if ($Derrota) { " + Derrota" } else { "" }) + $(if ($Arnes1) { " + arnés" } else { "" }))

Copy-Item -Recurse -Force (Join-Path $carpetaPropia "content\scripts\*") (Join-Path $tmp "scripts")
if ($Arnes1) {
    Copy-Item -Force (Join-Path $raiz "mod\variantes\arnes-fase1\nemesisArnes.ws") (Join-Path $tmp "scripts\local")
    Copy-Item -Force (Join-Path $raiz "mod\variantes\arnes-fase1\nemesisArnesModoA.ws") (Join-Path $tmp "scripts\local")
}
if ($V2) {
    Copy-Item -Force (Join-Path $raiz "mod\variantes\v2\nemesisPruebaV2.ws") (Join-Path $tmp "scripts\local")
}
if ($Derrota -or $AutoDerrota) {
    Copy-Item -Force (Join-Path $raiz "mod\variantes\derrota\nemesisPruebaDerrota.ws") (Join-Path $tmp "scripts\local")
}
if ($AutoDerrota) {
    Copy-Item -Force (Join-Path $raiz "mod\variantes\autoderrota\nemesisPruebaAutoDerrota.ws") (Join-Path $tmp "scripts\local")
}
if ($AutoPrueba) {
    Copy-Item -Force (Join-Path $raiz "mod\variantes\autoprueba\nemesisAutoPrueba.ws") (Join-Path $tmp "scripts\local")
}

Write-Host ("Juego instalado: " + (Get-Item (Join-Path $juego "bin\x64_dx12\witcher3.exe")).VersionInfo.FileVersion)
Push-Location (Join-Path $redkit "bin\x64_RedKit")
try {
    $salida = & .\wcc_lite.exe compilescripts "$tmp\scripts\" "-out=$tmp\salida" 2>&1 | ForEach-Object { "$_" }
} finally {
    Pop-Location
}

$apartado = Join-Path $raiz "work\apartado-wcc-lite"
foreach ($f in $antes.Keys) {
    $p = Join-Path $docs $f
    if (-not $antes[$f] -and (Test-Path $p)) {
        New-Item -ItemType Directory -Force $apartado | Out-Null
        Move-Item -Force $p (Join-Path $apartado $f)
    }
}

$errores = $salida | Where-Object { $_ -match "\[Error\]\[WCC\].*\.ws\[" }
$avisos = $salida | Where-Object { $_ -match "\[Warning\]\[WCC\].*nemesis" }
$avisos | ForEach-Object { Write-Host $_ -ForegroundColor Yellow }
if ($salida -match "Success! Scripts cooked") {
    Write-Host "OK: el mod compila con los scripts de la versión instalada." -ForegroundColor Green
    exit 0
}
$errores | ForEach-Object { Write-Host $_ -ForegroundColor Red }
if (-not $errores) { $salida | Select-Object -Last 15 }
exit 1
