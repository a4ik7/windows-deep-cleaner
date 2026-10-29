# Contributing to Windows Deep Cleaner

First off, thank you for considering contributing to **Windows Deep Cleaner**! It's people like you that make open-source software incredible.

---

## 📋 Table of Contents
- [Code of Conduct](#code-of-conduct)
- [How Can I Contribute?](#how-can-i-contribute)
  - [Reporting Bugs](#reporting-bugs)
  - [Suggesting Features](#suggesting-features)
  - [Pull Requests](#pull-requests)
- [Development Guidelines](#development-guidelines)
- [Commit Message Conventions](#commit-message-conventions)

---

## 📜 Code of Conduct
This project and everyone participating in it is governed by our [Code of Conduct](CODE_OF_CONDUCT.md). By participating, you are expected to uphold this code.

---

## 💡 How Can I Contribute?

### Reporting Bugs
If you encounter an issue or an unexpected behavior on your Windows version:
1. Check the [Issues tab](https://github.com/abhigyansati/windows-deep-cleaner/issues) to make sure the bug hasn't already been reported.
2. If not, open a new issue using our **Bug Report Template**.
3. Include your exact Windows build (`winver`), script output or error logs, and whether you ran it in Administrator mode.

### Suggesting Features
Got an idea for another safe cache to purge or a useful CLI flag?
1. Open an issue using our **Feature Request Template**.
2. Explain the rationale: Which cache/location does it target? Is it completely safe for end users? How much disk space does it typically reclaim?

### Pull Requests
1. Fork the repository and create your branch from `main`:
   ```bash
   git checkout -b feature/amazing-cleanup-target
   ```
2. Test your changes thoroughly on Windows 10 and Windows 11.
3. Ensure no personal user files (`Desktop`, `Documents`, `Downloads`) are touched.
4. Keep syntax clean, compatible with Windows Command Prompt (`cmd.exe`) and PowerShell 5.1+.
5. Submit your Pull Request with a clear explanation of what was added or fixed.

---

## 🛠️ Development Guidelines
- **Idempotency**: All cleanup steps must be idempotent (safe to run multiple times without errors).
- **Graceful Failure**: Never assume a file or directory exists. Always suppress or catch locked-file errors with `>nul 2>&1` or `-ErrorAction SilentlyContinue`.
- **Zero Dependencies**: Keep the core `deepclean.bat` script strictly dependent on native Windows binaries (`del`, `rmdir`, `cleanmgr.exe`, `ipconfig`, `powershell.exe`).

---

## 💬 Community & Questions
Feel free to open a [Discussion](https://github.com/abhigyansati/windows-deep-cleaner/discussions) or reach out to project author **Abhigyan Sati**.
