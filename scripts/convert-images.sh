#!/usr/bin/env bash
# PNG → WebP batch convert for banners.
# Quality tuned for photographic/painterly art with no visible 2nd-pass artifacts.

set -euo pipefail

SRC_DIR="../assets"
OUT_DIR="../banners"
QUALITY="${QUALITY:-90}"   # override with: QUALITY=92 ./convert-images.sh

mkdir -p "$OUT_DIR"

shopt -s nullglob
for f in "$SRC_DIR"/*.png; do
    filename=$(basename "$f" .png)
    out="$OUT_DIR/${filename}.webp"

    cwebp \
        -q "$QUALITY" \
        -m 6 \
        -sharp_yuv \
        -af \
        -pre 0 \
        -metadata none \
        -mt \
        "$f" -o "$out" \
        2>/dev/null

    in_kb=$(( $(wc -c < "$f") / 1024 ))
    out_kb=$(( $(wc -c < "$out") / 1024 ))
    printf "  %s: %d KiB → %d KiB\n" "$filename" "$in_kb" "$out_kb"
done