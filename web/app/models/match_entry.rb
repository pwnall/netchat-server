# An entry in a user's match history.
class MatchEntry < ActiveRecord::Base
  # One of the users who got matched.
  #
  # Each entry has a matching entry whose other_user points to this user.
  belongs_to :user
  validates :user, presence: true

  # The other user that this user got matched to.
  #
  # Each entry has a matching entry whose user points to this other_user.
  belongs_to :other_user, class_name: 'User'
  validates :other_user, presence: true

  # The match between the two users.
  belongs_to :match
  validates :match, presence: true

  # The deadline by which the match must be accepted by both sides.
  def expires_at
    created_at + 30
  end

  # The last (most recent) queue history entry.
  def self.last_for(user)
    MatchEntry.where(user_id: user.id).order(:created_at).reverse_order.first
  end

  # Creates matching entries for a pair of users who got matched.
  def self.create_pair(user1, user2)
    match = Match.new
    match.created_at = Time.now
    match.rejected = false
    match.save!

    entry1 = MatchEntry.new user: user1, other_user: user2
    entry2 = MatchEntry.new user: user2, other_user: user1
    entry1.match = entry2.match = match
    entry1.created_at = entry2.created_at = match.created_at
    entry1.save!
    entry2.save!
    [entry1, entry2]
  end

  def accept()
  end

  def reject()
    match.rejected = true
    match.save!

    match.match_entries
  end
end
