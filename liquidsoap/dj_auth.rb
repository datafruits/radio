#!/usr/bin/env ruby

Bundler.require

require 'httparty'

username = ARGV[0]
password = ARGV[1]
radio_name = ARGV[2]

opts = { body: { :user => {"login" => username, "password" => password} } }

if ENV['RAILS_ENV'] == 'development'
  host = '192.168.1.4'
else
  host = "#{ENV['RADIO_NAME']}.streampusher.com"

resp = HTTParty.post("http://#{host}/login.json", opts)
if resp["success"] == true
  puts true
else
  puts false
end
