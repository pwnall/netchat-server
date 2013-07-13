class Profile < ActiveRecord::Base
  belongs_to :user
  validates :user, presence: true

  validates :name, presence: true

  # True if the profile has a Facebook profile connected.
  def has_facebook
  end

  def has_linkedin
  end
end
