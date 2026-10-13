#!/usr/bin/env bash
# uninstall.sh: Clean uninstaller for adb-wireless
set -euo pipefail

DEST_DIR="${HOME}/.local/bin"
SYSTEMD_USER_DIR="${XDG_CONFIG_HOME:-${HOME}/.config}/systemd/user"
SKILL_DIR="${HOME}/.agents/skills/adb-wireless"
CLAUDE_SKILL_LINK="${HOME}/.claude/skills/adb-wireless"

echo "==> Uninstalling adb-wireless..."

if systemctl --user is-active --quiet adb-wireless.timer 2>/dev/null; then
  systemctl --user stop adb-wireless.timer adb-wireless.service 2>/dev/null || true
  systemctl --user disable adb-wireless.timer 2>/dev/null || true
fi

rm -f "${DEST_DIR}/adb-wireless"
rm -f "${SYSTEMD_USER_DIR}/adb-wireless.service" "${SYSTEMD_USER_DIR}/adb-wireless.timer"
rm -rf "$SKILL_DIR" "$CLAUDE_SKILL_LINK"
systemctl --user daemon-reload 2>/dev/null || true

echo "[✓] Uninstalled successfully."
