#!/bin/bash

USERNAME=$1
PASSWORD=$2
RADIO=$3
HOST=https://$RADIO_NAME.streampusher.com/login.json

result=$(curl -s -H "Accept: application/json" -H "Content-type: application/json"  -X POST -d '{"user": {"login":"'"$USERNAME"'","password":"'"$PASSWORD"'"}}' $HOST)

echo $result | jq -r '.success'
