#!/usr/bin/env bash
set -euo pipefail

# Kimi Desktop for Ubuntu 26.04+ — Rebuild script
# Rebuilds the .deb from Pake v3 using Tauri v2 (webkit2gtk-4.1)
#
# Prerequisites:
#   - Node.js >= 22
#   - Rust >= 1.85
#   - pake-cli (npm install -g pake-cli)
#   - libwebkit2gtk-4.1-dev, libgtk-3-dev, libayatana-appindicator3-dev, librsvg2-dev

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
CONFIG_DIR="$SCRIPT_DIR/config"
OUTPUT_DIR="$SCRIPT_DIR/dist"

echo "==> Rebuilding Kimi desktop app (Pake v3 / Tauri v2)..."

# Ensure pake-cli is installed
if ! command -v pake &>/dev/null; then
    echo "ERROR: pake-cli not found. Install with: npm install -g pake-cli"
    exit 1
fi

# Rebuild with --new-window for OAuth/SSO support
pake https://kimi.moonshot.cn \
    --name Kimi \
    --width 1200 \
    --height 780 \
    --new-window \
    --targets deb

# Find and copy the built .deb to dist/
mkdir -p "$OUTPUT_DIR"
DEB_PATH="$(find /home/johnohhh1/.npm-global/lib/node_modules/pake-cli/src-tauri -name "kimi*.deb" -path "*/bundle/deb/*" | head -1)"
if [ -z "$DEB_PATH" ]; then
    # Try alternate location (Pake copies it next to the source tree)
    DEB_PATH="$(find /home/johnohhh1 -maxdepth 4 -name "kimi*.deb" -newer "$0" 2>/dev/null | head -1)"
fi

if [ -n "$DEB_PATH" ]; then
    cp "$DEB_PATH" "$OUTPUT_DIR/"
    echo "==> .deb copied to: $OUTPUT_DIR/$(basename "$DEB_PATH")"
    echo "==> Install with: sudo dpkg -i $OUTPUT_DIR/$(basename "$DEB_PATH")"
else
    echo "WARNING: Could not locate built .deb file. Check Pake output above."
    exit 1
fi