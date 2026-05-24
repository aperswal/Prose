#!/usr/bin/env bash
# Capture the current booted-simulator screen into screenshots/raw/<name>.png
# Usage: ./shot.sh <name>      e.g. ./shot.sh 02-highlights
set -euo pipefail

NAME="${1:-}"
if [ -z "$NAME" ]; then echo "Usage: ./shot.sh <name>"; exit 1; fi

HERE="$(cd "$(dirname "$0")" && pwd)"
OUT="$HERE/raw"
mkdir -p "$OUT"

xcrun simctl io booted screenshot "$OUT/$NAME.png"
echo "Saved $OUT/$NAME.png"
