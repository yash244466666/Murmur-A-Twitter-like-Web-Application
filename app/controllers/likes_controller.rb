class LikesController < ApplicationController
  # POST /api/likes
  def create
    @murmur = Murmur.find(params[:murmur_id])
    @like = current_user.likes.build(murmur: @murmur)

    if @like.save
      render json: { message: 'Liked successfully' }, status: :created
    else
      render json: { errors: @like.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # DELETE /api/likes/:id
  def destroy
    @like = current_user.likes.find_by!(murmur_id: params[:id])
    @like.destroy
    head :no_content
  rescue ActiveRecord::RecordNotFound
    render json: { error: 'Like not found' }, status: :not_found
  end
end
