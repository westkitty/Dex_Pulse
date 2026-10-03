#!/bin/sh
set -eu
ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
cd "$ROOT"

required='README.md PROJECT_BIBLE.md OPERATIONAL_STATE.md MASTER_IMPLEMENTATION_PLAN.md PROJECT_SYSTEM_INSTRUCTION.md docs/V1_ACCEPTANCE_MATRIX.md docs/PERFORMANCE_BUDGETS.md docs/DEXDICTATE_COEXISTENCE.md docs/VISUAL_LANGUAGE.md docs/VISUAL_REFERENCE_MANIFEST.md fixtures/visual-references/SHA256SUMS.txt'
for f in $required; do
  test -f "$f" || { echo "missing: $f" >&2; exit 1; }
done

chars=$(wc -m < PROJECT_SYSTEM_INSTRUCTION.md | tr -d ' ')
if [ "$chars" -gt 5000 ]; then
  echo "PROJECT_SYSTEM_INSTRUCTION.md exceeds internal 5000-character budget: $chars" >&2
  exit 1
fi

# Public-source guard: reject obvious private-home paths or secret-file patterns in tracked planning text.
if grep -R -n -E '/Users/(andrew|bigmac)/|BEGIN (RSA|OPENSSH|EC) PRIVATE KEY|sk-[A-Za-z0-9_-]{20,}' \
  --exclude-dir='.build' --exclude-dir='build' --exclude-dir='.git' \
  --include='*.md' --include='*.json' --include='*.swift' --include='*.sh' .; then
  echo "planning source contains a forbidden private-path/secret pattern" >&2
  exit 1
fi

if command -v shasum >/dev/null 2>&1; then
  (cd fixtures/visual-references && shasum -a 256 -c SHA256SUMS.txt)
elif command -v sha256sum >/dev/null 2>&1; then
  (cd fixtures/visual-references && sha256sum -c SHA256SUMS.txt)
else
  echo "warning: no SHA-256 verifier found" >&2
fi

echo "planning source OK; project instruction chars=$chars"
