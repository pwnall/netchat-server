require 'set'

# :nodoc: namespace
module QueueSrv

# A chat user.
class User
  attr_reader :join_key
  attr_reader :sessions

  def initialize(join_key)
    @join_key = join_key
    @sessions = []
  end

  def add_session(session)
    @sessions << session
  end

  def remove_session(session)
    @sessions.delete session
  end
end  # class QueueSrv::User

end  # namespace QueueSrv
