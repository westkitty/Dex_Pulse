#!/bin/sh
set -eu

ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
cd "$ROOT/fixtures/visual-references"

echo "=== Verifying DEX//PULSE Visual Fixtures ==="

if command -v shasum >/dev/null 2>&1; then
    shasum -a 256 -c SHA256SUMS.txt
elif command -v sha256sum >/dev/null 2>&1; then
    sha256sum -c SHA256SUMS.txt
else
    echo "error: No SHA-256 verifier found" >&2
    exit 1
fi

echo "✓ Visual fixtures verified cleanly against canonical SHA-256 sums."
