# An entry in a user's queue history.
class QueueEntry < ActiveRecord::Base
  belongs_to :user
  validates :user_id, presence: true

  # New entry indicating that a user joined the queue.
  def self.new_for(user)
    queue_entry = QueueEntry.new
    queue_entry.user = user
    queue_entry.entered_at = Time.now
    queue_entry
  end

  # The last (most recent) queue history entry.
  def self.last_for(user)
    QueueEntry.where(user_id: user.id).order(:entered_at).reverse_order.first
  end
end
