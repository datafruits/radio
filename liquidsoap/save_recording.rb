#!/usr/bin/env ruby

Bundler.require

redis_url = "redis://#{ENV['REDIS_PORT_6379_TCP_ADDR']}:#{ENV['REDIS_PORT_6379_TCP_PORT']}"

Sidekiq.configure_server do |config|
  config.redis = { url: redis_url }
end

Sidekiq.configure_client do |config|
  config.redis = { url: redis_url }
end

class SaveRecording
  def self.save_recording filename, radio
    sidekiq = Sidekiq::Client.new
    sidekiq.push 'queue' => 'default', 'class' => 'SaveRecordingWorker', 'args' => [filename, radio]
  end
end

filename = ARGV[0]
radio = ARGV[1]

SaveRecording.save_recording filename, radio
