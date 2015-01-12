#!/usr/bin/env ruby
Bundler.require
require_relative './playlist_download_job'

redis = Redis.new host: ENV['REDIS_PORT_6379_TCP_ADDR'], port: ENV['REDIS_PORT_6379_TCP_PORT']

key = "#{ENV['RADIO_NAME']}:playlist"

song = redis.rpoplpush key, key

puts song
