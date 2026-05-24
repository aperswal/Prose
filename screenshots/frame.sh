#!/usr/bin/env bash
# Composite every raw iPhone 16 Pro screenshot (1206x2622) in screenshots/raw/
# into the two App Store sizes, matching the existing images/ style:
#   out/iphone/<name>.png  1320x2868  (screen scaled, rounded, soft shadow, indigo bg)
#   out/ipad/<name>.png    2064x2752  (screen centered full size on indigo bg)
#
# Usage: ./frame.sh            # process every png in raw/
#        ./frame.sh 02-highlights   # just one (no extension)
set -euo pipefail

HERE="$(cd "$(dirname "$0")" && pwd)"
# Defaults point at the local capture flow; override RAW/OUT_IPHONE/OUT_IPAD to
# frame an arbitrary batch (e.g. images/v1.1/Originals -> images/v1.1/iPhone).
RAW="${RAW:-$HERE/raw}"
OUT_IPHONE="${OUT_IPHONE:-$HERE/out/iphone}"
OUT_IPAD="${OUT_IPAD:-$HERE/out/ipad}"
mkdir -p "$OUT_IPHONE" "$OUT_IPAD"

INDIGO="srgb(92,115,217)"        # #5C73D9, the app's light-mode tint

# iPhone canvas + how wide the screen sits inside it
IPH_W=1320; IPH_H=2868; SCREEN_W=1084; RADIUS=120

# iPad canvas (screen is placed at native size, centered)
IPAD_W=2064; IPAD_H=2752

frame_one() {
  local src="$1"
  local name; name="$(basename "$src" .png)"

  # --- iPhone: scale screen, round its corners, drop a soft shadow, center on indigo ---
  local rounded; rounded="$(mktemp -t prose_round).png"
  magick "$src" -resize "${SCREEN_W}x" \
    \( +clone -alpha extract \
        -draw "fill black polygon 0,0 0,$RADIUS $RADIUS,0 fill white circle $RADIUS,$RADIUS $RADIUS,0" \
        \( +clone -flip \) -compose Multiply -composite \
        \( +clone -flop \) -compose Multiply -composite \
    \) -alpha off -compose CopyOpacity -composite \
    "$rounded"

  magick -size "${IPH_W}x${IPH_H}" "xc:${INDIGO}" \
    \( "$rounded" \( +clone -background black -shadow 35x18+0+8 \) +swap \
       -background none -layers merge +repage \) \
    -gravity center -compose over -composite \
    "$OUT_IPHONE/$name.png"
  rm -f "$rounded"

  # --- iPad: place the raw screen at native size, centered on indigo ---
  magick -size "${IPAD_W}x${IPAD_H}" "xc:${INDIGO}" \
    "$src" -gravity center -compose over -composite \
    "$OUT_IPAD/$name.png"

  echo "framed $name  ->  iphone/ + ipad/"
}

if [ "${1:-}" != "" ]; then
  frame_one "$RAW/$1.png"
else
  shopt -s nullglob
  found=0
  for f in "$RAW"/*.png; do frame_one "$f"; found=1; done
  [ "$found" = 1 ] || { echo "No PNGs in $RAW. Capture some with ./shot.sh first."; exit 1; }
fi

echo "Done. iPhone -> $OUT_IPHONE   iPad -> $OUT_IPAD"
