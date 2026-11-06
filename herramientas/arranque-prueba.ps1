# Arranca The Witcher 3 con -debugscripts sin tocar la pantalla y dice si llega a funcionar o falla.
# FALLA: aparece CrashReporter o el proceso muere. OK: el juego responde 20 s seguidos sin fallo.
# Al terminar cierra el juego. Uso: .\herramientas\arranque-prueba.ps1 [-Limite 240]

param([int]$Limite = 240, [int]$Estable = 20, [switch]$DejarAbierto)

$juego = "C:\Program Files (x86)\Steam\steamapps\common\The Witcher 3"
$exe = Join-Path $juego "bin\x64_dx12\witcher3.exe"
if (Get-Process witcher3 -ErrorAction SilentlyContinue) { Write-Host "El juego ya está abierto."; exit 2 }

$t0 = Get-Date
Start-Process $exe -ArgumentList "-debugscripts" -WorkingDirectory (Split-Path $exe)
$respondeDesde = $null
$resultado = "SIN DECIDIR"
while (((Get-Date) - $t0).TotalSeconds -lt $Limite) {
    Start-Sleep 3
    if (Get-Process CrashReporter -ErrorAction SilentlyContinue) { $resultado = "FALLA (CrashReporter)"; break }
    $p = Get-Process witcher3 -ErrorAction SilentlyContinue
    if (-not $p) {
        if (((Get-Date) - $t0).TotalSeconds -gt 20) { $resultado = "FALLA (el proceso terminó)"; break }
        continue
    }
    if ($p.Responding -and $p.MainWindowHandle -ne 0) {
        if (-not $respondeDesde) { $respondeDesde = Get-Date }
        if (((Get-Date) - $respondeDesde).TotalSeconds -ge $Estable) { $resultado = "OK (responde $Estable s)"; break }
    } else {
        $respondeDesde = $null
    }
}
$seg = [int]((Get-Date) - $t0).TotalSeconds
$cache = Get-Item (Join-Path $juego "content\content0\x64.final.redscripts") -ErrorAction SilentlyContinue
Write-Host "$resultado en $seg s; caché compilada: $(if ($cache) { $cache.LastWriteTime } else { 'no' })"
$log = Join-Path ([Environment]::GetFolderPath("MyDocuments")) "The Witcher 3\scriptslog.txt"
if (Test-Path $log) { Write-Host "scriptslog: $((Get-Content $log).Count) líneas"; Get-Content $log -Tail 5 }
if (-not $DejarAbierto -or $resultado -notlike "OK*") {
    Stop-Process -Name CrashReporter, witcher3 -Force -ErrorAction SilentlyContinue
}
if ($resultado -like "OK*") { exit 0 } else { exit 1 }

