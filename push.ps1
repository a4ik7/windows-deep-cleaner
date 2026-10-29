<#
.SYNOPSIS
    Automated 1-Click Git Sync for Windows Deep Cleaner
    Author: Abhigyan Sati (@a4ik7)
#>

[CmdletBinding()]
param()

$repoDir = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location -LiteralPath $repoDir

Write-Host "==============================================================================" -ForegroundColor Cyan
Write-Host "  WINDOWS DEEP CLEANER — AUTOMATED GITHUB SYNC                                 " -ForegroundColor White
Write-Host "  Repository: a4ik7/windows-deep-cleaner                                       " -ForegroundColor DarkCyan
Write-Host "==============================================================================" -ForegroundColor Cyan
Write-Host ""

# 1. Verify Git installation
if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    Write-Error "[!] Git is not found in PATH. Please install Git for Windows."
    exit 1
}

# 2. Configure Remote URL
$targetRemote = "https://github.com/a4ik7/windows-deep-cleaner.git"
$currentRemote = git remote get-url origin 2>$null

if ($null -eq $currentRemote -or $currentRemote -ne $targetRemote) {
    Write-Host "[*] Configuring remote origin to: $targetRemote" -ForegroundColor Yellow
    git remote remove origin 2>$null
    git remote add origin $targetRemote
}

# 3. Stage & Commit
Write-Host "[*] Staging all updated repository files..." -ForegroundColor Cyan
git add -A

$status = git status --porcelain
if ($status) {
    Write-Host "[*] Creating release commit..." -ForegroundColor Cyan
    git commit -m "refactor: align documentation and codebase with Windows internals and forensic hygiene standards"
} else {
    Write-Host "[i] Working tree is clean. Ready to push." -ForegroundColor Green
}

# 4. Push to GitHub
Write-Host "[*] Pushing to GitHub (main branch)..." -ForegroundColor Yellow
git branch -M main
git push -u origin main

if ($LASTEXITCODE -eq 0) {
    Write-Host ""
    Write-Host "==============================================================================" -ForegroundColor Green
    Write-Host "  [+] SUCCESS! Repository is updated and live on GitHub!                       " -ForegroundColor White
    Write-Host "  🔗 https://github.com/a4ik7/windows-deep-cleaner                             " -ForegroundColor Cyan
    Write-Host "==============================================================================" -ForegroundColor Green
} else {
    Write-Host ""
    Write-Host "[!] Push finished with code $LASTEXITCODE." -ForegroundColor Yellow
    Write-Host "    If Git prompted you for credentials, please complete authentication in your browser." -ForegroundColor DarkGray
}
