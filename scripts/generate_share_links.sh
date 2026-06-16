#!/bin/bash
set -uo pipefail

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

# Helper function to manual URL-encode names for the Pinterest Intent API
url_encode() {
  local string="${1}"
  local strlen="${#string}"
  local encoded=""
  local pos c o

  for (( pos=0 ; pos<strlen ; pos++ )); do
     c=${string:$pos:1}
     case "$c" in
        [-_.~a-zA-Z0-9] ) o="${c}" ;;
        * )               printf -v o '%%%02X' "'$c"
     esac
     encoded+="${o}"
  done
  echo "${encoded}"
}

echo "=========================================================="
echo "         LUDO-THERAPY SHARE ROUTING GENERATOR             "
echo "=========================================================="
echo "Generating explicit sharing configurations for ${#CARDS[@]} links..."
echo "----------------------------------------------------------"

for card in "${CARDS[@]}"; do
  # 1. Base sharing link structure
  SHARE_URL="https://ludo-therapy.com/share?card=${card}"
  
  # 2. Build human-readable description text for the custom pin attachment
  # Replaces dashes with spaces and capitalizes words for clean display copy
  RAW_NAME=$(echo "$card" | sed 's/-/ /g')
  CLEAN_NAME=$(echo "$RAW_NAME" | awk '{for(i=1;i<=NF;i++)sub(/./,toupper(substr($i,1,1)),$i)}1')
  PIN_TEXT="Discover my psychological profile card: ${CLEAN_NAME} on Ludo-Therapy"
  
  # 3. URL Encode strings to build a working, native Pinterest Share Intent link
  ENV_URL=$(url_encode "$SHARE_URL")
  ENV_TEXT=$(url_encode "$PIN_TEXT")
  PINTEREST_INTENT="https://www.pinterest.com/pin/create/button/?url=${ENV_URL}&description=${ENV_TEXT}"

  # Print organized link registry block
  echo "🃏 CARD IDENTIFIER: $card"
  echo "🔗 Main/Facebook Share Link:"
  echo "   $SHARE_URL"
  echo "📌 Pinterest Direct Share Button Link:"
  echo "   $PINTEREST_INTENT"
  echo "----------------------------------------------------------"
done

echo "✅ Generation complete. All share hooks registered."