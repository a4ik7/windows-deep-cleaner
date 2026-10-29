# 📊 Performance & Disk Space Benchmarks

Real-world test benchmarks collected across different Windows environments running **Windows Deep Cleaner (WDC)**.

---

## 💻 Test Machine Profiles

### Environment A: Developer Workstation (Windows 11 Pro, 1TB NVMe)
- **Profile**: Active coding workstation with Visual Studio, Docker, Node.js, and regular Windows cumulative updates.
- **Initial Free Space**: 142.30 GB
- **Post-Cleanup Free Space**: 168.85 GB
- **Space Reclaimed**: **+26.55 GB** 🎉
- **Primary Reclaim Sources**: Windows Update Download cache (14.2 GB), Shader caches (4.8 GB), User Temp & npm/pip caches (5.9 GB), Recycle Bin (1.65 GB).

### Environment B: Gaming Rig (Windows 10 Home, 512GB SSD)
- **Profile**: Gaming PC playing AAA titles (Cyberpunk 2077, Modern Warfare, Apex Legends).
- **Initial Free Space**: 38.40 GB
- **Post-Cleanup Free Space**: 52.10 GB
- **Space Reclaimed**: **+13.70 GB** 🎉
- **Primary Reclaim Sources**: DirectX & NVIDIA DXCache (8.2 GB), System Temp (2.4 GB), Delivery Optimization (3.1 GB).

### Environment C: Office Laptop (Windows 11 Home, 256GB SSD)
- **Profile**: General productivity machine (Office 365, Teams, Zoom, Chrome).
- **Initial Free Space**: 45.12 GB
- **Post-Cleanup Free Space**: 53.60 GB
- **Space Reclaimed**: **+8.48 GB** 🎉
- **Primary Reclaim Sources**: User Temp (3.8 GB), INetCache (1.9 GB), Recycle Bin (2.1 GB), Prefetch & Recent (0.68 GB).

---

## ⚡ Execution Speed Comparison

| Cleaner Utility | Average Execution Time | Memory Footprint | Requires Install? |
| :--- | :---: | :---: | :---: |
| **Windows Deep Cleaner (WDC)** | **8 - 18 seconds** | **~2 MB** | ❌ **No (Portable)** |
| Native Windows Disk Cleanup GUI | 45 - 120 seconds | ~35 MB | Pre-installed |
| Commercial 3rd-Party Cleaners | 60 - 180 seconds | 150 - 300 MB | Yes (Installer) |

---

*Note: Disk space reclamation varies based on how long since your last Windows cleanup and system usage patterns.*
