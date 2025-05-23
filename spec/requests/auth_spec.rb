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
       consumes 'application/json'
      produces 'application/json'

      parameter name: :user, in: :body, schema: {
        type: :object,
        required: ['user'],
        properties: {
          user: {
            type: :object,
            required: ['username', 'email', 'password'],
            properties: {
              username: { type: :string, example: 'johndoe' },
              email: { type: :string, example: 'john@example.com' },
              password: { type: :string, example: 'password123' },
              bio: { type: :string, example: "Hello, I'm John!" }
            }
          }
        }
      }
      
      response '201', 'user created' do
        let(:user) { { user: { username: 'johndoe', email: 'john@example.com', password: 'password123', bio: "Hello, I'm John!" } } }
        schema type: :object,
          properties: {
            token: { type: :string, example: 'eyJhbGciOiJIUzI1NiJ9...' },
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
            error: { type: :string, example: 'Validation failed' },
            errors: { 
              type: :array,
              items: { type: :string },
              example: ['Username has already been taken', 'Email is invalid']
            }
          }
        run_test!
      end
    end
  end
end
