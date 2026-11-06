# Construye el zip PÚBLICO para Nexus Mods: dist\Nemesis-W3-<versión>-nexus.zip
#
#   Mods\modNemesis\content\scripts\local\*.ws   el mod (copia de mod\modNemesis, solo .ws)
#   Mods\modNemesis\LEEME-nemesis-w3.txt          marca del mod (la reconoce el instalador de amigos)
#   README.txt                                    paquete-nexus\README.txt con la versión puesta
#
# Sin instalador, recolector ni cuestionario: el mod funciona copiando la carpeta Mods, y no llevar
# scripts (.bat/.ps1) ni binarios evita la cuarentena de Nexus (lección de Second Screen).
# La versión sale de NemesisVersion() en nemesis_datos.ws ("0.3" -> "0.3.0"): una sola fuente.
# Al terminar pasa el comprobador común (mods\herramientas\comprobar-paquete.py) y falla si no es apto.
# Temporales en work\nexus-paquete. Uso: .\herramientas\empaquetar-nexus.ps1

$ErrorActionPreference = "Stop"
$raiz = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
$mod = Join-Path $raiz "mod\modNemesis"
$readme = Join-Path $raiz "paquete-nexus\README.txt"
$comprobador = Join-Path $raiz "..\..\herramientas\comprobar-paquete.py"
$tmp = Join-Path $raiz "work\nexus-paquete"
$dist = Join-Path $raiz "dist"

# Versión desde el propio mod.
$ws = [IO.File]::ReadAllText((Join-Path $mod "content\scripts\local\nemesis_datos.ws"))
$m = [regex]::Match($ws, 'function\s+NemesisVersion\s*\(\s*\)\s*:\s*string\s*\{\s*return\s*"([0-9.]+)"')
if (-not $m.Success) { throw "No encuentro NemesisVersion() en nemesis_datos.ws" }
$version = $m.Groups[1].Value
if ($version -match '^\d+\.\d+$') { $version = "$version.0" }
if ($version -notmatch '^\d+\.\d+\.\d+$') { throw "Versión no válida en NemesisVersion(): $version" }

$nombre = "Nemesis-W3-$version-nexus"
$zip = Join-Path $dist "$nombre.zip"

if (Test-Path $tmp) { Remove-Item -Recurse -Force -LiteralPath $tmp }
$destMod = Join-Path $tmp "Mods\modNemesis"
New-Item -ItemType Directory -Force $destMod, $dist | Out-Null

# Solo los .ws del mod jugable, con su estructura (content\scripts\...).
$origenScripts = Join-Path $mod "content\scripts"
foreach ($f in Get-ChildItem $origenScripts -Recurse -File -Filter *.ws) {
    $rel = $f.FullName.Substring($mod.Length + 1)
    $dest = Join-Path $destMod $rel
    New-Item -ItemType Directory -Force (Split-Path $dest) | Out-Null
    Copy-Item -LiteralPath $f.FullName -Destination $dest
}

$crlf = "`r`n"
$utf8bom = New-Object Text.UTF8Encoding $true

# Marca pública (el instalador de amigos solo comprueba que exista este archivo).
$marca = @(
    "Nemesis - Bandits Who Come Back (WIP) for The Witcher 3 - version $version",
    "This file marks this folder as the Nemesis mod. To uninstall, delete the whole modNemesis folder",
    "with the game closed. See README.txt in the downloaded archive.",
    "",
    "Némesis para The Witcher 3. Este archivo marca la carpeta como el mod Némesis. Para quitarlo,",
    "borra la carpeta modNemesis entera con el juego cerrado."
) -join $crlf
[IO.File]::WriteAllText((Join-Path $destMod "LEEME-nemesis-w3.txt"), $marca + $crlf, $utf8bom)

# README con la versión y saltos de línea de Windows.
$texto = [IO.File]::ReadAllText($readme).Replace("{{VERSION}}", $version)
if ($texto -match '\{\{') { throw "Queda un marcador {{...}} sin sustituir en README.txt" }
$texto = ($texto -replace "`r`n", "`n") -replace "`n", $crlf
[IO.File]::WriteAllText((Join-Path $tmp "README.txt"), $texto, $utf8bom)

# Comprobaciones propias: nada de pruebas, solo .ws y .txt, y los cuatro scripts del mod.
$archivos = Get-ChildItem $tmp -Recurse -File
$prueba = $archivos | Where-Object { $_.Name -match "(?i)arnes|prueba|autoprueba" }
if ($prueba) { throw "El paquete lleva archivos de prueba: $($prueba.Name -join ', ')" }
$raros = $archivos | Where-Object { $_.Extension -notin ".ws", ".txt" }
if ($raros) { throw "Tipos no previstos en el paquete: $($raros.Name -join ', ')" }
foreach ($n in "nemesis_datos.ws", "nemesis_ganchos.ws", "nemesis_motor.ws", "nemesis_textos.ws") {
    if (-not ($archivos | Where-Object Name -eq $n)) { throw "Falta $n en el paquete" }
}

# Zip con separadores «/» (Compress-Archive de Windows PowerShell 5.1 usa «\», que algunos
# gestores no entienden).
Add-Type -AssemblyName System.IO.Compression, System.IO.Compression.FileSystem
if (Test-Path $zip) { Remove-Item -Force -LiteralPath $zip }
$fs = [IO.File]::Open($zip, [IO.FileMode]::CreateNew)
try {
    $za = New-Object IO.Compression.ZipArchive($fs, [IO.Compression.ZipArchiveMode]::Create)
    try {
        foreach ($f in $archivos | Sort-Object FullName) {
            $entrada = $f.FullName.Substring($tmp.Length + 1).Replace("\", "/")
            [void][IO.Compression.ZipFileExtensions]::CreateEntryFromFile($za, $f.FullName, $entrada,
                [IO.Compression.CompressionLevel]::Optimal)
        }
    } finally { $za.Dispose() }
} finally { $fs.Dispose() }

$hash = (Get-FileHash -Algorithm SHA256 -LiteralPath $zip).Hash
Write-Host "Creado $zip ($([math]::Round((Get-Item $zip).Length / 1KB, 1)) KB), versión $version"
Write-Host "SHA-256: $hash"
$archivos | ForEach-Object { "  " + $_.FullName.Substring($tmp.Length + 1) }

# Comprobador común de paquetes (sin --permitir-scripts: este paquete no lleva scripts).
$python = Get-Command python -ErrorAction SilentlyContinue
if (-not $python) {
    Write-Host "AVISO: no encuentro python; pasa a mano: python -I `"$comprobador`" `"$zip`" --juego witcher3" -ForegroundColor Yellow
    exit 0
}
& $python.Source -I (Resolve-Path $comprobador).Path $zip --juego witcher3
if ($LASTEXITCODE -ne 0) { throw "El comprobador de paquetes dice NO SUBIR." }
