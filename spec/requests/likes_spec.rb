require 'swagger_helper'

RSpec.describe 'Likes API', type: :request, swagger_doc: 'v1/swagger.yaml' do
  let(:user) { create(:user) }
  let(:token) { auth_tokens_for_user(user) }
  let(:murmur) { create(:murmur) }
  let!(:like) { create(:like, user: user, murmur: murmur) }
  path '/api/likes' do
    post 'Like a murmur' do
      tags 'Likes'
      consumes 'application/json'
      produces 'application/json'
      security [bearerAuth: []]
      
      parameter name: :like_params, in: :body, schema: {
        type: :object,
        properties: {
          murmur_id: { type: :integer, example: 1, description: 'ID of the murmur to like' }
        },
        required: ['murmur_id']
      }

      response '201', 'murmur liked' do
        schema type: :object,
          properties: {
            message: { type: :string }
          }
        run_test!
      end

      response '422', 'invalid request' do
        schema type: :object,
          properties: {
            errors: {
              type: :array,
              items: { type: :string }
            }
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

  path '/api/likes/{id}' do
    delete 'Unlike a murmur' do
      tags 'Likes'
      produces 'application/json'
      security [bearerAuth: []]
      
      parameter name: :id, in: :path, type: :integer, description: 'ID of the murmur to unlike'

      response '204', 'unliked successfully' do
        run_test!
      end

      response '404', 'like not found' do
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
