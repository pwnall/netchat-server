# :nodoc: namespace
module QueueSrv

# Central location for a chat server's data.
#
# This class caches User and Room instances, and ensures against aliasing (the
# rest of the code will never see different Room or User objects pointing to the
# same user or room).
class Nexus
  # Prepares a nexus with a cold cache.
  #
  # Args:
  #   db:: database backing user profiles
  #   log:: Logger instance
  def initialize(db, log)
    @db = db
    @log = log
    @users = {}
  end

  # Creates or retrieves a user.
  #
  # Returns nil.
  #
  # The User instance is yielded, possibly after the call completes.
  def user_by_key(join_key, &block)
    if @users[join_key]
      block.call @users[join_key]
      return nil
    end

    new_user = User.new join_key  # TODO: database create-or-fetch

    # TODO: this goes in the db's response block
    @users[join_key] ||= new_user
    block.call @users[join_key]

    nil
  end

  # The Logger instance used by this server.
  attr_reader :log
end  # class QueueSrv::Nexus

end  # namespace QueueSrv
