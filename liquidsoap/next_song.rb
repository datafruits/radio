#!/usr/bin/env ruby
Bundler.require

redis = Redis.new host: ENV['REDIS_PORT_6379_TCP_ADDR'], port: ENV['REDIS_PORT_6379_TCP_PORT']

key = "#{ENV['RADIO_NAME']}:playlist"

song = redis.rpop key
redis.lpush key, song

puts "/home/liquidsoap/tracks/#{song}"
