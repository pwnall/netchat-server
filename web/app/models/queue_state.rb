require 'net/http'
require 'net/https'
require 'securerandom'
require 'uri'

# Logistics about a queued up user.
#
# This doesn't need to stay in a SQL database.
class QueueState < ActiveRecord::Base
  # The user whose queue state is represented by this.
  belongs_to :user
  validates :user, presence: true
  validates :user_id, uniqueness: true

  # The queue server that will handle this user.
  validates :backend_url, presence: true, length: 1...128
  
  # Configuration URL for the queue server that will handle this user.
  validates :backend_http_url, presence: true, length: 1...128

  # The token user by the user to authenticate to the queue backend.
  validates :join_key, presence: true, length: 32...64

  # The token used by the queue backend to authenticate back to the user.
  validates :match_key, presence: true, length: 32...64

  # The QueryState for a user. May be null.
  def self.for_user(user)
    where(user_id: user.id).first
  end

  # Saved QueueState assigning a user to a queue backend.
  def self.create_for(user, hostname)
    if old_state = self.for_user(user)
      old_state.destroy
    end

    state = QueueState.new
    state.user = user
    state.join_key = SecureRandom.urlsafe_base64 32
    state.match_key = SecureRandom.urlsafe_base64 32
    backend = Backend.queue hostname
    state.backend_url = backend[:url]
    state.backend_http_url = backend[:http_url]
    state.save!
    state
  end

  # Sends the queuing information to the queue backend.
  def push_to_backend(queue_matched_url)
    uri = URI.parse "#{backend_http_url}/user"
    info = {
      key: join_key,
      match_key: match_key,
      url: queue_matched_url,
      profile: user.profile.to_queue_json
    }

    request = Net::HTTP::Post.new uri.path,
                                  'Content-Type' => 'application/json'
    request.body = info.to_json
    response_klass = if uri.scheme == 'https'
      Net::HTTPS
    else
      Net::HTTP
    end
    response = response_klass.new(uri.host, uri.port).start do |http|
      http.request request
    end
    return if response.instance_of? Net::HTTPSuccess

    # TODO(pwnall): handle non-200 response
  end
end
