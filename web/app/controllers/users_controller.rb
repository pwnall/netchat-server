class UsersController < ApplicationController
  # GET /users/new
  def new
    @user = User.new
  end

  # POST /users
  # POST /users.json
  def create
    @user = User.new(user_params)
    @user.admin = true if User.count == 0  # Bootstrap admin privileges.

    respond_to do |format|
      if @user.save
        format.html do
          set_session_current_user @user
          redirect_to session_url
        end
        format.json do
          render action: 'show', status: :created, location: @user
        end
      else
        format.html { render action: 'new' }
        format.json do
          render json: @user.errors, status: :unprocessable_entity
        end
      end
    end
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def user_params
    params.require(:user).permit(:email, :password, :password_confirmation)
  end
  private :user_params
end

