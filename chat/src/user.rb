require 'set'

# :nodoc: namespace
module Chatty

# A chat user.
class User
  attr_reader :key
  attr_reader :name
  attr_reader :session
  attr_reader :room

  def initialize(attrs)
    @key = attrs[:key]
    @name = attrs[:name]
    @session = nil
    @room = nil
  end

  def set_session(session)
    # NOTE: might be nice to check that the session is not assigned
    @session = session
    session.room.ack_new_session session
  end

  def remove_session
    return unless @session
    old_session = @session
    @session = nil
    old_session.room.ack_closed_session old_session
  end

  def room=(new_room)
    # NOTE: might be nice to check that the room is not assigned
    @room = new_room
  end

end  # class Chatty::User

end  # namespace Chatty
