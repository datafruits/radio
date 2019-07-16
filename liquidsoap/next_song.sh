#!/bin/bash
HOST=""

#if [ "$RAILS_ENV" == "development" ]; then
#  HOST="http://rails:3000/radios/${RADIO_NAME}/next.json"
#else
#  HOST="https://datafruits.streampusher.com/next.json"
#fi

#result=$(curl  -s -H "Accept: application/json" -H "Content-type: application/json" $HOST)

#echo $result | jq -c -r -M .

echo '{"cue_out":"0","cue_in":"0","fade_out":"0","fade_in":"0","track":"https://streampusher.s3.amazonaws.com/datafruits/l_at_dhl_05022019.mp3"}'
