#!/usr/bin/env ruby
Bundler.require
require_relative "./time_parser"

redis = Redis.new host: ENV['REDIS_PORT_6379_TCP_ADDR'], port: ENV['REDIS_PORT_6379_TCP_PORT']

key = "#{ENV['RADIO_NAME']}:playlist"

schedule_key = get_key_for_current_time Time.now.utc
playlist_key = redis.get schedule_key

song = redis.rpop playlist_key
redis.lpush playlist_key, song

puts "/home/liquidsoap/tracks/#{song}"
