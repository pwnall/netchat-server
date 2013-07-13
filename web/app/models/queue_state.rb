require 'securerandom'

# Logistics about a queued up user.
#
# This doesn't need to stay in a SQL database.
class QueueState < ActiveRecord::Base
  # The user whose queue state is represented by this.
  belongs_to :user
  validates :user, presence: true
  validates :user_id, uniqueness: true

  # The queue server that will handle this user.
  validates :backend_url, presence: true, length: 1...128

  # The token user by the user to authenticate to the queue backend.
  validates :join_key, presence: true, length: 32...64

  # The token used by the queue backend to authenticate back to the user.
  validates :match_key, presence: true, length: 32...64

  # The QueryState for a user. May be null.
  def self.for_user(user)
    where(user_id: user.id).first
  end

  # Saved QueueState assigning a user to a queue backend.
  def self.create_for(user, hostname)
    if old_state = self.for_user(user)
      old_state.destroy
    end

    state = QueueState.new
    state.user = user
    state.join_key = SecureRandom.urlsafe_base64 32
    state.match_key = SecureRandom.urlsafe_base64 32
    state.backend_url = Backend.queue hostname
    state.save!
  end
end
