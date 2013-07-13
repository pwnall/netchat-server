# Logistics for putting two users in a chat room.
#
# This does not need to be in a SQL database.
class ChatState < ActiveRecord::Base
  # The match that this state is for.
  belongs_to :match
  validates :match, presence: true

  # One of the users that the chat state is built for.
  belongs_to :user1, class_name: 'User'
  validates :user1, presence: true

  # The other user that the chat state is built for.
  belongs_to :user2, class_name: 'User'
  validates :users2, presence: true

  # Create a chat room for two matched users.
  def self.create_for(match)
    match_entry = match.match_entries.first
    user1, user2 = match_entry.user, match_entry.other_user
    if user1.id > user2.id
      user1, user2 = user2, user1
    end

    state = ChatState.new
    state.match = match
    state.user1 = user1
    state.user2 = user2
    state.room_key = SecureRandom.urlsafe_base64 32
    state.user1_key = SecureRandom.urlsafe_base64 32
    state.user2_key = SecureRandom.urlsafe_base64 32
    backend = Backend.queue hostname
    state.backend_url = backend[:url]
    state.backend_http_url = backend[:http_url]
    state.save!
    state
  end
end

# Communication with the queuing backend.
class ChatState
  def push_to_backend(chat_closed_url)
    json_body = {
      room_key: room_key,
      join_key1: join_key1,
      join_key2: join_key2,
      close_url: chat_closed_url
    }
    response = send_json "#{backend_http_url}/room", json_body
    return if response.instance_of? Net::HTTPSuccess

    # TODO(pwnall): handle non-200 response
  end

  def remove_from_backend
    json_body = {
      room_key: room_key,
      join_key1: join_key1,
      join_key2: join_key2
    }
    send_json "#{backend_http_url}/kill_room", json_body
    # NOTE: no error handling here; if the backend is down, it already killed
    #       the chat room
  end

  include JsonHttpBackend
end
