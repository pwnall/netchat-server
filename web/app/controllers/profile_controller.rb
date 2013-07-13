class ProfileController < ApplicationController
  before_filter :ensure_user_has_profile

  # GET /profile
  def show
    @profile = current_user.profile
    if current_user.queued?
      redirect_to queue_path
    elsif current_user.matched?
      redirect_to match_path
    elsif current_user.chatting?
      redirect_to chat_path
    else
      respond_to do |format|
        format.html  # profile/show.html.erb
      end
    end
  end

  # POST /profile/add_linkedin
  def add_linkedin
    @profile.name = "LinkedIn User #{@profile.user.email}"
    @profile.save!

    redirect_to profile_path
  end

  # POST /profile/add_facebook
  def add_facebook
    # TODO: real integration
    @profile.name = "Facebook User #{@profile.user.email}"
    @profile.save!

    redirect_to profile_path
  end
end

