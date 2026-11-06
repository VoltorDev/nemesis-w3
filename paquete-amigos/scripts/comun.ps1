# Funciones compartidas por instalar, desinstalar y recoger. Compatible con Windows PowerShell 5.1.

$ErrorActionPreference = "Stop"
$NombreMod = "modNemesis"
$Datos = Join-Path $env:LOCALAPPDATA "NemesisW3"
$Marca = Join-Path $Datos "juego.txt"

function Es-CarpetaJuego([string]$ruta) {
    if (-not $ruta) { return $false }
    return (Test-Path (Join-Path $ruta "content\content0")) -and (Get-Ejecutable $ruta)
}

function Get-Ejecutable([string]$ruta) {
    foreach ($sub in "bin\x64_dx12\witcher3.exe", "bin\x64\witcher3.exe") {
        $exe = Join-Path $ruta $sub
        if (Test-Path $exe) { return $exe }
    }
    return $null
}

function Buscar-Juego {
    $candidatos = New-Object System.Collections.Generic.List[string]

    # Lo que se usó al instalar.
    if (Test-Path $Marca) { $candidatos.Add((Get-Content $Marca -Raw).Trim()) }

    # Bibliotecas de Steam.
    $steam = $null
    foreach ($k in "HKCU:\Software\Valve\Steam", "HKLM:\SOFTWARE\WOW6432Node\Valve\Steam") {
        try {
            $p = Get-ItemProperty $k -ErrorAction Stop
            if ($p.SteamPath) { $steam = $p.SteamPath } elseif ($p.InstallPath) { $steam = $p.InstallPath }
            if ($steam) { break }
        } catch { }
    }
    if (-not $steam) { $steam = "C:\Program Files (x86)\Steam" }
    $steam = $steam -replace "/", "\"
    $bibliotecas = @($steam)
    $vdf = Join-Path $steam "steamapps\libraryfolders.vdf"
    if (Test-Path $vdf) {
        foreach ($m in [regex]::Matches((Get-Content $vdf -Raw), '"path"\s+"([^"]+)"')) {
            $bibliotecas += ($m.Groups[1].Value -replace "\\\\", "\")
        }
    }
    foreach ($b in $bibliotecas) { $candidatos.Add((Join-Path $b "steamapps\common\The Witcher 3")) }

    # GOG y otros: entradas de desinstalación de Windows.
    foreach ($k in "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*",
                   "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*",
                   "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*") {
        try {
            Get-ItemProperty $k -ErrorAction SilentlyContinue |
                Where-Object { $_.DisplayName -like "*Witcher 3*" -and $_.InstallLocation } |
                ForEach-Object { $candidatos.Add($_.InstallLocation.TrimEnd("\")) }
        } catch { }
    }
    foreach ($r in "C:\GOG Games\The Witcher 3 Wild Hunt GOTY", "C:\GOG Games\The Witcher 3 Wild Hunt",
                   "C:\Program Files (x86)\GOG Galaxy\Games\The Witcher 3 Wild Hunt GOTY",
                   "C:\Program Files (x86)\GOG Galaxy\Games\The Witcher 3 Wild Hunt") {
        $candidatos.Add($r)
    }

    foreach ($c in $candidatos) {
        if (Es-CarpetaJuego $c) { return (Resolve-Path $c).Path }
    }

    Write-Host "No encuentro The Witcher 3 automáticamente." -ForegroundColor Yellow
    while ($true) {
        $r = Read-Host "Pega la ruta de la carpeta del juego (la que contiene 'bin' y 'content'), o deja vacío para salir"
        if (-not $r) { return $null }
        $r = $r.Trim('"', ' ')
        if (Es-CarpetaJuego $r) { return (Resolve-Path $r).Path }
        Write-Host "Esa carpeta no parece la del juego." -ForegroundColor Yellow
    }
}

function Get-VersionJuego([string]$juego) {
    $exe = Get-Ejecutable $juego
    if (-not $exe) { return $null }
    return (Get-Item $exe).VersionInfo.FileVersion
}

function Juego-Abierto {
    return [bool](Get-Process witcher3 -ErrorAction SilentlyContinue)
}

# Aparta la caché de scripts compilados para que el juego la regenere con o sin el mod.
function Apartar-Cache([string]$juego, [string]$sufijo) {
    $cache = Join-Path $juego "content\content0\x64.final.redscripts"
    if (Test-Path $cache) {
        Move-Item -Force $cache "$cache.$sufijo"
        Write-Host "Caché de scripts apartada: el próximo arranque tardará un poco más (el juego recompila)."
    }
}

function Es-NuestroMod([string]$carpeta) {
    return Test-Path (Join-Path $carpeta "LEEME-nemesis-w3.txt")
}

function Puede-Escribir([string]$carpeta) {
    try {
        New-Item -ItemType Directory -Force $carpeta -ErrorAction Stop | Out-Null
        $p = Join-Path $carpeta ".nemesis-prueba-escritura"
        Set-Content -Path $p -Value "x" -ErrorAction Stop
        Remove-Item -Force $p -ErrorAction Stop
        return $true
    } catch {
        return $false
    }
}

function Carpeta-Documentos {
    return Join-Path ([Environment]::GetFolderPath("MyDocuments")) "The Witcher 3"
}
