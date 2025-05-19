class MurmursController < ApplicationController
  before_action :set_murmur, only: [:show, :destroy]
  before_action :check_murmur_owner, only: [:destroy]

  # GET /api/murmurs
  def index
    @murmurs = Murmur.includes(:user).order(created_at: :desc).limit(20)
    render json: @murmurs.map { |m| murmur_with_user(m) }
  end

  # GET /api/murmurs/:id
  def show
    render json: murmur_with_user(@murmur)
  end

  # POST /api/murmurs
  def create
    @murmur = current_user.murmurs.build(murmur_params)
    if @murmur.save
      render json: murmur_with_user(@murmur), status: :created
    else
      render json: { errors: @murmur.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # DELETE /api/murmurs/:id
  def destroy
    @murmur.destroy
    head :no_content
  end

  # GET /api/timeline
  def timeline
    following_ids = current_user.followings.pluck(:id)
    @murmurs = Murmur.includes(:user)
                     .where(user_id: following_ids + [current_user.id])
                     .order(created_at: :desc)
                     .limit(20)
    render json: @murmurs.map { |m| murmur_with_user(m) }
  end

  private

  def murmur_params
    params.permit(:content)
  end

  def set_murmur
    @murmur = Murmur.find(params[:id])
  end

  def check_murmur_owner
    unless @murmur.user_id == current_user.id
      render json: { error: 'Unauthorized' }, status: :unauthorized
    end
  end

  def murmur_with_user(murmur)
    {
      id: murmur.id,
      content: murmur.content,
      created_at: murmur.created_at,
      user: UserSerializer.new(murmur.user),
      likes_count: murmur.likes.count,
      liked_by_current_user: murmur.likes.exists?(user: current_user)
    }
  end
end
