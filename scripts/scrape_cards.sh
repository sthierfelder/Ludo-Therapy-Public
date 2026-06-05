#!/bin/bash
# Requires FB_APP_ACCESS_TOKEN env var (format: "{app_id}|{app_secret}").
# Export it locally before running, e.g.:
#   export FB_APP_ACCESS_TOKEN="<app_id>|<app_secret>"
# Never commit the token.
set -euo pipefail

if [ -z "${FB_APP_ACCESS_TOKEN:-}" ]; then
  echo "ERROR: FB_APP_ACCESS_TOKEN env var is not set." >&2
  echo "Export it before running: export FB_APP_ACCESS_TOKEN='<app_id>|<app_secret>'" >&2
  exit 1
fi

for card in life-pattern excuses; do
  echo "Scraping card: $card..."

  curl -s -X POST \
    --data-urlencode "id=https://ludo-therapy.com/share?card=${card}" \
    --data-urlencode "scrape=true" \
    --data-urlencode "access_token=${FB_APP_ACCESS_TOKEN}" \
    "https://graph.facebook.com/"

  echo -e "\n---"
  sleep 1
done
