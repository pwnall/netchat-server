# An entry in a user's match history.
class MatchEntry < ActiveRecord::Base
  # One of the users who got matched.
  #
  # Each entry has a matching entry whose other_user points to this user.
  belongs_to :user
  validates :user_id, presence: true

  # The other user that this user got matched to.
  #
  # Each entry has a matching entry whose user points to this other_user.
  belongs_to :other_user, class_name: 'User'
  validates :other_user_id, presence: true

  # The last (most recent) queue history entry.
  def self.last_for(user)
    MatchEntry.where(user_id: user.id).order(:created_at).reverse_order.first
  end

  # Creates matching entries for a pair of users who got matched.
  def self.create_pair(user1, user2)
    entry1 = MatchEntry.new user: user1, other_user: user2
    entry2 = MatchEntry.new user: user2, other_user: user1
    entry1.created_at = entry2.created_at = Time.now
    entry1.save!
    entry2.save!
    [entry1, entry2]
  end
end
