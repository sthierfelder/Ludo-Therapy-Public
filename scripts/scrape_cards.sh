#!/bin/bash
# Disabling global immediate-exit (-e) to safely handle empty web values or API warnings
set -uo pipefail

# Requires FB_APP_ACCESS_TOKEN env var (format: "{app_id}|{app_secret}") to clear Meta's cache
if [ -z "${FB_APP_ACCESS_TOKEN:-}" ]; then
  echo "⚠️  WARNING: FB_APP_ACCESS_TOKEN env var is not set." >&2
  echo "   The script will force-refresh your server, but it cannot force-refresh Meta's cache." >&2
  echo "   Fix: export FB_APP_ACCESS_TOKEN='<app_id>|<app_secret>'" >&2
  echo "----------------------------------------------------------"
fi

# Complete list of maladaptive schemas and pattern routing cards
CARDS=(
  "abandonment-protocol"
  "life-pattern"
  "excuses"
  "mistrust-abuse"
  "emotional-deprivation"
  "defectiveness-shame"
  "social-isolation"
  "dependence-incompetence"
  "vulnerability-to-harm"
  "enmeshment-undeveloped-self"
  "failure"
  "entitlement-grandiosity"
  "insufficient-self-control"
  "subjugation"
  "self-sacrifice"
  "approval-seeking"
  "negativity-pessimism"
  "emotional-inhibition"
  "unrelenting-standards"
  "punitiveness"
)

echo "=========================================================="
echo "  FORCE-REFRESHING CACHE & AUDITING METADATA (WITH IG)   "
echo "=========================================================="
echo "Processing ${#CARDS[@]} targets..."
echo "----------------------------------------------------------"

TEMP_HTML=$(mktemp)
trap 'rm -f "$TEMP_HTML"' EXIT

# Helper function to parse Open Graph fields securely
extract_meta_property() {
    echo "$(grep -i "property=['\"]$1['\"]" "$TEMP_HTML" | sed -n "s/.*content=['\"]\([^'\"]*\)['\"].*/\1/p" | head -n 1)"
}

# Helper function to parse standard name/metadata fields securely
extract_meta_name() {
    echo "$(grep -i "name=['\"]$1['\"]" "$TEMP_HTML" | sed -n "s/.*content=['\"]\([^'\"]*\)['\"].*/\1/p" | head -n 1)"
}

for card in "${CARDS[@]}"; do
  # Cache busting step 1: Append a random microsecond timestamp to the query parameters.
  # This tricks Nginx, Firebase Hosting, and CDNs into pulling a fresh copy from the backend.
  CACHE_BUSTER=$(date +%s%N)
  INITIAL_URL="https://ludo-therapy.com/share?card=${card}&nocache=${CACHE_BUSTER}"
  
  echo "📥 [1/2] Fetching clean, live server data for: $card"
  
  # Cache busting step 2: Inject strict cache-control headers directly into the curl request
  if ! curl -sL "$INITIAL_URL" \
    -H "Cache-Control: no-cache, no-store, must-revalidate" \
    -H "Pragma: no-cache" \
    -H "Expires: 0" \
    -A "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36" \
    -o "$TEMP_HTML"; then
    echo "   ❌ Connection Error: Could not reach the server."
    echo "----------------------------------------------------------"
    continue
  fi

  # Core Meta Extraction
  OG_TITLE=$(extract_meta_property "og:title")
  OG_DESC=$(extract_meta_property "og:description")
  OG_IMG=$(extract_meta_property "og:image")
  PIN_DESC=$(extract_meta_name "pinterest-description")
  STD_DESC=$(extract_meta_name "description")
  HTML_TITLE=$(grep -i -o '<title>[^<]*</title>' "$TEMP_HTML" | sed 's/<[^>]*>//g' | head -n 1 || echo "")

  # Evaluate fallback presentation strings
  PINTEREST_TITLE="${OG_TITLE:-$HTML_TITLE}"
  [ -z "$PINTEREST_TITLE" ] && PINTEREST_TITLE="Default Platform Title"

  if [ -n "$PIN_DESC" ]; then PINTEREST_FINAL_DESC="$PIN_DESC (via explicit pinterest-description tag)";
  elif [ -n "$STD_DESC" ]; then PINTEREST_FINAL_DESC="$STD_DESC (via structural fallback description tag)";
  elif [ -n "$OG_DESC" ]; then PINTEREST_FINAL_DESC="$OG_DESC (via standard open-graph fallback description)";
  else PINTEREST_FINAL_DESC="Missing card description profile asset."; fi

  if [[ -n "$OG_IMG" && "$OG_IMG" == /* ]]; then FINAL_IMAGE_LINK="https://ludo-therapy.com${OG_IMG}";
  else FINAL_IMAGE_LINK="${OG_IMG:-Missing asset destination link}"; fi

  # Print current live state on server
  echo "   📘 FACEBOOK & INSTAGRAM OPEN GRAPH PREVIEW DATA:"
  echo "      🔹 Title:       ${OG_TITLE:-$HTML_TITLE}"
  echo "      🔹 Description: ${OG_DESC:-No OG description defined}"
  
  echo "   🔴 PINTEREST RICH PIN PREVIEW DATA:"
  echo "      🔹 Title:       $PINTEREST_TITLE"
  echo "      🔹 Description: $PINTEREST_FINAL_DESC"
  
  echo "   🖼️  SHARED PREVIEW MEDIA ASSET (All Platforms):"
  echo "      🔹 Media URL:   $FINAL_IMAGE_LINK"
  
  # Structural context warning helper for Instagram asset delivery
  if [[ "$FINAL_IMAGE_LINK" == *"Missing"* ]]; then
     echo "      ⚠️  ALERT: Missing media asset will break visual cards across Instagram DMs/Threads."
  fi

  # Cache busting step 3: Force Meta / Facebook / Instagram to dump its crawler cache
  if [ -n "${FB_APP_ACCESS_TOKEN:-}" ]; then
    echo "🚀 [2/2] Forcing Meta Ecosystem (FB/IG) to clear cache for this card..."
    
    # FORCED WORKAROUND: Feed the literal share link directly instead of the dashboard link
    FORCED_RAW_URL="https://ludo-therapy.com/share?card=${card}"
    
    fb_response=$(curl -s -X POST \
      "https://graph.facebook.com/v19.0/" \
      --data-urlencode "id=${FORCED_RAW_URL}" \
      -d "scrape=true" \
      -d "access_token=${FB_APP_ACCESS_TOKEN}")
      
    if echo "$fb_response" | grep -q '"error"'; then
      CLEAN_ERR=$(echo "$fb_response" | sed -n 's/.*"message":[^"]*"\([^"]*\)".*/\1/p')
      # Fallback error extractor if JSON structure varies
      [ -z "$CLEAN_ERR" ] && CLEAN_ERR=$(echo "$fb_response" | grep -o '"message":"[^"]*"' | cut -d'"' -f4)
      echo "      ❌ Meta Graph Refresh Failed: ${CLEAN_ERR:-Unknown API Error}"
    else
      echo "      ✅ Meta Database & Instagram Cache Cleared Successfully!"
    fi
  fi

  echo "----------------------------------------------------------"
  sleep 1.5
done

echo "✅ Cache clearance and platform audit sequence completed."