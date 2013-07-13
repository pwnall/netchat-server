class QueueController < ApplicationController
  before_filter :ensure_user_has_profile

  # GET /queue
  def show
    unless current_user.queued?
      redirect_to profile_path
      return
    end

    @queue_entry = QueueEntry.last_for current_user
    @queue_state = QueueState.for_user current_user

    respond_to do |format|
      format.html  # queue/show.html.erb
    end
  end

  # POST /queue/enter
  def enter
    if current_user.queued?
      redirect_to queue_path
      return
    end

    queue_state = current_user.queue! request.host
    # TODO(pwnall): post to the queue backend
    redirect_to queue_path
  end

  # POST /queue/leave
  def leave
    unless current_user.queued?
      redirect_to profile_path
      return
    end

    # TODO(pwnall): code for leaving the queue
  end
end
