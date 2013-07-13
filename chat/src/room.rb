# :nodoc: namespace
module Chatty

# Connects two users.
class Room
  attr_reader :key
  attr_reader :user1
  attr_reader :user2

  def ack_new_session(session)
    user = session.user
    event type: 'join', name: user.name, name_color: session.name_color
    nil
  end

  def ack_closed_session(session)
    user = session.user
    event type: 'part', name: user.name, name_color: session.name_color
    nil
  end

  def av_event(user, type, av_nonce, name_color, client_timestamp)
    case type
    when 'av-accept'
      @users.each do |room_user|
        next unless room_user.session
        session = room_user.session
        if session.av_nonce == av_nonce
          session.av_nonce = nil
        end
      end
    end

    event :type => type, :name => user.name, :av_nonce => av_nonce,
          :name_color => name_color, :client_ts => client_timestamp
  end

  def message(user, text, name_color, client_timestamp)
    event :type => 'text', :name => user.name, :text => text,
          :name_color => name_color, :client_ts => client_timestamp
  end

  def events_after(last_known_id)
    events = []
    i = 1
    while i <= @events.length && @events[-i][:id] > last_known_id
      events << @events[-i]
      i += 1
    end
    events.reverse
  end

  def recent_events(count)
    length = [count, @events.length].min
    @events[-length, length]
  end

  # Relays a message between two users.
  #
  # Unlike events, relayed messages are not persisted, so they cannot survive
  # hardware issues. Relayed messages are intended to help users establish a
  # direct connection, e.g. by using ICE, and should not be used to transmit
  # user data.
  def relay(from_user, to_user_name, body, client_timestamp)
    message = { relays: [
        { from: from_user.name, body: body, client_ts: client_timestamp }] }
    @users.each do |user|
      next unless user.name == to_user_name
      session = user.session
      session.respond message if session
    end
  end

  # Creates a Room to host two users.
  def initialize(attrs)
    @key = attrs[:key]
    @user1 = attrs[:user1]
    @user2 = attrs[:user2]

    @events = []
    @next_event_id = 0
    @users = [@user1, @user2]
  end

  # Saves and broadcasts an event that happened in the chat room.
  #
  # This method is called internally by methods such as add_user and message.
  # It should not be called directly.
  #
  # Args:
  #   data:: Hash containing the event details, such as a message's author and
  #          content
  #
  # Returns nil and completes asynchronously.
  def event(data)
    # Prepare the event object.
    id = @next_event_id
    @next_event_id += 1
    event = data.merge :id => id, :server_ts => Time.now.to_f
    @events << event

    # Broadcast the event to users.
    @users.each do |user|
      next unless user.session
      user.session.sync_events
    end
  end
  private :event
end  # class Chatty::Room

end  # namespace Chatty
