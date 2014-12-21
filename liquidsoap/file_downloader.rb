require 'net/http'

class FileDownloader
  def self.download uri, dest
    uri = URI(uri)
    Net::HTTP.start(uri.host, uri.port,
      use_ssl: uri.scheme == 'https') do |http|
      request = Net::HTTP::Get.new uri.request_uri
      puts "downloading #{uri.request_uri} to #{dest}..."
      http.request(request) do |response|
        File.open(dest, 'wb') do |io|
          response.read_body do |chunk|
            io.write(chunk)
          end
        end
      end
    end
  end
end
