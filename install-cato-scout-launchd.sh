#!/bin/sh
set -eu

ACTION="${1:-install}"
PKG_DIR="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)"
SCRIPT_SRC="$PKG_DIR/cato-scout-refresh.sh"
PLIST_SRC="$PKG_DIR/com.catonetworks.ai-scout-refresh.plist"
SCRIPT_DST="/usr/local/sbin/cato-scout-refresh.sh"
PLIST_DST="/Library/LaunchDaemons/com.catonetworks.ai-scout-refresh.plist"
TOKEN_DIR="/etc/cato-scout"
TOKEN_FILE="$TOKEN_DIR/token"
LABEL="system/com.catonetworks.ai-scout-refresh"

install_files() {
  [ -f "$SCRIPT_SRC" ] || { echo "missing: $SCRIPT_SRC" >&2; exit 1; }
  [ -f "$PLIST_SRC" ] || { echo "missing: $PLIST_SRC" >&2; exit 1; }
  [ -r "$TOKEN_FILE" ] || { echo "missing token file: $TOKEN_FILE" >&2; exit 1; }

  mkdir -p /usr/local/sbin /Library/LaunchDaemons "$TOKEN_DIR"

  cp "$SCRIPT_SRC" "$SCRIPT_DST"
  chown root:wheel "$SCRIPT_DST"
  chmod 700 "$SCRIPT_DST"

  cp "$PLIST_SRC" "$PLIST_DST"
  chown root:wheel "$PLIST_DST"
  chmod 644 "$PLIST_DST"

  chown root:wheel "$TOKEN_FILE"
  chmod 600 "$TOKEN_FILE"
  chmod 700 "$TOKEN_DIR"

  launchctl bootout system "$PLIST_DST" 2>/dev/null || true
  launchctl bootstrap system "$PLIST_DST"
  launchctl enable "$LABEL"
  launchctl kickstart -k "$LABEL"

  echo "Installed and started: $LABEL"
}

uninstall_files() {
  launchctl bootout system "$PLIST_DST" 2>/dev/null || true
  rm -f "$PLIST_DST"
  rm -f "$SCRIPT_DST"
  echo "Removed launchd plist and wrapper script."
  echo "Token file left in place: $TOKEN_FILE"
}

case "$ACTION" in
  install)
    install_files
    ;;
  uninstall)
    uninstall_files
    ;;
  *)
    echo "Usage: sudo sh ./install-cato-scout-launchd.sh [install|uninstall]" >&2
    exit 1
    ;;
esac
