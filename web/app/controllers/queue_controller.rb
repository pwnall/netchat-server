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

  # PUT /queue/enter
  def enter
    if current_user.queued?
      redirect_to queue_path
      return
    end

    queue_state = current_user.queue! request.host
    queue_state.push_to_backend queue_matched_url
    redirect_to queue_path
  end

  # PUT /queue/leave
  def leave
    unless current_user.queued?
      redirect_to profile_path
      return
    end

    current_user.leave_queue! true
    redirect_to profile_path
  end

  # POST /queue/matched
  #
  # Called by the queue backend.
  def matched
    if param[:left_mk]
      # A user left the queue.
      queue_state = QueueState.for_match_key param[:left_mk]
      if queue_state
        # NOTE: the queue backend is telling us the user left, so we don't need
        #       to repeat the information back.
        queue_state.user.leave_queue! false
      else
        # We already know that the user left the queue.
      end
    elsif param[:mk1] and param[:mk2]
      # Two users have been matched.
      queue_state1 = QueueState.for_match_key param[:mk1]
      queue_state2 = QueueState.for_match_key param[:mk2]
      if queue_state1 && queue_state2
      else
        # At least one of the users just left the matching process.

        # TODO(pwnall): do something smart here
      end
    else
      # Bad request.
    end

    head :ok
  end
end
