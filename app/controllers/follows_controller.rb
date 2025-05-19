class FollowsController < ApplicationController
  # POST /follows
  def create
    @user_to_follow = User.find(params[:followed_id])
    
    if @user_to_follow.id == current_user.id
      respond_to do |format|
        format.html { redirect_back(fallback_location: root_path, alert: 'Cannot follow yourself') }
        format.turbo_stream { 
          render turbo_stream: turbo_stream.replace(
            "follow-button-#{@user_to_follow.id}", 
            partial: 'users/follow_button', 
            locals: { user: @user_to_follow }
          )
        }
        format.json { render json: { error: 'Cannot follow yourself' }, status: :unprocessable_entity }
      end
      return
    end

    @follow = current_user.active_follows.build(followed: @user_to_follow)

    if @follow.save
      respond_to do |format|
        format.html { redirect_back(fallback_location: root_path, notice: 'Successfully followed user') }
        format.turbo_stream { 
          render turbo_stream: [
            turbo_stream.replace(
              "follow-button-#{@user_to_follow.id}", 
              partial: 'users/follow_button', 
              locals: { user: @user_to_follow }
            ),
            turbo_stream.update(
              "following-count",
              current_user.following.count.to_s
            )
          ]
        }
        format.json { render json: { message: 'Following successfully' }, status: :created }
      end
    else
      respond_to do |format|
        format.html { redirect_back(fallback_location: root_path, alert: @follow.errors.full_messages.join(', ')) }
        format.turbo_stream { 
          render turbo_stream: turbo_stream.replace(
            "follow-button-#{@user_to_follow.id}", 
            partial: 'users/follow_button', 
            locals: { user: @user_to_follow }
          )
        }
        format.json { render json: { errors: @follow.errors.full_messages }, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /follows/:id
  def destroy
    @user_to_unfollow = User.find(params[:id])
    @follow = current_user.active_follows.find_by(followed: @user_to_unfollow)
    
    if @follow
      @follow.destroy
      respond_to do |format|
        format.html { redirect_back(fallback_location: root_path, notice: 'Successfully unfollowed user') }
        format.turbo_stream { 
          render turbo_stream: [
            turbo_stream.replace("follow-button-#{@user_to_unfollow.id}", 
              partial: 'users/follow_button', 
              locals: { user: @user_to_unfollow }
            ),
            turbo_stream.update("following-count",
              current_user.following.count.to_s
            )
          ]
        }
        format.json { head :no_content }
      end
    else
      respond_to do |format|
        format.html { redirect_back(fallback_location: root_path, alert: 'Follow relationship not found') }
        format.turbo_stream { 
          render turbo_stream: turbo_stream.replace("follow-button-#{@user_to_unfollow.id}", 
            partial: 'users/follow_button', 
            locals: { user: @user_to_unfollow }
          )
        }
        format.json { render json: { error: 'Follow relationship not found' }, status: :not_found }
      end
    end
  end
end
