#!/usr/bin/env ruby
Bundler.require
if ENV['RAILS_ENV'] == 'development'
  host = "rails:3000/radios/#{ENV['RADIO_NAME']}"
  protocol = "http"
else
  host = "#{ENV['RADIO_NAME']}.streampusher.com"
  protocol = "https"
end

resp = HTTParty.get("#{protocol}://#{host}/next.json")
puts JSON.parse(resp.body).to_json
