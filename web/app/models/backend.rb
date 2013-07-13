# Configuration for queue and chat backends.
class Backend < ActiveRecord::Base
  # The type of backend.
  validates :kind, presence: true, inclusion: { in: ['chat', 'queue'] }

  # The backend URL.
  validates :url, presence: true, length: 1..128

  # The backend configuration URL.
  validates :http_url, presence: true, length: 1..128

  # Choose a queue backend.
  def self.queue(hostname)
    backends = self.where(kind: 'queue')
    if backends.length == 0
      { url: "ws://#{hostname}:8443", http_url: "http://#{hostname}:8543" }
    else
      backend = backends.first
      { url: backend.url, http_url: backend.http_url }
    end
  end

  # Choose a chat backend.
  def self.chat(hostname)
    backends = self.where(kind: 'chat')
    if backends.length == 0
      { url: "ws://#{hostname}:9443", http_url: "http://#{hostname}:9543" }
    else
      backend = backends.first
      { url: backend.url, http_url: backend.http_url }
    end
  end
end
