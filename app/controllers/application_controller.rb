class ApplicationController < ActionController::Base
  protect_from_forgery with: :null_session, if: -> { request.format.json? }
  before_action :authenticate_user!
  helper_method :current_user, :user_signed_in?

  private

  def authenticate_user!
    return authenticate_api_request if request.format.json?
    
    unless current_user
      store_location
      redirect_to login_path, alert: "Please sign in to continue."
    end
  end

  def current_user
    return @current_user if defined?(@current_user)
    
    if session[:user_id]
      @current_user = User.find_by(id: session[:user_id])
    elsif (header = request.headers['Authorization'])
      token = header.split(' ').last
      decoded = JsonWebToken.decode(token)
      @current_user = User.find_by(id: decoded[:user_id]) if decoded
    end
  end

  def user_signed_in?
    !!current_user
  end

  def authenticate_api_request
    unless current_user
      render json: { error: 'Unauthorized' }, status: :unauthorized
    end
  rescue ActiveRecord::RecordNotFound
    render json: { error: 'Unauthorized' }, status: :unauthorized
  end

  def store_location
    session[:return_to] = request.fullpath if request.get?
  end

  def stored_location_or(default)
    session.delete(:return_to) || default
  end
end
