#!/bin/bash
HOST=""

if [ "$RAILS_ENV" == "development" ]; then
  HOST="http://rails:3000/radios/${RADIO_NAME}/next.json"
else
  HOST="https://${RADIO_NAME}.streampusher.com/next.json"
fi

result=$(curl  -s -H "Accept: application/json" -H "Content-type: application/json" $HOST)

echo $result | jq -c -r -M .
