# GhostBuster for reMarkable Paper Pro (Gallery 3)

**Eliminate severe color/black ghosting on early-batch reMarkable Paper Pro tablets without sacrificing writing latency.**

---

## 📖 The Problem

Early manufacturing batches of the **reMarkable Paper Pro** featured first-generation E Ink Gallery 3 (AceP 2) color panels. While these panels worked well at launch, recent firmware updates introduced aggressive partial refresh strategies to make the UI feel "snappier."

For newer hardware revisions with updated display characteristics, this works fine. But on earlier hardware, frequent partial refreshes leave behind **severe green and black ghosting artifacts** across the screen when:
* Erasing handwritten strokes with the Marker / Marker Plus
* Turning pages or navigating hyperlinks in PDFs and notebooks
* Opening and closing the Settings menu
* Navigating between views

Because many users bought their devices second-hand or live in countries where reMarkable does not offer warranty replacements, many users were left with severely compromised devices.

---

## 💡 The Solution

**GhostBuster** is a lightweight, non-invasive extension built for `qt-resource-rebuilder` (via `XOVI`). It patches the high-level QML UI layer to trigger native hardware full-waveform clears (`GhostBuster_Gallery3`) at the exact moments when ghosting occurs.

* **Zero pen latency impact**: Drawing and writing speed are 100% untouched.
* **100% Non-invasive & Safe**: Lives completely in userland memory (`/home/root/xovi/`). **Never modifies read-only rootfs partitions or system binaries**.
* **Completely reversible**: Uninstalling is as simple as deleting the `.qmd` files and restarting `xochitl`.

---

## ✨ Features

1. **🧹 Immediate Stylus Eraser Auto-Clear**
   * Automatically triggers a full waveform refresh ~400ms after you lift the eraser.
   * Works with the eraser tool in the toolbar and the back eraser of the Marker Plus.
2. **📖 Smart Page Turn & Hyperlink Clear**
   * Listens to the asynchronous document tile rendering engine (`isLoading`).
   * When you flip pages or click heavy PDF hyperlinks, it waits until all destination tiles are completely drawn before clearing—preventing premature refresh flashes.
3. **⚙️ Settings Menu Debounced Clear**
   * Debounces the screen clear by 400ms when opening and closing Settings, giving the UI time to paint before refreshing.
4. **🖐️ 5-Finger Document Force Clear Gesture**
   * Re-enables reMarkable's native 5-finger screen tap gesture inside documents for a manual hardware clear whenever you want one.
5. **👆 Completely Unobstructed Touch**
   * Library, folders, books, sidebar menus, and bezel swipe gestures remain completely natural and responsive.

---

## 📋 Prerequisites

1. A **reMarkable Paper Pro** running firmware `3.28.x` (tested and confirmed on `3.28.0.169`).
2. SSH access enabled on your tablet (via USB or Wi-Fi).
3. **[XOVI](https://github.com/asivery/xovi)** and **qt-resource-rebuilder** installed on the device.

---

## 🚀 Quick Start (Installation)

### Automatic Installation

Connect your Paper Pro via USB (or Wi-Fi), clone this repository, and run:

```bash
git clone https://github.com/YOUR_USERNAME/remarkable-paper-pro-ghostbuster.git
cd remarkable-paper-pro-ghostbuster
./install.sh
```

*(Optional: pass device IP if connecting over Wi-Fi: `./install.sh 192.168.1.xxx`)*

### Manual Installation

If you prefer copying manually:

```bash
# Copy pre-hashed diffs to qt-resource-rebuilder
scp dist/3.28.0.169/*.qmd root@10.11.99.1:/home/root/xovi/exthome/qt-resource-rebuilder/

# Restart xochitl via XOVI
ssh root@10.11.99.1 "/home/root/xovi/start"
```

---

## 🗑️ Uninstallation

Run:
```bash
./uninstall.sh
```

Or manually delete the extensions from the device:
```bash
ssh root@10.11.99.1 "rm -f /home/root/xovi/exthome/qt-resource-rebuilder/ghostbuster-*.qmd && /home/root/xovi/start"
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
