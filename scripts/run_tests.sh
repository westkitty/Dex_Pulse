#!/bin/sh
set -eu

ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
cd "$ROOT"

# Detect toolchain framework paths for CommandLineTools vs Xcode
FRAMEWORK_PATHS=""
LINKER_PATHS=""

CLT_FRAMEWORKS="/Library/Developer/CommandLineTools/Library/Developer/Frameworks"
CLT_USRLIB="/Library/Developer/CommandLineTools/Library/Developer/usr/lib"

if [ -d "$CLT_FRAMEWORKS" ]; then
    FRAMEWORK_PATHS="-Xswiftc -F -Xswiftc $CLT_FRAMEWORKS"
    LINKER_PATHS="-Xlinker -rpath -Xlinker $CLT_FRAMEWORKS -Xlinker -rpath -Xlinker $CLT_USRLIB"
fi

swift test $FRAMEWORK_PATHS $LINKER_PATHS "$@"
