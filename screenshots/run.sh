#!/usr/bin/env bash
# Boot the iPhone 16 Pro simulator, build Prose, install it, and launch it with
# the demo notes seeded. After this you drive the app by hand in the Simulator
# and grab frames with ./shot.sh, then composite them with ./frame.sh.
#
# Usage: ./run.sh
set -euo pipefail

DEVICE="iPhone 16 Pro"          # raw capture is 1206x2622, matching the existing shots
BUNDLE_ID="Prose.WritingSimply"
SCHEME="WritingSimply"
HERE="$(cd "$(dirname "$0")" && pwd)"
PROJECT="$HERE/../WritingSimply.xcodeproj"
DERIVED="$HERE/.build"

# Resolve the exact simulator UDID so xcodebuild/simctl never guess the wrong one.
UDID="$(xcrun simctl list devices available \
  | grep -E "^[[:space:]]*${DEVICE} \(" | head -1 \
  | grep -oE '[0-9A-Fa-f-]{36}')"
if [ -z "$UDID" ]; then echo "No available simulator named '$DEVICE'"; exit 1; fi
echo "==> $DEVICE = $UDID"

echo "==> Booting"
xcrun simctl boot "$UDID" 2>/dev/null || true
open -a Simulator
xcrun simctl bootstatus "$UDID" -b >/dev/null

echo "==> Forcing light appearance"
xcrun simctl ui "$UDID" appearance light || true

echo "==> Building $SCHEME (this is slow the first time)"
xcodebuild \
  -project "$PROJECT" \
  -scheme "$SCHEME" \
  -configuration Debug \
  -destination "id=$UDID" \
  -derivedDataPath "$DERIVED" \
  -quiet \
  build

APP="$(find "$DERIVED/Build/Products" -maxdepth 2 -name 'Prose.app' -type d | head -1)"
if [ -z "$APP" ]; then echo "Could not find built Prose.app"; exit 1; fi

echo "==> Installing $APP"
xcrun simctl install "$UDID" "$APP"

echo "==> Launching with seeded demo notes"
xcrun simctl terminate "$UDID" "$BUNDLE_ID" 2>/dev/null || true
xcrun simctl launch "$UDID" "$BUNDLE_ID" -SEED_SCREENSHOTS >/dev/null

cat <<'DONE'

Ready. The Simulator now shows Prose with the demo notes loaded.

Capture frames as you go:
  ./shot.sh 01-list          # whatever name you want
  ./shot.sh 02-highlights    # tap the eye first, then the grade chip
Raw frames land in screenshots/raw/.

When you have them all:
  ./frame.sh                 # builds iPhone (1320x2868) + iPad (2064x2752) versions
DONE
