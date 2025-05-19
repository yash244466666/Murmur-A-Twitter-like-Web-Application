class UsersController < ApplicationController
  skip_before_action :authenticate_request, only: [:create]

  # POST /users
  def create
    @user = User.new(user_params)
    if @user.save
      token = JsonWebToken.encode(user_id: @user.id)
      render json: {
        token: token,
        user: UserSerializer.new(@user)
      }, status: :created
    else
      render json: { errors: @user.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # GET /api/profile/:username
  def profile
    @user = User.find_by!(username: params[:username])
    render json: {
      user: UserSerializer.new(@user),
      murmurs_count: @user.murmurs.count,
      followers_count: @user.followers.count,
      following_count: @user.followings.count,
      is_following: current_user.followings.include?(@user),
      murmurs: @user.murmurs.order(created_at: :desc).limit(20).map { |m|
        {
          id: m.id,
          content: m.content,
          created_at: m.created_at,
          likes_count: m.likes.count,
          liked_by_current_user: m.likes.exists?(user: current_user)
        }
      }
    }
  rescue ActiveRecord::RecordNotFound
    render json: { error: 'User not found' }, status: :not_found
  end

  private

  def user_params
    params.permit(:username, :email, :password, :password_confirmation, :bio)
  end
end
