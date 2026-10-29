@echo off
setlocal EnableDelayedExpansion
title Windows 1-Click Total Deep Cleaner - Abhigyan Sati

:: ====================================================================
:: 1. AUTO-ELEVATE TO ADMINISTRATOR PRIVILEGES (FAIL-PROOF)
:: ====================================================================
net session >nul 2>&1
if %errorLevel% neq 0 (
    if "%~1"=="" (
        powershell -NoProfile -ExecutionPolicy Bypass -Command "Start-Process -FilePath '%~f0' -Verb RunAs"
    ) else (
        powershell -NoProfile -ExecutionPolicy Bypass -Command "Start-Process -FilePath '%~f0' -ArgumentList '%*' -Verb RunAs"
    )
    exit /b
)

:: Set working directory to script location
cd /d "%~dp0"

:: Set console text color to high-contrast green
color 0A

echo ======================================================================
echo              AUTOMATED ONE-CLICK WINDOWS DEEP CLEANER
echo                Developed by Abhigyan Sati (@a4ik7)
echo ======================================================================
echo.

:: ====================================================================
:: 2. OPEN PREFETCH LOCATION & CLEAN PREFETCH
:: ====================================================================
echo [*] Opening Prefetch location in Explorer...
start "" explorer.exe "%SystemRoot%\Prefetch"

echo [*] Purging Windows Prefetch cache (%SystemRoot%\Prefetch)...
del /s /f /q "%SystemRoot%\Prefetch\*.*" >nul 2>&1
for /d %%p in ("%SystemRoot%\Prefetch\*.*") do rmdir /s /q "%%p" >nul 2>&1
echo [+] Prefetch cleaned successfully.
echo.

:: ====================================================================
:: 3. OPEN WINDOWS SETTINGS (TEMPORARY FILES) & CLEAN SYSTEM TEMP
:: ====================================================================
echo [*] Opening Windows Settings - Storage and Temporary Files...
start ms-settings:storagesettings

echo [*] Cleaning User and System Temp files...
del /s /f /q "%temp%\*.*" >nul 2>&1
for /d %%p in ("%temp%\*.*") do rmdir /s /q "%%p" >nul 2>&1

del /s /f /q "%SystemRoot%\Temp\*.*" >nul 2>&1
for /d %%p in ("%SystemRoot%\Temp\*.*") do rmdir /s /q "%%p" >nul 2>&1
echo [+] Temporary directories cleaned successfully.
echo.

:: ====================================================================
:: 4. CLEAN RECENT FILES & JUMPLISTS
:: ====================================================================
echo [*] Cleaning Recent files and File Explorer JumpLists...
del /s /f /q "%AppData%\Microsoft\Windows\Recent\*.*" >nul 2>&1
del /s /f /q "%AppData%\Microsoft\Windows\Recent\AutomaticDestinations\*.*" >nul 2>&1
del /s /f /q "%AppData%\Microsoft\Windows\Recent\CustomDestinations\*.*" >nul 2>&1
echo [+] Recent history cleared successfully.
echo.

:: ====================================================================
:: 5. EMPTY RECYCLE BIN (ALL DRIVES)
:: ====================================================================
echo [*] Completely emptying Recycle Bin across all drives...
powershell -NoProfile -Command "Clear-RecycleBin -Force -ErrorAction SilentlyContinue" >nul 2>&1
powershell -NoProfile -Command "Get-PSDrive -PSProvider FileSystem | ForEach-Object { $rb = Join-Path $_.Root '$Recycle.Bin'; if (Test-Path $rb) { Remove-Item -LiteralPath $rb -Recurse -Force -ErrorAction SilentlyContinue } }" >nul 2>&1
echo [+] Recycle Bin emptied successfully.
echo.

:: ====================================================================
:: 6. GPU SHADER CACHES, CRASH DUMPS & TELEMETRY LOGS
:: ====================================================================
echo [*] Cleaning DirectX, NVIDIA and AMD Shader caches...
del /s /f /q "%LocalAppData%\D3DSCache\*.*" >nul 2>&1
for /d %%p in ("%LocalAppData%\D3DSCache\*.*") do rmdir /s /q "%%p" >nul 2>&1
del /s /f /q "%LocalAppData%\NVIDIA\DXCache\*.*" >nul 2>&1
for /d %%p in ("%LocalAppData%\NVIDIA\DXCache\*.*") do rmdir /s /q "%%p" >nul 2>&1
del /s /f /q "%LocalAppData%\AMD\DxCache\*.*" >nul 2>&1
for /d %%p in ("%LocalAppData%\AMD\DxCache\*.*") do rmdir /s /q "%%p" >nul 2>&1

echo [*] Cleaning Crash Dumps and Windows Error Reporting (WER)...
del /s /f /q "%LocalAppData%\CrashDumps\*.*" >nul 2>&1
del /s /f /q "%ProgramData%\Microsoft\Windows\WER\ReportArchive\*.*" >nul 2>&1
del /s /f /q "%ProgramData%\Microsoft\Windows\WER\ReportQueue\*.*" >nul 2>&1
del /s /f /q "%ProgramData%\Microsoft\Windows\WER\Temp\*.*" >nul 2>&1

echo [*] Cleaning Temporary Internet Cache and Setup logs...
del /s /f /q "%LocalAppData%\Microsoft\Windows\INetCache\*.*" >nul 2>&1
for /d %%p in ("%LocalAppData%\Microsoft\Windows\INetCache\*.*") do rmdir /s /q "%%p" >nul 2>&1
del /s /f /q "%SystemRoot%\Panther\*.*" >nul 2>&1
del /s /f /q "%SystemRoot%\inf\*.log" >nul 2>&1
echo [+] Shader caches and crash dumps cleared.
echo.

:: ====================================================================
:: 7. WINDOWS UPDATE DOWNLOAD CACHE & DELIVERY OPTIMIZATION
:: ====================================================================
echo [*] Cleaning Windows Update packages and Delivery Optimization...
net stop wuauserv >nul 2>&1
net stop bits >nul 2>&1
net stop dosvc >nul 2>&1

del /s /f /q "%SystemRoot%\SoftwareDistribution\Download\*.*" >nul 2>&1
for /d %%p in ("%SystemRoot%\SoftwareDistribution\Download\*.*") do rmdir /s /q "%%p" >nul 2>&1

del /s /f /q "%SystemRoot%\SoftwareDistribution\DeliveryOptimization\*.*" >nul 2>&1
for /d %%p in ("%SystemRoot%\SoftwareDistribution\DeliveryOptimization\*.*") do rmdir /s /q "%%p" >nul 2>&1

net start dosvc >nul 2>&1
net start bits >nul 2>&1
net start wuauserv >nul 2>&1
echo [+] Update caches cleaned.
echo.

:: ====================================================================
:: 8. WINDOWS VOLUME CLEANUP ENGINE (STORAGE SENSE BACKEND)
:: ====================================================================
echo [*] Configuring and launching Windows Volume Cleanup engine...
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

start "" cleanmgr.exe /sagerun:64
echo [+] Storage Sense cleanup running in background.
echo.

:: ====================================================================
:: 9. FLUSH DNS RESOLVER CACHE
:: ====================================================================
echo [*] Flushing DNS cache...
ipconfig /flushdns >nul 2>&1
echo [+] DNS Resolver cache successfully flushed.
echo.

:: ====================================================================
:: 10. COMPLETION
:: ====================================================================
echo ======================================================================
echo                  ALL CLEANUP COMPLETED SUCCESSFULLY!
echo ======================================================================
echo.
echo  [*] Note: Windows Settings has been opened so you can also review or click
echo      'Remove files' under Temporary files.
echo.
echo  Press any key to exit...
pause >nul
exit /b 0
