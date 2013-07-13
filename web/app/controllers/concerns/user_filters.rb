module UserFilters
  extend ActiveSupport::Concern

  included do
    authenticates_using_session
  end

  # before_filter that only lets registered users through.
  def ensure_user_logged_in
    bounce_user unless current_user
  end

  # before_filter that only lets admins through.
  def ensure_user_is_admin
    bounce_user unless current_user and current_user.admin?
  end
end

