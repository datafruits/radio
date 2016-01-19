#!/usr/bin/env ruby
Bundler.require
if ENV['RAILS_ENV'] == 'development'
  # TODO find a better way to get the docker host
  host = 'docker:3000'
  puts true
  exit(0)
else
  host = "#{ENV['RADIO_NAME']}.streampusher.com"
end

resp = HTTPartyget.get("http://#{host}/next.json")
JSON.parse(resp.body)
