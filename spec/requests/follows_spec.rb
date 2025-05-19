require 'swagger_helper'

RSpec.describe 'Follows API', type: :request, swagger_doc: 'v1/swagger.yaml' do
  let(:user) { create(:user) }
  let(:token) { auth_tokens_for_user(user) }
  let(:user_to_follow) { create(:user) }
  let!(:follow) { create(:follow, follower: user, followed: user_to_follow) }
  path '/api/follows' do
    post 'Follow a user' do
      tags 'Follows'
      consumes 'application/json'
      produces 'application/json'
      security [bearerAuth: []]
      
      parameter name: :follow_params, in: :body, schema: {
        type: :object,
        properties: {
          followed_id: { type: :integer, example: 2, description: 'ID of the user to follow' }
        },
        required: ['followed_id']
      }

      response '201', 'started following user' do
        schema type: :object,
          properties: {
            message: { type: :string }
          }
        run_test!
      end

      response '422', 'invalid request' do
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

  path '/api/follows/{id}' do
    delete 'Unfollow a user' do
      tags 'Follows'
      produces 'application/json'
      security [bearerAuth: []]
      
      parameter name: :id, in: :path, type: :integer, description: 'ID of the user to unfollow'

      response '204', 'unfollowed successfully' do
        run_test!
      end

      response '404', 'follow relationship not found' do
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
