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

  # The chat history entries connecting the matched users to this match.
  has_many :chat_entries

  # Common logic for closing out the matching.
  def close!
    match_entries.each do |entry|
      unless entry.closed_at
        entry.closed_at = Time.now
        entry.save!
      end
    end

    if rejected?
      if chat_state
        chat_state.remove_from_backend!
        chat_state.destroy
      end
    end
  end
end
