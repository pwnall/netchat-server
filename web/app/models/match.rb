# A match between two users.
class Match < ActiveRecord::Base
  # True if at least one of the users rejected the match.
  #validates :rejected, inclusion: { in: [true, false] }

  # Logistics for getting the matched users chatting.
  #
  # This is null if neither user has accepted the matching.
  has_one :chat_state

  # The match history entries connecting the matched users to this match.
  has_many :match_entries
end
