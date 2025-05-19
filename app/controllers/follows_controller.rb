class FollowsController < ApplicationController
  # POST /api/follows
  def create
    @user_to_follow = User.find(params[:followed_id])
    
    if @user_to_follow.id == current_user.id
      render json: { error: 'Cannot follow yourself' }, status: :unprocessable_entity
      return
    end

    @follow = current_user.active_follows.build(followed: @user_to_follow)

    if @follow.save
      render json: { message: 'Following successfully' }, status: :created
    else
      render json: { errors: @follow.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # DELETE /api/follows/:id
  def destroy
    @follow = current_user.active_follows.find_by!(followed_id: params[:id])
    @follow.destroy
    head :no_content
  rescue ActiveRecord::RecordNotFound
    render json: { error: 'Follow relationship not found' }, status: :not_found
  end
end
