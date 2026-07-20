@echo off
rem ZMK firmware auto-flasher for XIAO nRF52840 (UF2 bootloader).
rem
rem Usage (Windows, cmd or double-click):
rem   scripts\flash-watch.bat          watch mode: flashes every time the bootloader drive appears
rem   scripts\flash-watch.bat /once    exit after the first successful flash
rem
rem Put the keyboard into bootloader mode (double-tap RESET); the script
rem detects the UF2 drive by its INFO_UF2.TXT marker file and copies the
rem latest build\zephyr\zmk.uf2 onto it.

setlocal
set "UF2=%~dp0..\build\zephyr\zmk.uf2"
set "ONCE=0"
if /i "%~1"=="/once" set "ONCE=1"

if not exist "%UF2%" (
    echo Firmware not found: %UF2%
    echo Run the Build task first.
    exit /b 1
)

echo Watching for UF2 bootloader drive...
echo Firmware: %UF2%
echo Double-tap RESET on the keyboard to enter bootloader mode. Ctrl+C to stop.

:watch
for %%D in (D E F G H I J K L M N O P Q R S T U V W X Y Z) do (
    if exist "%%D:\INFO_UF2.TXT" (
        echo [%TIME:~0,8%] Bootloader drive %%D: detected. Copying zmk.uf2...
        copy /y "%UF2%" "%%D:\" >nul 2>&1
        rem The device reboots mid-copy once the transfer completes, which can
        rem be reported as an error even on success - so don't treat it as one.
        echo Flashed. Keyboard will reboot.
        if "%ONCE%"=="1" exit /b 0
        call :waitgone %%D
        echo Watching for next bootloader entry...
    )
)
timeout /t 1 /nobreak >nul
goto watch

:waitgone
if exist "%1:\INFO_UF2.TXT" (
    timeout /t 1 /nobreak >nul
    goto waitgone
)
exit /b 0
