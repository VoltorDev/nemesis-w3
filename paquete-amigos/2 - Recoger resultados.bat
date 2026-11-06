@echo off
chcp 65001 >nul
if not exist "%~dp0scripts\recoger.ps1" (
  echo No encuentro la carpeta scripts junto a este archivo.
  echo Primero descomprime el zip en una carpeta: clic derecho sobre el zip, Extraer todo.
  echo Luego ejecuta este archivo desde esa carpeta.
  pause
  exit /b 1
)
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0scripts\recoger.ps1"
echo.
pause
