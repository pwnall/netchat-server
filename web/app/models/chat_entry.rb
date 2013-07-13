# An entry in a user's chat history.
class ChatEntry < ActiveRecord::Base
  # One of the users who started chatting.
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
  
  # Logistics for connecting two users.
  has_one :chat_state, through: :match

  # The last (most recent) chat history entry.
  def self.last_for(user)
    MatchEntry.where(user_id: user.id).order(:created_at).reverse_order.first
  end

  # Creates matching entries for a pair of users who started chatting.
  def self.create_pair(match)
    match_entry = match.match_entries.first
    user1, user2 = match_entry.user, match_entry.other_user
    if user1.id > user2.id
      user1, user2 = user2, user1
    end
    entry1 = ChatEntry.new user: user1, other_user: user2
    entry2 = ChatEntry.new user: user2, other_user: user1
    entry1.match = entry2.match = match
    entry1.created_at = entry2.created_at = match.chat_state.created_at
    entry1.save!
    entry2.save!
    [entry1, entry2]
  end
end
