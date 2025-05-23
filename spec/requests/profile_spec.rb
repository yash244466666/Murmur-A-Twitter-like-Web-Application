require 'swagger_helper'

RSpec.describe 'Profile API', type: :request, swagger_doc: 'v1/swagger.yaml' do
  let(:user) { create(:user) }
  let(:token) { auth_tokens_for_user(user) }
  let(:profile_user) { create(:user) }
  let!(:murmurs) { create_list(:murmur, 3, user: profile_user) }
  path '/api/profile/{username}' do
    get 'Get user profile' do
      tags 'Profile'
      produces 'application/json'
      security [bearerAuth: []]
      
      parameter name: :username, in: :path, type: :string, description: 'Username of the profile to view'

      response '200', 'profile found' do
        schema type: :object,
          properties: {
            user: {
              type: :object,
              properties: {
                id: { type: :integer },
                username: { type: :string },
                email: { type: :string },
                bio: { type: :string },
                created_at: { type: :string, format: 'date-time' }
              }
            },
            murmurs_count: { type: :integer },
            followers_count: { type: :integer },
            following_count: { type: :integer },
            is_following: { type: :boolean },
            murmurs: {
              type: :array,
              items: {
                type: :object,
                properties: {
                  id: { type: :integer },
                  content: { type: :string },
                  created_at: { type: :string, format: 'date-time' },
                  likes_count: { type: :integer },
                  liked_by_current_user: { type: :boolean }
                }
              }
            }
          }
        run_test!
      end

      response '404', 'profile not found' do
        schema type: :object,
          properties: {
            error: { type: :string }
          }
        run_test!
      end

      response '401', 'unauthorized' do
        schema type: :object,
          properties: {
            error: { type: :string }
          }
        run_test!
      end
    end
  end
end
