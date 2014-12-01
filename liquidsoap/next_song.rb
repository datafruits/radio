#!/usr/bin/env ruby

Bundler.require

require 'httparty'

resp = HTTParty.get("http://#{radio_name}.streampusher.io/playlists/next.json")
resp["track"]
