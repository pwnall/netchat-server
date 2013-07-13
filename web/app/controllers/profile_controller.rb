class ProfileController < ApplicationController
  before_filter :ensure_user_logged_in

  # GET /profile
  def show
    @user = current_user
    @profile = current_user.profile
  end

  # POST /profile/add_linkedin
  def add_linkedin
    @profile = current_user.profile

    @profile.name = 'LinkedIn User'
    @profile.save!

    redirect_to profile_path
  end

  # POST /profile/add_facebook
  def add_facebook
    @profile = current_user.profile
    
    # TODO: real integration
    @profile.name = 'Facebook User'
    @profile.save!

    redirect_to profile_path
  end
end

