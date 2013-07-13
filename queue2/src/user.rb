require 'set'

# :nodoc: namespace
module QueueSrv

# A chat user.
class User
  attr_reader :join_key
  attr_reader :match_key
  attr_reader :profile
  attr_reader :match_url
  attr_reader :matched
  attr_reader :sessions

  def initialize(attrs)
    @join_key = attrs[:key]
    @match_key = attrs[:match_key]
    @profile = attrs[:profile]
    @match_url = attrs[:match_url]
    @matched = false
    @sessions = []
  end

  def add_session(session)
    @sessions << session
  end

  def remove_session(session)
    @sessions.delete session
  end

  def found_match(other_user)
    @matched = true
    @sessions.last.send_matched
  end
end  # class QueueSrv::User

end  # namespace QueueSrv
