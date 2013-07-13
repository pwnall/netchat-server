require 'net/http'
require 'net/https'
require 'uri'

# Helpers for talking to backends using JSON over HTTP.
module JsonHttpBackend
  # Helper for sending JSON payloads to the queue backend.
  def send_json(url, json_body)
    uri = URI.parse url
    request = Net::HTTP::Post.new uri.path,
                                  'Content-Type' => 'application/json'
    request.body = json_body.to_json
    response_klass = if uri.scheme == 'https'
      Net::HTTPS
    else
      Net::HTTP
    end
    response = response_klass.new(uri.host, uri.port).start do |http|
      http.request request
    end
    response
  end
  private :send_json
end
