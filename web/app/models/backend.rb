# Configuration for queue and chat backends.
class Backend < ActiveRecord::Base
  # The type of backend.
  validates :kind, presence: true, inclusion: { in: ['chat', 'queue'] }

  # The backend URL.
  validates :url, presence: true, length: 1..128

  # Choose a queue backend.
  def self.queue(host)
    backends = self.where(kind: 'queue')
    if backends.length == 0
      "ws://#{host}:8443"
    else
      backends.first.url
    end
  end

  # Choose a chat backend.
  def self.chat(host)
    backends = self.where(kind: 'chat')
    if backends.length == 0
      "ws://#{host}:9443"
    else
      backends.first.url
    end
  end
end
