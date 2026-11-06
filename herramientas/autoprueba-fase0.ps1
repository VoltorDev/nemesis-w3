# Prueba automática de la Fase 0 en el PC de desarrollo, sin tocar la pantalla.
# Sesión 1: el arnés carga la última partida, el mod crea los datos y el arnés guarda en una
#           ranura manual nueva; se cierra el juego cuando el .sav nuevo deja de crecer.
# Sesión 2: el arnés carga esa partida nueva, el mod verifica y la variante AutoDerrota prueba la
#           derrota sin recarga; se cierra el juego al ver el resultado o al agotar el tiempo.
# Los registros quedan en work\autoprueba\. Al final se deja instalado el mod base, sin arnés.

param([int]$Limite = 300)

$ErrorActionPreference = "Stop"
$raiz = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
$juego = "C:\Program Files (x86)\Steam\steamapps\common\The Witcher 3"
$exe = Join-Path $juego "bin\x64_dx12\witcher3.exe"
$docs = Join-Path ([Environment]::GetFolderPath("MyDocuments")) "The Witcher 3"
$log = Join-Path $docs "scriptslog.txt"
$saves = Join-Path $docs "gamesaves"
$salida = Join-Path $raiz "work\autoprueba"
New-Item -ItemType Directory -Force $salida | Out-Null

function Lineas-NEM {
    if (-not (Test-Path $log)) { return @() }
    # El juego tiene el archivo abierto: hay que leerlo compartido.
    $fs = [IO.File]::Open($log, 'Open', 'Read', 'ReadWrite')
    $sr = New-Object IO.StreamReader($fs)
    $t = $sr.ReadToEnd()
    $sr.Close()
    return @($t -split "`r?`n" | ForEach-Object { $i = $_.IndexOf("NEM|"); if ($i -ge 0) { $_.Substring($i).Trim() } })
}

function Cerrar-Juego {
    Stop-Process -Name CrashReporter, witcher3 -Force -ErrorAction SilentlyContinue
    Start-Sleep 4
}

function Sesion([string]$nombre, [scriptblock]$terminado) {
    if (Get-Process witcher3 -ErrorAction SilentlyContinue) { throw "El juego ya está abierto." }
    $t0 = Get-Date
    Start-Process $exe -ArgumentList "-debugscripts" -WorkingDirectory (Split-Path $exe)
    $estado = "TIEMPO AGOTADO"
    while (((Get-Date) - $t0).TotalSeconds -lt $Limite) {
        Start-Sleep 3
        if (Get-Process CrashReporter -ErrorAction SilentlyContinue) { $estado = "FALLO DEL JUEGO (CrashReporter)"; break }
        if (-not (Get-Process witcher3 -ErrorAction SilentlyContinue) -and ((Get-Date) - $t0).TotalSeconds -gt 20) { $estado = "EL JUEGO SE CERRÓ"; break }
        if (& $terminado $t0) { $estado = "TERMINADA"; break }
    }
    $seg = [int]((Get-Date) - $t0).TotalSeconds
    Cerrar-Juego
    if (Test-Path $log) { Copy-Item -Force $log (Join-Path $salida "$nombre.log") }
    Write-Host "== $nombre`: $estado en $seg s ==" -ForegroundColor Cyan
    Lineas-NEM | ForEach-Object { Write-Host "  $_" }
    return $estado
}

# Instalación: base + derrota + derrota automática + arnés.
& (Join-Path $PSScriptRoot "prueba-fase0.ps1") -Instalar -AutoDerrota | Out-Host
Copy-Item (Join-Path $raiz "mod\variantes\autoprueba\nemesisAutoPrueba.ws") (Join-Path $juego "Mods\modNemesisPrueba\content\scripts\local")

# Sesión 1: termina cuando hay un .sav nuevo que lleva 6 s sin cambiar.
$e1 = Sesion "sesion1" {
    param($t0)
    $nuevo = Get-ChildItem $saves -Filter "ManualSave_*.sav" -ErrorAction SilentlyContinue |
        Where-Object { $_.LastWriteTime -gt $t0 } | Sort-Object LastWriteTime -Descending | Select-Object -First 1
    if (-not $nuevo) { return $false }
    return ((Get-Date) - $nuevo.LastWriteTime).TotalSeconds -ge 6
}

$e2 = "NO EJECUTADA"
if ($e1 -eq "TERMINADA") {
    # Sesión 2: termina 15 s después de que el Geralt inconsciente se levante, o del resumen si no llega a caer.
    $script:marca = $null
    $e2 = Sesion "sesion2" {
        param($t0)
        $l = Lineas-NEM
        $listo = ($l | Where-Object { $_ -like "NEM|DERROTA|Geralt se levanta*" }) -or
                 (($l | Where-Object { $_ -like "NEM|RESUMEN|*" }) -and ((Get-Date) - $t0).TotalSeconds -gt 200)
        if ($listo -and -not $script:marca) { $script:marca = Get-Date }
        return $script:marca -and ((Get-Date) - $script:marca).TotalSeconds -ge 15
    }
}

# Dejar instalado solo el mod base, sin arnés ni derrota automática.
& (Join-Path $PSScriptRoot "prueba-fase0.ps1") -Instalar | Out-Host
Write-Host "Sesión 1: $e1 | Sesión 2: $e2. Registros en $salida"
