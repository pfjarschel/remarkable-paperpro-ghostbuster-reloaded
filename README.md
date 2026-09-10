# GhostBuster for reMarkable Paper Pro (Gallery 3)

**Eliminate severe color/black ghosting on early-batch reMarkable Paper Pro tablets without sacrificing writing latency.**

---

## 📖 The Problem

Early manufacturing batches of the **reMarkable Paper Pro** featured first-generation E Ink Gallery 3 (AceP 2) color panels. While these panels worked well at launch, recent firmware updates introduced aggressive partial refresh strategies to make the UI feel "snappier."

For newer hardware revisions with updated display characteristics, this works fine. But on earlier hardware, frequent partial refreshes leave behind **severe green and black ghosting artifacts** across the screen when:
* Turning pages or navigating hyperlinks in PDFs and notebooks
* Opening and closing the Settings menu
* Erasing handwritten strokes with the Marker / Marker Plus
* Navigating between views

Because many users bought their devices second-hand or live in countries where reMarkable does not offer warranty replacements, many were left with severely compromised devices.

---

## 💡 The Solution

**GhostBuster** is a lightweight, non-invasive extension built for `qt-resource-rebuilder` (via `XOVI`). It patches the high-level QML UI layer to trigger native hardware full-waveform clears (`GhostBuster_Gallery3`) at the exact moments when ghosting occurs.

* **Zero pen latency impact**: Drawing and writing speed are 100% untouched.
* **100% Non-invasive & Safe**: Lives completely in userland memory (`/home/root/xovi/`). **Never modifies read-only rootfs partitions or system binaries**.
* **Completely reversible**: Uninstalling is as simple as running `./uninstall.sh`.
* **Modular Design**: Choose only the modules you want.

---

## 🧩 Modules Overview

| Module | Status | Description |
| :--- | :--- | :--- |
| **Page Turns & Navigation** | **Recommended** (Default: Yes) | Asynchronous-aware refresh: waits until views finish rendering before clearing on page flips, fast scrolling, link jumps, and library folder navigation. |
| **Settings Menu** | **Recommended** (Default: Yes) | Debounces the refresh by 400ms when opening and closing device Settings and document settings (PDF/notebook/ebook) so views completely paint before refreshing. |
| **Stylus Eraser** | Optional (Default: No) | Triggers a full refresh ~400ms after you lift the eraser. Great if your panel exhibits heavy ghosting specifically after erasing strokes. |
| **5-Finger Gesture** | Optional (Default: No) | Enables a system-wide 5-finger screen tap gesture anywhere (Library, Documents, Settings) for an immediate manual hardware clear without interfering with single-finger touch. |

> **Why are only Page and Settings recommended by default?**  
> For most users, page navigation and settings transitions represent 99% of ghosting triggers. Keeping the eraser module optional preserves maximum snappiness during rapid note-taking, and the 5-finger gesture is rarely needed once automated clears are running.

---

## 📋 Prerequisites

1. A **reMarkable Paper Pro** running firmware `3.28.x` (tested on `3.28.0.169`).
2. SSH access enabled on your tablet (via USB or Wi-Fi).
3. **[XOVI](https://github.com/asivery/xovi)** and **qt-resource-rebuilder** installed on the device.

---

## 🚀 Quick Start (Installation)

Connect your Paper Pro via USB (or Wi-Fi), clone this repository, and run the interactive installer:

```bash
git clone https://github.com/pfjarschel/remarkable-paperpro-ghostbuster-reloaded.git
cd remarkable-paperpro-ghostbuster-reloaded
./install.sh
```

The installer will guide you through each module and allow you to toggle them.

### Automated / Non-interactive Install

To install the recommended defaults (Page + Settings) automatically without prompts:

```bash
./install.sh -y
```

*(Optional: pass device IP if connecting over Wi-Fi: `./install.sh 192.168.1.xxx`)*

---

## 🗑️ Uninstallation

To remove all GhostBuster modules and restore stock behavior:

```bash
./uninstall.sh
```

---

## 🛠️ Building & Porting to Newer Firmware

The human-readable source diffs are located in `src/`. To compile/hash them for different firmware versions:

1. Extract the firmware's `hashtab` using `qmldiff` or copy `/home/root/xovi/exthome/qt-resource-rebuilder/hashtab` from your tablet.
2. Install [`qmldiff`](https://github.com/asivery/qmldiff).
3. Run:
   ```bash
   qmldiff check-compatibility hashtab src/*.qmd
   qmldiff hash-diffs hashtab src/*.qmd
   ```

---

## 📜 Credits & Acknowledgments

* Special thanks to **[asivery](https://github.com/asivery)** for creating `XOVI`, `qt-resource-rebuilder`, and `qmldiff`.
* The reMarkable modding community.

---

## 📄 License

GPL-3.0 License.
