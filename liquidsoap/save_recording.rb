#!/usr/bin/env ruby

Bundler.require

class SaveRecording
  def self.save_recording filename, radio
    sidekiq = Sidekiq::Client.new
    sidekiq.push 'queue' => 'default', 'class' => 'SaveRecordingWorker', 'args' => [filename, radio]
  end
end

filename = ARGV[0]
radio = ARGV[1]

SaveRecording.save_recording filename, radio
