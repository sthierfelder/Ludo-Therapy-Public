# Ensure the output directory exists

# Batch convert PNGs from assets/ and save as WebP in assets/banners/
for f in ../assets/*.png; do
    [ -e "$f" ] || continue # Check if files exist
    filename=$(basename "$f" .png)
    cwebp -q 80 "$f" -o "../banners/${filename}.webp"
done