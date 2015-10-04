#!/usr/bin/env ruby

Bundler.require

username = ARGV[0]
password = ARGV[1]
radio_name = ARGV[2]

opts = { body: { :user => {"login" => username, "password" => password} } }

if ENV['RAILS_ENV'] == 'development'
  # TODO find a better way to get the docker host
  host = 'docker:3000'
  puts true
  exit(0)
else
  host = "#{ENV['RADIO_NAME']}.streampusher.com"
end

resp = HTTParty.post("http://#{host}/login.json", opts)
if resp["success"] == true
  puts true
else
  puts false
end
