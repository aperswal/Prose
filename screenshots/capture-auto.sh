#!/usr/bin/env bash
# Run the capture UI test, then pull its screenshot attachments into raw/.
# This grabs the interaction-heavy shots (eye on, legend popover) deterministically
# so you do not have to tap them by hand. Then run ./frame.sh.
#
# Usage: ./capture-auto.sh
set -euo pipefail

DEVICE="iPhone 16 Pro"
SCHEME="WritingSimply"
HERE="$(cd "$(dirname "$0")" && pwd)"
PROJECT="$HERE/../WritingSimply.xcodeproj"
DERIVED="$HERE/.build"
RESULT="$HERE/.result.xcresult"
RAW="$HERE/raw"
EXPORT="$HERE/.export"

UDID="$(xcrun simctl list devices available \
  | grep -E "^[[:space:]]*${DEVICE} \(" | head -1 \
  | grep -oE '[0-9A-Fa-f-]{36}')"
if [ -z "$UDID" ]; then echo "No available simulator named '$DEVICE'"; exit 1; fi

xcrun simctl boot "$UDID" 2>/dev/null || true
xcrun simctl bootstatus "$UDID" -b >/dev/null
xcrun simctl ui "$UDID" appearance light || true

rm -rf "$RESULT" "$EXPORT"
mkdir -p "$RAW" "$EXPORT"

echo "==> Running capture test"
xcodebuild test \
  -project "$PROJECT" \
  -scheme "$SCHEME" \
  -destination "id=$UDID" \
  -derivedDataPath "$DERIVED" \
  -only-testing:WritingSimplyUITests/ScreenshotCaptureUITests/test_captureHighlights \
  -resultBundlePath "$RESULT" \
  -quiet

echo "==> Exporting screenshots"
xcrun xcresulttool export attachments --path "$RESULT" --output-path "$EXPORT" >/dev/null

python3 - "$EXPORT" "$RAW" <<'PY'
import json, os, sys, shutil
export, raw = sys.argv[1], sys.argv[2]
manifest = json.load(open(os.path.join(export, "manifest.json")))
count = 0
for entry in manifest:
    for a in entry.get("attachments", []):
        name = a.get("suggestedHumanReadableName") or a["exportedFileName"]
        if not name.lower().endswith(".png"):
            name += ".png"
        src = os.path.join(export, a["exportedFileName"])
        if os.path.exists(src):
            shutil.copy(src, os.path.join(raw, name))
            print("  raw/%s" % name)
            count += 1
print("exported %d screenshots" % count)
PY

rm -rf "$EXPORT"
echo "Done. Now: ./frame.sh"
