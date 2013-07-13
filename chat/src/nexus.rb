# :nodoc: namespace
module Chatty

# Central location for a chat server's data.
#
# This class caches User and Room instances, and ensures against aliasing (the
# rest of the code will never see different Room or User objects pointing to the
# same user or room).
class Nexus
  # Prepares a nexus with a cold cache.
  #
  # Args:
  #   db:: Mongo database backing chat logs
  #   log:: Logger instance
  def initialize(db, log)
    @db = db
    @log = log
    @users = {}
    @rooms = {}
  end

  # Creates a room.
  #
  # Returns nil.
  #
  # The Room instance is yielded, possibly after the call completes.
  def create_room(json_info, &block)
    join_key1 = json_info['join_key1']
    name1 = json_info['name1']
    @users[join_key1] = user1 = User.new key: join_key1, name: name1
    join_key2 = json_info['join_key2']
    name2 = json_info['name2']
    @users[join_key2] = user2 = User.new key: join_key2, name: name2

    room_key = json_info['key']
    room = Room.new user1: user1, user2: user2, key: room_key
    @rooms[room_key] = room

    user1.room = room
    user2.room = room
    block.call
  end

  # Creates a user.
  #
  # Returns nil.
  #
  # The User instance is yielded, possibly after the call completes.
  def user_by_key(join_key, &block)
    if @users[join_key]
      block.call @users[join_key]
    else
      block.call nil
    end
    nil
  end

  # Creates or retrieves a chat room.
  #
  # Returns nil.
  #
  # The Room instance is yielded, most likely after the call completes.
  def room_by_key(room_key, &block)
    if @rooms[room_key]
      block.call @rooms[room_key]
    else
      block.call nil
    end
    nil
  end

  # The Logger instance used by this server.
  attr_reader :log
end  # class Chatty::Nexus

end  # namespace Chatty
