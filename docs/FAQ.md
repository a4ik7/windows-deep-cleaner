# Frequently Asked Questions (FAQ)

### 1. Does Windows Deep Cleaner delete any of my personal files?
**No, absolutely not.** Windows Deep Cleaner exclusively targets disposable caches, temporary build artifacts, prefetch hashes, crash dumps, and Windows Update leftovers. Your personal documents, desktop files, downloads folder, browser history, bookmarks, and saved passwords remain 100% untouched.

---

### 2. Is it safe to delete the Prefetch folder?
**Yes.** The `C:\Windows\Prefetch` folder contains trace files created by Windows to optimize initial application load times. Over months and years, it accumulates hundreds of obsolete `.pf` files from uninstalled programs, portable tools, and temporary updaters. 
- Windows will automatically regenerate fresh, optimal `.pf` files for your active daily apps as you launch them.
- Deleting them cleans up thousands of orphaned filesystem inodes and reclaims disk space.

---

### 3. How does the script interact with Windows Settings?
In **Visual Mode** (`deepclean.bat /visual` or Option 2), the script automatically launches:
1. File Explorer to `C:\Windows\Prefetch` so you can watch obsolete entries disappear.
2. Windows Settings directly to the **System > Storage > Temporary Files** page (`ms-settings:storagesettings`).

This gives you a visual view of the cleanup, allowing you to cross-verify the freed space in Windows' official interface while the background engine purges caches simultaneously.

---

### 4. Why does the script require Administrator privileges?
Windows protects system-wide directories such as `C:\Windows\Temp`, `C:\Windows\Prefetch`, and `C:\Windows\SoftwareDistribution` with strict NTFS permissions. Standard user accounts cannot delete files in these folders. The script automatically requests elevation via a standard Windows UAC prompt.

---

### 5. Why are some files skipped during cleanup?
If an application is currently running (e.g., your web browser or Discord), it may hold an exclusive lock on its current active session log in `%temp%`. Windows Deep Cleaner safely ignores locked files without crashing or hanging, ensuring zero interruptions to your active work.

---

### 6. How do I automate Windows Deep Cleaner to run weekly?
You can use Windows Task Scheduler to run the script silently every Sunday:

1. Press `Win + R`, type `taskschd.msc`, and press **Enter**.
2. Click **Create Basic Task...** and name it `Windows Deep Clean`.
3. Set Trigger to **Weekly**.
4. Set Action to **Start a program**.
5. Browse and select your `deepclean.bat` file.
6. In **Add arguments**, enter `/silent` or `/auto`.
7. Check **Run with highest privileges** in the task properties.

---

### 7. What is the difference between this and CCleaner?
- **Zero bloatware**: No background telemetry, no system tray popups, no ads, no upselling.
- **100% Open Source**: You can inspect every single line of code in `deepclean.bat` before running it.
- **Zero dependencies**: No installation required. Runs directly on native Windows commands.
