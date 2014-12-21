#!/usr/bin/env ruby
Bundler.require
require_relative './playlist_download_job'

R = Redis.new

next_song = R.lpop "#{ENV['RADIO_NAME']}:playlist"
if next_song != nil
  puts next_song
else
  puts "enqueueing PlaylistDownload..."
  PlaylistDownload.perform_async
  nil
end
