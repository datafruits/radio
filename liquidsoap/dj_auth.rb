#!/usr/bin/env ruby

Bundler.require

require 'httparty'

username = ARGV[0]
password = ARGV[1]
radio_name = ARGV[2]

opts = { body: { :user => {"login" => username, "password" => password} } }

resp = HTTParty.post("http://#{ENV['RADIO_NAME']}.streampusher.io/login.json", opts)
if resp["success"] == true
  puts true
else
  puts false
end
