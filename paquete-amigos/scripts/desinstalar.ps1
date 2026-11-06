# Quita el mod Némesis del juego y el acceso directo.

param([switch]$Elevado)

. (Join-Path $PSScriptRoot "comun.ps1")

Write-Host "== Némesis para The Witcher 3: desinstalación ==" -ForegroundColor Cyan
$juego = Buscar-Juego
if (-not $juego) { Write-Host "Cancelado."; exit 1 }
if (Juego-Abierto) {
    Write-Host "Cierra The Witcher 3 antes de desinstalar." -ForegroundColor Red
    exit 1
}

$destino = Join-Path $juego "Mods\$NombreMod"
if ((Test-Path $destino) -and -not (Puede-Escribir (Join-Path $juego "Mods")) -and -not $Elevado) {
    Write-Host "La carpeta del juego necesita permisos de administrador; Windows te los pedirá."
    Start-Process powershell -Verb RunAs -Wait -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`" -Elevado"
    exit 0
}
if ((Test-Path $destino) -and -not (Es-NuestroMod $destino)) {
    Write-Host "$destino no es este mod (le falta su marca): no lo borro." -ForegroundColor Red
} elseif (Test-Path $destino) {
    Remove-Item -Recurse -Force $destino
    Apartar-Cache $juego "con-nemesis"
    Write-Host "Mod quitado de $destino" -ForegroundColor Green
} else {
    Write-Host "El mod no estaba instalado en $destino."
}

$atajo = Join-Path ([Environment]::GetFolderPath("Desktop")) "Witcher 3 - Nemesis.lnk"
if (Test-Path $atajo) { Remove-Item -Force $atajo; Write-Host "Acceso directo borrado." }

Write-Host ""
Write-Host "Listo. Las partidas que guardaste con el mod llevan sus datos de némesis: cargan sin él"
Write-Host "(comprobado), pero esos némesis quedan dormidos hasta que vuelvas a instalarlo."
Write-Host "Si notas algo raro en alguna partida, cuéntaselo a Nico."
