#!/bin/sh
set -eu

ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
cd "$ROOT"

# Ensure the app bundle is built
if [ ! -d "$ROOT/build/DEX_PULSE.app" ]; then
    "$ROOT/scripts/build_app.sh"
fi

USER_APPS="$HOME/Applications"
USER_BIN="$HOME/.local/bin"

mkdir -p "$USER_APPS"
mkdir -p "$USER_BIN"

echo "=== Installing DEX//PULSE for User ($USER) ==="

# Install DEX_PULSE.app to ~/Applications
DEST_APP="$USER_APPS/DEX_PULSE.app"
rm -rf "$DEST_APP"
cp -R "$ROOT/build/DEX_PULSE.app" "$DEST_APP"
echo "✓ Installed application to: $DEST_APP"

# Install dexpulse CLI to ~/.local/bin
RELEASE_CLI="$ROOT/.build/release/dexpulse"
if [ -f "$RELEASE_CLI" ]; then
    cp "$RELEASE_CLI" "$USER_BIN/dexpulse"
    chmod +x "$USER_BIN/dexpulse"
    echo "✓ Installed CLI to: $USER_BIN/dexpulse"
fi

echo ""
echo "Installation complete."
echo "You can launch the app via: open \"$DEST_APP\""
echo "Or run diagnostics: $USER_BIN/dexpulse doctor"
