# An entry in a user's queue history.
class QueueEntry < ActiveRecord::Base
  belongs_to :user
  validates :user_id, presence: true

  # New entry indicating that a user joined the queue.
  def self.new_for(user)
    self.new user: user, entered_at: Time.now
  end

  # The last (most recent) queue history entry.
  def self.last_for(user)
    where(user_id: user.id).last
  end
end
