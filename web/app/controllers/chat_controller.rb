class ChatController < ApplicationController
  before_filter :ensure_user_is_chatting, except: [:closed]
  skip_before_filter :verify_authenticity_token, only: [:closed]

  # GET /match
  def show
    @other_profile = @chat_entry.other_user.profile

    respond_to do |format|
      format.html  # match/show.html.erb
    end
  end

  # PUT /chat/leave
  def leave

  end


  # POST /chat/closed
  def closed
  end

  def ensure_user_is_chatting
    ensure_user_has_profile
    return if performed?

    unless current_user.chatting?
      redirect_to profile_path
      return
    end
    @chat_entry = ChatEntry.last_for current_user
  end
end
