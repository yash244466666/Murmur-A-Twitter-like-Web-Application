class UsersController < ApplicationController
  skip_before_action :authenticate_user!, only: [:new, :create]
  skip_before_action :verify_authenticity_token, if: -> { request.format.json? }
  before_action :set_user, only: [:profile, :followers, :following]
  layout 'application'

  def new
    @user = User.new
  end

  # POST /users or POST /signup
  def create
    @user = User.new(user_params)
    
    respond_to do |format|
      if @user.save
        format.html do
          # For web interface, log the user in and redirect to timeline
          session[:user_id] = @user.id
          redirect_to timeline_path, notice: 'Welcome! Your account has been created.'
        end
        format.json do
          # For API requests, return token and user data
          token = JsonWebToken.encode(user_id: @user.id)
          render json: {
            token: token,
            user: UserSerializer.new(@user).as_json
          }, status: :created
        end
      else
        format.html do 
          render :new, status: :unprocessable_entity
        end
        format.json do
          render json: { 
            error: "Validation failed",
            errors: @user.errors.full_messages 
          }, status: :unprocessable_entity
        end
      end
    end
  end

  # GET /@:username
  def profile
    @murmurs = @user.murmurs.includes(:user, :likes).order(created_at: :desc).page(params[:page]).per(10)

    respond_to do |format|
      format.html
      format.json do
        render json: {
          user: UserSerializer.new(@user),
          murmurs_count: @user.murmurs.count,
          followers_count: @user.followers.count,
          following_count: @user.following.count,
          is_following: current_user.following.include?(@user),
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
      end
    end
  end

  # GET /@:username/followers
  def followers
    @followers = @user.followers.includes(:followers, :following).page(params[:page]).per(20)
    
    respond_to do |format|
      format.html
      format.json do
        render json: {
          user: UserSerializer.new(@user),
          followers: @followers.map { |follower| 
            {
              id: follower.id,
              username: follower.username,
              bio: follower.bio,
              is_following: current_user&.following?(follower)
            }
          }
        }
      end
    end
  end

  # GET /@:username/following
  def following
    @following = @user.following.includes(:followers, :following).page(params[:page]).per(20)
    
    respond_to do |format|
      format.html
      format.json do
        render json: {
          user: UserSerializer.new(@user),
          following: @following.map { |followed| 
            {
              id: followed.id,
              username: followed.username,
              bio: followed.bio,
              is_following: current_user&.following?(followed)
            }
          }
        }
      end
    end
  end

  private

  def set_user
    @user = User.find_by!(username: params[:username])
  rescue ActiveRecord::RecordNotFound
    respond_to do |format|
      format.html { redirect_to root_path, alert: 'User not found' }
      format.json { render json: { error: 'User not found' }, status: :not_found }
    end
  end

  def user_params
    if params.key?(:user)
      params.require(:user).permit(:username, :email, :password, :password_confirmation, :bio)
    else
      params.permit(:username, :email, :password, :password_confirmation, :bio)
    end
  end
end
