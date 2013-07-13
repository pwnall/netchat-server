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
    else
      block.call nil
    end

    nil
  end

  # Called when the Web server sends us a user profile.
  def user_profile(json_info, &block)
    join_key = json_info['key']
    match_key = json_info['match_key']
    profile_info = json_info['profile']
    match_url = json_info['url']

    # TODO: database create
    new_user = User.new(key: join_key, match_key: match_key,
                        profile_info: profile_info, match_url: match_url)

    # TODO: this goes in the db's response block
    @users[join_key] ||= new_user
    block.call
  end

  # Called when the Web server tells us a user left the queue.
  def user_left(json_info, &block)
    join_key = json_info['key']

    # TODO: database fetch
    user = @users[join_key]

    if user
      # TODO: terminate user's sessions
      user.sessions
    end

    block.call
  end

  # Yields the users eligible to be matched.
  # 
  # Returns nil.
  #
  # The yield might happen after the call completes.
  def matchable_users(&block)
    users = @users.values.select { |u| u.sessions.length > 0 && !u.matched }
    block.call users
  end

  # The Logger instance used by this server.
  attr_reader :log
end  # class QueueSrv::Nexus

end  # namespace QueueSrv
