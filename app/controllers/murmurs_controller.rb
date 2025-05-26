class MurmursController < ApplicationController
  before_action :set_murmur, only: [:show, :destroy]
  before_action :check_murmur_owner, only: [:destroy]

  def index
    @murmurs = current_user.murmurs.includes(:user, :likes).order(created_at: :desc).page(params[:page]).per(10)
    respond_to do |format|
      format.html
      format.json { render json: @murmurs.map { |m| murmur_with_user(m) } }
    end
  end

  def show
    respond_to do |format|
      format.html
      format.json { render json: murmur_with_user(@murmur) }
    end
  end

  def create
    @murmur = current_user.murmurs.build(murmur_params)
    
    respond_to do |format|
      if @murmur.save
        format.html { redirect_to timeline_path, notice: 'Murmured successfully!' }
        format.json { render json: murmur_with_user(@murmur), status: :created }
      else
        format.html { redirect_back fallback_location: timeline_path, alert: @murmur.errors.full_messages.join(', ') }
        format.json { render json: @murmur.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @murmur.destroy
    
    respond_to do |format|
      format.html { redirect_back(fallback_location: root_path, notice: 'Murmur was deleted.') }
      format.json { render json: { message: 'Murmur deleted successfully' }, status: :ok }
      format.any { render json: { message: 'Murmur deleted successfully' }, status: :ok }
    end
  rescue ActiveRecord::RecordNotFound
    render json: { error: 'Murmur has already been deleted or does not exist' }, status: :not_found
  end

  def timeline
    following_ids = current_user.following.pluck(:id)
    @murmurs = Murmur.includes(:user, :likes)
                     .where(user_id: following_ids + [current_user.id])
                     .order(created_at: :desc)
                     .page(params[:page])
                     .per(10)
                     
    @suggested_users = User.where.not(id: following_ids + [current_user.id])
                          .order(Arel.sql('RAND()'))
                          .limit(5)
                          
    respond_to do |format|
      format.html
      format.json { 
        render json: {
          murmurs: @murmurs.map { |m| murmur_with_user(m) },
          suggested_users: @suggested_users.map { |u| {
            id: u.id,
            username: u.username,
            bio: u.bio,
            following: current_user.following?(u)
          }}
        }
      }
    end
  end

  def my_murmurs
    @murmurs = current_user.murmurs.includes(:likes).order(created_at: :desc).page(params[:page]).per(10)
    
    respond_to do |format|
      format.html { render :index }
      format.json { render json: @murmurs.map { |m| murmur_with_user(m) } }
    end
  end

  private

  def murmur_params
    params.require(:murmur).permit(:content)
  end

  def set_murmur
    @murmur = Murmur.order(created_at: :desc).find(params[:id])
  rescue ActiveRecord::RecordNotFound
    respond_to do |format|
      format.html { 
        flash[:alert] = 'Murmur has already been deleted or does not exist'
        redirect_back(fallback_location: root_path)
      }
      format.json { render json: { error: 'Murmur has already been deleted or does not exist' }, status: :not_found }
      format.any { render json: { error: 'Murmur has already been deleted or does not exist' }, status: :not_found }
    end
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
