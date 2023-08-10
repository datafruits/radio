#!/bin/bash

TITLE=$1
URL=https://$RADIO_NAME.streampusher.com/publish_metadata.json

ESCAPED_TITLE=$(printf '%s' "$TITLE" | jq -s -Rr @json)

result=$(curl -s -H "Accept: application/json" -H "Content-type: application/json" -H "liq-secret: $LIQ_SECRET" -X POST -d "{\"metadata\": $ESCAPED_TITLE}" $URL)

echo $result
