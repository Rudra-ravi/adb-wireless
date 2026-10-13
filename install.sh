#!/usr/bin/env bash
# install.sh: Installer for adb-wireless
set -euo pipefail

DEST_DIR="${HOME}/.local/bin"
SYSTEMD_USER_DIR="${XDG_CONFIG_HOME:-${HOME}/.config}/systemd/user"
SKILL_DIR="${HOME}/.agents/skills/adb-wireless"
CLAUDE_SKILL_DIR="${HOME}/.claude/skills"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

INSTALL_SYSTEMD=0
INSTALL_SKILL=1

usage() {
  cat <<EOF
Usage: ./install.sh [OPTIONS]

Options:
  --systemd         Install and enable background systemd user service & timer
  --no-skill        Do not install AI agent skill
  --dest <DIR>      Custom installation destination (default: ~/.local/bin)
  -h, --help        Show this help
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --systemd)
      INSTALL_SYSTEMD=1
      shift
      ;;
    --no-skill)
      INSTALL_SKILL=0
      shift
      ;;
    --dest)
      DEST_DIR="$2"
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown option: $1" >&2
      usage >&2
      exit 1
      ;;
  esac
done

echo "==> Installing adb-wireless..."
mkdir -p "$DEST_DIR"
cp -f "${SCRIPT_DIR}/bin/adb-wireless" "${DEST_DIR}/adb-wireless"
chmod +x "${DEST_DIR}/adb-wireless"
echo "  [✓] Installed binary: ${DEST_DIR}/adb-wireless"

# Ensure PATH includes DEST_DIR
if [[ ":$PATH:" != *":$DEST_DIR:"* ]]; then
  echo "  [!] Note: Ensure $DEST_DIR is in your PATH."
fi

# Optional: Systemd user service & timer
if [[ $INSTALL_SYSTEMD -eq 1 ]]; then
  echo "==> Configuring systemd user timer..."
  mkdir -p "$SYSTEMD_USER_DIR"
  cp -f "${SCRIPT_DIR}/systemd/adb-wireless.service" "${SYSTEMD_USER_DIR}/adb-wireless.service"
  cp -f "${SCRIPT_DIR}/systemd/adb-wireless.timer" "${SYSTEMD_USER_DIR}/adb-wireless.timer"
  systemctl --user daemon-reload
  systemctl --user enable --now adb-wireless.timer
  echo "  [✓] Enabled systemd timer: adb-wireless.timer (runs every 5m in background)"
fi

# AI Skill installation
if [[ $INSTALL_SKILL -eq 1 ]]; then
  echo "==> Installing AI agent skill..."
  mkdir -p "$SKILL_DIR"
  cp -f "${SCRIPT_DIR}/skill/SKILL.md" "${SKILL_DIR}/SKILL.md"
  if [[ -d "$CLAUDE_SKILL_DIR" ]]; then
    ln -sfn "$SKILL_DIR" "${CLAUDE_SKILL_DIR}/adb-wireless"
  fi
  echo "  [✓] Installed AI skill: ${SKILL_DIR}/SKILL.md"
fi

# Dependency check
echo ""
echo "==> Checking optional dependencies:"
check_dep() {
  local name="$1" pkg="$2" desc="$3"
  if command -v "$name" >/dev/null 2>&1; then
    printf '  %-14s [found]\n' "$name"
  else
    printf '  %-14s [missing] -> %s (provides %s)\n' "$name" "$pkg" "$desc"
  fi
}

check_dep "adb" "android-tools / platform-tools" "core ADB client"
check_dep "avahi-browse" "avahi-utils" "fast dynamic mDNS resolution"
check_dep "nmap" "nmap" "hotspot & router-isolation fallback probe"
check_dep "qrencode" "qrencode" "terminal QR code pairing"

echo ""
echo "Installation complete! Try running: adb-wireless"
