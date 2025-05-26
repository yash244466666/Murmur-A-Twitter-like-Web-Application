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
      respond_to do |format|
        format.html do 
          session[:user_id] = @user.id
          redirect_to timeline_path, notice: "Signed in successfully!"
        end
        format.json do
          token = JsonWebToken.encode(user_id: @user.id)
          render json: { 
            token: token,
            user: UserSerializer.new(@user)
          }, status: :ok
        end
      end
    else
      respond_to do |format|
        format.html do
          flash.now[:alert] = "Invalid email or password"
          render :login_form, status: :unprocessable_entity
        end
        format.json do
          render json: { error: "Invalid email or password" }, status: :unauthorized
        end
      end
    end
  end

  def logout
    session[:user_id] = nil
    redirect_to root_path, notice: "Signed out successfully!"
  end
end
