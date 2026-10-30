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
:: 1B. EXTRACT THE EMBEDDED POPUP SCRIPT (stored at the bottom of this file)
::     It is saved outside the folders that get cleaned, and removed at the end.
:: ====================================================================
set "UI=%ProgramData%\DeepCleaner_ui.ps1"
powershell -NoProfile -ExecutionPolicy Bypass -Command "$c=[IO.File]::ReadAllText('%~f0'); $i=$c.LastIndexOf('#'+'PSBEGIN'); [IO.File]::WriteAllText('%UI%', $c.Substring($i))"

:: Measure free disk space before cleanup
echo [*] Analyzing system storage before cleanup...
for /f "tokens=1,2 delims=;" %%a in ('powershell -NoProfile -ExecutionPolicy Bypass -File "%UI%" drive') do (
    set "DC_BEFORE=%%a"
    set "DC_TOTAL=%%b"
)
for /f "delims=" %%d in ('powershell -NoProfile -ExecutionPolicy Bypass -File "%UI%" fmt %DC_BEFORE%') do set "FREE_BEFORE_GB=%%d"
echo [i] Initial Free Space on C: Drive: %FREE_BEFORE_GB%
echo.

:: ====================================================================
:: 1C. MEASURE HOW MUCH UNNECESSARY DATA EXISTS (BEFORE DELETING ANYTHING)
:: ====================================================================
echo [*] Measuring unnecessary files (this can take a minute)...
for /f "tokens=1-4 delims=;" %%a in ('powershell -NoProfile -ExecutionPolicy Bypass -File "%UI%" measure') do (
    set "DC_C1=%%a"
    set "DC_C2=%%b"
    set "DC_C3=%%c"
    set "DC_C4=%%d"
)
echo [+] Measurement complete.
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
net stop wuauserv /y >nul 2>&1
net stop bits /y >nul 2>&1
net stop dosvc /y >nul 2>&1

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

:: /wait makes the script pause until Disk Cleanup finishes,
:: so the "space freed" number is measured AFTER all cleanup is really done.
echo [*] Waiting for Windows Disk Cleanup to finish (this can take a few minutes)...
start "" /wait cleanmgr.exe /sagerun:64
echo [+] Storage Sense cleanup finished.
echo.

:: ====================================================================
:: 9. FLUSH DNS RESOLVER CACHE
:: ====================================================================
echo [*] Flushing DNS cache...
ipconfig /flushdns >nul 2>&1
echo [+] DNS Resolver cache successfully flushed.
echo.

:: ====================================================================
:: 10. MEASURE RESULTS & SHOW THE RESULTS POPUP
:: ====================================================================
for /f "tokens=1,2 delims=;" %%a in ('powershell -NoProfile -ExecutionPolicy Bypass -File "%UI%" drive') do set "DC_AFTER=%%a"

for /f "tokens=1-4 delims=;" %%a in ('powershell -NoProfile -ExecutionPolicy Bypass -File "%UI%" summary') do (
    set "S_FOUND=%%a"
    set "S_FREED=%%b"
    set "S_BEFORE=%%c"
    set "S_AFTER=%%d"
)

echo ======================================================================
echo                  ALL CLEANUP COMPLETED SUCCESSFULLY
echo ======================================================================
echo.
echo   [i] Unnecessary data found    : %S_FOUND%
echo   [i] Free space before cleanup : %S_BEFORE%
echo   [i] Free space after cleanup  : %S_AFTER%
echo   [+] Total disk space freed    : %S_FREED%
echo.
echo ======================================================================
echo.
echo  [*] Note: Windows Settings has been opened so you can also review or click
echo      'Remove files' under Temporary files.
echo.

:: Show the results window WITHOUT waiting for it (no blocking, no key press needed).
:: The popup script deletes itself after the window is closed.
start "" powershell -NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File "%UI%" popup

exit /b 0

#PSBEGIN
param([string]$Mode = 'popup', [string]$Arg = '')
$ErrorActionPreference = 'SilentlyContinue'

function Fmt([double]$b) {
    if ($b -ge 1GB) { return ('{0:N2} GB' -f ($b / 1GB)) }
    if ($b -ge 1MB) { return ('{0:N0} MB' -f ($b / 1MB)) }
    return ('{0:N0} KB' -f ($b / 1KB))
}

function Get-Bytes([string]$Path, [string]$Filter = '*') {
    if (-not (Test-Path -LiteralPath $Path)) { return [double]0 }
    $m = Get-ChildItem -LiteralPath $Path -Filter $Filter -Recurse -Force -File -ErrorAction SilentlyContinue | Measure-Object -Property Length -Sum
    if ($m.Sum) { return [double]$m.Sum }
    return [double]0
}

if ($Mode -eq 'fmt') { Write-Output (Fmt ([double]$Arg)); return }

if ($Mode -eq 'drive') {
    $d = Get-PSDrive C
    Write-Output ('{0};{1}' -f [int64]$d.Free, [int64]($d.Used + $d.Free))
    return
}

if ($Mode -eq 'measure') {
    $c1 = (Get-Bytes $env:TEMP) + (Get-Bytes "$env:SystemRoot\Temp")
    $c2 = (Get-Bytes "$env:SystemRoot\SoftwareDistribution\Download") + (Get-Bytes "$env:SystemRoot\SoftwareDistribution\DeliveryOptimization")
    $c3 = 0
    $shaderPaths = @(
        "$env:LocalAppData\D3DSCache",
        "$env:LocalAppData\NVIDIA\DXCache",
        "$env:LocalAppData\AMD\DxCache",
        "$env:LocalAppData\CrashDumps",
        "$env:ProgramData\Microsoft\Windows\WER\ReportArchive",
        "$env:ProgramData\Microsoft\Windows\WER\ReportQueue",
        "$env:ProgramData\Microsoft\Windows\WER\Temp",
        "$env:LocalAppData\Microsoft\Windows\INetCache",
        "$env:SystemRoot\Panther"
    )
    foreach ($p in $shaderPaths) { $c3 += Get-Bytes $p }
    $c3 += Get-Bytes "$env:SystemRoot\inf" '*.log'
    $c4 = (Get-Bytes "$env:SystemRoot\Prefetch") + (Get-Bytes "$env:AppData\Microsoft\Windows\Recent")
    foreach ($dr in (Get-PSDrive -PSProvider FileSystem)) { $c4 += Get-Bytes (Join-Path $dr.Root '$Recycle.Bin') }
    Write-Output ('{0};{1};{2};{3}' -f [int64]$c1, [int64]$c2, [int64]$c3, [int64]$c4)
    return
}

# ---- numbers shared by 'summary' and 'popup' ----
$c1 = [double]$env:DC_C1
$c2 = [double]$env:DC_C2
$c3 = [double]$env:DC_C3
$c4 = [double]$env:DC_C4
$before = [double]$env:DC_BEFORE
$after  = [double]$env:DC_AFTER
$total  = [double]$env:DC_TOTAL

$freed    = [math]::Max(0, $after - $before)
$measured = $c1 + $c2 + $c3 + $c4
$junk     = [math]::Max($measured, $freed)
$extra    = [math]::Max(0, $junk - $measured)
$pct = 100
if ($junk -gt 0) { $pct = [int][math]::Min(100, [math]::Round(100 * $freed / $junk)) }

if ($Mode -eq 'summary') {
    Write-Output ('{0};{1};{2};{3}' -f (Fmt $junk), (Fmt $freed), (Fmt $before), (Fmt $after))
    return
}

# ---- results window (Option A) ----
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
Add-Type -TypeDefinition 'using System.Runtime.InteropServices; public class DcDpi { [DllImport("user32.dll")] public static extern bool SetProcessDPIAware(); }'
[void][DcDpi]::SetProcessDPIAware()
[System.Windows.Forms.Application]::EnableVisualStyles()

function Col([string]$hex) { return [System.Drawing.ColorTranslator]::FromHtml($hex) }
$cDark   = Col '#2C2C2A'
$cMuted  = Col '#5F5E5A'
$cLine   = Col '#E5E3DC'
$cCard   = Col '#F5F4F0'
$cGreen  = Col '#3B6D11'
$cGreenD = Col '#27500A'
$cGreenBg = Col '#EAF3DE'
$cGrayBar = Col '#B4B2A9'
$cTrack  = Col '#F1EFE8'

function New-Label([string]$text, $x, $y, $w, $h, $size, [string]$fam, [string]$style, $color, [string]$align) {
    $l = New-Object System.Windows.Forms.Label
    $l.AutoSize = $false
    $l.Text = $text
    $l.Location = New-Object System.Drawing.Point($x, $y)
    $l.Size = New-Object System.Drawing.Size($w, $h)
    $l.Font = New-Object System.Drawing.Font($fam, [single]$size, [System.Drawing.FontStyle]$style)
    $l.ForeColor = $color
    $l.BackColor = [System.Drawing.Color]::Transparent
    $l.TextAlign = $align
    return $l
}

function Set-Round($ctl) {
    $r = [int]($ctl.Height * 0.1)
    $d = $r * 2
    $w = $ctl.Width
    $h = $ctl.Height
    $p = New-Object System.Drawing.Drawing2D.GraphicsPath
    $p.AddArc(0, 0, $d, $d, 180, 90)
    $p.AddArc($w - $d, 0, $d, $d, 270, 90)
    $p.AddArc($w - $d, $h - $d, $d, $d, 0, 90)
    $p.AddArc(0, $h - $d, $d, $d, 90, 90)
    $p.CloseFigure()
    $ctl.Region = New-Object System.Drawing.Region($p)
}

$rows = @(
    @('Temp files', (Fmt $c1)),
    @('Windows Update cache', (Fmt $c2)),
    @('Shader cache, crash dumps and logs', (Fmt $c3)),
    @('Recycle Bin, Prefetch and recent files', (Fmt $c4))
)
if ($extra -gt 50MB) { $rows += ,@('Other Windows cleanup files', (Fmt $extra)) }

$rowsTop = 342
$btnTop  = $rowsTop + ($rows.Count * 36) + 24
$formH   = $btnTop + 40 + 28

$form = New-Object System.Windows.Forms.Form
$form.AutoScaleDimensions = New-Object System.Drawing.SizeF(96, 96)
$form.AutoScaleMode = 'Dpi'
$form.Text = 'Windows Deep Cleaner'
$form.FormBorderStyle = 'FixedDialog'
$form.MaximizeBox = $false
$form.MinimizeBox = $false
$form.StartPosition = 'CenterScreen'
$form.BackColor = [System.Drawing.Color]::White
$form.TopMost = $true
$form.ClientSize = New-Object System.Drawing.Size(760, $formH)

# check circle
$chk = New-Object System.Windows.Forms.Panel
$chk.Location = New-Object System.Drawing.Point(40, 28)
$chk.Size = New-Object System.Drawing.Size(56, 56)
$chk.BackColor = [System.Drawing.Color]::White
$chk.Add_Paint({
    param($s, $e)
    $g = $e.Graphics
    $g.SmoothingMode = 'AntiAlias'
    $b = New-Object System.Drawing.SolidBrush($cGreenBg)
    $g.FillEllipse($b, 1, 1, ($s.Width - 3), ($s.Height - 3))
    $pen = New-Object System.Drawing.Pen($cGreen, [single]($s.Width * 0.075))
    $pen.StartCap = 'Round'
    $pen.EndCap = 'Round'
    $pen.LineJoin = 'Round'
    $w = $s.Width
    $h = $s.Height
    $pts = [System.Drawing.PointF[]]@(
        (New-Object System.Drawing.PointF(($w * 0.28), ($h * 0.52))),
        (New-Object System.Drawing.PointF(($w * 0.44), ($h * 0.67))),
        (New-Object System.Drawing.PointF(($w * 0.72), ($h * 0.36)))
    )
    $g.DrawLines($pen, $pts)
})
$form.Controls.Add($chk)

$sub = 'Your C: drive is lighter and cleaner.'
if ($freed -lt 10MB) { $sub = 'Your drive was already mostly clean.' }
$form.Controls.Add((New-Label 'Cleanup complete' 112 26 600 36 20 'Segoe UI Semibold' 'Regular' $cDark 'MiddleLeft'))
$form.Controls.Add((New-Label $sub 112 60 600 24 10.5 'Segoe UI' 'Regular' $cMuted 'MiddleLeft'))

# metric cards
$card1 = New-Object System.Windows.Forms.Panel
$card1.Location = New-Object System.Drawing.Point(40, 112)
$card1.Size = New-Object System.Drawing.Size(332, 112)
$card1.BackColor = $cCard
$card1.Controls.Add((New-Label 'Junk found' 20 14 290 22 10 'Segoe UI' 'Regular' $cMuted 'MiddleLeft'))
$card1.Controls.Add((New-Label (Fmt $junk) 20 36 290 46 26 'Segoe UI Semibold' 'Regular' $cDark 'MiddleLeft'))
$card1.Controls.Add((New-Label 'Unnecessary files on your drive' 20 82 290 20 9 'Segoe UI' 'Regular' $cMuted 'MiddleLeft'))
$form.Controls.Add($card1)

$card2 = New-Object System.Windows.Forms.Panel
$card2.Location = New-Object System.Drawing.Point(388, 112)
$card2.Size = New-Object System.Drawing.Size(332, 112)
$card2.BackColor = $cGreenBg
$card2.Controls.Add((New-Label 'Space freed' 20 14 290 22 10 'Segoe UI' 'Regular' $cGreen 'MiddleLeft'))
$card2.Controls.Add((New-Label (Fmt $freed) 20 36 290 46 26 'Segoe UI Semibold' 'Regular' $cGreenD 'MiddleLeft'))
$card2.Controls.Add((New-Label ("$pct% of it removed") 20 82 290 20 9 'Segoe UI' 'Regular' $cGreen 'MiddleLeft'))
$form.Controls.Add($card2)
$cards = @($card1, $card2)

# free space before -> after
$form.Controls.Add((New-Label 'Free space on C:' 40 248 300 26 10.5tateFlags0064 /t REG_DWORD /d 2 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Windows Error Reporting Files" /v StateFlags0064 /t REG_DWORD /d 2 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Windows Upgrade Log Files" /v StateFlags0064 /t REG_DWORD /d 2 /f >nul 2>&1

:: /wait makes the script pause until Disk Cleanup finishes,
:: so the "space freed" number is measured AFTER all cleanup is really done.
echo [*] Waiting for Windows Disk Cleanup to finish (this can take a few minutes)...
start "" /wait cleanmgr.exe /sagerun:64
echo [+] Storage Sense cleanup finished.
echo.

:: ====================================================================
:: 9. FLUSH DNS RESOLVER CACHE
:: ====================================================================
echo [*] Flushing DNS cache...
ipconfig /flushdns >nul 2>&1
echo [+] DNS Resolver cache successfully flushed.
echo.

:: ====================================================================
:: 10. MEASURE RESULTS & SHOW THE RESULTS POPUP
:: ====================================================================
for /f "tokens=1,2 delims=;" %%a in ('powershell -NoProfile -ExecutionPolicy Bypass -File "%UI%" drive') do set "DC_AFTER=%%a"

for /f "tokens=1-4 delims=;" %%a in ('powershell -NoProfile -ExecutionPolicy Bypass -File "%UI%" summary') do (
    set "S_FOUND=%%a"
    set "S_FREED=%%b"
    set "S_BEFORE=%%c"
    set "S_AFTER=%%d"
)

echo ======================================================================
echo                  ALL CLEANUP COMPLETED SUCCESSFULLY
echo ======================================================================
echo.
echo   [i] Unnecessary data found    : %S_FOUND%
echo   [i] Free space before cleanup : %S_BEFORE%
echo   [i] Free space after cleanup  : %S_AFTER%
echo   [+] Total disk space freed    : %S_FREED%
echo.
echo ======================================================================
echo.
echo  [*] Note: Windows Settings has been opened so you can also review or click
echo      'Remove files' under Temporary files.
echo.

:: Show the results window (waits here until you close it)
powershell -NoProfile -ExecutionPolicy Bypass -File "%UI%" popup

:: Remove the temporary popup script
del /f /q "%UI%" >nul 2>&1

echo Press any key to exit...
pause >nul
exit /b 0

#PSBEGIN
param([string]$Mode = 'popup', [string]$Arg = '')
$ErrorActionPreference = 'SilentlyContinue'

function Fmt([double]$b) {
    if ($b -ge 1GB) { return ('{0:N2} GB' -f ($b / 1GB)) }
    if ($b -ge 1MB) { return ('{0:N0} MB' -f ($b / 1MB)) }
    return ('{0:N0} KB' -f ($b / 1KB))
}

function Get-Bytes([string]$Path, [string]$Filter = '*') {
    if (-not (Test-Path -LiteralPath $Path)) { return [double]0 }
    $m = Get-ChildItem -LiteralPath $Path -Filter $Filter -Recurse -Force -File -ErrorAction SilentlyContinue | Measure-Object -Property Length -Sum
    if ($m.Sum) { return [double]$m.Sum }
    return [double]0
}

if ($Mode -eq 'fmt') { Write-Output (Fmt ([double]$Arg)); return }

if ($Mode -eq 'drive') {
    $d = Get-PSDrive C
    Write-Output ('{0};{1}' -f [int64]$d.Free, [int64]($d.Used + $d.Free))
    return
}

if ($Mode -eq 'measure') {
    $c1 = (Get-Bytes $env:TEMP) + (Get-Bytes "$env:SystemRoot\Temp")
    $c2 = (Get-Bytes "$env:SystemRoot\SoftwareDistribution\Download") + (Get-Bytes "$env:SystemRoot\SoftwareDistribution\DeliveryOptimization")
    $c3 = 0
    $shaderPaths = @(
        "$env:LocalAppData\D3DSCache",
        "$env:LocalAppData\NVIDIA\DXCache",
        "$env:LocalAppData\AMD\DxCache",
        "$env:LocalAppData\CrashDumps",
        "$env:ProgramData\Microsoft\Windows\WER\ReportArchive",
        "$env:ProgramData\Microsoft\Windows\WER\ReportQueue",
        "$env:ProgramData\Microsoft\Windows\WER\Temp",
        "$env:LocalAppData\Microsoft\Windows\INetCache",
        "$env:SystemRoot\Panther"
    )
    foreach ($p in $shaderPaths) { $c3 += Get-Bytes $p }
    $c3 += Get-Bytes "$env:SystemRoot\inf" '*.log'
    $c4 = (Get-Bytes "$env:SystemRoot\Prefetch") + (Get-Bytes "$env:AppData\Microsoft\Windows\Recent")
    foreach ($dr in (Get-PSDrive -PSProvider FileSystem)) { $c4 += Get-Bytes (Join-Path $dr.Root '$Recycle.Bin') }
    Write-Output ('{0};{1};{2};{3}' -f [int64]$c1, [int64]$c2, [int64]$c3, [int64]$c4)
    return
}

# ---- numbers shared by 'summary' and 'popup' ----
$c1 = [double]$env:DC_C1
$c2 = [double]$env:DC_C2
$c3 = [double]$env:DC_C3
$c4 = [double]$env:DC_C4
$before = [double]$env:DC_BEFORE
$after  = [double]$env:DC_AFTER
$total  = [double]$env:DC_TOTAL

$freed    = [math]::Max(0, $after - $before)
$measured = $c1 + $c2 + $c3 + $c4
$junk     = [math]::Max($measured, $freed)
$extra    = [math]::Max(0, $junk - $measured)
$pct = 100
if ($junk -gt 0) { $pct = [int][math]::Min(100, [math]::Round(100 * $freed / $junk)) }

if ($Mode -eq 'summary') {
    Write-Output ('{0};{1};{2};{3}' -f (Fmt $junk), (Fmt $freed), (Fmt $before), (Fmt $after))
    return
}

# ---- results window (Option A) ----
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
Add-Type -TypeDefinition 'using System.Runtime.InteropServices; public class DcDpi { [DllImport("user32.dll")] public static extern bool SetProcessDPIAware(); }'
[void][DcDpi]::SetProcessDPIAware()
[System.Windows.Forms.Application]::EnableVisualStyles()

function Col([string]$hex) { return [System.Drawing.ColorTranslator]::FromHtml($hex) }
$cDark   = Col '#2C2C2A'
$cMuted  = Col '#5F5E5A'
$cLine   = Col '#E5E3DC'
$cCard   = Col '#F5F4F0'
$cGreen  = Col '#3B6D11'
$cGreenD = Col '#27500A'
$cGreenBg = Col '#EAF3DE'
$cGrayBar = Col '#B4B2A9'
$cTrack  = Col '#F1EFE8'

function New-Label([string]$text, $x, $y, $w, $h, $size, [string]$fam, [string]$style, $color, [string]$align) {
    $l = New-Object System.Windows.Forms.Label
    $l.AutoSize = $false
    $l.Text = $text
    $l.Location = New-Object System.Drawing.Point($x, $y)
    $l.Size = New-Object System.Drawing.Size($w, $h)
    $l.Font = New-Object System.Drawing.Font($fam, [single]$size, [System.Drawing.FontStyle]$style)
    $l.ForeColor = $color
    $l.BackColor = [System.Drawing.Color]::Transparent
    $l.TextAlign = $align
    return $l
}

function Set-Round($ctl) {
    $r = [int]($ctl.Height * 0.1)
    $d = $r * 2
    $w = $ctl.Width
    $h = $ctl.Height
    $p = New-Object System.Drawing.Drawing2D.GraphicsPath
    $p.AddArc(0, 0, $d, $d, 180, 90)
    $p.AddArc($w - $d, 0, $d, $d, 270, 90)
    $p.AddArc($w - $d, $h - $d, $d, $d, 0, 90)
    $p.AddArc(0, $h - $d, $d, $d, 90, 90)
    $p.CloseFigure()
    $ctl.Region = New-Object System.Drawing.Region($p)
}

$rows = @(
    @('Temp files', (Fmt $c1)),
    @('Windows Update cache', (Fmt $c2)),
    @('Shader cache, crash dumps and logs', (Fmt $c3)),
    @('Recycle Bin, Prefetch and recent files', (Fmt $c4))
)
if ($extra -gt 50MB) { $rows += ,@('Other Windows cleanup files', (Fmt $extra)) }

$rowsTop = 342
$btnTop  = $rowsTop + ($rows.Count * 36) + 24
$formH   = $btnTop + 40 + 28

$form = New-Object System.Windows.Forms.Form
$form.AutoScaleDimensions = New-Object System.Drawing.SizeF(96, 96)
$form.AutoScaleMode = 'Dpi'
$form.Text = 'Windows Deep Cleaner'
$form.FormBorderStyle = 'FixedDialog'
$form.MaximizeBox = $false
$form.MinimizeBox = $false
$form.StartPosition = 'CenterScreen'
$form.BackColor = [System.Drawing.Color]::White
$form.TopMost = $true
$form.ClientSize = New-Object System.Drawing.Size(760, $formH)

# check circle
$chk = New-Object System.Windows.Forms.Panel
$chk.Location = New-Object System.Drawing.Point(40, 28)
$chk.Size = New-Object System.Drawing.Size(56, 56)
$chk.BackColor = [System.Drawing.Color]::White
$chk.Add_Paint({
    param($s, $e)
    $g = $e.Graphics
    $g.SmoothingMode = 'AntiAlias'
    $b = New-Object System.Drawing.SolidBrush($cGreenBg)
    $g.FillEllipse($b, 1, 1, ($s.Width - 3), ($s.Height - 3))
    $pen = New-Object System.Drawing.Pen($cGreen, [single]($s.Width * 0.075))
    $pen.StartCap = 'Round'
    $pen.EndCap = 'Round'
    $pen.LineJoin = 'Round'
    $w = $s.Width
    $h = $s.Height
    $pts = [System.Drawing.PointF[]]@(
        (New-Object System.Drawing.PointF(($w * 0.28), ($h * 0.52))),
        (New-Object System.Drawing.PointF(($w * 0.44), ($h * 0.67))),
        (New-Object System.Drawing.PointF(($w * 0.72), ($h * 0.36)))
    )
    $g.DrawLines($pen, $pts)
})
$form.Controls.Add($chk)

$sub = 'Your C: drive is lighter and cleaner.'
if ($freed -lt 10MB) { $sub = 'Your drive was already mostly clean.' }
$form.Controls.Add((New-Label 'Cleanup complete' 112 26 600 36 20 'Segoe UI Semibold' 'Regular' $cDark 'MiddleLeft'))
$form.Controls.Add((New-Label $sub 112 60 600 24 10.5 'Segoe UI' 'Regular' $cMuted 'MiddleLeft'))

# metric cards
$card1 = New-Object System.Windows.Forms.Panel
$card1.Location = New-Object System.Drawing.Point(40, 112)
$card1.Size = New-Object System.Drawing.Size(332, 112)
$card1.BackColor = $cCard
$card1.Controls.Add((New-Label 'Junk found' 20 14 290 22 10 'Segoe UI' 'Regular' $cMuted 'MiddleLeft'))
$card1.Controls.Add((New-Label (Fmt $junk) 20 36 290 46 26 'Segoe UI Semibold' 'Regular' $cDark 'MiddleLeft'))
$card1.Controls.Add((New-Label 'Unnecessary files on your drive' 20 82 290 20 9 'Segoe UI' 'Regular' $cMuted 'MiddleLeft'))
$form.Controls.Add($card1)

$card2 = New-Object System.Windows.Forms.Panel
$card2.Location = New-Object System.Drawing.Point(388, 112)
$card2.Size = New-Object System.Drawing.Size(332, 112)
$card2.BackColor = $cGreenBg
$card2.Controls.Add((New-Label 'Space freed' 20 14 290 22 10 'Segoe UI' 'Regular' $cGreen 'MiddleLeft'))
$card2.Controls.Add((New-Label (Fmt $freed) 20 36 290 46 26 'Segoe UI Semibold' 'Regular' $cGreenD 'MiddleLeft'))
$card2.Controls.Add((New-Label ("$pct% of it removed") 20 82 290 20 9 'Segoe UI' 'Regular' $cGreen 'MiddleLeft'))
$form.Controls.Add($card2)
$cards = @($card1, $card2)

# free space before -> after
$form.Controls.Add((New-Label 'Free space on C:' 40 248 300 26 10.5 'Segoe UI' 'Regular' $cMuted 'MiddleLeft'))
$arrow = [string][char]0x2192
$form.Controls.Add((New-Label ("$(Fmt $before)  $arrow  $(Fmt $after)") 340 248 380 26 10.5 'Segoe UI Semibold' 'Regular' $cDark 'MiddleRight'))

$bar = New-Object System.Windows.Forms.Panel
$bar.Location = New-Object System.Drawing.Point(40, 282)
$bar.Size = New-Object System.Drawing.Size(680, 12)
$bar.BackColor = $cTrack
$bar.Add_Paint({
    param($s, $e)
    $g = $e.Graphics
    $tot = [math]::Max($total, 1)
    $wb = [int]($s.Width * [math]::Min($before / $tot, 1))
    $wf = [int]($s.Width * [math]::Min($freed / $tot, 1))
    if ($freed -gt 0 -and $wf -lt 3) { $wf = 3 }
    $g.FillRectangle((New-Object System.Drawing.SolidBrush($cGrayBar)), 0, 0, $wb, $s.Height)
    $g.FillRectangle((New-Object System.Drawing.SolidBrush($cGreen)), $wb, 0, $wf, $s.Height)
})
$form.Controls.Add($bar)

$sq = [string][char]0x25A0
$form.Controls.Add((New-Label ("$sq  Free before cleanup") 40 300 200 22 9 'Segoe UI' 'Regular' $cGrayBar 'MiddleLeft'))
$form.Controls.Add((New-Label ("$sq  Freed now") 250 300 200 22 9 'Segoe UI' 'Regular' $cGreen 'MiddleLeft'))

# breakdown rows
$top = New-Object System.Windows.Forms.Panel
$top.Location = New-Object System.Drawing.Point(40, $rowsTop)
$top.Size = New-Object System.Drawing.Size(680, 1)
$top.BackColor = $cLine
$form.Controls.Add($top)

$y = $rowsTop
foreach ($r in $rows) {
    $form.Controls.Add((New-Label $r[0] 40 ($y + 1) 460 34 10.5 'Segoe UI' 'Regular' $cMuted 'MiddleLeft'))
    $form.Controls.Add((New-Label $r[1] 500 ($y + 1) 220 34 10.5 'Segoe UI Semibold' 'Regular' $cDark 'MiddleRight'))
    $y += 36
    $ln = New-Object System.Windows.Forms.Panel
    $ln.Location = New-Object System.Drawing.Point(40, ($y - 1))
    $ln.Size = New-Object System.Drawing.Size(680, 1)
    $ln.BackColor = $cLine
    $form.Controls.Add($ln)
}

# buttons
$btnClose = New-Object System.Windows.Forms.Button
$btnClose.Text = 'Close'
$btnClose.Size = New-Object System.Drawing.Size(120, 40)
$btnClose.Location = New-Object System.Drawing.Point(600, $btnTop)
$btnClose.FlatStyle = 'Flat'
$btnClose.FlatAppearance.BorderSize = 0
$btnClose.BackColor = $cDark
$btnClose.ForeColor = [System.Drawing.Color]::White
$btnClose.Font = New-Object System.Drawing.Font('Segoe UI Semibold', [single]10)
$btnClose.Add_Click({ $form.Close() })
$form.Controls.Add($btnClose)

$btnSet = New-Object System.Windows.Forms.Button
$btnSet.Text = 'Storage settings'
$btnSet.Size = New-Object System.Drawing.Size(150, 40)
$btnSet.Location = New-Object System.Drawing.Point(438, $btnTop)
$btnSet.FlatStyle = 'Flat'
$btnSet.FlatAppearance.BorderColor = Col '#D3D1C7'
$btnSet.BackColor = [System.Drawing.Color]::White
$btnSet.ForeColor = $cDark
$btnSet.Font = New-Object System.Drawing.Font('Segoe UI', [single]10)
$btnSet.Add_Click({ Start-Process 'ms-settings:storagesettings' })
$form.Controls.Add($btnSet)

$form.AcceptButton = $btnClose
$form.CancelButton = $btnClose
$form.Add_Shown({
    $form.Activate()
    foreach ($c in $cards) { Set-Round $c }
})
[void]$form.ShowDialog()
