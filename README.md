# adb-wireless 📶⚡

[![License: Apache 2.0](https://img.shields.io/badge/License-Apache_2.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)
[![Shell: Bash](https://img.shields.io/badge/Shell-Bash-4EAA25.svg)](https://www.gnu.org/software/bash/)
[![Platform: Linux](https://img.shields.io/badge/Platform-Linux-FCC624.svg)](https://kernel.org)
[![Android: 11+](https://img.shields.io/badge/Android-11%2B-3DDC84.svg)](https://developer.android.com/tools/adb#wireless)

> **Zero hardcoded IPs, ports, interfaces, or SSIDs.**  
> A single, rock-solid CLI tool and AI Agent Skill that reliably detects, pairs, and connects to Android 11+ Wireless Debugging devices across local Wi-Fi and mobile hotspots.

---

## 🎯 The Problem

Android 11+ introduced modern Wireless Debugging over TLS, but on Linux and developer workstations it frequently breaks:

1. **mDNS Daemon Conflict**: The ADB server's internal OpenScreen mDNS table frequently returns empty when Linux's system `avahi-daemon` is listening on port 5353.
2. **Ephemeral Dynamic Ports**: Every time Wireless Debugging is toggled or the phone reconnects, Android assigns a random high port (`30000–49999`). Static scripts hardcoding ports or relying on `5555` fail.
3. **Wi-Fi Router AP Isolation**: Many office and home routers drop multicast mDNS packets between wireless clients, preventing standard discovery.
4. **Mobile Hotspots**: When a developer connects their laptop to their phone's Wi-Fi hotspot, the phone is the default gateway but usually does not advertise mDNS across its tethering interface, and port 5555 is closed.
5. **Ghost & Stale Devices**: Old connections linger as `offline` in ADB's transport table, triggering `error: more than one device/emulator`.

`adb-wireless` solves all of these with a 4-tier dynamic discovery pipeline.

---

## 🏗️ How It Works (4-Tier Dynamic Discovery)

```text
[ Trigger: CLI / Background Systemd / AI Agent ]
                       │
                       ▼
    [ Stage 1: Health Check & Stale Cleanup ]
    • Tests active device responsiveness via `adb get-state`
    • Automatically prunes dead / `offline` transports
                       │
                       ▼
    [ Tier 1: Active Multi-Source mDNS ]
    • Actively queries Avahi: `avahi-browse _adb-tls-connect._tcp`
    • Cross-checks native ADB mDNS: `adb mdns services`
    • Immediately resolves dynamic IP and TLS port
                       │ (if mDNS blocked by router AP isolation)
                       ▼
    [ Tier 2: Dynamic LAN & Hotspot Fallback ]
    • Inspects active interface routing and neighbor tables
    • Inspects default gateway (for tethered phone hotspot mode)
    • Performs ultra-fast targeted probe (`nmap -T5 --min-rate 5000` on 30000–49999 & 5555)
                       │ (if phone is plugged into USB)
                       ▼
    [ Tier 3: Dynamic USB Bootstrap ]
    • Detects plugged-in USB phone
    • Queries device's Wi-Fi IP dynamically via device route table
    • Switches device to wireless mode (`adb -s <serial> tcpip 5555`) and connects
```

---

## 🚀 Quick Install

### 1. One-Line Git Install

```bash
git clone https://github.com/Rudra-ravi/adb-wireless.git
cd adb-wireless
./install.sh --systemd
```

### 2. Manual Install

Copy `bin/adb-wireless` anywhere in your `$PATH` (e.g. `~/.local/bin/` or `/usr/local/bin/`):

```bash
cp bin/adb-wireless ~/.local/bin/adb-wireless
chmod +x ~/.local/bin/adb-wireless
```

### Optional Dependencies

For maximum speed and all features:
- **`avahi-utils`** (`avahi-browse`): Instant dynamic mDNS resolution.
- **`nmap`**: Ultra-fast fallback port discovery when routers block mDNS or on phone hotspots.
- **`qrencode`**: Zero-typing QR code pairing directly in your terminal.

On Arch Linux:
```bash
sudo pacman -S android-tools avahi nmap qrencode
```

On Ubuntu / Debian:
```bash
sudo apt update && sudo apt install -y adb avahi-utils nmap qrencode
```

---

## 💻 CLI Usage

### Automatic Connect (Zero-Conf)
```bash
adb-wireless
```
Scans the network, finds your phone, prunes stale endpoints, and connects.

### Show Status & Endpoints
```bash
adb-wireless --status
```
Displays connected ADB devices alongside all discovered connect and pairing mDNS endpoints.

### Pairing with 6-Digit Code
```bash
# Auto-detects pairing port, prompts for code:
adb-wireless --pair

# Or provide the code directly:
adb-wireless --pair 123456
```

### Pairing with Terminal QR Code (Zero Typing)
```bash
adb-wireless --qr
```
Renders an ASCII QR code in your terminal. On your phone, go to **Settings → Developer options → Wireless debugging → Pair device with QR code** and scan your terminal screen.

### USB-to-Wireless Bootstrap
```bash
adb-wireless --usb
```
If your phone is plugged in via USB, this reads the phone's Wi-Fi IP directly from device routing, enables TCP mode, and connects wirelessly.

### Force Reconnect / Disconnect
```bash
adb-wireless --reconnect    # Drops existing connections and forces a fresh scan
adb-wireless --disconnect   # Disconnects all wireless ADB sessions
```

---

## 🤖 AI Agent Skill (`SKILL.md`)

`adb-wireless` includes a built-in AI Agent Skill specification for AI assistants like **Claude Code**, **Cursor**, **Windsurf**, and **OpenCode / OMP**.

The installer automatically installs the skill into `~/.agents/skills/adb-wireless/SKILL.md` and links it for Claude Code.

AI agents can run:
```bash
adb-wireless
```
to automatically resolve ADB wireless connectivity without needing manual user intervention.

---

## ⚙️ Background Auto-Connect (Systemd)

If you enable `--systemd` during installation:
- `adb-wireless.service` connects at login.
- `adb-wireless.timer` retries every 5 minutes in the background, keeping your development device connected whenever you sit down at your workstation.

Check status with:
```bash
systemctl --user status adb-wireless.timer
```

---

## 📄 License

Licensed under the [Apache License, Version 2.0](LICENSE).  
Authored by **Ravikumar E ([@Rudra-ravi](https://github.com/Rudra-ravi))**.
