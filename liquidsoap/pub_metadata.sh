#!/bin/bash

TITLE=$1
URL=https://$RADIO_NAME.streampusher.com/publish_metadata.json

result=$(curl -s -H "Accept: application/json" -H "Content-type: application/json" -H "liq-secret: ${LIQ_SECRET}" -X POST -d '{"metadata": "'"$TITLE"'"}' $URL)

echo $result
