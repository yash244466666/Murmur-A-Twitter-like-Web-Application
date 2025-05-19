require 'swagger_helper'

RSpec.describe 'Authentication API', type: :request, swagger_doc: 'v1/swagger.yaml' do
  let(:user) { create(:user) }
  path '/auth/login' do
    post 'Authenticates user' do
      tags 'Authentication'
      consumes 'application/json'
      produces 'application/json'
      parameter name: :login_params, in: :body, schema: {
        type: :object,
        properties: {
          email: { type: :string, example: 'john@example.com' },
          password: { type: :string, example: 'password123' }
        },
        required: ['email', 'password']
      }

      response '200', 'user authenticated' do
        schema type: :object,
          properties: {
            token: { type: :string },
            user: {
              type: :object,
              properties: {
                id: { type: :integer },
                username: { type: :string },
                email: { type: :string },
                bio: { type: :string },
                created_at: { type: :string, format: 'date-time' }
              }
            }
          }
        run_test!
      end

      response '401', 'authentication failed' do
        schema type: :object,
          properties: {
            error: { type: :string }
          }
        run_test!
      end
    end
  end

  path '/users' do
    post 'Creates a user' do
      tags 'Authentication'
      consumes 'application/json'
      produces 'application/json'
      parameter name: :user_params, in: :body, schema: {
        type: :object,
        properties: {
          username: { type: :string, example: 'johndoe' },
          email: { type: :string, example: 'john@example.com' },
          password: { type: :string, example: 'password123' },
          bio: { type: :string, example: "Hello, I'm John!" }
        },
        required: ['username', 'email', 'password']
      }

      response '201', 'user created' do
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
            }
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
    end
  end
end
