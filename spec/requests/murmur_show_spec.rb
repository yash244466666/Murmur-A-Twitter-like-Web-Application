require 'swagger_helper'

RSpec.describe 'Murmur Show API', type: :request, swagger_doc: 'v1/swagger.yaml' do
  let(:user) { create(:user) }
  let(:token) { auth_tokens_for_user(user) }
  let!(:murmur) { create(:murmur, user: user) }

  path '/api/murmurs/{id}' do
    get 'Get a specific murmur' do
      tags 'Murmurs'
      produces 'application/json'
      security [bearerAuth: []]

      parameter name: :id, in: :path, type: :integer, required: true,
                description: 'ID of murmur to retrieve', example: 1

      response '200', 'murmur found' do
        schema type: :object,
          properties: {
            id: { type: :integer },
            content: { type: :string },
            created_at: { type: :string, format: 'date-time' },
            user: {
              type: :object,
              properties: {
                id: { type: :integer },
                username: { type: :string },
                bio: { type: :string }
              }
            },
            likes_count: { type: :integer },
            liked_by_current_user: { type: :boolean }
          }

        let(:id) { murmur.id }
        run_test!
      end

      response '404', 'murmur not found' do
        schema type: :object,
          properties: {
            error: { type: :string }
          }

        let(:id) { 'invalid' }
        run_test!
      end
    end
  end
end
