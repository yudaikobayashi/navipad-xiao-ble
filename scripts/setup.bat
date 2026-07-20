@echo off
rem Native Windows build environment setup for navipad ZMK firmware.
rem
rem Usage:  scripts\setup.bat
rem
rem Safe to re-run: every step skips itself if already done, so if a step
rem fails, fix the cause and run the script again to continue.
rem
rem Prerequisites (install once, no admin needed):
rem   winget install Python.Python.3.12 Kitware.CMake Ninja-build.Ninja Git.Git 7zip.7zip JernejSimoncic.Wget
rem
rem Recommended one-time admin settings (run in an ADMIN prompt):
rem   reg add "HKLM\SYSTEM\CurrentControlSet\Control\FileSystem" /v LongPathsEnabled /t REG_DWORD /d 1 /f
rem   powershell -c "Add-MpPreference -ExclusionPath '%~dp0..'"

setlocal
cd /d "%~dp0.."
set "REPO=%CD%"

echo === [1/8] Checking required tools ===
where python >nul 2>&1 || (echo ERROR: python not found. Install it: winget install Python.Python.3.12 & exit /b 1)
where git    >nul 2>&1 || (echo ERROR: git not found. Install it: winget install Git.Git & exit /b 1)
where cmake  >nul 2>&1 || (echo ERROR: cmake not found. Install it: winget install Kitware.CMake & exit /b 1)
where ninja  >nul 2>&1 || (echo ERROR: ninja not found. Install it: winget install Ninja-build.Ninja & exit /b 1)
echo OK

echo === [2/8] Git long-path support ===
git config --global core.longpaths true || exit /b 1
reg query "HKLM\SYSTEM\CurrentControlSet\Control\FileSystem" /v LongPathsEnabled 2>nul | find "0x1" >nul
if errorlevel 1 (
    echo WARNING: Windows long paths are DISABLED. west update may fail.
    echo   Fix in an ADMIN prompt:
    echo   reg add "HKLM\SYSTEM\CurrentControlSet\Control\FileSystem" /v LongPathsEnabled /t REG_DWORD /d 1 /f
)

echo === [3/8] Python venv ===
if not exist "%REPO%\.venv\Scripts\python.exe" (
    python -m venv "%REPO%\.venv" || exit /b 1
)
call "%REPO%\.venv\Scripts\activate.bat" || exit /b 1
echo OK: %VIRTUAL_ENV%

echo === [4/8] Installing west ===
pip install --quiet west || exit /b 1

echo === [5/8] west workspace ===
if not exist "%REPO%\.west" (
    west init -l firmware\config || exit /b 1
)
rem Shallow + narrow keeps zephyr/modules small (~1/3 of a full clone).
west update -o=--depth=1 --narrow || exit /b 1
west zephyr-export || exit /b 1

echo === [6/8] Python build dependencies ===
pip install --quiet -r "%REPO%\zephyr\scripts\requirements.txt" || exit /b 1
pip install --quiet -r "%REPO%\modules\lib\nanopb\requirements.txt" || exit /b 1

echo === [7/8] Zephyr SDK (ARM toolchain only) ===
rem Version is read from zephyr\SDK_VERSION automatically; installs to
rem %USERPROFILE%\zephyr-sdk-^<version^> and registers itself with CMake.
west sdk install -t arm-zephyr-eabi || exit /b 1

echo === [8/8] Applying ZMK patches ===
pushd "%REPO%\firmware\config"
west patch -l patches.yml -b patches clean || (popd & exit /b 1)
west patch -l patches.yml -b patches apply || (popd & exit /b 1)
popd

echo.
echo === Setup complete ===
echo Build:  Ctrl+Shift+B in VS Code, or:
echo   .venv\Scripts\west build -s zmk\app -b xiao_ble -- -DSHIELD=navipad -DZMK_CONFIG=%REPO%\firmware\config
echo Flash:  scripts\flash-watch.bat
