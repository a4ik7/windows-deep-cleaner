@echo off
:: ============================================================================
::  Windows Deep Cleaner (WDC) - Professional Edition
::  Author      : Abhigyan Sati
::  Repository  : https://github.com/a4ik7/windows-deep-cleaner
::  License     : MIT License
::  Description : High-performance Windows cache, prefetch, settings temporary
::                files, recent history, and recycle bin deep cleaning engine.
:: ============================================================================

setlocal EnableDelayedExpansion
title Windows Deep Cleaner v2.0 - Abhigyan Sati

:: Configure UTF-8 console output where available
chcp 65001 >nul 2>&1

:: Set Working Directory to current script directory
cd /d "%~dp0"

:: Handle CLI Arguments that don't require admin
if /i "%~1"=="/help"   goto :SHOW_HELP
if /i "%~1"=="-h"      goto :SHOW_HELP
if /i "%~1"=="/?"      goto :SHOW_HELP
if /i "%~1"=="--help"  goto :SHOW_HELP
if /i "%~1"=="/version" goto :SHOW_VERSION
if /i "%~1"=="-v"      goto :SHOW_VERSION

:: ============================================================================
:: 1. AUTO-ELEVATION TO ADMINISTRATOR PRIVILEGES (PRESERVING ARGUMENTS)
:: ============================================================================
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo [*] Checking Administrator privileges...
    powershell -NoProfile -ExecutionPolicy Bypass -Command ^
        "Start-Process -FilePath '%~f0' -ArgumentList '%*' -Verb RunAs" >nul 2>&1
    if !errorLevel! neq 0 (
        echo.
        echo  ==============================================================================
        echo   [!] ELEVATION REQUIRED
        echo  ==============================================================================
        echo   Windows Deep Cleaner requires Administrator privileges to purge system caches,
        echo   Prefetch files, and Windows Update downloads.
        echo.
        echo   Please right-click on 'deepclean.bat' and select:
        echo   "Run as administrator"
        echo  ==============================================================================
        echo.
        pause
        exit /b 1
    )
    exit /b
)

:: Handle Direct CLI Arguments after elevation
if /i "%~1"=="/auto"   goto :DO_AUTO_CLEAN
if /i "%~1"=="-y"      goto :DO_AUTO_CLEAN
if /i "%~1"=="/silent" goto :DO_SILENT_CLEAN
if /i "%~1"=="/visual" goto :DO_VISUAL_CLEAN
if /i "%~1"=="/open"   goto :DO_OPEN_LOCATIONS

:: ============================================================================
:: 2. INTERACTIVE MAIN DASHBOARD
:: ============================================================================
:MAIN_MENU
cls
color 0B
echo  ==============================================================================
echo      __        ___           _                     ____                      
echo      \ \      / (_)_ __   __| | _____      _____  |  _ \  ___  ___ _ __      
echo       \ \ /\ / /| | '_ \ / _` |/ _ \ \ /\ / / __| | | | |/ _ \/ _ \ '_ \     
echo        \ V  V / | | | | | (_| | (_) \ V  V /\__ \ | |_| |  __/  __/ |_) ^|    
echo         \_/\_/  |_|_| |_|\__,_|\___/ \_/\_/ ^|___/ |____/ \___^|\___^| .__/     
echo                            C L E A N E R                       ^|_^|          
echo  ==============================================================================
echo    Professional System Disk Optimization Engine  ^|  Developed by Abhigyan Sati
echo  ==============================================================================
echo.

:: Measure Initial Free Disk Space
for /f "delims=" %%a in ('powershell -NoProfile -Command "[math]::Round((Get-PSDrive C).Free / 1GB, 2)"') do (
    set "INITIAL_FREE=%%a"
)
echo    [i] Current Free Space on System Drive (C:): !INITIAL_FREE! GB
echo.
echo    Choose an operating mode:
echo.
echo    [1] Automated Deep Clean (Recommended)
echo        - Rapidly purges Temp, Prefetch, Shaders, Updates, Recent ^& Recycle Bin.
echo.
echo    [2] Visual Deep Clean (Interactive Mode)
echo        - Opens Prefetch folder ^& Windows Settings Temp Files UI while cleaning.
echo.
echo    [3] Open Cleaners ^& System Locations
echo        - Opens Prefetch, Temp, Recent history ^& Windows Storage Settings UI.
echo.
echo    [4] Selective Custom Cleanup
echo        - Choose specifically which caches or history directories to wipe.
echo.
echo    [5] Exit
echo.
echo  ==============================================================================

:: Read user selection with a 15-second default timeout to option 1
choice /c 12345 /n /t 15 /d 1 /m "  Select option [1-5] (Auto-running Option 1 in 15s): "
set "MENU_CHOICE=%errorlevel%"

if "%MENU_CHOICE%"=="1" goto :DO_AUTO_CLEAN
if "%MENU_CHOICE%"=="2" goto :DO_VISUAL_CLEAN
if "%MENU_CHOICE%"=="3" goto :DO_OPEN_LOCATIONS
if "%MENU_CHOICE%"=="4" goto :DO_CUSTOM_MENU
if "%MENU_CHOICE%"=="5" exit /b
goto :MAIN_MENU

:: ============================================================================
:: 3. CLEANUP IMPLEMENTATION ROUTINES
:: ============================================================================

:DO_AUTO_CLEAN
cls
color 0A
echo  ==============================================================================
echo                RUNNING AUTOMATED TOTAL SYSTEM DEEP CLEAN
echo  ==============================================================================
echo.
set "OPEN_GUI=0"
goto :EXECUTE_ENGINE

:DO_VISUAL_CLEAN
cls
color 0E
echo  ==============================================================================
echo                 RUNNING VISUAL SYSTEM DEEP CLEAN (GUI MODE)
echo  ==============================================================================
echo  [*] Opening Prefetch location, Recent Files, and Windows Storage Settings...
echo.
set "OPEN_GUI=1"

:: Open Prefetch Explorer Window
echo  [+] Launching Explorer at: %SystemRoot%\Prefetch
start "" explorer.exe "%SystemRoot%\Prefetch"

:: Open Windows Settings Temporary Files / Storage Sense UI
echo  [+] Launching Windows Settings - Temporary Files Manager...
start ms-settings:storagesettings
timeout /t 2 >nul
start ms-settings:storagesense

goto :EXECUTE_ENGINE

:EXECUTE_ENGINE
echo.
echo  ==============================================================================
echo  Phase 1: Windows User ^& System Temporary Directories
echo  ==============================================================================
echo  [*] Purging User Temp folder (%temp%)...
del /s /f /q "%temp%\*.*" >nul 2>&1
for /d %%p in ("%temp%\*.*") do rmdir /s /q "%%p" >nul 2>&1

echo  [*] Purging Windows System Temp folder (%SystemRoot%\Temp)...
del /s /f /q "%SystemRoot%\Temp\*.*" >nul 2>&1
for /d %%p in ("%SystemRoot%\Temp\*.*") do rmdir /s /q "%%p" >nul 2>&1

echo.
echo  ==============================================================================
echo  Phase 2: Windows Prefetch Cache
echo  ==============================================================================
echo  [*] Purging Windows Prefetch files (%SystemRoot%\Prefetch)...
del /s /f /q "%SystemRoot%\Prefetch\*.*" >nul 2>&1
for /d %%p in ("%SystemRoot%\Prefetch\*.*") do rmdir /s /q "%%p" >nul 2>&1
echo  [+] Prefetch cache wiped successfully.

echo.
echo  ==============================================================================
echo  Phase 3: File Explorer Recent History ^& JumpLists
echo  ==============================================================================
echo  [*] Cleaning Recent Items History (%AppData%\Microsoft\Windows\Recent)...
del /s /f /q "%AppData%\Microsoft\Windows\Recent\*.*" >nul 2>&1
del /s /f /q "%AppData%\Microsoft\Windows\Recent\AutomaticDestinations\*.*" >nul 2>&1
del /s /f /q "%AppData%\Microsoft\Windows\Recent\CustomDestinations\*.*" >nul 2>&1
echo  [+] Explorer Recent files and JumpList cache cleared.

echo.
echo  ==============================================================================
echo  Phase 4: GPU Shader Caches, Crash Dumps ^& Telemetry Logs
echo  ==============================================================================
echo  [*] Wiping DirectX and GPU Shader Caches (DirectX, NVIDIA, AMD)...
del /s /f /q "%LocalAppData%\D3DSCache\*.*" >nul 2>&1
for /d %%p in ("%LocalAppData%\D3DSCache\*.*") do rmdir /s /q "%%p" >nul 2>&1
del /s /f /q "%LocalAppData%\NVIDIA\DXCache\*.*" >nul 2>&1
for /d %%p in ("%LocalAppData%\NVIDIA\DXCache\*.*") do rmdir /s /q "%%p" >nul 2>&1
del /s /f /q "%LocalAppData%\AMD\DxCache\*.*" >nul 2>&1
for /d %%p in ("%LocalAppData%\AMD\DxCache\*.*") do rmdir /s /q "%%p" >nul 2>&1

echo  [*] Clearing Crash Dumps and Windows Error Reporting (WER)...
del /s /f /q "%LocalAppData%\CrashDumps\*.*" >nul 2>&1
del /s /f /q "%ProgramData%\Microsoft\Windows\WER\ReportArchive\*.*" >nul 2>&1
del /s /f /q "%ProgramData%\Microsoft\Windows\WER\ReportQueue\*.*" >nul 2>&1
del /s /f /q "%ProgramData%\Microsoft\Windows\WER\Temp\*.*" >nul 2>&1

echo  [*] Clearing Internet Cache and Panther Setup waste...
del /s /f /q "%LocalAppData%\Microsoft\Windows\INetCache\*.*" >nul 2>&1
for /d %%p in ("%LocalAppData%\Microsoft\Windows\INetCache\*.*") do rmdir /s /q "%%p" >nul 2>&1
del /s /f /q "%SystemRoot%\Panther\*.*" >nul 2>&1
del /s /f /q "%SystemRoot%\inf\*.log" >nul 2>&1

echo.
echo  ==============================================================================
echo  Phase 5: Windows Update Delivery Optimization ^& Download Cache
echo  ==============================================================================
echo  [*] Pausing update services to release file locks...
net stop wuauserv >nul 2>&1
net stop bits >nul 2>&1
net stop dosvc >nul 2>&1

echo  [*] Deleting leftover Windows Update installer packages...
del /s /f /q "%SystemRoot%\SoftwareDistribution\Download\*.*" >nul 2>&1
for /d %%p in ("%SystemRoot%\SoftwareDistribution\Download\*.*") do rmdir /s /q "%%p" >nul 2>&1
del /s /f /q "%SystemRoot%\SoftwareDistribution\DeliveryOptimization\*.*" >nul 2>&1
for /d %%p in ("%SystemRoot%\SoftwareDistribution\DeliveryOptimization\*.*") do rmdir /s /q "%%p" >nul 2>&1

echo  [*] Restarting update services...
net start dosvc >nul 2>&1
net start bits >nul 2>&1
net start wuauserv >nul 2>&1

echo.
echo  ==============================================================================
echo  Phase 6: Windows Settings Storage Sense Engine (cleanmgr backend)
echo  ==============================================================================
echo  [*] Registering volume cleanup handlers...
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Active Setup Temp Folders" /v StateFlags0064 /t REG_DWORD /d 2 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Delivery Optimization Files" /v StateFlags0064 /t REG_DWORD /d 2 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Diagnostic Data Viewer database files" /v StateFlags0064 /t REG_DWORD /d 2 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Downloaded Program Files" /v StateFlags0064 /t REG_DWORD /d 2 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Internet Cache Files" /v StateFlags0064 /t REG_DWORD /d 2 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Old ChkDsk Files" /v StateFlags0064 /t REG_DWORD /d 2 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Previous Installations" /v StateFlags0064 /t REG_DWORD /d 2 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Recycle Bin" /v StateFlags0064 /t REG_DWORD /d 2 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\RetailDemo Offline Content" /v StateFlags0064 /t REG_DWORD /d 2 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Setup Log Files" /v StateFlags0064 /t REG_DWORD /d 2 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\System error memory dump files" /v StateFlags0064 /t REG_DWORD /d 2 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\System error minidump files" /v StateFlags0064 /t REG_DWORD /d 2 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Temporary Files" /v StateFlags0064 /t REG_DWORD /d 2 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Temporary Setup Files" /v StateFlags0064 /t REG_DWORD /d 2 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Thumbnail Cache" /v StateFlags0064 /t REG_DWORD /d 2 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Update Cleanup" /v StateFlags0064 /t REG_DWORD /d 2 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Upgrade Discarded Files" /v StateFlags0064 /t REG_DWORD /d 2 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Windows Defender" /v StateFlags0064 /t REG_DWORD /d 2 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Windows Error Reporting Files" /v StateFlags0064 /t REG_DWORD /d 2 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Windows Upgrade Log Files" /v StateFlags0064 /t REG_DWORD /d 2 /f >nul 2>&1

echo  [*] Executing Storage Sense background clean engine (cleanmgr /sagerun)...
cleanmgr.exe /sagerun:64

echo.
echo  ==============================================================================
echo  Phase 7: Recycle Bin Complete Empty (All Local ^& External Drives)
echo  ==============================================================================
echo  [*] Emptying Recycle Bin completely across all drives...
powershell -NoProfile -Command "Clear-RecycleBin -Force -ErrorAction SilentlyContinue" >nul 2>&1
for /f "tokens=1" %%d in ('wmic logicaldisk get caption ^| findstr /r "[A-Z]:"') do (
    if exist "%%d\$Recycle.Bin" (
        rd /s /q "%%d\$Recycle.Bin" >nul 2>&1
    )
)
echo  [+] Recycle Bin completely purged.

echo.
echo  ==============================================================================
echo  Phase 8: DNS Resolver Cache Flush
echo  ==============================================================================
echo  [*] Flushing DNS cache...
ipconfig /flushdns >nul 2>&1
echo  [+] DNS Resolver cache successfully flushed.

echo.
echo  ==============================================================================
echo  SUMMARY OF RESULTS
echo  ==============================================================================
for /f "delims=" %%b in ('powershell -NoProfile -Command "[math]::Round((Get-PSDrive C).Free / 1GB, 2)"') do (
    set "FINAL_FREE=%%b"
)
for /f "delims=" %%c in ('powershell -NoProfile -Command "[math]::Round(([double]!FINAL_FREE! - [double]!INITIAL_FREE!), 2)"') do (
    set "SPACE_FREED=%%c"
)

echo    [i] Initial Free Space : !INITIAL_FREE! GB
echo    [i] Final Free Space   : !FINAL_FREE! GB
echo    [+] Total Space Freed  : !SPACE_FREED! GB
echo.
echo  ==============================================================================
echo               CLEANUP COMPLETED SUCCESSFULLY! THANK YOU!
echo               Project: https://github.com/a4ik7/windows-deep-cleaner
echo  ==============================================================================
echo.
if "%OPEN_GUI%"=="1" (
    echo  [*] Note: You can also review or click 'Remove files' in the Windows Settings
    echo      window that was opened during cleanup.
    echo.
)
pause
goto :MAIN_MENU

:: ============================================================================
:: 4. DIRECT OPEN LOCATIONS (INSPECTION MODE)
:: ============================================================================
:DO_OPEN_LOCATIONS
cls
color 0B
echo  ==============================================================================
echo                 OPEN SYSTEM LOCATIONS FOR INSPECTION
echo  ==============================================================================
echo.
echo    [1] Open Prefetch Directory (%SystemRoot%\Prefetch)
echo    [2] Open User Temp Directory (%temp%)
echo    [3] Open Recent Files Directory (%AppData%\Microsoft\Windows\Recent)
echo    [4] Open Windows Settings - Storage ^& Temporary Files
echo    [5] Open All Above Locations Simultaneously
echo    [6] Return to Main Menu
echo.
choice /c 123456 /n /m "  Choose an option [1-6]: "
set "LOC_CHOICE=%errorlevel%"

if "%LOC_CHOICE%"=="1" (
    start "" explorer.exe "%SystemRoot%\Prefetch"
    goto :DO_OPEN_LOCATIONS
)
if "%LOC_CHOICE%"=="2" (
    start "" explorer.exe "%temp%"
    goto :DO_OPEN_LOCATIONS
)
if "%LOC_CHOICE%"=="3" (
    start "" explorer.exe "%AppData%\Microsoft\Windows\Recent"
    goto :DO_OPEN_LOCATIONS
)
if "%LOC_CHOICE%"=="4" (
    start ms-settings:storagesettings
    goto :DO_OPEN_LOCATIONS
)
if "%LOC_CHOICE%"=="5" (
    start "" explorer.exe "%SystemRoot%\Prefetch"
    start "" explorer.exe "%temp%"
    start "" explorer.exe "%AppData%\Microsoft\Windows\Recent"
    start ms-settings:storagesettings
    goto :DO_OPEN_LOCATIONS
)
if "%LOC_CHOICE%"=="6" goto :MAIN_MENU
goto :DO_OPEN_LOCATIONS

:: ============================================================================
:: 5. CUSTOM / SELECTIVE CLEANUP MENU
:: ============================================================================
:DO_CUSTOM_MENU
cls
color 0C
echo  ==============================================================================
echo                    CUSTOM / SELECTIVE CLEANUP MENU
echo  ==============================================================================
echo.
echo    [1] Clean Temp and Prefetch Only (including subfolders)
echo    [2] Clean Recent Files and JumpLists Only
echo    [3] Empty Recycle Bin on All Drives Only
echo    [4] Flush DNS and Clear Network Resolver Cache Only
echo    [5] Clean GPU Shader Caches and Crash Dumps Only
echo    [6] Open Windows Settings Temporary Files UI
echo    [7] Back to Main Menu
echo.
choice /c 1234567 /n /m "  Choose an option [1-7]: "
set "CUST_CHOICE=%errorlevel%"

if "%CUST_CHOICE%"=="1" (
    echo [*] Cleaning Temp and Prefetch...
    del /s /f /q "%temp%\*.*" >nul 2>&1
    del /s /f /q "%SystemRoot%\Temp\*.*" >nul 2>&1
    del /s /f /q "%SystemRoot%\Prefetch\*.*" >nul 2>&1
    echo [+] Done.
    timeout /t 2 >nul
    goto :DO_CUSTOM_MENU
)
if "%CUST_CHOICE%"=="2" (
    echo [*] Clearing Recent files...
    del /s /f /q "%AppData%\Microsoft\Windows\Recent\*.*" >nul 2>&1
    del /s /f /q "%AppData%\Microsoft\Windows\Recent\AutomaticDestinations\*.*" >nul 2>&1
    del /s /f /q "%AppData%\Microsoft\Windows\Recent\CustomDestinations\*.*" >nul 2>&1
    echo [+] Done.
    timeout /t 2 >nul
    goto :DO_CUSTOM_MENU
)
if "%CUST_CHOICE%"=="3" (
    echo [*] Emptying Recycle Bin...
    powershell -NoProfile -Command "Clear-RecycleBin -Force -ErrorAction SilentlyContinue" >nul 2>&1
    echo [+] Done.
    timeout /t 2 >nul
    goto :DO_CUSTOM_MENU
)
if "%CUST_CHOICE%"=="4" (
    echo [*] Flushing DNS...
    ipconfig /flushdns >nul 2>&1
    echo [+] Done.
    timeout /t 2 >nul
    goto :DO_CUSTOM_MENU
)
if "%CUST_CHOICE%"=="5" (
    echo [*] Cleaning Shader Caches and Crash Dumps...
    del /s /f /q "%LocalAppData%\D3DSCache\*.*" >nul 2>&1
    del /s /f /q "%LocalAppData%\NVIDIA\DXCache\*.*" >nul 2>&1
    del /s /f /q "%LocalAppData%\AMD\DxCache\*.*" >nul 2>&1
    del /s /f /q "%LocalAppData%\CrashDumps\*.*" >nul 2>&1
    echo [+] Done.
    timeout /t 2 >nul
    goto :DO_CUSTOM_MENU
)
if "%CUST_CHOICE%"=="6" (
    start ms-settings:storagesettings
    goto :DO_CUSTOM_MENU
)
if "%CUST_CHOICE%"=="7" goto :MAIN_MENU
goto :DO_CUSTOM_MENU

:: ============================================================================
:: 6. SILENT CLI MODE
:: ============================================================================
:DO_SILENT_CLEAN
del /s /f /q "%temp%\*.*" >nul 2>&1
del /s /f /q "%SystemRoot%\Temp\*.*" >nul 2>&1
del /s /f /q "%SystemRoot%\Prefetch\*.*" >nul 2>&1
del /s /f /q "%AppData%\Microsoft\Windows\Recent\*.*" >nul 2>&1
del /s /f /q "%LocalAppData%\D3DSCache\*.*" >nul 2>&1
powershell -NoProfile -Command "Clear-RecycleBin -Force -ErrorAction SilentlyContinue" >nul 2>&1
ipconfig /flushdns >nul 2>&1
exit /b 0

:: ============================================================================
:: 7. HELP / DOCUMENTATION
:: ============================================================================
:SHOW_HELP
cls
echo ==============================================================================
echo  Windows Deep Cleaner (WDC) - Command Line Usage
echo  Author: Abhigyan Sati
echo ==============================================================================
echo.
echo  Usage:
echo    deepclean.bat             Launch the interactive dashboard
echo    deepclean.bat /auto       Run full automated deep clean (non-interactive)
echo    deepclean.bat /visual     Open Prefetch and Settings GUI while cleaning
echo    deepclean.bat /open       Open system directories for inspection
echo    deepclean.bat /silent     Run completely silent cleanup without UI
echo    deepclean.bat /help       Show this help documentation
echo    deepclean.bat /version    Display version information
echo.
echo  For full documentation and updates, visit:
echo  https://github.com/a4ik7/windows-deep-cleaner
echo ==============================================================================
echo.
exit /b 0

:SHOW_VERSION
echo Windows Deep Cleaner (WDC) v2.0.0
echo Developed by Abhigyan Sati
echo Released under the MIT License
exit /b 0
