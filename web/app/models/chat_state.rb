class ChatState < ActiveRecord::Base
  belongs_to :match
  belongs_to :user1
  belongs_to :user2
end
