# Windows Deep Cleaner — Technical Cleanup Matrix

This document provides a comprehensive, transparent breakdown of every file path, cache location, service interaction, and registry value managed by **Windows Deep Cleaner (WDC)**.

---

## 🗂️ Target Locations & Rationale

| Category | Path / Identifier | Safe to Remove? | Purpose & Impact |
| :--- | :--- | :---: | :--- |
| **User Temporary Files** | `%temp%\*.*`<br>`%LocalAppData%\Temp\*.*` | ✅ **Yes** | Transient scratch files left behind by installers, browsers, and unpacked archives. Reclaims substantial space. |
| **System Temporary Files** | `%SystemRoot%\Temp\*.*`<br>`C:\Windows\Temp\*.*` | ✅ **Yes** | System-level temp files created during Windows updates, driver installations, and service jobs. |
| **Windows Prefetch** | `%SystemRoot%\Prefetch\*.*` | ✅ **Yes** | Application startup traces and ReadyBoot logs. Windows automatically rebuilds optimal prefetch hashes on subsequent launches. |
| **File Explorer Recent Files** | `%AppData%\Microsoft\Windows\Recent\*.*` | ✅ **Yes** | Shortcuts to recently opened files, folders, and documents. Clears private browsing/access footprint. |
| **Automatic Destinations** | `%AppData%\Microsoft\Windows\Recent\AutomaticDestinations\*.*` | ✅ **Yes** | Taskbar and Start menu JumpList tracking databases. |
| **Custom Destinations** | `%AppData%\Microsoft\Windows\Recent\CustomDestinations\*.*` | ✅ **Yes** | Pinned JumpList historical metadata. |
| **DirectX Shader Cache** | `%LocalAppData%\D3DSCache\*.*` | ✅ **Yes** | Compiled DirectX shaders. Purging resolves corrupted game shaders and frees multi-gigabyte caches. |
| **NVIDIA Shader Cache** | `%LocalAppData%\NVIDIA\DXCache\*.*` | ✅ **Yes** | NVIDIA GPU driver compiled graphics shader cache. Driver safely recompiles upon game launch. |
| **AMD Shader Cache** | `%LocalAppData%\AMD\DxCache\*.*` | ✅ **Yes** | AMD Radeon GPU driver compiled shader cache. |
| **Crash Dumps** | `%LocalAppData%\CrashDumps\*.*` | ✅ **Yes** | Application crash memory dumps (`.dmp`) generated during program exceptions. |
| **Windows Error Reporting (WER)** | `%ProgramData%\Microsoft\Windows\WER\*` | ✅ **Yes** | Telemetry logs, queued bug reports, and diagnostic records waiting to sync or archive. |
| **Internet & App Cache** | `%LocalAppData%\Microsoft\Windows\INetCache\*.*` | ✅ **Yes** | Windows HTTP client cache, Edge legacy components, and WebView cache files. |
| **Windows Setup Residuals** | `%SystemRoot%\Panther\*.*`<br>`%SystemRoot%\inf\*.log` | ✅ **Yes** | Installation and setup log leftovers from previous Windows feature upgrades. |
| **Windows Update Packages** | `%SystemRoot%\SoftwareDistribution\Download\*.*` | ✅ **Yes** | Downloaded `.cab` and `.msu` update installation payloads already processed and applied. |
| **Delivery Optimization Files** | `%SystemRoot%\SoftwareDistribution\DeliveryOptimization\*.*` | ✅ **Yes** | P2P local update sharing chunks cached across LAN computers. |
| **Recycle Bin (All Drives)** | `$Recycle.Bin` across all logical drives | ✅ **Yes** | Completely purges deleted files across C:, D:, E: and external drives permanently. |
| **DNS Resolver Cache** | `ipconfig /flushdns` | ✅ **Yes** | Clears cached domain name lookups. Resolves stale network routing and DNS poisoning. |

---

## ⚙️ Windows Settings & Storage Sense Backend Integration

Windows Deep Cleaner automates the native Windows `cleanmgr.exe` storage engine using pre-configured `StateFlags0064` in:

```registry
HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches
```

The script enables cleanup flags (`REG_DWORD = 2`) across 20+ Windows native volume cache subkeys:
1. `Active Setup Temp Folders`
2. `Delivery Optimization Files`
3. `Diagnostic Data Viewer database files`
4. `Downloaded Program Files`
5. `Internet Cache Files`
6. `Old ChkDsk Files`
7. `Previous Installations` (`Windows.old` leftovers)
8. `Recycle Bin`
9. `RetailDemo Offline Content`
10. `Setup Log Files`
11. `System error memory dump files`
12. `System error minidump files`
13. `Temporary Files`
14. `Temporary Setup Files`
15. `Thumbnail Cache`
16. `Update Cleanup`
17. `Upgrade Discarded Files`
18. `Windows Defender`
19. `Windows Error Reporting Files`
20. `Windows Upgrade Log Files`

Running `cleanmgr.exe /sagerun:64` triggers Windows' low-level kernel disk compression and cleanup algorithms with zero pop-up friction.

---

## 🛡️ Safety Guarantees

- **No Personal Data Touched**: Documents, Pictures, Videos, Desktop, Downloads, and user registry hives are completely untouched.
- **Active Process Protection**: Locked files currently open by running software are safely bypassed with graceful exception handling (`>nul 2>&1`), preventing system crashes or hung processes.
- **Service State Preservation**: Windows Update services (`wuauserv`, `bits`, `dosvc`) are cleanly stopped before deleting update downloads and immediately restarted afterward.
