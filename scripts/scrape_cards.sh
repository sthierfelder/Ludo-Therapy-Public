#!/bin/bash
TOKEN="***REMOVED-FB-APP-TOKEN***"

for card in life-pattern excuses; do
  echo "Scraping card: $card..."
  
  curl -s -X POST \
    --data-urlencode "id=https://ludo-therapy.com/share?card=${card}" \
    --data-urlencode "scrape=true" \
    --data-urlencode "access_token=${TOKEN}" \
    "https://graph.facebook.com/"
    
  echo -e "\n---"
  sleep 1
done
