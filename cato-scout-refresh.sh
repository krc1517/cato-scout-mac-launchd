#!/bin/sh
set -eu

TOKEN_FILE="/etc/cato-scout/token"
INSTALL_URL="https://api.aisec.catonetworks.com/ai-scout/installation.sh"
LOG_TAG="cato-scout"
LOCKDIR="/tmp/cato-scout-refresh.lock"

if ! mkdir "$LOCKDIR" 2>/dev/null; then
  logger -t "$LOG_TAG" "another run is already in progress"
  exit 0
fi

cleanup() {
  rmdir "$LOCKDIR" 2>/dev/null || true
}
trap cleanup EXIT INT TERM

if [ ! -r "$TOKEN_FILE" ]; then
  logger -t "$LOG_TAG" "token file missing or unreadable: $TOKEN_FILE"
  exit 1
fi

TOKEN="$(cat "$TOKEN_FILE")"

curl -fsSL \
  -H "Authorization: Bearer ${TOKEN}" \
  "$INSTALL_URL" \
| /bin/sh
