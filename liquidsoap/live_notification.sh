#!/bin/bash

TITLE=$1

if [ "$RAILS_ENV" = "development" ]; then
  URL="http://rails:3000/live_notification.json"
else
  URL="https://$RADIO_NAME.streampusher.com/live_notification.json"
fi

result=$(curl -s -H "Accept: application/json" -H "Content-type: application/json" -H "liq-secret: ${LIQ_SECRET}" -X POST -d '{"metadata": "'"$TITLE"'"}' $URL)

echo $result
