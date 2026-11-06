# Construye el zip para los amigos de Nico: paquete-amigos (instalador, recolector, LEEME, cuestionario)
# + mod\modNemesis, sin arneses ni variantes de prueba. Resultado en dist\Nemesis-W3-<fecha>.zip.
# Los .ps1 se guardan en UTF-8 con BOM para que Windows PowerShell 5.1 lea bien las tildes.

$ErrorActionPreference = "Stop"
$raiz = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
$fecha = Get-Date -Format "dd-MM-yyyy"
$nombre = "Nemesis-W3-$fecha"
$tmp = Join-Path $env:TEMP $nombre
$dist = Join-Path $raiz "dist"
$zip = Join-Path $dist "$nombre.zip"

if (Test-Path $tmp) { Remove-Item -Recurse -Force $tmp }
New-Item -ItemType Directory -Force $tmp, $dist | Out-Null
Copy-Item -Recurse (Join-Path $raiz "paquete-amigos\*") $tmp
New-Item -ItemType Directory -Force (Join-Path $tmp "mod") | Out-Null
Copy-Item -Recurse (Join-Path $raiz "mod\modNemesis") (Join-Path $tmp "mod\modNemesis")

$bom = New-Object Text.UTF8Encoding $true
foreach ($f in Get-ChildItem $tmp -Recurse -Include *.ps1, *.txt) {
    $t = [IO.File]::ReadAllText($f.FullName)
    [IO.File]::WriteAllText($f.FullName, $t, $bom)
}

# Comprobación: el mod empaquetado es el del proyecto y no lleva nada de pruebas.
$extra = Get-ChildItem $tmp -Recurse -Filter *.ws | Where-Object { $_.Name -match "(?i)arnes|prueba" }
if ($extra) { throw "El paquete lleva archivos de prueba: $($extra.Name -join ', ')" }

if (Test-Path $zip) { Remove-Item -Force $zip }
Compress-Archive -Path (Join-Path $tmp "*") -DestinationPath $zip
Write-Host "Creado $zip ($([math]::Round((Get-Item $zip).Length / 1KB)) KB)"
Get-ChildItem $tmp -Recurse -File | ForEach-Object { "  " + $_.FullName.Substring($tmp.Length + 1) }
