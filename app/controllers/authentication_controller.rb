class AuthenticationController < ApplicationController
  skip_before_action :authenticate_user!, only: [:login, :login_form]
  layout 'application'

  def login_form
    redirect_to timeline_path if current_user
    @user = User.new
  end

  # POST /auth/login
  def login
    @user = User.find_by(email: params[:email])
    if @user&.authenticate(params[:password])
      session[:user_id] = @user.id
      redirect_to timeline_path, notice: "Signed in successfully!"
    else
      flash.now[:alert] = "Invalid email or password"
      render :login_form, status: :unprocessable_entity
    end
  end

  def logout
    session[:user_id] = nil
    redirect_to root_path, notice: "Signed out successfully!"
  end
end
