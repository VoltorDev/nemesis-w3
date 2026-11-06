# Recoge lo que ha hecho el mod Némesis en la última sesión de juego y lo añade a un archivo del
# escritorio para mandárselo a Nico. Ejecútalo DESPUÉS DE CADA SESIÓN: el juego borra su registro
# (scriptslog.txt) al arrancar. -Salida: ruta del archivo de resultados (por defecto, el escritorio).

param([string]$Salida)

. (Join-Path $PSScriptRoot "comun.ps1")
$ErrorActionPreference = "Continue"
if (-not $Salida) { $Salida = Join-Path ([Environment]::GetFolderPath("Desktop")) "resultados-nemesis.txt" }

Write-Host "== Némesis: recoger resultados ==" -ForegroundColor Cyan
$log = Join-Path (Carpeta-Documentos) "scriptslog.txt"
if (-not (Test-Path $log)) {
    Write-Host "No existe $log." -ForegroundColor Red
    Write-Host "El juego no se abrió con -debugscripts: usa el acceso directo 'Witcher 3 - Nemesis'. El mod funciona igual, pero sin ese registro no hay resultados que mandar."
    exit 1
}

$fs = [IO.File]::Open($log, 'Open', 'Read', 'ReadWrite')
$sr = New-Object IO.StreamReader($fs)
$texto = $sr.ReadToEnd()
$sr.Close()
$lineas = @()
foreach ($l in ($texto -split "`r?`n")) {
    $i = $l.IndexOf("NEM|")
    if ($i -ge 0) { $lineas += $l.Substring($i).Trim() }
}

$juego = $null
if (Test-Path $Marca) { $juego = (Get-Content $Marca -Raw).Trim() }
$version = if ($juego) { Get-VersionJuego $juego } else { "desconocida" }
$mods = if ($juego) { (Get-ChildItem (Join-Path $juego "Mods") -Directory -ErrorAction SilentlyContinue | ForEach-Object { $_.Name }) -join ", " } else { "" }
$fecha = (Get-Item $log).LastWriteTime.ToString("dd-MM-yyyy HH:mm")

function Contar([string]$tipo) { return @($lineas | Where-Object { $_.StartsWith("NEM|$tipo|") }).Count }
$resumen = "nacidos {0} · emboscadas {1} · derrotas de Geralt {2} · sobrevivieron {3} · muertos {4} · avisos {5}" -f `
    (Contar "NACE"), (Contar "EMBOSCADA"), (Contar "DERROTA"), (Contar "SOBREVIVE"), (Contar "MUERE"), (Contar "AVISO")
if ($lineas.Count -eq 0) {
    $resumen = "SIN DATOS: el mod no escribió nada. ¿Abriste el juego con el acceso directo y cargaste una partida?"
}

$bloque = @(
    "",
    "==== Sesión del $fecha ====",
    "Equipo: $env:COMPUTERNAME | Juego: $juego | Versión: $version",
    "Mods instalados: $mods",
    "Resumen: $resumen",
    "--- líneas del mod ---"
) + $lineas
Add-Content -Path $Salida -Value $bloque -Encoding UTF8

Write-Host ""
Write-Host $resumen -ForegroundColor $(if ($lineas.Count -gt 0) { "Green" } else { "Yellow" })
foreach ($c in ($lineas | Where-Object { $_.StartsWith("NEM|CRONICA|") })) { Write-Host ("  · " + $c.Substring(12)) }
Write-Host ""
Write-Host "Guardado en: $Salida"
