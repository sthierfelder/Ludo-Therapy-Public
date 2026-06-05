rm /Users/suzy/Documents/ludo-therapy_prod/public/banners/*.webp
node /Users/suzy/Documents/ludo-therapy_prod/scripts/build-banners-from-png.mjs
cd /Users/suzy/Documents/ludo-therapy_prod && npm run build && firebase deploy