#!/usr/bin/env ruby
Bundler.require
if ENV['RAILS_ENV'] == 'development'
  host = "#{ENV['RADIO_NAME']}.streampusher.com:3000"
else
  host = "#{ENV['RADIO_NAME']}.streampusher.com"
end

resp = HTTParty.get("http://#{host}/next.json")
puts JSON.parse(resp.body).to_json
