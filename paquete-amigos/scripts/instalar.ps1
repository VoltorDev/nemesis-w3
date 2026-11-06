# Instala el mod Némesis en The Witcher 3 y crea un acceso directo con -debugscripts.
# -SoloDetectar: solo dice dónde está el juego y su versión, sin tocar nada.

param([switch]$SoloDetectar, [switch]$Elevado)

. (Join-Path $PSScriptRoot "comun.ps1")
$paquete = Split-Path -Parent $PSScriptRoot

Write-Host "== Némesis para The Witcher 3: instalación ==" -ForegroundColor Cyan
$juego = Buscar-Juego
if (-not $juego) { Write-Host "Instalación cancelada."; exit 1 }
$version = Get-VersionJuego $juego
Write-Host "Juego: $juego"
Write-Host "Versión: $version"
if ($SoloDetectar) { exit 0 }

if (-not $version -or [int]($version.Split(".")[0]) -lt 5) {
    Write-Host "Este mod necesita The Witcher 3 actualizado a la versión 5.0 o posterior (Next-Gen)." -ForegroundColor Red
    Write-Host "Tu versión es '$version'. Actualiza el juego y vuelve a probar."
    exit 1
}
if (Juego-Abierto) {
    Write-Host "Cierra The Witcher 3 antes de instalar." -ForegroundColor Red
    exit 1
}
foreach ($m in Get-ChildItem (Join-Path $juego "Mods") -Directory -ErrorAction SilentlyContinue) {
    if ($m.Name -match "(?i)nemesis" -and $m.Name -ne $NombreMod) {
        Write-Host "Aviso: tienes otro mod que parece de némesis ($($m.Name)). Desactívalo mientras uses este: los dos tocan la derrota de Geralt." -ForegroundColor Yellow
    }
}

$destino = Join-Path $juego "Mods\$NombreMod"
if ((Test-Path $destino) -and -not (Es-NuestroMod $destino)) {
    Write-Host "Ya existe $destino y no es este mod (le falta su marca). No lo toco." -ForegroundColor Red
    Write-Host "Si es una versión vieja de Némesis de Nico, bórrala a mano y vuelve a instalar."
    exit 1
}

# Juegos en Program Files (GOG, a veces Steam) pueden no admitir escritura sin administrador.
if (-not (Puede-Escribir (Join-Path $juego "Mods"))) {
    if (-not $Elevado) {
        Write-Host "La carpeta del juego necesita permisos de administrador; Windows te los pedirá."
        Start-Process powershell -Verb RunAs -Wait -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`" -Elevado"
        exit 0
    }
    Write-Host "No se puede escribir en $juego\Mods ni siquiera como administrador." -ForegroundColor Red
    exit 1
}

if (Test-Path $destino) { Remove-Item -Recurse -Force $destino }
New-Item -ItemType Directory -Force (Split-Path $destino) | Out-Null
Copy-Item -Recurse (Join-Path $paquete "mod\$NombreMod") $destino
Get-ChildItem $destino -Recurse -File | ForEach-Object { Unblock-File $_.FullName -ErrorAction SilentlyContinue }
Apartar-Cache $juego "antes-nemesis"

New-Item -ItemType Directory -Force $Datos | Out-Null
Set-Content -Path $Marca -Value $juego -Encoding UTF8

# Acceso directo con -debugscripts: sin esa opción el mod no puede escribir sus resultados.
$exe = Get-Ejecutable $juego
$atajo = Join-Path ([Environment]::GetFolderPath("Desktop")) "Witcher 3 - Nemesis.lnk"
$shell = New-Object -ComObject WScript.Shell
$lnk = $shell.CreateShortcut($atajo)
$lnk.TargetPath = $exe
$lnk.Arguments = "-debugscripts"
$lnk.WorkingDirectory = Split-Path $exe
$lnk.Save()

Write-Host ""
Write-Host "Instalado en $destino" -ForegroundColor Green
Write-Host "Acceso directo creado en el escritorio: 'Witcher 3 - Nemesis'."
Write-Host "Abre el juego con ese acceso directo para que se registre lo que pasa y puedas mandárselo a Nico (si usas Steam, que Steam esté abierto)."
Write-Host "Alternativa en Steam: Propiedades del juego > Opciones de lanzamiento: -debugscripts"
