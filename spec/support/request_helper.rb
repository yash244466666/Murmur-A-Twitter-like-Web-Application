module RequestHelper
  def json_response
    JSON.parse(response.body)
  end

  def auth_tokens_for_user(user)
    token = JsonWebToken.encode(user_id: user.id)
    {
      'Authorization' => "Bearer #{token}"
    }
  end
end

RSpec.configure do |config|
  config.include RequestHelper, type: :request
end
