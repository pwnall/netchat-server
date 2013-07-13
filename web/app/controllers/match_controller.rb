class MatchController < ApplicationController
  before_filter :ensure_user_is_matched

  # GET /match
  def show
    @other_profile = @match_entry.other_user.profile

    respond_to do |format|
      format.html  # match/show.html.erb
    end
  end

  # PUT /match/accept
  def accept

  end

  # PUT /match/reject
  def reject

  end

  def ensure_user_is_matched
    ensure_user_has_profile
    return if performed?

    unless current_user.matched?
      redirect_to profile_path
      return
    end
    @match_entry = MatchEntry.last_for current_user
  end
end
