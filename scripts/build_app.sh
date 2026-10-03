#!/bin/sh
set -eu

ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
cd "$ROOT"

CONFIGURATION="release"
BUILD_DIR="$ROOT/build"
APP_NAME="DEX_PULSE.app"
APP_BUNDLE="$BUILD_DIR/$APP_NAME"
CONTENTS="$APP_BUNDLE/Contents"
MACOS_DIR="$CONTENTS/MacOS"
RESOURCES_DIR="$CONTENTS/Resources"

echo "=== Building DEX//PULSE Native Application Bundle ($CONFIGURATION) ==="

# Build the release binaries via Swift Package Manager
swift build -c "$CONFIGURATION" --product DexPulseApp
swift build -c "$CONFIGURATION" --product dexpulse
swift build -c "$CONFIGURATION" --product PulseVerification

BIN_DIR="$ROOT/.build/$CONFIGURATION"

# Assemble .app bundle layout
rm -rf "$APP_BUNDLE"
mkdir -p "$MACOS_DIR"
mkdir -p "$RESOURCES_DIR"

# Copy binary
cp "$BIN_DIR/DexPulseApp" "$MACOS_DIR/DexPulseApp"
chmod +x "$MACOS_DIR/DexPulseApp"

# Write Info.plist
cat <<EOF > "$CONTENTS/Info.plist"
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleIdentifier</key>
    <string>com.westkitty.dexpulse</string>
    <key>CFBundleName</key>
    <string>DEX_PULSE</string>
    <key>CFBundleDisplayName</key>
    <string>DEX//PULSE</string>
    <key>CFBundleExecutable</key>
    <string>DexPulseApp</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>CFBundleShortVersionString</key>
    <string>0.1.0</string>
    <key>CFBundleVersion</key>
    <string>1</string>
    <key>LSMinimumSystemVersion</key>
    <string>14.0</string>
    <key>LSUIElement</key>
    <true/>
    <key>NSHighResolutionCapable</key>
    <true/>
</dict>
</plist>
EOF

# Write PkgInfo
echo -n "APPL????" > "$CONTENTS/PkgInfo"

# Ad-hoc codesign the bundle
if command -v codesign >/dev/null 2>&1; then
    codesign --force --deep --sign - "$APP_BUNDLE"
fi

echo "✓ Native application bundle built successfully at: $APP_BUNDLE"
codesign -dv "$APP_BUNDLE" 2>&1 | grep -E "Identifier|Format|Signature" || true
