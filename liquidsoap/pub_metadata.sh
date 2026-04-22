#!/bin/bash

TITLE=$1

if [ "$RAILS_ENV" == "development" ]; then
  URL="http://rails:3000/publish_metadata.json"
else
  URL="https://$RADIO_NAME.streampusher.com/publish_metadata.json"
fi

ESCAPED_TITLE=$(printf '%s' "$TITLE" | jq -s -Rr @json)

result=$(curl -s -H "Accept: application/json" -H "Content-type: application/json" -H "liq-secret: $LIQ_SECRET" -X POST -d "{\"metadata\": $ESCAPED_TITLE}" $URL)

echo $result
