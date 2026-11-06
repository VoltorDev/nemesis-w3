# Prueba automática de la Fase 1 (mod jugable) en el PC de desarrollo, sin tocar la pantalla.
# Instala mod\modNemesis + el arnés, juega la sesión A (nacimiento, emboscada, derrota, guardado) y
# la sesión B (persistencia, supervivencia, muerte). Registros en work\autoprueba-fase1\.
# Al final retira el mod y el arnés: el juego queda sin ningún mod de Némesis.

param([int]$Limite = 360, [string]$SoloB)
# -SoloB <partida>: solo la sesión B, cargando esa partida (nombre sin extensión) que se copia antes
# desde work\partidas-de-prueba a la carpeta del juego.

$ErrorActionPreference = "Stop"
$raiz = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
$juego = "C:\Program Files (x86)\Steam\steamapps\common\The Witcher 3"
$exe = Join-Path $juego "bin\x64_dx12\witcher3.exe"
$docs = Join-Path ([Environment]::GetFolderPath("MyDocuments")) "The Witcher 3"
$log = Join-Path $docs "scriptslog.txt"
$saves = Join-Path $docs "gamesaves"
$salida = Join-Path $raiz "work\autoprueba-fase1"
$cache = Join-Path $juego "content\content0\x64.final.redscripts"
New-Item -ItemType Directory -Force $salida | Out-Null

# Sin foco, el juego se pausa (en la intro ni llega al menú). Si otra ventana lo tiene, se le
# devuelve al juego: solo cambia qué ventana está delante, no envía teclas ni clics al juego.
Add-Type @"
using System; using System.Runtime.InteropServices;
public class FocoJuego {
  [DllImport("user32.dll")] public static extern IntPtr GetForegroundWindow();
  [DllImport("user32.dll")] public static extern bool SetForegroundWindow(IntPtr h);
  [DllImport("user32.dll")] public static extern bool ShowWindow(IntPtr h, int c);
  [DllImport("user32.dll")] public static extern bool IsIconic(IntPtr h);
  [DllImport("user32.dll")] public static extern uint GetWindowThreadProcessId(IntPtr h, out uint pid);
  [DllImport("user32.dll")] public static extern bool AttachThreadInput(uint a, uint b, bool f);
  [DllImport("kernel32.dll")] public static extern uint GetCurrentThreadId();
}
"@

function Dar-Foco {
    $p = Get-Process witcher3 -ErrorAction SilentlyContinue | Where-Object { $_.MainWindowHandle -ne 0 } | Select-Object -First 1
    if (-not $p) { return }
    $fg = [FocoJuego]::GetForegroundWindow()
    if ($fg -eq $p.MainWindowHandle) { return }
    $fpid = 0
    $hiloFg = [FocoJuego]::GetWindowThreadProcessId($fg, [ref]$fpid)
    $yo = [FocoJuego]::GetCurrentThreadId()
    [void][FocoJuego]::AttachThreadInput($yo, $hiloFg, $true)
    if ([FocoJuego]::IsIconic($p.MainWindowHandle)) { [void][FocoJuego]::ShowWindow($p.MainWindowHandle, 9) }
    [void][FocoJuego]::SetForegroundWindow($p.MainWindowHandle)
    [void][FocoJuego]::AttachThreadInput($yo, $hiloFg, $false)
}

function Lineas-NEM {
    if (-not (Test-Path $log)) { return @() }
    # El juego tiene el archivo abierto: hay que leerlo compartido.
    $fs = [IO.File]::Open($log, 'Open', 'Read', 'ReadWrite')
    $sr = New-Object IO.StreamReader($fs)
    $t = $sr.ReadToEnd()
    $sr.Close()
    return @($t -split "`r?`n" | ForEach-Object { $i = $_.IndexOf("NEM|"); if ($i -ge 0) { $_.Substring($i).Trim() } })
}

function Instalar([bool]$conArnes, [string]$modo = "A") {
    foreach ($n in "modNemesisPrueba", "modNemesis") {
        $d = Join-Path $juego "Mods\$n"
        if (Test-Path $d) { Remove-Item -Recurse -Force $d }
    }
    if (Test-Path $cache) { Move-Item -Force $cache "$cache.antes-nemesis" }
    if ($conArnes) {
        Copy-Item -Recurse (Join-Path $raiz "mod\modNemesis") (Join-Path $juego "Mods\modNemesis")
        Copy-Item (Join-Path $raiz "mod\variantes\arnes-fase1\nemesisArnes.ws") (Join-Path $juego "Mods\modNemesis\content\scripts\local")
        Copy-Item (Join-Path $raiz "mod\variantes\arnes-fase1\nemesisArnesModo$modo.ws") (Join-Path $juego "Mods\modNemesis\content\scripts\local")
    }
}

function Sesion([string]$nombre, [scriptblock]$terminado) {
    if (Get-Process witcher3 -ErrorAction SilentlyContinue) { throw "El juego ya está abierto." }
    $t0 = Get-Date
    Start-Process $exe -ArgumentList "-debugscripts" -WorkingDirectory (Split-Path $exe)
    $estado = "TIEMPO AGOTADO"
    while (((Get-Date) - $t0).TotalSeconds -lt $Limite) {
        Start-Sleep 3
        # El foco se da desde el arranque y ya no cambia: sin foco el juego se pausa en partida, y
        # cambiárselo con la partida cargada (pantalla completa exclusiva DX12) lo cerraba a ~1 s.
        # La pantalla de «Pulsa cualquier tecla» la pasa el arnés.
        if (-not (Lineas-NEM | Where-Object { $_ -like "NEM|CARGA|*" })) { Dar-Foco }
        if (Get-Process CrashReporter -ErrorAction SilentlyContinue) { $estado = "FALLO DEL JUEGO (CrashReporter)"; break }
        if (-not (Get-Process witcher3 -ErrorAction SilentlyContinue) -and ((Get-Date) - $t0).TotalSeconds -gt 20) { $estado = "EL JUEGO SE CERRÓ"; break }
        if (& $terminado $t0) { $estado = "TERMINADA"; break }
    }
    $seg = [int]((Get-Date) - $t0).TotalSeconds
    Stop-Process -Name CrashReporter, witcher3 -Force -ErrorAction SilentlyContinue
    Start-Sleep 4
    if (Test-Path $log) { Copy-Item -Force $log (Join-Path $salida "$nombre.log") }
    Write-Host "== $nombre`: $estado en $seg s ==" -ForegroundColor Cyan
    Lineas-NEM | ForEach-Object { Write-Host "  $_" }
    return $estado
}

$inicio = Get-Date
if ($SoloB) {
    Get-ChildItem (Join-Path $raiz "work\partidas-de-prueba") -Filter "$SoloB.*" | Copy-Item -Destination $saves -Force
    Get-ChildItem $saves -Filter "$SoloB.*" | ForEach-Object { $_.LastWriteTime = Get-Date }
    $eA = "TERMINADA"
} else {
Instalar $true

$eA = Sesion "sesionA" {
    param($t0)
    if (-not (Lineas-NEM | Where-Object { $_ -like "NEM|ARNES|FIN*" })) { return $false }
    $nuevo = Get-ChildItem $saves -Filter "ManualSave_*.sav" -ErrorAction SilentlyContinue |
        Where-Object { $_.LastWriteTime -gt $t0 } | Sort-Object LastWriteTime -Descending | Select-Object -First 1
    return $nuevo -and ((Get-Date) - $nuevo.LastWriteTime).TotalSeconds -ge 6
}
}

$eB = "NO EJECUTADA"
if ($eA -eq "TERMINADA") {
    Instalar $true "B"
    $eB = Sesion "sesionB" {
        param($t0)
        return [bool](Lineas-NEM | Where-Object { $_ -like "NEM|ARNES|FIN*" })
    }
}

Instalar $false

# Las partidas que ha creado la prueba salen de la carpeta del juego, para que «Continuar» no
# cargue una partida de prueba.
$apartadas = Join-Path $raiz "work\partidas-de-prueba"
New-Item -ItemType Directory -Force $apartadas | Out-Null
Get-ChildItem $saves -File | Where-Object { $_.LastWriteTime -gt $inicio -and $_.Name -ne "steam_autocloud.vdf" } |
    Move-Item -Destination $apartadas -Force
Write-Host "Sesión A: $eA | Sesión B: $eB. Registros en $salida. Mod retirado del juego; partidas de prueba en $apartadas."
