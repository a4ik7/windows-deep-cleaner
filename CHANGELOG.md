# Changelog

All notable changes to **Windows Deep Cleaner** will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

---

## [2.0.0] - 2026-10-29

### Added
- **Visual Deep Clean Mode**: Launches Windows Explorer directly into `%SystemRoot%\Prefetch` and Windows Settings Storage / Temporary Files (`ms-settings:storagesettings` and `ms-settings:storagesense`) to visually observe disk analysis.
- **Prefetch Purge & Inspector**: Full cleanup of `%SystemRoot%\Prefetch` with ReadyBoot subfolder pruning.
- **Recent Files & JumpLists Wipe**: Complete removal of `%AppData%\Microsoft\Windows\Recent` along with `AutomaticDestinations` and `CustomDestinations`.
- **System Drive Free Space Benchmark**: Automatic calculation and real-time terminal display of free space before cleanup and exact gigabytes reclaimed.
- **Direct CLI Argument Preservation**: Arguments like `/auto`, `/visual`, `/silent`, `/open`, and `/help` are preserved during UAC administrative privilege elevation.
- **Open Locations Inspection Menu**: Quick interactive launcher to inspect Prefetch, User Temp, Recent history, and Windows Storage Settings.
- **Comprehensive Docs Suite**: Detailed `CLEANUP_MATRIX.md`, `BENCHMARKS.md`, and `FAQ.md`.
- **Companion PowerShell Engine**: Added `src/DeepClean.ps1` for PowerShell 5.1/7+ environments.

### Changed
- Refactored administrative check to provide user-friendly instructions if non-elevated.
- Improved locked file suppression so running programs are never interrupted.
- Enhanced disk cleanup flags with 20+ registry-backed volume cache targets.

---

## [1.0.0] - 2026-10-24
- Initial release of automated 1-click batch cleanup script.
- Basic user temp and system temp purging.
- cleanmgr StateFlags0064 configuration.
- Basic DNS flush.
