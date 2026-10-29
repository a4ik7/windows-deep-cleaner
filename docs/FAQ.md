# Frequently Asked Questions (FAQ)

### 1. Does Windows Deep Cleaner touch personal files or browser data?
**No.** WDC strictly targets system and user scratch directories (`%temp%`, `C:\Windows\Temp`), prefetch caches, shader binaries, crash dumps, and update installer leftovers. It does not touch personal documents, desktop files, downloads, browser cookies, history, or saved passwords.

---

### 2. Is deleting the Prefetch folder safe?
**Yes.** The `C:\Windows\Prefetch` folder contains trace files created by Windows Cache Manager to optimize initial launch times of programs.
- Over time, it retains hundreds of stale `.pf` files from deleted programs, temporary updaters, and single-use executables.
- Deleting them cleans up orphaned filesystem records. Windows automatically generates fresh `.pf` files for your active applications when you launch them.

---

### 3. How does Visual Mode interact with Windows Settings?
In **Visual Mode** (`deepclean.bat /visual` or Option 2 from the menu):
1. File Explorer opens directly at `C:\Windows\Prefetch` so you can observe the directory.
2. Windows Settings opens to **System > Storage > Temporary Files** (`ms-settings:storagesettings`).

This allows you to visually verify Windows' storage analysis while the background engine purges caches simultaneously.

---

### 4. Why does the script require Administrator privileges?
Folders like `C:\Windows\System32`, `C:\Windows\Prefetch`, `C:\Windows\Temp`, and `C:\Windows\SoftwareDistribution` are owned by `NT SERVICE\TrustedInstaller` or `SYSTEM` with restrictive DACLs. Modifying or deleting files in these locations requires an elevated security token (`SeDebugPrivilege` / Administrative group membership).

---

### 5. Why are some files skipped during execution?
If a program is running (e.g., Discord or an active Chrome tab), it holds an exclusive file lock on its runtime log in `%temp%`. WDC safely ignores locked files (`>nul 2>&1`), ensuring running applications never crash.

---

### 6. Can this be automated with Windows Task Scheduler?
Yes. WDC includes a headless `/silent` flag designed for automated maintenance tasks:

```powershell
schtasks /create /tn "WindowsDeepClean" /tr "C:\path\to\deepclean.bat /silent" /sc weekly /d SUN /st 02:00 /rl highest
```

---

### 7. How does this compare to third-party cleaners like CCleaner?
- **Zero Third-Party Binaries**: Runs entirely on native Windows utilities (`del`, `cleanmgr.exe`, `powershell.exe`).
- **Zero Background Services**: No daemons running in the system tray, no telemetry, and no auto-updaters.
- **Full Transparency**: Every single line of code is open-source and auditable before execution.
