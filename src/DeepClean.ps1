<#
.SYNOPSIS
    Windows Deep Cleaner (WDC) - PowerShell Edition
    Developed by Abhigyan Sati
    Repository: https://github.com/abhigyansati/windows-deep-cleaner

.DESCRIPTION
    High-performance Windows system cleaner and disk optimization utility.
    Safely cleans User Temp, System Temp, Prefetch, Recent File history, JumpLists,
    DirectX/GPU Shader caches, crash dumps, Windows Update download cache, 
    and empties the Recycle Bin on all drives.

.PARAMETER Mode
    Cleanup mode: 'Auto', 'Visual', 'Inspect', 'Silent'. Default is 'Auto'.

.PARAMETER OpenLocations
    Opens Prefetch, Temp, and Windows Settings Storage UI during or before cleanup.

.EXAMPLE
    .\DeepClean.ps1 -Mode Auto
    Runs automated deep clean and outputs reclaimed space summary.

.EXAMPLE
    .\DeepClean.ps1 -Mode Visual
    Launches Explorer at Prefetch and opens Windows Storage Settings while cleaning.
#>

[CmdletBinding()]
param(
    [ValidateSet('Auto', 'Visual', 'Inspect', 'Silent')]
    [string]$Mode = 'Auto',

    [switch]$OpenLocations
)

# -------------------------------------------------------------------------
# 1. ELEVATION CHECK
# -------------------------------------------------------------------------
$currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
$isAdmin = $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if (-not $isAdmin) {
    Write-Host "[!] Administrator privileges required. Elevating session..." -ForegroundColor Yellow
    try {
        Start-Process powershell.exe -ArgumentList ("-NoProfile -ExecutionPolicy Bypass -File `"{0}`" -Mode {1}" -f $MyInvocation.MyCommand.Path, $Mode) -Verb RunAs
        exit
    }
    catch {
        Write-Error "[X] Failed to elevate privileges. Please run PowerShell as Administrator."
        exit 1
    }
}

# -------------------------------------------------------------------------
# 2. HELPER FUNCTIONS
# -------------------------------------------------------------------------
function Get-DriveFreeGB ([string]$DriveLetter = "C") {
    $drive = Get-PSDrive $DriveLetter -ErrorAction SilentlyContinue
    if ($drive) {
        return [math]::Round($drive.Free / 1GB, 2)
    }
    return 0.0
}

function Remove-PathSafe ([string]$Path, [string]$Label) {
    if (Test-Path -LiteralPath $Path) {
        Write-Host "  [*] Purging $Label..." -ForegroundColor Cyan
        try {
            Get-ChildItem -LiteralPath $Path -Force -Recurse -ErrorAction SilentlyContinue | 
                Remove-Item -Force -Recurse -ErrorAction SilentlyContinue
            Write-Host "  [+] $Label cleared successfully." -ForegroundColor Green
        } catch {
            Write-Host "  [-] Some files in $Label were locked by active processes (safely skipped)." -ForegroundColor DarkGray
        }
    }
}

# -------------------------------------------------------------------------
# 3. HEADER & INITIAL BENCHMARK
# -------------------------------------------------------------------------
Clear-Host
Write-Host "==============================================================================" -ForegroundColor Cyan
Write-Host "     WINDOWS DEEP CLEANER (WDC) - POWERSHELL POWER UTILITY                    " -ForegroundColor White
Write-Host "     Developed by Abhigyan Sati | Open-Source System Optimization Engine      " -ForegroundColor DarkCyan
Write-Host "==============================================================================" -ForegroundColor Cyan
Write-Host ""

$initialFree = Get-DriveFreeGB "C"
Write-Host "  [i] Initial Free Space on System Drive (C:): $initialFree GB" -ForegroundColor White
Write-Host ""

# Visual Mode triggers GUI folder inspection
if ($Mode -eq 'Visual' -or $OpenLocations) {
    Write-Host "  [*] Visual Mode Active: Launching Prefetch and Windows Storage UI..." -ForegroundColor Yellow
    Start-Process "explorer.exe" "$env:SystemRoot\Prefetch" -ErrorAction SilentlyContinue
    Start-Process "ms-settings:storagesettings" -ErrorAction SilentlyContinue
    Start-Sleep -Seconds 1
}

if ($Mode -eq 'Inspect') {
    Start-Process "explorer.exe" "$env:SystemRoot\Prefetch" -ErrorAction SilentlyContinue
    Start-Process "explorer.exe" "$env:temp" -ErrorAction SilentlyContinue
    Start-Process "explorer.exe" "$env:AppData\Microsoft\Windows\Recent" -ErrorAction SilentlyContinue
    Start-Process "ms-settings:storagesettings" -ErrorAction SilentlyContinue
    Write-Host "  [+] System inspection directories opened." -ForegroundColor Green
    exit 0
}

# -------------------------------------------------------------------------
# 4. EXECUTION PIPELINE
# -------------------------------------------------------------------------
Write-Host "--- [Phase 1/7] User & System Temporary Directories ---" -ForegroundColor Yellow
Remove-PathSafe -Path $env:temp -Label "User Temp Directory"
Remove-PathSafe -Path "$env:SystemRoot\Temp" -Label "System Temp Directory"

Write-Host "--- [Phase 2/7] Windows Prefetch Cache ---" -ForegroundColor Yellow
Remove-PathSafe -Path "$env:SystemRoot\Prefetch" -Label "Prefetch Cache"

Write-Host "--- [Phase 3/7] File Explorer Recent History & JumpLists ---" -ForegroundColor Yellow
Remove-PathSafe -Path "$env:AppData\Microsoft\Windows\Recent" -Label "Recent History and JumpLists"

Write-Host "--- [Phase 4/7] DirectX & GPU Shader Caches ---" -ForegroundColor Yellow
Remove-PathSafe -Path "$env:LocalAppData\D3DSCache" -Label "DirectX Shader Cache"
Remove-PathSafe -Path "$env:LocalAppData\NVIDIA\DXCache" -Label "NVIDIA Shader Cache"
Remove-PathSafe -Path "$env:LocalAppData\AMD\DxCache" -Label "AMD Shader Cache"
Remove-PathSafe -Path "$env:LocalAppData\CrashDumps" -Label "Application Crash Dumps"
Remove-PathSafe -Path "$env:ProgramData\Microsoft\Windows\WER" -Label "Windows Error Reporting Logs"

Write-Host "--- [Phase 5/7] Windows Update Download Cache ---" -ForegroundColor Yellow
Write-Host "  [*] Stopping update services temporarily..." -ForegroundColor DarkGray
Stop-Service -Name wuauserv, bits, dosvc -Force -ErrorAction SilentlyContinue
Remove-PathSafe -Path "$env:SystemRoot\SoftwareDistribution\Download" -Label "Update Downloads"
Remove-PathSafe -Path "$env:SystemRoot\SoftwareDistribution\DeliveryOptimization" -Label "Delivery Optimization Cache"
Start-Service -Name dosvc, bits, wuauserv -ErrorAction SilentlyContinue
Write-Host "  [+] Update services resumed." -ForegroundColor DarkGray

Write-Host "--- [Phase 6/7] Recycle Bin Emptying (All Drives) ---" -ForegroundColor Yellow
try {
    Clear-RecycleBin -Force -ErrorAction SilentlyContinue
    Write-Host "  [+] All Recycle Bins emptied successfully." -ForegroundColor Green
} catch {
    Write-Host "  [-] Notice: Recycle bin clean completed with standard permissions." -ForegroundColor DarkGray
}

Write-Host "--- [Phase 7/7] Network DNS Resolver Cache ---" -ForegroundColor Yellow
Clear-DnsClientCache -ErrorAction SilentlyContinue
Write-Host "  [+] DNS Cache flushed." -ForegroundColor Green

# -------------------------------------------------------------------------
# 5. SUMMARY BENCHMARKS
# -------------------------------------------------------------------------
$finalFree = Get-DriveFreeGB "C"
$spaceFreed = [math]::Round(($finalFree - $initialFree), 2)
if ($spaceFreed -lt 0) { $spaceFreed = 0.0 }

Write-Host ""
Write-Host "==============================================================================" -ForegroundColor Green
Write-Host "                        CLEANUP COMPLETED!                                    " -ForegroundColor White
Write-Host "==============================================================================" -ForegroundColor Green
Write-Host "  [i] Initial Free Space : $initialFree GB" -ForegroundColor White
Write-Host "  [i] Final Free Space   : $finalFree GB" -ForegroundColor White
Write-Host "  [+] Total Space Freed  : $spaceFreed GB" -ForegroundColor Green
Write-Host "==============================================================================" -ForegroundColor Green
Write-Host "  Project GitHub: https://github.com/abhigyansati/windows-deep-cleaner" -ForegroundColor DarkCyan
Write-Host ""
