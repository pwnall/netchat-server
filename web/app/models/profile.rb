class Profile < ActiveRecord::Base
  belongs_to :user
  validates :user, presence: true

  validates :name, presence: true

  # True if the profile has a Facebook profile connected.
  def has_facebook
    false
  end

  # True if the profile has a LinkedIn profile connected.
  def has_linkedin
    false
  end

  # Empty profile (default settings) for a new user.
  def self.default_for(user)
    profile = Profile.new user: user
    profile.name = user.email
    profile
  end
end
