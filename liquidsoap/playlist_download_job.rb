Bundler.require
require './file_downloader'

class PlaylistDownload
  include Sidekiq::Worker

  PLAYLIST_PATH = "/tmp/playlist"
  R = Redis.new

  def perform
    radio_name = ENV['RADIO_NAME']
    Dir.mkdir PLAYLIST_PATH unless Dir.exists?(PLAYLIST_PATH)
    response = HTTParty.get("http://#{radio_name}.streampusher.io/playlist.txt")
    playlist = response.body
    playlist.each_line do |p|
      puts File.basename(p)
      dest = "#{PLAYLIST_PATH}/#{File.basename(p.chomp)}"
      uri = URI(p)
      unless File.exists?(dest)
        FileDownloader.download uri, dest
      end
      R.lpush "#{radio_name}:playlist", dest
    end
  end
end

