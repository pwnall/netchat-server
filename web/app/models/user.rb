# An user account.
class User < ActiveRecord::Base
  include Authpwn::UserModel

  # Virtual email attribute, with validation.
  include Authpwn::UserExtensions::EmailField
  # Virtual password attribute, with confirmation validation.
  include Authpwn::UserExtensions::PasswordField
  # Convenience Facebook accessors.
  # include Authpwn::UserExtensions::FacebookFields

  # Change this method to change the way users are looked up when signing in.
  #
  # For example, to implement Facebook / Twitter's ability to log in using
  # either an e-mail address or a username, look up the user by the username,
  # and pass their e-mail to super.
  def self.authenticate_signin(email, password)
    super
  end

  # Add your extensions to the User class here.

  # The user's profile information.
  has_one :profile, dependent: :nullify
end


# Queueing.
class User
  # True if the user is queued up, false otherwise.
  def queued?
    last_queue_entry = QueueEntry.last_for self
    last_queue_entry && !last_queue_entry.left_at
  end

  # Create a queue entry for the user.
  def queue!(hostname)
    QueueEntry.transaction do
      queue_entry = QueueEntry.new_for self
      queue_entry.save!
      QueueState.create_for self, hostname
    end
  end

  # Reports the fact that a user has left the queue.
  def leave_queue!(remove_from_backend)
    queue_entry = QueueEntry.last_for self
    return unless queue_entry

    remove_from_queue!

    queue_state = QueueState.for_user self
    queue_state.remove_from_backend if remove_from_backend
    queue_state.destroy if queue_state
  end

  # Updates queue entries to reflect the fact that the user is no longer queued.
  def remove_from_queue!
    queue_entry = QueueEntry.last_for self
    return unless queue_entry

    queue_entry.left_at = Time.now
    queue_entry.save!
  end
end


# Match accepting.
class User
  # True if this user has a match they need to accept.
  def matched?
    last_match_entry = MatchEntry.last_for self
    last_match_entry && !last_match_entry.closed_at
  end
end


# Chatting
class User
  def chatting?
    last_chat_entry = ChatEntry.last_for self
    last_chat_entry && !last_chat_entry.closed_at
  end
end
