#!/usr/bin/env ruby
Bundler.require
require_relative "./time_parser"

redis = Redis.new host: ENV['REDIS_PORT_6379_TCP_ADDR'], port: ENV['REDIS_PORT_6379_TCP_PORT']

fallback_key = redis.get "#{ENV['RADIO_NAME']}:default_playlist"

schedule_key = TimeParser.get_key_for_current_time Time.now.utc
playlist_key = redis.get schedule_key

if playlist_key.nil?
  key = fallback_key
else
  key = playlist_key
end

song = redis.rpop key
redis.lpush key, song

puts "/home/liquidsoap/tracks/#{song}"
