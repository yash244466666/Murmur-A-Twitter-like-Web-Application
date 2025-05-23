class LikesController < ApplicationController
  before_action :set_format_from_accept_header
  rescue_from ActiveRecord::RecordNotFound, with: :handle_not_found

  # POST /api/likes
  def create
    @murmur = Murmur.find(params[:murmur_id])
    @like = current_user.likes.build(murmur: @murmur)

    respond_to do |format|
      if @like.save
        format.html { redirect_back(fallback_location: root_path) }
        format.json { render json: { message: 'Liked successfully' }, status: :created }
      else
        format.html { redirect_back(fallback_location: root_path, alert: @like.errors.full_messages.join(', ')) }
        format.json { render json: { errors: @like.errors.full_messages }, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /api/likes/:id
  def destroy
    @murmur = Murmur.find(params[:murmur_id] || params[:id])
    @like = current_user.likes.find_by!(murmur: @murmur)
    @like.destroy

    respond_to do |format|
      format.html { redirect_back(fallback_location: root_path) }
      format.json { render json: { message: 'Unliked successfully' }, status: :ok }
      format.any { render json: { message: 'Unliked successfully' }, status: :ok }
    end
  rescue ActiveRecord::RecordNotFound
    respond_to do |format|
      format.html { redirect_back(fallback_location: root_path, alert: 'Like not found') }
      format.json { render json: { error: 'Like not found' }, status: :not_found }
      format.any { render json: { error: 'Like not found' }, status: :not_found }
    end
  end

  private

  def set_format_from_accept_header
    request.format = :json if request.headers["Accept"] == '*/*' || request.headers["Accept"] =~ /json/
  end

  def handle_not_found
    respond_to do |format|
      format.html { redirect_back(fallback_location: root_path, alert: 'Like not found') }
      format.json { render json: { error: 'Like not found' }, status: :not_found }
      format.any { render json: { error: 'Like not found' }, status: :not_found }
    end
  end
end
