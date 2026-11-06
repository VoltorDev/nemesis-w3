# Diagnóstico de una sesión de prueba que se queda quieta: instala el mod y el arnés (modo A),
# arranca el juego y cada 10 s anota si responde, qué ventana tiene el foco y si el registro crece.
# Al terminar cierra el juego y retira el mod. Uso: .\herramientas\diagnostico-arranque.ps1 [-Segundos 150] [-ModOrigen <carpeta>]

param([int]$Segundos = 150, [string]$ModOrigen)

$ErrorActionPreference = "Stop"
$raiz = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
$juego = "C:\Program Files (x86)\Steam\steamapps\common\The Witcher 3"
$exe = Join-Path $juego "bin\x64_dx12\witcher3.exe"
$log = Join-Path ([Environment]::GetFolderPath("MyDocuments")) "The Witcher 3\scriptslog.txt"
$cache = Join-Path $juego "content\content0\x64.final.redscripts"
if (-not $ModOrigen) { $ModOrigen = Join-Path $raiz "mod\modNemesis" }
if (Get-Process witcher3 -ErrorAction SilentlyContinue) { throw "El juego ya está abierto." }

Add-Type @"
using System; using System.Runtime.InteropServices;
public class Foco { [DllImport("user32.dll")] public static extern IntPtr GetForegroundWindow();
  [DllImport("user32.dll")] public static extern uint GetWindowThreadProcessId(IntPtr h, out uint pid);
  [DllImport("user32.dll")] public static extern bool SetForegroundWindow(IntPtr h);
  [DllImport("user32.dll")] public static extern bool ShowWindow(IntPtr h, int c);
  [DllImport("user32.dll")] public static extern bool AttachThreadInput(uint a, uint b, bool f);
  [DllImport("kernel32.dll")] public static extern uint GetCurrentThreadId(); }
"@

function Dar-Foco {
    $p = Get-Process witcher3 -ErrorAction SilentlyContinue | Where-Object { $_.MainWindowHandle -ne 0 } | Select-Object -First 1
    if (-not $p) { return "sin ventana" }
    $fg = [Foco]::GetForegroundWindow()
    if ($fg -eq $p.MainWindowHandle) { return "ya tenia" }
    $fpid = 0
    $hilo = [Foco]::GetWindowThreadProcessId($fg, [ref]$fpid)
    $yo = [Foco]::GetCurrentThreadId()
    [void][Foco]::AttachThreadInput($yo, $hilo, $true)
    [void][Foco]::ShowWindow($p.MainWindowHandle, 9)
    $ok = [Foco]::SetForegroundWindow($p.MainWindowHandle)
    [void][Foco]::AttachThreadInput($yo, $hilo, $false)
    return "pedido=$ok"
}

$d = Join-Path $juego "Mods\modNemesis"
if (Test-Path $d) { Remove-Item -Recurse -Force $d }
Copy-Item -Recurse $ModOrigen $d
Copy-Item (Join-Path $raiz "mod\variantes\arnes-fase1\nemesisArnes.ws") (Join-Path $d "content\scripts\local")
Copy-Item (Join-Path $raiz "mod\variantes\arnes-fase1\nemesisArnesModoA.ws") (Join-Path $d "content\scripts\local")
if (Test-Path $cache) { Move-Item -Force $cache "$cache.antes-nemesis" }

$t0 = Get-Date
Start-Process $exe -ArgumentList "-debugscripts" -WorkingDirectory (Split-Path $exe)
$anterior = 0
while (((Get-Date) - $t0).TotalSeconds -lt $Segundos) {
    Start-Sleep 10
    $intento = Dar-Foco
    Start-Sleep 1
    $p = Get-Process witcher3 -ErrorAction SilentlyContinue
    $fg = [Foco]::GetForegroundWindow(); $fpid = 0; [void][Foco]::GetWindowThreadProcessId($fg, [ref]$fpid)
    $fproc = (Get-Process -Id $fpid -ErrorAction SilentlyContinue).ProcessName
    $tam = if (Test-Path $log) { (Get-Item $log).Length } else { 0 }
    $nem = if (Test-Path $log) { $fs = [IO.File]::Open($log, 'Open', 'Read', 'ReadWrite'); $sr = New-Object IO.StreamReader($fs); $t = $sr.ReadToEnd(); $sr.Close(); ([regex]::Matches($t, 'NEM\|')).Count } else { 0 }
    "{0,4}s juego={1} responde={2} foco={3} ({8}) log={4} (+{5}) NEM={6} crash={7}" -f [int]((Get-Date) - $t0).TotalSeconds, [bool]$p, $(if ($p) { $p.Responding } else { '-' }), $fproc, $tam, ($tam - $anterior), $nem, [bool](Get-Process CrashReporter -ErrorAction SilentlyContinue), $intento
    $anterior = $tam
}
Stop-Process -Name CrashReporter, witcher3 -Force -ErrorAction SilentlyContinue
Start-Sleep 4
Copy-Item -Force $log (Join-Path $raiz "work\diagnostico.log") -ErrorAction SilentlyContinue
Remove-Item -Recurse -Force $d
if (Test-Path $cache) { Move-Item -Force $cache "$cache.antes-nemesis" }
"Fin. Registro copiado a work\diagnostico.log; mod retirado."
