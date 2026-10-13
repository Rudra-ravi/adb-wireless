---
name: adb-wireless
description: Detect, pair, connect, and troubleshoot Android 11+ Wireless Debugging dynamically without hardcoded IPs, ports, or interfaces. Handles mDNS (Avahi/Openscreen), phone hotspots, QR code pairing, and USB-to-wireless transition.
license: Apache-2.0
metadata:
  author: Ravikumar E (Rudra-ravi)
  keywords:
  - adb
  - wireless-debugging
  - android
  - mdns
  - avahi
  - adb-pair
  - adb-connect
  - hotspot
  - openscreen
---

# Android Wireless Debugging CLI & AI Agent Skill (`adb-wireless`)

`adb-wireless` is a single unified CLI tool and AI agent skill for reliably connecting to Android 11+ devices over Wi-Fi without hardcoded IPs, ports, network interfaces, or device serials.

## When to use this skill

- The user wants to connect an Android phone to ADB wirelessly.
- The user is debugging Flutter, React Native, Android native, or running shell commands on an Android phone over Wi-Fi.
- Wireless debugging fails or disconnects because of dynamic ephemeral ports, sleep mode, or router mDNS isolation.
- The computer is connected to the phone's Wi-Fi Hotspot (where mDNS multicast is not forwarded).
- The user needs to pair a new device via a 6-digit code or QR code directly from the terminal.
- An existing USB-connected phone needs to switch to wireless debugging without manual IP lookup.

## Core Capabilities

1. **Active mDNS Resolution (Avahi & OpenScreen)**:
   Does not rely solely on the passive `adb mdns services` table. Actively queries Avahi (`_adb-tls-connect._tcp` and `_adb-tls-pairing._tcp`) to wake up sleepy device radios and resolve exact dynamic TLS ports.
2. **Zero Hardcoding**:
   Dynamically enumerates active network interfaces, gateway routes, ARP neighbors, and advertised mDNS endpoints.
3. **Hotspot & AP-Isolation Fallback**:
   When on a phone hotspot or a Wi-Fi router with client isolation, it dynamically probes candidate IPs (such as the default gateway) for ephemeral TLS ports (30000–49999 and legacy 5555).
4. **Interactive & QR Pairing**:
   Supports pairing via `adb-wireless --pair [CODE]` or zero-typing terminal QR code (`adb-wireless --qr`).
5. **Dynamic USB Bootstrap**:
   `adb-wireless --usb` detects any plugged-in USB phone, reads its Wi-Fi IP directly from device network routing, enables TCP/IP port 5555, and connects wirelessly.
6. **Automatic Stale Device Pruning**:
   Cleans up `offline` or broken endpoints before connecting to avoid `error: more than one device/emulator`.

## Commands Reference

| Command | Action |
| --- | --- |
| `adb-wireless` | Dynamically discover and connect to any wireless debugging device on LAN/hotspot |
| `adb-wireless --auto` | Silent background run (for systemd timer, NetworkManager dispatcher, or CI) |
| `adb-wireless --pair [CODE]` | Auto-detect pairing port and pair with 6-digit pairing code |
| `adb-wireless --qr` | Display ASCII QR code in terminal for instant pairing via phone camera |
| `adb-wireless --usb` | Switch connected USB device to wireless TCP/IP mode dynamically |
| `adb-wireless --reconnect` | Drop existing wireless sessions, prune stale entries, and reconnect freshly |
| `adb-wireless --disconnect`| Disconnect all wireless ADB endpoints |
| `adb-wireless --status` | Display connected devices and all discovered mDNS connect/pairing endpoints |

## Autonomous Troubleshooting Workflow for Agents

When a user reports that ADB cannot find or connect to their wireless device:

1. **Check status**:
   ```bash
   adb-wireless --status
   ```
2. **Attempt dynamic reconnect**:
   ```bash
   adb-wireless --reconnect
   ```
3. **If device was never paired with this computer**:
   - Instruct the user to open:
     `Settings -> Developer options -> Wireless debugging -> Pair device with pairing code`
   - Run:
     ```bash
     adb-wireless --pair <CODE_DISPLAYED_ON_PHONE>
     ```
   - Or display a terminal QR code:
     ```bash
     adb-wireless --qr
     ```
4. **If device is currently connected via USB**:
   - Seamlessly convert to wireless:
     ```bash
     adb-wireless --usb
     ```
5. **Verify active transport**:
   ```bash
   adb devices -l
   ```
   Confirm the device is listed with state `device`.
